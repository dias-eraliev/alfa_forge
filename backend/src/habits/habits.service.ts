import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateHabitDto, UpdateHabitDto, CompleteHabitDto, HabitStatsDto } from './dto/habits.dto';

@Injectable()
export class HabitsService {
  constructor(private prisma: PrismaService) {}

  // Получить все привычки пользователя
  async getUserHabits(userId: string) {
    return this.prisma.habit.findMany({
      where: { userId },
      include: {
        category: true,
        template: true,
        completions: {
          where: {
            date: {
              gte: new Date(new Date().setDate(new Date().getDate() - 30)) // последние 30 дней
            }
          },
          orderBy: { date: 'desc' }
        }
      },
      orderBy: { createdAt: 'desc' }
    });
  }

  // Получить привычку по ID
  async getHabitById(id: string, userId: string) {
    const habit = await this.prisma.habit.findUnique({
      where: { id },
      include: {
        category: true,
        template: true,
        completions: {
          orderBy: { date: 'desc' },
          take: 100 // последние 100 выполнений
        }
      }
    });

    if (!habit) {
      throw new NotFoundException('Привычка не найдена');
    }

    if (habit.userId !== userId) {
      throw new ForbiddenException('Нет доступа к этой привычке');
    }

    return habit;
  }

  // Создать привычку
  async createHabit(userId: string, createHabitDto: CreateHabitDto) {
    // Проверяем существование категории
    const category = await this.prisma.habitCategory.findUnique({
      where: { id: createHabitDto.categoryId }
    });

    if (!category) {
      throw new NotFoundException('Категория не найдена');
    }

    // Проверяем шаблон если указан
    if (createHabitDto.templateId) {
      const template = await this.prisma.habitTemplate.findUnique({
        where: { id: createHabitDto.templateId }
      });

      if (!template) {
        throw new NotFoundException('Шаблон не найден');
      }
    }

    return this.prisma.habit.create({
      data: {
        ...createHabitDto,
        userId,
        currentStreak: 0,
        maxStreak: 0,
        strength: 0
      },
      include: {
        category: true,
        template: true
      }
    });
  }

  // Обновить привычку
  async updateHabit(id: string, userId: string, updateHabitDto: UpdateHabitDto) {
    await this.getHabitById(id, userId);

    return this.prisma.habit.update({
      where: { id },
      data: updateHabitDto,
      include: {
        category: true,
        template: true
      }
    });
  }

  // Удалить привычку
  async deleteHabit(id: string, userId: string) {
    await this.getHabitById(id, userId);

    await this.prisma.habit.delete({
      where: { id }
    });

    return { message: 'Привычка успешно удалена' };
  }

  // Отметить выполнение привычки
  async completeHabit(habitId: string, userId: string, completeHabitDto: CompleteHabitDto) {
    await this.getHabitById(habitId, userId);
    const completionDate = new Date(completeHabitDto.date);

    // Проверяем, не отмечена ли уже привычка на эту дату
    const existingCompletion = await this.prisma.habitCompletion.findUnique({
      where: {
        habitId_date: {
          habitId,
          date: completionDate
        }
      }
    });

    if (existingCompletion) {
      // Обновляем существующую запись
      return this.prisma.habitCompletion.update({
        where: {
          habitId_date: {
            habitId,
            date: completionDate
          }
        },
        data: {
          notes: completeHabitDto.notes,
          duration: completeHabitDto.duration,
          quality: completeHabitDto.quality,
          mood: completeHabitDto.mood,
          completed: true
        }
      });
    } else {
      // Создаем новую запись
      // eslint-disable-next-line @typescript-eslint/no-unused-vars
      const { date, ...habitData } = completeHabitDto;
      const completion = await this.prisma.habitCompletion.create({
        data: {
          habitId,
          userId,
          date: completionDate,
          completed: true,
          ...habitData
        }
      });

      // Обновляем стрик и силу привычки
      await this.updateHabitStreak(habitId, userId);

      return completion;
    }
  }

  // Отменить выполнение привычки
  async uncompleteHabit(habitId: string, userId: string, date: string) {
    await this.getHabitById(habitId, userId);
    const completionDate = new Date(date);

    await this.prisma.habitCompletion.deleteMany({
      where: {
        habitId,
        date: completionDate
      }
    });

    // Пересчитываем стрик
    await this.updateHabitStreak(habitId, userId);

    return { message: 'Выполнение привычки отменено' };
  }

