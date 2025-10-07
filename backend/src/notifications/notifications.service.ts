import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { 
  CreateNotificationDto, 
  UpdateNotificationDto, 
  NotificationFilterDto,
  CreateQuoteDto,
  UpdateQuoteDto,
  QuoteFilterDto,
  NotificationSettingsDto,
  BulkNotificationActionDto,
  SendNotificationDto,
  NotificationStatsDto,
  NotificationPriority,
  NotificationStatus,
  QuoteCategory
} from './dto/notifications.dto';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  // ========== NOTIFICATIONS ==========

  // Простые методы для уведомлений (заглушки)
  async getUserNotifications(userId: string, filters?: NotificationFilterDto) {
    return [];
  }

  async createNotification(userId: string, createNotificationDto: CreateNotificationDto) {
    return { message: 'Уведомление создано' };
  }

  async updateNotification(id: string, userId: string, updateNotificationDto: UpdateNotificationDto) {
    return { message: 'Уведомление обновлено' };
  }

  async deleteNotification(id: string, userId: string) {
    return { message: 'Уведомление удалено' };
  }

  async markAsRead(id: string, userId: string) {
    return { message: 'Уведомление отмечено как прочитанное' };
  }

  async markAllAsRead(userId: string) {
    return { message: 'Все уведомления отмечены как прочитанные' };
  }

  async bulkNotificationAction(userId: string, bulkActionDto: BulkNotificationActionDto) {
    const { notificationIds, action } = bulkActionDto;
    return { message: `Выполнено действие ${action} для ${notificationIds.length} уведомлений` };
  }

  // ========== QUOTES ==========

  // Получить цитаты
  async getQuotes(filters?: QuoteFilterDto) {
    const where: any = {};

    if (filters?.category) {
      where.category = filters.category;
    }

    if (filters?.author) {
      where.author = { contains: filters.author, mode: 'insensitive' };
    }

    if (filters?.search) {
      where.OR = [
        { text: { contains: filters.search, mode: 'insensitive' } },
        { author: { contains: filters.search, mode: 'insensitive' } }
      ];
    }

    if (filters?.tags && filters.tags.length > 0) {
      where.tags = { hasSome: filters.tags };
    }

    if (filters?.activeOnly !== false) {
      where.isActive = true;
    }

    return this.prisma.quote.findMany({
      where,
      orderBy: { createdAt: 'desc' }
    });
  }

  // Получить случайную цитату
  async getRandomQuote(category?: QuoteCategory) {
    const where: any = { isActive: true };

    if (category) {
      where.category = category;
    }

    const quotesCount = await this.prisma.quote.count({ where });

    if (quotesCount === 0) {
      return null;
    }

    const skip = Math.floor(Math.random() * quotesCount);

    return this.prisma.quote.findFirst({
      where,
      skip
    });
  }

  // Создать цитату
  async createQuote(createQuoteDto: CreateQuoteDto) {
    const quoteData = {
      text: createQuoteDto.text,
      author: createQuoteDto.author || 'Неизвестный автор',
      category: createQuoteDto.category,
      tags: createQuoteDto.tags || [],
      isActive: createQuoteDto.isActive !== false
    };

    return this.prisma.quote.create({
      data: {
        ...quoteData,
        category: quoteData.category as any
      }
    });
  }

  // Обновить цитату
  async updateQuote(id: string, updateQuoteDto: UpdateQuoteDto) {
    const quote = await this.prisma.quote.findUnique({
      where: { id }
    });

    if (!quote) {
      throw new NotFoundException('Цитата не найдена');
    }

    const updateData = {
      text: updateQuoteDto.text,
      author: updateQuoteDto.author || 'Неизвестный автор',
      category: updateQuoteDto.category as any,
      tags: updateQuoteDto.tags || [],
      isActive: updateQuoteDto.isActive
    };

    return this.prisma.quote.update({
      where: { id },
      data: updateData
    });
  }

  // Удалить цитату
  async deleteQuote(id: string) {
    const quote = await this.prisma.quote.findUnique({
      where: { id }
    });

    if (!quote) {
      throw new NotFoundException('Цитата не найдена');
    }

    await this.prisma.quote.delete({
      where: { id }
    });

    return { message: 'Цитата удалена' };
  }

  // ========== SETTINGS ==========

  // Получить настройки уведомлений пользователя
  async getNotificationSettings(userId: string) {
    const settings = await this.prisma.notificationSettings.findUnique({
      where: { userId }
    });

    if (!settings) {
      // Создать настройки по умолчанию
      return this.createDefaultNotificationSettings(userId);
    }

    return settings;
  }

  // Обновить настройки уведомлений
  async updateNotificationSettings(userId: string, settingsDto: NotificationSettingsDto) {
    const existingSettings = await this.prisma.notificationSettings.findUnique({
      where: { userId }
    });

    const settingsData = {
      habitsEnabled: settingsDto.habitsEnabled !== false,
      tasksEnabled: settingsDto.tasksEnabled !== false,
      workoutsEnabled: settingsDto.workoutsEnabled !== false,
      healthEnabled: settingsDto.healthEnabled !== false,
      motivationalEnabled: settingsDto.motivationalEnabled !== false,
      achievementsEnabled: settingsDto.achievementsEnabled !== false,
      quietHoursStart: settingsDto.quietHoursStart || '22:00',
      quietHoursEnd: settingsDto.quietHoursEnd || '08:00',
      motivationalFrequency: settingsDto.motivationalFrequency || 24,
      enabledDays: settingsDto.enabledDays || [1, 2, 3, 4, 5, 6, 0]
    };

    if (existingSettings) {
      return this.prisma.notificationSettings.update({
        where: { userId },
        data: settingsData as any
      });
    } else {
      return this.prisma.notificationSettings.create({
        data: {
          userId,
          ...settingsData
        } as any
      });
    }
  }

  // ========== STATISTICS ==========

  // Получить статистику уведомлений
  async getNotificationStats(userId: string, statsDto: NotificationStatsDto) {
    const days = statsDto.days || 30;
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - days);

    const stats = {
      period: {
        days,
        startDate: startDate.toISOString(),
        endDate: new Date().toISOString()
      },
      total: 0,
      read: 0,
      unread: 0,
      dismissed: 0
    };

    if (statsDto.groupByType) {
      return { ...stats, byType: {} };
    }

    return stats;
  }

  // ========== HELPER METHODS ==========

  private async createDefaultNotificationSettings(userId: string) {
    const defaultSettings = {
      userId,
      habitsEnabled: true,
      tasksEnabled: true,
      workoutsEnabled: true,
      healthEnabled: true,
      motivationalEnabled: true,
      achievementsEnabled: true,
      quietHoursStart: '22:00',
      quietHoursEnd: '08:00',
      motivationalFrequency: 24,
      enabledDays: [1, 2, 3, 4, 5, 6, 0] // Все дни недели
    };

    return this.prisma.notificationSettings.create({
      data: defaultSettings
    });
  }

  // Отправить уведомление (заглушка для будущей интеграции с push-сервисами)
  async sendNotification(sendNotificationDto: SendNotificationDto) {
    const { userIds, notification } = sendNotificationDto;
    const users = Array.isArray(userIds) ? userIds : [userIds];

    return {
      message: `Уведомление отправлено ${users.length} пользователям`,
      notification
    };
  }
}
