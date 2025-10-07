import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTaskDto, UpdateTaskDto, TaskStatsDto, TaskFilterDto, TaskStatus } from './dto/tasks.dto';

@Injectable()
export class TasksService {
  constructor(private prisma: PrismaService) {}

  // Получить все задачи пользователя с фильтрацией
  async getUserTasks(userId: string, filters?: TaskFilterDto) {
    const where: any = { userId };

    if (filters?.status) {
      where.status = filters.status;
    }

    if (filters?.priority) {
      where.priority = filters.priority;
    }

    if (filters?.search) {
      where.OR = [
        { title: { contains: filters.search, mode: 'insensitive' } },
        { description: { contains: filters.search, mode: 'insensitive' } }
      ];
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

    if (filters?.tag) {
      where.tags = {
        has: filters.tag
      };
    }

    if (filters?.habitId) {
      where.habitId = filters.habitId;
    }

    if (filters?.isRecurring !== undefined) {
      where.isRecurring = filters.isRecurring;
    }

    return this.prisma.task.findMany({
      where,
      orderBy: [
        { priority: 'desc' },
        { deadline: 'asc' },
        { createdAt: 'desc' }
      ]
    });
  }

  // Получить задачу по ID
  async getTaskById(id: string, userId: string) {
    const task = await this.prisma.task.findUnique({
      where: { id }
    });

    if (!task) {
      throw new NotFoundException('Задача не найдена');
    }

    if (task.userId !== userId) {
      throw new ForbiddenException('Нет доступа к этой задаче');
    }

    return task;
  }

  // Создать задачу
  async createTask(userId: string, createTaskDto: CreateTaskDto) {
    const taskData = {
      ...createTaskDto,
      userId,
      status: TaskStatus.ASSIGNED,
      deadline: new Date(createTaskDto.deadline),
      reminderAt: createTaskDto.reminderAt ? new Date(createTaskDto.reminderAt) : null
    };

    return this.prisma.task.create({
      data: taskData
    });
  }

  // Обновить задачу
  async updateTask(id: string, userId: string, updateTaskDto: UpdateTaskDto) {
    await this.getTaskById(id, userId);

    const updateData: any = { ...updateTaskDto };
    
    if (updateTaskDto.deadline) {
      updateData.deadline = new Date(updateTaskDto.deadline);
    }
    
    if (updateTaskDto.reminderAt) {
      updateData.reminderAt = new Date(updateTaskDto.reminderAt);
    }

    return this.prisma.task.update({
      where: { id },
      data: updateData
    });
  }

  // Удалить задачу
  async deleteTask(id: string, userId: string) {
    await this.getTaskById(id, userId);

    await this.prisma.task.delete({
      where: { id }
    });

    return { message: 'Задача успешно удалена' };
  }

  // Отметить задачу как выполненную
  async completeTask(id: string, userId: string) {
    await this.getTaskById(id, userId);

    return this.prisma.task.update({
      where: { id },
      data: {
        status: TaskStatus.DONE
      }
    });
  }

  // Отменить выполнение задачи
  async uncompleteTask(id: string, userId: string) {
    await this.getTaskById(id, userId);

    return this.prisma.task.update({
      where: { id },
      data: {
        status: TaskStatus.ASSIGNED
      }
    });
  }

  // Получить задачи на сегодня
  async getTodayTasks(userId: string) {
    const today = new Date();
    const startOfDay = new Date(today.setHours(0, 0, 0, 0));
    const endOfDay = new Date(today.setHours(23, 59, 59, 999));

    return this.prisma.task.findMany({
      where: {
        userId,
        OR: [
          {
            deadline: {
              gte: startOfDay,
              lte: endOfDay
            }
          },
          {
            reminderAt: {
              gte: startOfDay,
              lte: endOfDay
            }
          }
        ]
      },
      orderBy: [
        { priority: 'desc' },
        { deadline: 'asc' }
      ]
    });
  }

  // Получить просроченные задачи
  async getOverdueTasks(userId: string) {
    const now = new Date();

    return this.prisma.task.findMany({
      where: {
        userId,
        status: {
          not: TaskStatus.DONE
        },
        deadline: {
          lt: now
        }
      },
      orderBy: { deadline: 'asc' }
    });
  }

  // Получить задачи по привычкам
  async getHabitTasks(userId: string, habitId: string) {
    return this.prisma.task.findMany({
      where: {
        userId,
        habitId
      },
      orderBy: [
        { deadline: 'asc' },
        { createdAt: 'desc' }
      ]
    });
  }

  // Получить статистику задач
  async getTaskStats(userId: string, statsDto: TaskStatsDto) {
    const startDate = new Date(statsDto.startDate);
    const endDate = new Date(statsDto.endDate);

    const where: any = {
      userId,
      createdAt: {
        gte: startDate,
        lte: endDate
      }
    };

    const tasks = await this.prisma.task.findMany({
      where,
      select: {
        status: true,
        priority: true,
        createdAt: true,
        deadline: true,
        isRecurring: true,
        habitId: true
      }
    });

    const totalTasks = tasks.length;
    const completedTasks = tasks.filter(task => task.status === TaskStatus.DONE).length;
    const assignedTasks = tasks.filter(task => task.status === TaskStatus.ASSIGNED).length;
    const inProgressTasks = tasks.filter(task => task.status === TaskStatus.IN_PROGRESS).length;

    const completionRate = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    // Группировка по приоритетам
    const tasksByPriority = tasks.reduce((acc, task) => {
      acc[task.priority] = (acc[task.priority] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    // Статистика по повторяющимся задачам
    const recurringTasks = tasks.filter(task => task.isRecurring).length;
    const habitRelatedTasks = tasks.filter(task => task.habitId).length;

    // Просроченные задачи
    const now = new Date();
    const overdueTasks = tasks.filter(task => 
      task.status !== TaskStatus.DONE && 
      new Date(task.deadline) < now
    ).length;

    return {
      period: {
        startDate: statsDto.startDate,
        endDate: statsDto.endDate
      },
      summary: {
        totalTasks,
        completedTasks,
        assignedTasks,
        inProgressTasks,
        overdueTasks,
        completionRate: Math.round(completionRate * 100) / 100
      },
      distribution: {
        byPriority: tasksByPriority,
        recurringTasks,
        habitRelatedTasks
      }
    };
  }

  // Получить задачи с напоминаниями на ближайший час
  async getUpcomingReminders(userId: string) {
    const now = new Date();
    const nextHour = new Date(now.getTime() + 60 * 60 * 1000);

    return this.prisma.task.findMany({
      where: {
        userId,
        reminderAt: {
          gte: now,
          lte: nextHour
        },
        status: {
          not: TaskStatus.DONE
        }
      },
      orderBy: { reminderAt: 'asc' }
    });
  }
}
