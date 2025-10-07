import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { 
  CreateMeasurementDto, 
  UpdateMeasurementDto, 
  MeasurementFilterDto,
  CreateHealthGoalDto,
  UpdateHealthGoalDto,
  HealthGoalFilterDto,
  HealthStatsDto,
  CreateMeasurementTypeDto,
  UpdateMeasurementTypeDto
} from './dto/health.dto';

@Injectable()
export class HealthService {
  constructor(private prisma: PrismaService) {}

  // ========== BODY MEASUREMENTS ==========

  // Получить все измерения пользователя
  async getUserMeasurements(userId: string, filters?: MeasurementFilterDto) {
    const where: any = { userId };

    if (filters?.typeId) {
      where.typeId = filters.typeId;
    }

    if (filters?.category) {
      where.type = {
        category: filters.category
      };
    }

    if (filters?.startDate || filters?.endDate) {
      where.timestamp = {};
      if (filters.startDate) {
        where.timestamp.gte = new Date(filters.startDate);
      }
      if (filters.endDate) {
        where.timestamp.lte = new Date(filters.endDate);
      }
    }

    return this.prisma.bodyMeasurement.findMany({
      where,
      include: {
        type: true
      },
      orderBy: { timestamp: 'desc' },
      take: filters?.limit || 50
    });
  }

  // Получить измерение по ID
  async getMeasurementById(id: string, userId: string) {
    const measurement = await this.prisma.bodyMeasurement.findUnique({
      where: { id },
      include: { type: true }
    });

    if (!measurement) {
      throw new NotFoundException('Измерение не найдено');
    }

    if (measurement.userId !== userId) {
      throw new ForbiddenException('Нет доступа к этому измерению');
    }

    return measurement;
  }

  // Создать измерение
  async createMeasurement(userId: string, createMeasurementDto: CreateMeasurementDto) {
    const measurementData = {
      ...createMeasurementDto,
      userId,
      timestamp: createMeasurementDto.timestamp ? new Date(createMeasurementDto.timestamp) : new Date(),
      mood: createMeasurementDto.mood?.toString()
    };

    return this.prisma.bodyMeasurement.create({
      data: measurementData,
      include: { type: true }
    });
  }

  // Обновить измерение
  async updateMeasurement(id: string, userId: string, updateMeasurementDto: UpdateMeasurementDto) {
    await this.getMeasurementById(id, userId);

    const updateData: any = { ...updateMeasurementDto };
    
    if (updateMeasurementDto.timestamp) {
      updateData.timestamp = new Date(updateMeasurementDto.timestamp);
    }

    return this.prisma.bodyMeasurement.update({
      where: { id },
      data: updateData,
      include: { type: true }
    });
  }

  // Удалить измерение
  async deleteMeasurement(id: string, userId: string) {
    await this.getMeasurementById(id, userId);

    await this.prisma.bodyMeasurement.delete({
      where: { id }
    });

    return { message: 'Измерение успешно удалено' };
  }

  // Получить последние измерения по типам
  async getLatestMeasurements(userId: string) {
    const latestMeasurements = await this.prisma.bodyMeasurement.findMany({
      where: { userId },
      include: { type: true },
      orderBy: { timestamp: 'desc' },
      distinct: ['typeId']
    });

    return latestMeasurements;
  }

  // Получить историю измерений по типу
  async getMeasurementHistory(userId: string, typeId: string, days: number = 30) {
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    return this.prisma.bodyMeasurement.findMany({
      where: {
        userId,
        typeId,
        timestamp: {
          gte: startDate
        }
      },
      include: { type: true },
      orderBy: { timestamp: 'desc' }
    });
  }

  // ========== HEALTH GOALS ==========

