import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsBoolean, IsDateString, IsArray, IsNumber, Min, Max } from 'class-validator';

export enum NotificationType {
  HABIT_REMINDER = 'HABIT_REMINDER',
  TASK_REMINDER = 'TASK_REMINDER',
  WORKOUT_REMINDER = 'WORKOUT_REMINDER',
  HEALTH_CHECK = 'HEALTH_CHECK',
  MOTIVATIONAL = 'MOTIVATIONAL',
  ACHIEVEMENT = 'ACHIEVEMENT',
  MILESTONE = 'MILESTONE',
  STREAK = 'STREAK',
  SYSTEM = 'SYSTEM'
}

export enum NotificationPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH',
  URGENT = 'URGENT'
}

export enum NotificationStatus {
  PENDING = 'PENDING',
  SENT = 'SENT',
  READ = 'READ',
  DISMISSED = 'DISMISSED',
  FAILED = 'FAILED'
}

export enum QuoteCategory {
  MOTIVATION = 'MOTIVATION',
  SUCCESS = 'SUCCESS',
  PERSISTENCE = 'PERSISTENCE',
  HEALTH = 'HEALTH',
  FITNESS = 'FITNESS',
  MINDFULNESS = 'MINDFULNESS',
  PRODUCTIVITY = 'PRODUCTIVITY',
  GOALS = 'GOALS'
}

// Notification DTOs
export class CreateNotificationDto {
  @ApiProperty({ description: 'Заголовок уведомления' })
  @IsString()
  title: string;

  @ApiProperty({ description: 'Текст уведомления' })
  @IsString()
  message: string;

  @ApiProperty({ 
    description: 'Тип уведомления',
    enum: NotificationType
  })
  @IsEnum(NotificationType)
  type: NotificationType;

  @ApiPropertyOptional({ 
    description: 'Приоритет уведомления',
    enum: NotificationPriority,
    default: NotificationPriority.MEDIUM
  })
  @IsOptional()
  @IsEnum(NotificationPriority)
  priority?: NotificationPriority;

  @ApiPropertyOptional({ description: 'Время отправки (если не указано - сразу)' })
  @IsOptional()
  @IsDateString()
  scheduledFor?: string;

  @ApiPropertyOptional({ description: 'Дополнительные данные (JSON)' })
  @IsOptional()
  data?: any;

  @ApiPropertyOptional({ description: 'Действие при клике' })
  @IsOptional()
  @IsString()
  actionUrl?: string;

  @ApiPropertyOptional({ description: 'Иконка уведомления' })
  @IsOptional()
  @IsString()
  icon?: string;
}

export class UpdateNotificationDto {
  @ApiPropertyOptional({ 
    description: 'Статус уведомления',
    enum: NotificationStatus
  })
  @IsOptional()
  @IsEnum(NotificationStatus)
  status?: NotificationStatus;

  @ApiPropertyOptional({ description: 'Время прочтения' })
  @IsOptional()
  @IsDateString()
  readAt?: string;
}

export class NotificationFilterDto {
  @ApiPropertyOptional({ description: 'Тип уведомления', enum: NotificationType })
  @IsOptional()
  @IsEnum(NotificationType)
  type?: NotificationType;

  @ApiPropertyOptional({ description: 'Статус уведомления', enum: NotificationStatus })
  @IsOptional()
  @IsEnum(NotificationStatus)
  status?: NotificationStatus;

  @ApiPropertyOptional({ description: 'Приоритет уведомления', enum: NotificationPriority })
  @IsOptional()
  @IsEnum(NotificationPriority)
  priority?: NotificationPriority;

  @ApiPropertyOptional({ description: 'Только непрочитанные' })
  @IsOptional()
  @IsBoolean()
  unreadOnly?: boolean;

