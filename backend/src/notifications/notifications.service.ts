import { Injectable, NotFoundException } from '@nestjs/common';
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
  // NotificationPriority,
  // NotificationStatus,
  QuoteCategory
} from './dto/notifications.dto';

@Injectable()
export class NotificationsService {
  constructor(private prisma: PrismaService) {}

  // ========== NOTIFICATIONS ==========

  // Простые методы для уведомлений (заглушки)
  async getUserNotifications(_userId: string, _filters?: NotificationFilterDto) {
    // помечаем параметры как использованные, чтобы подавить noUnused
    void _userId; void _filters;
    return [];
  }

  async createNotification(_userId: string, _createNotificationDto: CreateNotificationDto) {
    void _userId; void _createNotificationDto;
    return { message: 'Уведомление создано' };
  }

  async updateNotification(_id: string, _userId: string, _updateNotificationDto: UpdateNotificationDto) {
    void _id; void _userId; void _updateNotificationDto;
    return { message: 'Уведомление обновлено' };
  }

  async deleteNotification(_id: string, _userId: string) {
    void _id; void _userId;
    return { message: 'Уведомление удалено' };
  }

  async markAsRead(_id: string, _userId: string) {
    void _id; void _userId;
    return { message: 'Уведомление отмечено как прочитанное' };
  }

  async markAllAsRead(_userId: string) {
    void _userId;
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
    // Получаем все playerId пользователей
    const tokens = await this.prisma.deviceToken.findMany({
      where: { userId: { in: users } },
      select: { playerId: true },
    });

    const appId = process.env.ONESIGNAL_APP_ID;
    const apiKey = process.env.ONESIGNAL_REST_API_KEY;

    if (!appId || !apiKey) {
      return {
        message: `ONESIGNAL_APP_ID/ONESIGNAL_REST_API_KEY не заданы. Пропускаем реальную отправку.`,
        stats: { users: users.length, devices: tokens.length },
      };
    }

    // Формируем payload для OneSignal (v1 notifications endpoint совместим)
    const playerIds = tokens.map(t => t.playerId);

    const body = {
      app_id: appId,
      include_player_ids: playerIds.length ? playerIds : undefined,
      // fallback: если нет playerIds, можем отправить по external_user_ids (при условии вызова OneSignal.login(externalId) на клиенте)
      include_external_user_ids: users.length ? users : undefined,
      target_channel: 'push',
      headings: { en: notification.title },
      contents: { en: notification.message },
      data: notification.data || undefined,
      url: notification.actionUrl || undefined,
    } as any;

    const fetchFn: any = (globalThis as any).fetch;
    if (!fetchFn) {
      return { message: 'Fetch недоступен в окружении Node. Используйте Node 18+ или настройте polyfill.' };
    }

    const resp = await fetchFn('https://api.onesignal.com/notifications', {
      method: 'POST',
      headers: {
        'content-type': 'application/json; charset=utf-8',
        authorization: `Key ${apiKey}`,
      },
      body: JSON.stringify(body),
    });

    const result = await resp.json().catch(() => ({}));
    if (!resp.ok) {
      return { message: 'Ошибка отправки в OneSignal', status: resp.status, result };
    }

    return { message: 'Уведомление отправлено в OneSignal', result };
  }

  // ========== DEVICE TOKEN MANAGEMENT ==========
  async registerDevice(userId: string, playerId: string, platform: string) {
    // upsert по playerId
    const existing = await this.prisma.deviceToken.findUnique({ where: { playerId } });
    if (existing) {
      return this.prisma.deviceToken.update({
        where: { playerId },
        data: { userId, platform, lastActive: new Date() },
      });
    }
    return this.prisma.deviceToken.create({
      data: { userId, playerId, platform },
    });
  }

  async unregisterDevice(userId: string, playerId: string) {
    const existing = await this.prisma.deviceToken.findUnique({ where: { playerId } });
    if (!existing || existing.userId !== userId) {
      return { message: 'Токен не найден или не принадлежит пользователю' };
    }
    await this.prisma.deviceToken.delete({ where: { playerId } });
    return { message: 'Токен удалён' };
  }
}
