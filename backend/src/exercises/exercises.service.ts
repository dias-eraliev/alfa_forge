import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { 
  CreateExerciseDto, 
  UpdateExerciseDto, 
  ExerciseFilterDto,
  CreateWorkoutSessionDto,
  UpdateWorkoutSessionDto,
  WorkoutFilterDto,
  CreateGTOResultDto,
  UpdateGTOResultDto,
  GTOFilterDto,
  ExerciseStatsDto,
  WorkoutStatus
} from './dto/exercises.dto';

@Injectable()
export class ExercisesService {
  constructor(private prisma: PrismaService) {}

  // ========== EXERCISES ==========

  // Получить все упражнения
  async getExercises(filters?: ExerciseFilterDto) {
    const where: any = {};

    if (filters?.type) {
      where.type = filters.type;
    }

    if (filters?.category) {
      where.category = filters.category;
    }

    if (filters?.difficulty) {
      where.difficulty = filters.difficulty;
    }

    if (filters?.requiresEquipment !== undefined) {
      where.requiresEquipment = filters.requiresEquipment;
    }

    if (filters?.search) {
      where.OR = [
        { name: { contains: filters.search, mode: 'insensitive' } },
        { description: { contains: filters.search, mode: 'insensitive' } }
      ];
    }

    return this.prisma.exercise.findMany({
      where,
      orderBy: [
        { category: 'asc' },
        { difficulty: 'asc' },
        { name: 'asc' }
      ]
    });
  }

  // Получить упражнение по ID
  async getExerciseById(id: string) {
    const exercise = await this.prisma.exercise.findUnique({
      where: { id }
    });

    if (!exercise) {
      throw new NotFoundException('Упражнение не найдено');
    }

    return exercise;
  }

  // Создать упражнение (только для админов)
  async createExercise(createExerciseDto: CreateExerciseDto) {
    const exerciseData = {
      ...createExerciseDto,
      description: createExerciseDto.description || '', // Обязательное поле
      iconEmoji: '🏃', // Добавляем обязательное поле
      instructions: createExerciseDto.instructions ? [createExerciseDto.instructions] : []
    };

    return this.prisma.exercise.create({
      data: exerciseData as any
    });
  }

  // Обновить упражнение (только для админов)
  async updateExercise(id: string, updateExerciseDto: UpdateExerciseDto) {
    await this.getExerciseById(id);

    const updateData: any = {};
    
    if (updateExerciseDto.name) updateData.name = updateExerciseDto.name;
    if (updateExerciseDto.description) updateData.description = updateExerciseDto.description;
    if (updateExerciseDto.type) updateData.type = updateExerciseDto.type;
    if (updateExerciseDto.category) updateData.category = updateExerciseDto.category;
    if (updateExerciseDto.difficulty) updateData.difficulty = updateExerciseDto.difficulty;
    if (updateExerciseDto.instructions) updateData.instructions = [updateExerciseDto.instructions];

    return this.prisma.exercise.update({
      where: { id },
      data: updateData
    });
  }

  // Удалить упражнение (только для админов)
  async deleteExercise(id: string) {
    await this.getExerciseById(id);

    await this.prisma.exercise.delete({
      where: { id }
    });

    return { message: 'Упражнение успешно удалено' };
  }

  // Получить упражнения ГТО
  async getGTOExercises() {
    return this.prisma.exercise.findMany({
      where: { category: 'STRENGTH' }, // Используем существующую категорию
      orderBy: { name: 'asc' }
    });
  }

  // Получить рекомендованные упражнения
  async getRecommendedExercises(userId: string, category?: string) {
    const where: any = {};
    
    if (category) {
      where.category = category;
    }

    return this.prisma.exercise.findMany({
      where,
      orderBy: { difficulty: 'asc' },
      take: 10
    });
  }

  // ========== WORKOUT SESSIONS ==========

  // Получить тренировки пользователя
  async getUserWorkouts(userId: string, filters?: WorkoutFilterDto) {
    const where: any = { userId };

    if (filters?.status) {
      where.status = filters.status;
    }

    if (filters?.startDate || filters?.endDate) {
      where.createdAt = {};
      if (filters.startDate) {
        where.createdAt.gte = new Date(filters.startDate);
      }
      if (filters.endDate) {
        where.createdAt.lte = new Date(filters.endDate);
      }
    }

    return this.prisma.workoutSession.findMany({
      where,
      orderBy: { createdAt: 'desc' }
    });
  }