  @ApiPropertyOptional({ description: 'Начальная дата' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Конечная дата' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Лимит записей', default: 50 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number;
}

// Quote DTOs
export class CreateQuoteDto {
  @ApiProperty({ description: 'Текст цитаты' })
  @IsString()
  text: string;

  @ApiPropertyOptional({ description: 'Автор цитаты' })
  @IsOptional()
  @IsString()
  author?: string;

  @ApiProperty({ 
    description: 'Категория цитаты',
    enum: QuoteCategory
  })
  @IsEnum(QuoteCategory)
  category: QuoteCategory;

  @ApiPropertyOptional({ description: 'Теги (массив строк)' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({ description: 'Активна ли цитата', default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ description: 'Рейтинг цитаты (1-5)', default: 3 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  rating?: number;
}

export class UpdateQuoteDto extends CreateQuoteDto {}

export class QuoteFilterDto {
  @ApiPropertyOptional({ description: 'Категория цитаты', enum: QuoteCategory })
  @IsOptional()
  @IsEnum(QuoteCategory)
  category?: QuoteCategory;

  @ApiPropertyOptional({ description: 'Автор цитаты' })
  @IsOptional()
  @IsString()
  author?: string;

  @ApiPropertyOptional({ description: 'Поиск по тексту' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: 'Теги для фильтрации' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({ description: 'Только активные цитаты', default: true })
  @IsOptional()
  @IsBoolean()
  activeOnly?: boolean;

  @ApiPropertyOptional({ description: 'Минимальный рейтинг' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  minRating?: number;
}

// Settings DTOs
export class NotificationSettingsDto {
  @ApiPropertyOptional({ description: 'Включены ли уведомления о привычках', default: true })
  @IsOptional()
  @IsBoolean()
  habitsEnabled?: boolean;

  @ApiPropertyOptional({ description: 'Включены ли уведомления о задачах', default: true })
  @IsOptional()
  @IsBoolean()
  tasksEnabled?: boolean;

  @ApiPropertyOptional({ description: 'Включены ли уведомления о тренировках', default: true })
  @IsOptional()
  @IsBoolean()
  workoutsEnabled?: boolean;

  @ApiPropertyOptional({ description: 'Включены ли уведомления о здоровье', default: true })
  @IsOptional()
  @IsBoolean()
  healthEnabled?: boolean;

  @ApiPropertyOptional({ description: 'Включены ли мотивационные уведомления', default: true })
  @IsOptional()
  @IsBoolean()
  motivationalEnabled?: boolean;

  @ApiPropertyOptional({ description: 'Включены ли уведомления о достижениях', default: true })
  @IsOptional()
  @IsBoolean()
  achievementsEnabled?: boolean;

  @ApiPropertyOptional({ description: 'Время начала тихого режима (HH:MM)' })
  @IsOptional()
  @IsString()
  quietHoursStart?: string;

  @ApiPropertyOptional({ description: 'Время окончания тихого режима (HH:MM)' })
  @IsOptional()
  @IsString()
  quietHoursEnd?: string;

  @ApiPropertyOptional({ description: 'Частота мотивационных цитат (часы)', default: 24 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(168)
  motivationalFrequency?: number;

  @ApiPropertyOptional({ description: 'Дни недели для уведомлений (0-6, где 0 - воскресенье)' })
  @IsOptional()
  @IsArray()
  @IsNumber({}, { each: true })
  enabledDays?: number[];
}

// Bulk operations DTOs
export class BulkNotificationActionDto {
  @ApiProperty({ description: 'Массив ID уведомлений' })
  @IsArray()
  @IsString({ each: true })
  notificationIds: string[];

  @ApiProperty({ 
    description: 'Действие для выполнения',
    enum: ['mark_read', 'mark_unread', 'dismiss', 'delete']
  })
  @IsEnum(['mark_read', 'mark_unread', 'dismiss', 'delete'])
  action: 'mark_read' | 'mark_unread' | 'dismiss' | 'delete';
}

export class SendNotificationDto {
  @ApiProperty({ description: 'ID пользователя или массив ID пользователей' })
  userIds: string | string[];

  @ApiProperty({ description: 'Данные уведомления' })
  notification: CreateNotificationDto;

  @ApiPropertyOptional({ description: 'Отправить немедленно', default: true })
  @IsOptional()
  @IsBoolean()
  immediate?: boolean;
}

// Statistics DTOs
export class NotificationStatsDto {
  @ApiPropertyOptional({ description: 'Период в днях для статистики', default: 30 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(365)
  days?: number;

  @ApiPropertyOptional({ description: 'Группировать по типам уведомлений' })
  @IsOptional()
  @IsBoolean()
  groupByType?: boolean;
}
