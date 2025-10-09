import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsNumber, IsDateString, IsBoolean, Min, Max } from 'class-validator';

export enum ProgressType {
  HABITS = 'HABITS',
  TASKS = 'TASKS',
  HEALTH = 'HEALTH',
  EXERCISES = 'EXERCISES',
  OVERALL = 'OVERALL'
}

export enum TimeFrame {
  DAILY = 'DAILY',
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY',
  YEARLY = 'YEARLY'
}

export enum GoalStatus {
  NOT_STARTED = 'NOT_STARTED',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  OVERDUE = 'OVERDUE',
  PAUSED = 'PAUSED'
}

export enum AchievementType {
  HABIT_STREAK = 'HABIT_STREAK',
  TASK_COMPLETION = 'TASK_COMPLETION',
  HEALTH_MILESTONE = 'HEALTH_MILESTONE',
  EXERCISE_GOAL = 'EXERCISE_GOAL',
  CONSISTENCY = 'CONSISTENCY',
  MILESTONE = 'MILESTONE'
}

// Progress Tracking DTOs
export class CreateProgressEntryDto {
  @ApiProperty({ 
    description: 'Тип прогресса',
    enum: ProgressType
  })
  @IsEnum(ProgressType)
  type: ProgressType;

  @ApiProperty({ description: 'Значение прогресса (0-100)' })
  @IsNumber()
  @Min(0)
  @Max(100)
  value: number;

  @ApiPropertyOptional({ description: 'Дата записи' })
  @IsOptional()
  @IsDateString()
  date?: string;

  @ApiPropertyOptional({ description: 'Дополнительные метаданные (JSON)' })
  @IsOptional()
  metadata?: any;

  @ApiPropertyOptional({ description: 'Заметки' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class UpdateProgressEntryDto extends CreateProgressEntryDto {}

export class ProgressFilterDto {
  @ApiPropertyOptional({ description: 'Тип прогресса', enum: ProgressType })
  @IsOptional()
  @IsEnum(ProgressType)
  type?: ProgressType;

  @ApiPropertyOptional({ description: 'Начальная дата' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Конечная дата' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Минимальное значение' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  minValue?: number;

  @ApiPropertyOptional({ description: 'Максимальное значение' })
  @IsOptional()
  @IsNumber()
  @Max(100)
  maxValue?: number;
}

// Goal Management DTOs
export class CreateGoalDto {
  @ApiProperty({ description: 'Название цели' })
  @IsString()
  title: string;

  @ApiPropertyOptional({ description: 'Описание цели' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ 
    description: 'Тип цели',
    enum: ProgressType
  })
  @IsEnum(ProgressType)
  type: ProgressType;

  @ApiProperty({ description: 'Целевое значение' })
  @IsNumber()
  @Min(0)
  targetValue: number;

  @ApiPropertyOptional({ description: 'Текущее значение', default: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  currentValue?: number;

  @ApiPropertyOptional({ description: 'Единица измерения' })
  @IsOptional()
  @IsString()
  unit?: string;

  @ApiPropertyOptional({ description: 'Дата окончания' })
  @IsOptional()
  @IsDateString()
  deadline?: string;

  @ApiPropertyOptional({ description: 'Приоритет (1-5)', default: 3 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  priority?: number;

  @ApiPropertyOptional({ description: 'Активна ли цель', default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateGoalDto extends CreateGoalDto {
  @ApiPropertyOptional({ 
    description: 'Статус цели',
    enum: GoalStatus
  })
  @IsOptional()
  @IsEnum(GoalStatus)
  status?: GoalStatus;
}

export class GoalFilterDto {
  @ApiPropertyOptional({ description: 'Тип цели', enum: ProgressType })
  @IsOptional()
  @IsEnum(ProgressType)
  type?: ProgressType;

  @ApiPropertyOptional({ description: 'Статус цели', enum: GoalStatus })
  @IsOptional()
  @IsEnum(GoalStatus)
  status?: GoalStatus;

  @ApiPropertyOptional({ description: 'Только активные цели' })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ description: 'Минимальный приоритет' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  minPriority?: number;
}

// Achievement DTOs
export class CreateAchievementDto {
  @ApiProperty({ description: 'Название достижения' })
  @IsString()
  title: string;

  @ApiProperty({ description: 'Описание достижения' })
  @IsString()
  description: string;

  @ApiProperty({ 
    description: 'Тип достижения',
    enum: AchievementType
  })
  @IsEnum(AchievementType)
  type: AchievementType;

  @ApiPropertyOptional({ description: 'Иконка достижения' })
  @IsOptional()
  @IsString()
  icon?: string;

  @ApiPropertyOptional({ description: 'Очки за достижение' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  points?: number;

  @ApiPropertyOptional({ description: 'Условия получения (JSON)' })
  @IsOptional()
  criteria?: any;

  @ApiPropertyOptional({ description: 'Редкость достижения (1-5)', default: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  rarity?: number;
}

export class UpdateAchievementDto extends CreateAchievementDto {}

export class AchievementFilterDto {
  @ApiPropertyOptional({ description: 'Тип достижения', enum: AchievementType })
  @IsOptional()
  @IsEnum(AchievementType)
  type?: AchievementType;

  @ApiPropertyOptional({ description: 'Минимальная редкость' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  minRarity?: number;

  @ApiPropertyOptional({ description: 'Только полученные достижения' })
  @IsOptional()
  @IsBoolean()
  earnedOnly?: boolean;
}

// Statistics DTOs
export class ProgressStatsDto {
  @ApiProperty({ description: 'Начальная дата для статистики' })
  @IsString()
  startDate: string;

  @ApiProperty({ description: 'Конечная дата для статистики' })
  @IsString()
  endDate: string;

  @ApiPropertyOptional({ 
    description: 'Временные рамки',
    enum: TimeFrame,
    default: TimeFrame.DAILY
  })
  @IsOptional()
  @IsEnum(TimeFrame)
  timeFrame?: TimeFrame;

  @ApiPropertyOptional({ description: 'Типы прогресса для анализа' })
  @IsOptional()
  types?: ProgressType[];
}

export class DashboardStatsDto {
  @ApiPropertyOptional({ 
    description: 'Период для статистики (дни)',
    default: 30
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(365)
  days?: number;

  @ApiPropertyOptional({
    description: "Символьный период ('today'|'week'|'month')",
    default: undefined
  })
  @IsOptional()
  period?: string;

  @ApiPropertyOptional({ description: 'Включить детальную статистику', default: false })
  @IsOptional()
  @IsBoolean()
  includeDetails?: boolean;
}

export class LeaderboardDto {
  @ApiPropertyOptional({ 
    description: 'Тип рейтинга',
    enum: ProgressType,
    default: ProgressType.OVERALL
  })
  @IsOptional()
  @IsEnum(ProgressType)
  type?: ProgressType;

  @ApiPropertyOptional({ 
    description: 'Временные рамки',
    enum: TimeFrame,
    default: TimeFrame.MONTHLY
  })
  @IsOptional()
  @IsEnum(TimeFrame)
  timeFrame?: TimeFrame;

  @ApiPropertyOptional({ description: 'Количество позиций', default: 10 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number;
}