  // Получить тренировку по ID
  async getWorkoutById(id: string, userId: string) {
    const workout = await this.prisma.workoutSession.findUnique({
      where: { id }
    });

    if (!workout) {
      throw new NotFoundException('Тренировка не найдена');
    }

    if (workout.userId !== userId) {
      throw new ForbiddenException('Нет доступа к этой тренировке');
    }

    return workout;
  }

  // Создать тренировку
  async createWorkout(userId: string, createWorkoutDto: CreateWorkoutSessionDto) {
    const workoutData = {
      name: createWorkoutDto.name,
      userId,
      status: 'PLANNED' as any,
      startTime: createWorkoutDto.scheduledDate ? new Date(createWorkoutDto.scheduledDate) : new Date(),
      duration: 0,
      totalTargetReps: 0,
      totalCompletedReps: 0,
      averageQuality: 0,
      notes: createWorkoutDto.notes
    };

    return this.prisma.workoutSession.create({
      data: workoutData
    });
  }

  // Обновить тренировку
  async updateWorkout(id: string, userId: string, updateWorkoutDto: UpdateWorkoutSessionDto) {
    await this.getWorkoutById(id, userId);

    const updateData: any = {
      name: updateWorkoutDto.name,
      notes: updateWorkoutDto.notes,
      status: updateWorkoutDto.status
    };
    
    if (updateWorkoutDto.scheduledDate) {
      updateData.startTime = new Date(updateWorkoutDto.scheduledDate);
    }

    return this.prisma.workoutSession.update({
      where: { id },
      data: updateData
    });
  }

  // Удалить тренировку
  async deleteWorkout(id: string, userId: string) {
    await this.getWorkoutById(id, userId);

    await this.prisma.workoutSession.delete({
      where: { id }
    });

    return { message: 'Тренировка успешно удалена' };
  }

  // Начать тренировку
  async startWorkout(id: string, userId: string) {
    await this.getWorkoutById(id, userId);

    return this.prisma.workoutSession.update({
      where: { id },
      data: {
        status: 'IN_PROGRESS' as any,
        startTime: new Date()
      }
    });
  }

  // Завершить тренировку
  async completeWorkout(id: string, userId: string, _caloriesBurned?: number) {
    const workout = await this.getWorkoutById(id, userId);

    const endTime = new Date();
    const duration = Math.floor((endTime.getTime() - workout.startTime.getTime()) / 1000);

    return this.prisma.workoutSession.update({
      where: { id },
      data: {
        status: 'COMPLETED' as any,
        endTime,
        duration
      }
    });
  }

  // ========== STATISTICS ==========

  // Получить статистику упражнений
  async getExerciseStats(userId: string, statsDto: ExerciseStatsDto) {
    const startDate = new Date(statsDto.startDate);
    const endDate = new Date(statsDto.endDate);

    // Статистика тренировок
    const workouts = await this.prisma.workoutSession.findMany({
      where: {
        userId,
        createdAt: {
          gte: startDate,
          lte: endDate
        }
      }
    });

    // Подсчеты
    const totalWorkouts = workouts.length;
    const completedWorkouts = workouts.filter(w => w.status === 'COMPLETED').length;
    const totalDuration = workouts.reduce((sum, w) => sum + w.duration, 0);

    return {
      period: {
        startDate: statsDto.startDate,
        endDate: statsDto.endDate
      },
      workouts: {
        total: totalWorkouts,
        completed: completedWorkouts,
        completionRate: totalWorkouts > 0 ? (completedWorkouts / totalWorkouts) * 100 : 0,
        totalDuration,
        averageDuration: completedWorkouts > 0 ? totalDuration / completedWorkouts : 0
      }
    };
  }

  // Получить прогресс по упражнению
  async getExerciseProgress(userId: string, exerciseId: string, days: number = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const workouts = await this.prisma.workoutSession.findMany({
      where: {
        userId,
        createdAt: {
          gte: startDate
        }
      },
      orderBy: { createdAt: 'asc' }
    });

    return {
      workouts
    };
  }

  // Простые методы для ГТО (заглушки)
  async getUserGTOResults(_userId: string, _filters?: GTOFilterDto) {
    return [];
  }

  async createGTOResult(_userId: string, _createGTOResultDto: CreateGTOResultDto) {
    return { message: 'ГТО результат создан' };
  }

  async updateGTOResult(_id: string, _userId: string, _updateGTOResultDto: UpdateGTOResultDto) {
    return { message: 'ГТО результат обновлен' };
  }

  async deleteGTOResult(_id: string, _userId: string) {
    return { message: 'ГТО результат удален' };
  }
}
