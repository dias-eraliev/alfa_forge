import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsArray, IsInt, IsBoolean, Min, Max, IsHexColor } from 'class-validator';

export enum HabitFrequencyType {
  DAILY = 'DAILY',
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY',
  CUSTOM = 'CUSTOM'
}

export enum HabitDifficulty {
  EASY = 'EASY',
  MEDIUM = 'MEDIUM',
  HARD = 'HARD'
}

export enum HabitProgressionType {
  STANDARD = 'STANDARD',
  INCREMENTAL = 'INCREMENTAL',
  TARGET = 'TARGET'
}

export class CreateHabitDto {
  @ApiProperty({ description: 'Название привычки' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ description: 'Описание привычки' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ description: 'Мотивация для привычки' })
  @IsOptional()
  @IsString()
  motivation?: string;

  @ApiProperty({ description: 'Название иконки' })
  @IsString()
  iconName: string;

  @ApiPropertyOptional({ description: 'Семейство иконки' })
  @IsOptional()
  @IsString()
  iconFamily?: string;

  @ApiProperty({ description: 'Цвет в формате hex' })
  @IsHexColor()
  colorHex: string;

  @ApiProperty({ description: 'ID категории' })
  @IsString()
  categoryId: string;

  @ApiPropertyOptional({ description: 'ID шаблона' })
  @IsOptional()
  @IsString()
  templateId?: string;

  @ApiProperty({ 
    description: 'Тип частоты выполнения',
    enum: HabitFrequencyType,
    default: HabitFrequencyType.DAILY
  })
  @IsEnum(HabitFrequencyType)
  frequencyType: HabitFrequencyType;

  @ApiPropertyOptional({ description: 'Количество раз в неделю', minimum: 1, maximum: 7 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(7)
  timesPerWeek?: number;

  @ApiPropertyOptional({ description: 'Количество раз в месяц', minimum: 1, maximum: 31 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(31)
  timesPerMonth?: number;

  @ApiPropertyOptional({ description: 'Дни недели (1-7)', type: [Number] })
  @IsOptional()
  @IsArray()
  @IsInt({ each: true })
  specificWeekdays?: number[];

  @ApiPropertyOptional({ description: 'Время напоминания в формате HH:MM' })
  @IsOptional()
  @IsString()
  reminderTime?: string;

  @ApiPropertyOptional({ description: 'Продолжительность в минутах' })
  @IsOptional()
  @IsInt()
  @Min(1)
  duration?: number;

  @ApiProperty({ 
    description: 'Сложность привычки',
    enum: HabitDifficulty,
    default: HabitDifficulty.MEDIUM
  })
  @IsEnum(HabitDifficulty)
  difficulty: HabitDifficulty;

  @ApiPropertyOptional({ description: 'Включить напоминания', default: true })
  @IsOptional()
  @IsBoolean()
  enableReminders?: boolean;

  @ApiPropertyOptional({ description: 'Связанная цель' })
  @IsOptional()
  @IsString()
  linkedGoal?: string;

  @ApiPropertyOptional({ description: 'Теги', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({ description: 'Мотивационные сообщения', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  motivationalMessages?: string[];

  @ApiProperty({ 
    description: 'Тип прогрессии',
    enum: HabitProgressionType,
    default: HabitProgressionType.STANDARD
  })
  @IsEnum(HabitProgressionType)
  progressionType: HabitProgressionType;
}

export class UpdateHabitDto extends CreateHabitDto {
  @ApiPropertyOptional({ description: 'Активна ли привычка', default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class CompleteHabitDto {
  @ApiProperty({ description: 'Дата выполнения в формате YYYY-MM-DD' })
  @IsString()
  date: string;

  @ApiPropertyOptional({ description: 'Заметки о выполнении' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: 'Фактическая продолжительность в минутах' })
  @IsOptional()
  @IsInt()
  @Min(1)
  duration?: number;

  @ApiPropertyOptional({ description: 'Оценка качества выполнения (1-5)', minimum: 1, maximum: 5 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  quality?: number;

  @ApiPropertyOptional({ description: 'Настроение после выполнения (1-5)', minimum: 1, maximum: 5 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  mood?: number;
}

export class HabitStatsDto {
  @ApiProperty({ description: 'Начальная дата для статистики' })
  @IsString()
  startDate: string;

  @ApiProperty({ description: 'Конечная дата для статистики' })
  @IsString()
  endDate: string;
}
