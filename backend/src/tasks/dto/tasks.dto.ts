import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsDateString, IsBoolean, IsArray } from 'class-validator';

export enum TaskStatus {
  ASSIGNED = 'ASSIGNED',
  IN_PROGRESS = 'IN_PROGRESS',
  DONE = 'DONE'
}

export enum TaskPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH'
}

export enum RecurringTaskType {
  DAILY = 'DAILY',
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY'
}

export class CreateTaskDto {
  @ApiProperty({ description: 'Название задачи' })
  @IsString()
  title: string;

  @ApiPropertyOptional({ description: 'Описание задачи' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ 
    description: 'Приоритет задачи',
    enum: TaskPriority,
    default: TaskPriority.MEDIUM
  })
  @IsEnum(TaskPriority)
  priority: TaskPriority;

  @ApiProperty({ description: 'Дедлайн задачи' })
  @IsDateString()
  deadline: string;

  @ApiPropertyOptional({ description: 'Дата и время напоминания' })
  @IsOptional()
  @IsDateString()
  reminderAt?: string;

  @ApiPropertyOptional({ description: 'ID связанной привычки' })
  @IsOptional()
  @IsString()
  habitId?: string;

  @ApiPropertyOptional({ description: 'Название связанной привычки' })
  @IsOptional()
  @IsString()
  habitName?: string;

  @ApiPropertyOptional({ description: 'Повторяющаяся задача', default: false })
  @IsOptional()
  @IsBoolean()
  isRecurring?: boolean;

  @ApiPropertyOptional({ 
    description: 'Тип повторения',
    enum: RecurringTaskType
  })
  @IsOptional()
  @IsEnum(RecurringTaskType)
  recurringType?: RecurringTaskType;

  @ApiPropertyOptional({ description: 'Подзадачи', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  subtasks?: string[];

  @ApiPropertyOptional({ description: 'Теги', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];
}

export class UpdateTaskDto extends CreateTaskDto {
  @ApiPropertyOptional({ 
    description: 'Статус задачи',
    enum: TaskStatus
  })
  @IsOptional()
  @IsEnum(TaskStatus)
  status?: TaskStatus;
}

export class TaskFilterDto {
  @ApiPropertyOptional({ description: 'Статус задачи', enum: TaskStatus })
  @IsOptional()
  @IsEnum(TaskStatus)
  status?: TaskStatus;

  @ApiPropertyOptional({ description: 'Приоритет задачи', enum: TaskPriority })
  @IsOptional()
  @IsEnum(TaskPriority)
  priority?: TaskPriority;

  @ApiPropertyOptional({ description: 'Поиск по названию' })
  @IsOptional()
  @IsString()
  search?: string;

  @ApiPropertyOptional({ description: 'Дата начала периода' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Дата окончания периода' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Тег для фильтрации' })
  @IsOptional()
  @IsString()
  tag?: string;

  @ApiPropertyOptional({ description: 'ID привычки для фильтрации' })
  @IsOptional()
  @IsString()
  habitId?: string;

  @ApiPropertyOptional({ description: 'Только повторяющиеся задачи' })
  @IsOptional()
  @IsBoolean()
  isRecurring?: boolean;
}

export class TaskStatsDto {
  @ApiProperty({ description: 'Начальная дата для статистики' })
  @IsString()
  startDate: string;

  @ApiProperty({ description: 'Конечная дата для статистики' })
  @IsString()
  endDate: string;
}
