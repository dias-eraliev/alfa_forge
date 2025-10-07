import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private prisma: PrismaService) {}

  async getDashboardData(userId: string) {
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));
    const startOfWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);

    // Получаем пользователя с прогрессом
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        progress: true,
        profile: true,
      },
    });

    if (!user) {
      throw new Error('Пользователь не найден');
    }

    const userProgress = user.progress?.[0];

    // Привычки на сегодня с включением завершений
    const todayHabits = await this.prisma.habit.findMany({
      where: {
        userId,
        isActive: true,
      },
      include: {
        completions: {
          where: {
            date: {
              gte: startOfDay,
              lte: endOfDay,
            },
          },
        },
        category: true,
      },
    });

    // Задачи на сегодня
    const todayTasks = await this.prisma.task.findMany({
      where: {
        userId,
        OR: [
          { deadline: { gte: startOfDay, lte: endOfDay } },
          { status: 'IN_PROGRESS' },
        ],
      },
      orderBy: [
        { priority: 'desc' },
        { deadline: 'asc' },
      ],
      take: 10,
    });

    // Статистика привычек
    const habitsStats = {
      total: todayHabits.length,
      completed: todayHabits.filter(habit => habit.completions.length > 0).length,
      completionRate: todayHabits.length > 0 
        ? Math.round((todayHabits.filter(habit => habit.completions.length > 0).length / todayHabits.length) * 100)
        : 0,
    };

    // Еженедельная статистика
    const weeklyHabitCompletions = await this.prisma.habitCompletion.count({
      where: {
        habit: { userId },
        date: {
          gte: startOfWeek,
        },
      },
    });

    const weeklyTaskCompletions = await this.prisma.task.count({
      where: {
        userId,
        status: 'DONE',
        updatedAt: {
          gte: startOfWeek,
        },
      },
    });

    // Мотивационная цитата
    const quote = await this.getMotivationalQuote(userProgress?.currentZone || 'WILL');

    // Статистика прогресса по сферам
    const sphereProgress = userProgress?.sphereProgress || {
      body: 0,
      will: 0,
      focus: 0,
      mind: 0,
      peace: 0,
      money: 0,
    };

    return {
      user: {
        id: user.id,
        username: user.username,
        profile: user.profile,
        progress: userProgress,
      },
      todayHabits: todayHabits.map(habit => ({
        id: habit.id,
        name: habit.name,
        iconName: habit.iconName,
        colorHex: habit.colorHex,
        categoryId: habit.categoryId,
        completed: habit.completions.length > 0,
        currentStreak: habit.currentStreak,
        strength: habit.strength,
      })),
      todayTasks: todayTasks.map(task => ({
        id: task.id,
        title: task.title,
        description: task.description,
        priority: task.priority,
        status: task.status,
        deadline: task.deadline,
        tags: task.tags,
      })),
      stats: {
        habits: habitsStats,
        weekly: {
          habitCompletions: weeklyHabitCompletions,
          taskCompletions: weeklyTaskCompletions,
        },
        progress: {
          totalXP: userProgress?.totalXP || 0,
          currentStreak: userProgress?.currentStreak || 0,
          longestStreak: userProgress?.longestStreak || 0,
          currentZone: userProgress?.currentZone || 'WILL',
          currentRank: userProgress?.currentRank || 'NOVICE',
          totalSteps: userProgress?.totalSteps || 0,
          sphereProgress,
        },
      },
      quote,
    };
  }

  async getMotivationalQuote(zone: string) {
    const quotes = await this.prisma.quote.findMany({
      where: {
        targetZones: {
          has: zone,
        },
        isPremium: false,
      },
      orderBy: {
        priority: 'desc',
      },
      take: 10,
    });

    if (quotes.length === 0) {
      return {
        text: 'Каждый день - новая возможность стать лучше.',
        author: 'AlFA',
        category: 'DISCIPLINE',
      };
    }

    // Возвращаем случайную цитату из топ-10
    const randomIndex = Math.floor(Math.random() * quotes.length);
    return quotes[randomIndex];
  }

  async getWeeklyProgress(userId: string) {
    const today = new Date();
    const weekDays: Array<{
      date: string;
      habitCompletions: number;
      taskCompletions: number;
      totalActivities: number;
    }> = [];
    
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
      const startOfDay = new Date(date.setHours(0, 0, 0, 0));
      const endOfDay = new Date(date.setHours(23, 59, 59, 999));

      const habitCompletions = await this.prisma.habitCompletion.count({
        where: {
          habit: { userId },
          date: {
            gte: startOfDay,
            lte: endOfDay,
          },
        },
      });

      const taskCompletions = await this.prisma.task.count({
        where: {
          userId,
          status: 'DONE',
          updatedAt: {
            gte: startOfDay,
            lte: endOfDay,
          },
        },
      });

      weekDays.push({
        date: startOfDay.toISOString().split('T')[0],
        habitCompletions,
        taskCompletions,
        totalActivities: habitCompletions + taskCompletions,
      });
    }

    return weekDays;
  }

  async getSphereProgress(userId: string) {
    const userProgress = await this.prisma.userProgress.findFirst({
      where: { userId },
    });

    const sphereProgress = userProgress?.sphereProgress || {
      body: 0,
      will: 0,
      focus: 0,
      mind: 0,
      peace: 0,
      money: 0,
    };

    // Конвертируем в формат для графика
    const spheres = [
      { name: 'Тело', key: 'body', progress: (sphereProgress as any).body * 100, color: '#FF5722' },
      { name: 'Воля', key: 'will', progress: (sphereProgress as any).will * 100, color: '#E91E63' },
      { name: 'Фокус', key: 'focus', progress: (sphereProgress as any).focus * 100, color: '#2196F3' },
      { name: 'Разум', key: 'mind', progress: (sphereProgress as any).mind * 100, color: '#9C27B0' },
      { name: 'Покой', key: 'peace', progress: (sphereProgress as any).peace * 100, color: '#4CAF50' },
      { name: 'Деньги', key: 'money', progress: (sphereProgress as any).money * 100, color: '#FF9800' },
    ];

    return {
      currentZone: userProgress?.currentZone || 'WILL',
      currentRank: userProgress?.currentRank || 'NOVICE',
      totalXP: userProgress?.totalXP || 0,
      spheres,
    };
  }
}
