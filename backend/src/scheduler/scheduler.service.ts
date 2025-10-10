import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../prisma/prisma.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class SchedulerService {
  private readonly logger = new Logger(SchedulerService.name);

  constructor(
    private prisma: PrismaService,
    private notifications: NotificationsService,
  ) {}

  // Каждые 5 минут проверяем напоминания по задачам (близкие дедлайны или reminderAt)
  @Cron('*/5 * * * *')
  async remindUpcomingTasks() {
    const now = new Date();
    const in15 = new Date(now.getTime() + 15 * 60 * 1000);

    const tasks = await this.prisma.task.findMany({
      where: {
        OR: [
          { reminderAt: { lte: in15, gte: now } },
          { deadline: { lte: in15, gte: now } },
        ],
      },
      select: { id: true, title: true, userId: true, reminderAt: true, deadline: true },
    });

    for (const t of tasks) {
      try {
        await this.notifications.sendNotification({
          userIds: t.userId,
          notification: {
            title: 'Задача скоро истекает',
            message: `${t.title}`,
            type:  'TASK_REMINDER' as any,
            data: { type: 'task', taskId: t.id },
            actionUrl: `app://tasks`,
          },
          immediate: true,
        });
      } catch {
        // log and continue
      }
    }
  }

  // Ежедневно в 7:00 по серверному времени рассылаем привычки с reminderTime == HH:MM
  @Cron(CronExpression.EVERY_MINUTE)
  async remindHabitsByTime() {
    const now = new Date();
    const hh = now.getHours().toString().padStart(2, '0');
    const mm = now.getMinutes().toString().padStart(2, '0');
    const current = `${hh}:${mm}`;

    const habits = await this.prisma.habit.findMany({
      where: {
        isActive: true,
        enableReminders: true,
        reminderTime: current,
      },
      select: { id: true, name: true, userId: true },
    });

    for (const h of habits) {
      try {
        await this.notifications.sendNotification({
          userIds: h.userId,
          notification: {
            title: 'Время привычки',
            message: h.name,
            type: 'HABIT_REMINDER' as any,
            data: { type: 'habit', habitId: h.id },
            actionUrl: `app://habits`,
          },
          immediate: true,
        });
      } catch {
        // ignore
      }
    }
  }
}