  // Получить все цели здоровья пользователя
  async getUserHealthGoals(userId: string, filters?: HealthGoalFilterDto) {
    const where: any = { userId };

    if (filters?.goalType) {
      where.goalType = filters.goalType;
    }

    if (filters?.priority) {
      where.priority = filters.priority;
    }

    if (filters?.frequency) {
      where.frequency = filters.frequency;
    }

    if (filters?.isActive !== undefined) {
      where.isActive = filters.isActive;
    }

    return this.prisma.healthGoal.findMany({
      where,
      include: { measurementType: true },
      orderBy: [
        { priority: 'desc' },
        { createdAt: 'desc' }
      ]
    });
  }

  // Получить цель по ID
  async getHealthGoalById(id: string, userId: string) {
    const goal = await this.prisma.healthGoal.findUnique({
      where: { id },
      include: { measurementType: true }
    });

    if (!goal) {
      throw new NotFoundException('Цель не найдена');
    }

    if (goal.userId !== userId) {
      throw new ForbiddenException('Нет доступа к этой цели');
    }

    return goal;
  }

  // Создать цель здоровья
  async createHealthGoal(userId: string, createHealthGoalDto: CreateHealthGoalDto) {
    const goalData = {
      ...createHealthGoalDto,
      userId,
      startDate: createHealthGoalDto.startDate ? new Date(createHealthGoalDto.startDate) : new Date(),
      targetDate: createHealthGoalDto.targetDate ? new Date(createHealthGoalDto.targetDate) : null
    };

    return this.prisma.healthGoal.create({
      data: goalData,
      include: { measurementType: true }
    });
  }

  // Обновить цель здоровья
  async updateHealthGoal(id: string, userId: string, updateHealthGoalDto: UpdateHealthGoalDto) {
    await this.getHealthGoalById(id, userId);

    const updateData: any = { ...updateHealthGoalDto };
    
    if (updateHealthGoalDto.startDate) {
      updateData.startDate = new Date(updateHealthGoalDto.startDate);
    }
    
    if (updateHealthGoalDto.targetDate) {
      updateData.targetDate = new Date(updateHealthGoalDto.targetDate);
    }

    return this.prisma.healthGoal.update({
      where: { id },
      data: updateData,
      include: { measurementType: true }
    });
  }

  // Удалить цель здоровья
  async deleteHealthGoal(id: string, userId: string) {
    await this.getHealthGoalById(id, userId);

    await this.prisma.healthGoal.delete({
      where: { id }
    });

    return { message: 'Цель успешно удалена' };
  }

  // Обновить прогресс цели
  async updateGoalProgress(id: string, userId: string, currentValue: number) {
    await this.getHealthGoalById(id, userId);

    return this.prisma.healthGoal.update({
      where: { id },
      data: { currentValue },
      include: { measurementType: true }
    });
  }

  // ========== MEASUREMENT TYPES ==========

  // Получить все типы измерений
  async getMeasurementTypes() {
    return this.prisma.measurementType.findMany({
      orderBy: [
        { category: 'asc' },
        { name: 'asc' }
      ]
    });
  }

  // Получить типы измерений по категории
  async getMeasurementTypesByCategory(category: string) {
    return this.prisma.measurementType.findMany({
      where: { category: category as any },
      orderBy: { name: 'asc' }
    });
  }

  // Создать тип измерения (только для админов)
  async createMeasurementType(createMeasurementTypeDto: CreateMeasurementTypeDto) {
    return this.prisma.measurementType.create({
      data: createMeasurementTypeDto
    });
  }

  // Обновить тип измерения (только для админов)
  async updateMeasurementType(id: string, updateMeasurementTypeDto: UpdateMeasurementTypeDto) {
    const measurementType = await this.prisma.measurementType.findUnique({
      where: { id }
    });

    if (!measurementType) {
      throw new NotFoundException('Тип измерения не найден');
    }

    return this.prisma.measurementType.update({
      where: { id },
      data: updateMeasurementTypeDto
    });
  }

  // ========== STATISTICS ==========