  // Получить статистику привычки
  async getHabitStats(habitId: string, userId: string, statsDto: HabitStatsDto) {
    const habit = await this.getHabitById(habitId, userId);
    const startDate = new Date(statsDto.startDate);
    const endDate = new Date(statsDto.endDate);

    const completions = await this.prisma.habitCompletion.findMany({
      where: {
        habitId,
        date: {
          gte: startDate,
          lte: endDate
        }
      },
      orderBy: { date: 'asc' }
    });

    const totalDays = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 60 * 60 * 24)) + 1;
    const completedDays = completions.length;
    const completionRate = totalDays > 0 ? (completedDays / totalDays) * 100 : 0;

    const averageQuality = completions.length > 0 
      ? completions.reduce((sum, c) => sum + (c.quality || 0), 0) / completions.length 
      : 0;

    const averageMood = completions.length > 0 
      ? completions.reduce((sum, c) => sum + (c.mood || 0), 0) / completions.length 
      : 0;

    return {
      habit: {
        id: habit.id,
        name: habit.name,
        currentStreak: habit.currentStreak,
        maxStreak: habit.maxStreak,
        strength: habit.strength
      },
      period: {
        startDate: statsDto.startDate,
        endDate: statsDto.endDate,
        totalDays,
        completedDays
      },
      stats: {
        completionRate: Math.round(completionRate * 100) / 100,
        averageQuality: Math.round(averageQuality * 100) / 100,
        averageMood: Math.round(averageMood * 100) / 100
      },
      completions
    };
  }

  // Получить все категории
  async getCategories() {
    return this.prisma.habitCategory.findMany({
      orderBy: { name: 'asc' }
    });
  }

  // Получить все шаблоны
  async getTemplates(categoryId?: string) {
    return this.prisma.habitTemplate.findMany({
      where: categoryId ? { categoryId } : undefined,
      include: {
        category: true
      },
      orderBy: [
        { isPopular: 'desc' },
        { name: 'asc' }
      ]
    });
  }

  // Приватный метод для обновления стрика
  private async updateHabitStreak(habitId: string, userId: string) {
    const completions = await this.prisma.habitCompletion.findMany({
      where: { habitId },
      orderBy: { date: 'desc' },
      take: 365 // берем последний год
    });

    let currentStreak = 0;
    let maxStreak = 0;
    let tempStreak = 0;

    // Считаем текущий стрик (начиная с сегодня или вчера)
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    let checkDate = today;
    let foundToday = false;

    for (const completion of completions) {
      const completionDate = new Date(completion.date);
      
      if (this.isSameDate(completionDate, today)) {
        foundToday = true;
        currentStreak++;
      } else if (this.isSameDate(completionDate, yesterday) && !foundToday) {
        currentStreak++;
        checkDate = yesterday;
      } else if (this.isConsecutiveDay(completionDate, checkDate)) {
        currentStreak++;
        checkDate = completionDate;
      } else {
        break;
      }
    }

    // Считаем максимальный стрик
    tempStreak = 0;
    let prevDate: Date | null = null;

    for (const completion of completions.reverse()) {
      const completionDate = new Date(completion.date);
      
      if (!prevDate || this.isConsecutiveDay(completionDate, prevDate)) {
        tempStreak++;
        maxStreak = Math.max(maxStreak, tempStreak);
      } else {
        tempStreak = 1;
      }
      
      prevDate = completionDate;
    }

    // Считаем силу привычки (0-100 на основе последних 30 дней)
    const last30Days = completions.slice(0, 30);
    const strength = Math.min(100, (last30Days.length / 30) * 100);

    // Обновляем привычку
    await this.prisma.habit.update({
      where: { id: habitId },
      data: {
        currentStreak,
        maxStreak,
        strength: Math.round(strength)
      }
    });
  }

  private isSameDate(date1: Date, date2: Date): boolean {
    return date1.toDateString() === date2.toDateString();
  }

  private isConsecutiveDay(date1: Date, date2: Date): boolean {
    const diff = Math.abs(date1.getTime() - date2.getTime());
    const dayInMs = 24 * 60 * 60 * 1000;
    return diff === dayInMs;
  }
}
