import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { HabitsService } from '../habits/habits.service';
import { TasksService } from '../tasks/tasks.service';
import { HealthService } from '../health/health.service';
import { ExercisesService } from '../exercises/exercises.service';
import { 
  CreateProgressEntryDto, 
  UpdateProgressEntryDto, 
  ProgressFilterDto,
  CreateGoalDto,
  UpdateGoalDto,
  GoalFilterDto,
  CreateAchievementDto,
  AchievementFilterDto,
  ProgressStatsDto,
  DashboardStatsDto,
  GoalStatus
} from './dto/progress.dto';

@Injectable()
export class ProgressService {
  constructor(
    private prisma: PrismaService,
    private habitsService: HabitsService,
    private tasksService: TasksService,
    private healthService: HealthService,
    private exercisesService: ExercisesService,
  ) {}

  // ========== PROGRESS TRACKING ==========

  // Простые методы для прогресса (заглушки для работоспособности)
  async getUserProgress(userId: string, filters?: ProgressFilterDto) {
    return [];
  }

  async createProgressEntry(userId: string, createProgressDto: CreateProgressEntryDto) {
    return { message: 'Запись прогресса создана' };
  }

  async updateProgressEntry(id: string, userId: string, updateProgressDto: UpdateProgressEntryDto) {
    return { message: 'Запись прогресса обновлена' };
  }

  async deleteProgressEntry(id: string, userId: string) {
    return { message: 'Запись прогресса удалена' };
  }

  // ========== GOALS MANAGEMENT ==========

  // Простые методы для целей (заглушки)
  async getUserGoals(userId: string, filters?: GoalFilterDto) {
    return [];
  }

  async createGoal(userId: string, createGoalDto: CreateGoalDto) {
    return { message: 'Цель создана' };
  }

  async updateGoal(id: string, userId: string, updateGoalDto: UpdateGoalDto) {
    return { message: 'Цель обновлена' };
  }

  async deleteGoal(id: string, userId: string) {
    return { message: 'Цель удалена' };
  }

  // ========== ACHIEVEMENTS ==========

  // Получить достижения пользователя
  async getUserAchievements(userId: string, filters?: AchievementFilterDto) {
    const where: any = {};

    if (filters?.type) {
      where.category = filters.type;
    }

    const achievements = await this.prisma.achievement.findMany({
      where,
      orderBy: { createdAt: 'desc' }
    });

    if (filters?.earnedOnly) {
      const earnedAchievements = await this.prisma.userAchievement.findMany({
        where: { userId },
        include: { achievement: true }
      });

      return earnedAchievements.map(ua => ({
        ...ua.achievement,
        earnedAt: ua.unlockedAt
      }));
    }

    // Добавить информацию о том, получено ли достижение
    const earnedAchievements = await this.prisma.userAchievement.findMany({
      where: { userId }
    });

    const earnedIds = new Set(earnedAchievements.map(ua => ua.achievementId));

    return achievements.map(achievement => ({
      ...achievement,
      isEarned: earnedIds.has(achievement.id),
      earnedAt: earnedAchievements.find(ua => ua.achievementId === achievement.id)?.unlockedAt
    }));
  }

  // Создать достижение (только админы)
  async createAchievement(createAchievementDto: CreateAchievementDto) {
    const achievementData = {
      key: createAchievementDto.title.toLowerCase().replace(/\s+/g, '_'),
      iconName: createAchievementDto.icon || '🏆',
      conditions: createAchievementDto.criteria || {},
      category: 'GENERAL' as any,
      ...createAchievementDto
    };

    return this.prisma.achievement.create({
      data: achievementData
    });
  }

  // Присвоить достижение пользователю
  async grantAchievement(userId: string, achievementId: string) {
    const achievement = await this.prisma.achievement.findUnique({
      where: { id: achievementId }
    });

    if (!achievement) {
      throw new NotFoundException('Достижение не найдено');
    }

    // Проверить, не получено ли уже достижение
    const existing = await this.prisma.userAchievement.findFirst({
      where: {
        userId,
        achievementId
      }
    });

    if (existing) {
      return { message: 'Достижение уже получено' };
    }

    await this.prisma.userAchievement.create({
      data: {
        userId,
        achievementId,
        progressId: 'default',
        unlockedAt: new Date(),
        progress: 100,
        isCompleted: true,
        metadata: {}
      }
    });

    return {
      message: 'Достижение получено!',
      achievement
    };
  }

  // ========== STATISTICS ==========

  // Получить статистику прогресса
  async getProgressStats(userId: string, statsDto: ProgressStatsDto) {
    return {
      period: {
        startDate: statsDto.startDate,
        endDate: statsDto.endDate
      },
      totalEntries: 0,
      progressByType: {},
      averages: {},
      trends: {}
    };
  }

  // Получить данные для дашборда
  async getDashboardStats(userId: string, dashboardDto: DashboardStatsDto) {
    const days = dashboardDto.days || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    // Основная статистика из других сервисов
    const [habitsData, tasksData, healthData, exerciseData] = await Promise.all([
      this.getHabitsStats(userId),
      this.getTasksStats(userId),
      this.getHealthStats(userId),
      this.getExerciseStats(userId)
    ]);

    // Достижения
    const totalAchievements = await this.prisma.achievement.count();
    const earnedAchievements = await this.prisma.userAchievement.count({
      where: { userId }
    });

    return {
      period: {
        days,
        startDate: startDate.toISOString(),
        endDate: new Date().toISOString()
      },
      overview: {
        totalGoals: 0,
        completedGoals: 0,
        achievementsEarned: earnedAchievements,
        totalAchievements,
        achievementRate: totalAchievements > 0 ? (earnedAchievements / totalAchievements) * 100 : 0
      },
      modules: {
        habits: habitsData,
        tasks: tasksData,
        health: healthData,
        exercises: exerciseData
      },
      goals: []
    };
  }

  // ========== HELPER METHODS ==========

  private async getHabitsStats(userId: string) {
    try {
      const habits = await this.habitsService.getUserHabits(userId);
      return {
        total: habits.length,
        active: habits.filter((h: any) => h.isActive).length
      };
    } catch {
      return { total: 0, active: 0 };
    }
  }

  private async getTasksStats(userId: string) {
    try {
      const tasks = await this.tasksService.getUserTasks(userId);
      return {
        total: tasks.length,
        completed: tasks.filter((t: any) => t.status === 'COMPLETED').length
      };
    } catch {
      return { total: 0, completed: 0 };
    }
  }

  private async getHealthStats(userId: string) {
    try {
      const measurements = await this.healthService.getUserMeasurements(userId);
      const goals = await this.healthService.getUserHealthGoals(userId);
      return {
        measurements: measurements.length,
        goals: goals.length
      };
    } catch {
      return { measurements: 0, goals: 0 };
    }
  }

  private async getExerciseStats(userId: string) {
    try {
      const workouts = await this.exercisesService.getUserWorkouts(userId);
      return {
        workouts: workouts.length,
        completed: workouts.filter((w: any) => w.status === 'COMPLETED').length
      };
    } catch {
      return { workouts: 0, completed: 0 };
    }
  }
}