  // Получить статистику здоровья
  async getHealthStats(userId: string, statsDto: HealthStatsDto) {
    const startDate = new Date(statsDto.startDate);
    const endDate = new Date(statsDto.endDate);

    const where: any = {
      userId,
      timestamp: {
        gte: startDate,
        lte: endDate
      }
    };

    if (statsDto.typeId) {
      where.typeId = statsDto.typeId;
    }

    // Статистика измерений
    const measurements = await this.prisma.bodyMeasurement.findMany({
      where,
      include: { type: true },
      orderBy: { timestamp: 'asc' }
    });

    // Статистика целей
    const goalsWhere: any = { userId };
    if (statsDto.goalType) {
      goalsWhere.goalType = statsDto.goalType;
    }

    const goals = await this.prisma.healthGoal.findMany({
      where: goalsWhere,
      include: { measurementType: true }
    });

    // Подсчет статистики
    const totalMeasurements = measurements.length;
    const measurementsByType = measurements.reduce((acc, measurement) => {
      const typeName = measurement.type.name;
      acc[typeName] = (acc[typeName] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const activeGoals = goals.filter(goal => goal.isActive).length;
    const completedGoals = goals.filter(goal => 
      goal.isActive && goal.currentValue >= goal.targetValue
    ).length;

    // Прогресс по целям
    const goalsProgress = goals.map(goal => ({
      id: goal.id,
      title: goal.title,
      goalType: goal.goalType,
      progress: goal.targetValue > 0 ? (goal.currentValue / goal.targetValue) * 100 : 0,
      isCompleted: goal.currentValue >= goal.targetValue
    }));

    // Тренды измерений (для графиков)
    const trends = measurements.reduce((acc, measurement) => {
      const typeName = measurement.type.name;
      if (!acc[typeName]) {
        acc[typeName] = [];
      }
      acc[typeName].push({
        date: measurement.timestamp,
        value: measurement.value,
        unit: measurement.type.unit
      });
      return acc;
    }, {} as Record<string, Array<{ date: Date; value: number; unit: string }>>);

    return {
      period: {
        startDate: statsDto.startDate,
        endDate: statsDto.endDate
      },
      summary: {
        totalMeasurements,
        activeGoals,
        completedGoals,
        goalsCompletionRate: activeGoals > 0 ? (completedGoals / activeGoals) * 100 : 0
      },
      distribution: {
        measurementsByType
      },
      goals: {
        progress: goalsProgress
      },
      trends
    };
  }

  // Получить достижения в области здоровья
  async getHealthAchievements(userId: string) {
    const goals = await this.prisma.healthGoal.findMany({
      where: { userId },
      include: { measurementType: true }
    });

    const measurements = await this.prisma.bodyMeasurement.findMany({
      where: { userId },
      include: { type: true },
      orderBy: { timestamp: 'desc' },
      take: 100
    });

    // Анализ достижений
    const achievements: any[] = [];

    // Достижение: Первое измерение
    if (measurements.length > 0) {
      achievements.push({
        type: 'first_measurement',
        title: 'Первое измерение',
        description: 'Вы добавили свое первое измерение!',
        earnedAt: measurements[measurements.length - 1].timestamp
      });
    }

    // Достижение: Регулярность измерений
    if (measurements.length >= 7) {
      achievements.push({
        type: 'consistent_tracking',
        title: 'Регулярное отслеживание',
        description: 'Вы добавили 7 или более измерений!',
        earnedAt: measurements[6].timestamp
      });
    }

    // Достижение: Выполненная цель
    const completedGoals = goals.filter(goal => goal.currentValue >= goal.targetValue);
    if (completedGoals.length > 0) {
      achievements.push({
        type: 'goal_completed',
        title: 'Цель достигнута',
        description: `Вы достигли ${completedGoals.length} целей в области здоровья!`,
        earnedAt: completedGoals[0].updatedAt
      });
    }

    return achievements;
  }
}
