import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsNumber, IsDateString, IsBoolean, Min, Max } from 'class-validator';

export enum MeasurementCategory {
  BASIC = 'BASIC',
  BODY = 'BODY',
  COMPOSITION = 'COMPOSITION',
  VITAL = 'VITAL'
}

export enum MeasurementUnit {
  KG = 'KG',
  CM = 'CM',
  PERCENT = 'PERCENT',
  BPM = 'BPM',
  MMHG = 'MMHG',
  CELSIUS = 'CELSIUS',
  KCAL = 'KCAL'
}

export enum HealthGoalType {
  WEIGHT = 'WEIGHT',
  BODY_FAT = 'BODY_FAT',
  MUSCLE = 'MUSCLE',
  WAIST = 'WAIST',
  CHEST = 'CHEST',
  HIPS = 'HIPS',
  BICEPS = 'BICEPS',
  STEPS = 'STEPS',
  WATER = 'WATER',
  SLEEP = 'SLEEP',
  HEART_RATE = 'HEART_RATE',
  BLOOD_PRESSURE = 'BLOOD_PRESSURE',
  CALORIES = 'CALORIES'
}

export enum HealthGoalPriority {
  LOW = 'LOW',
  MEDIUM = 'MEDIUM',
  HIGH = 'HIGH'
}

export enum HealthGoalFrequency {
  DAILY = 'DAILY',
  WEEKLY = 'WEEKLY',
  MONTHLY = 'MONTHLY',
  YEARLY = 'YEARLY'
}

// Measurement DTOs
export class CreateMeasurementDto {
  @ApiProperty({ description: 'ID типа измерения' })
  @IsString()
  typeId: string;

  @ApiProperty({ description: 'Значение измерения' })
  @IsNumber()
  value: number;

  @ApiPropertyOptional({ description: 'Время измерения' })
  @IsOptional()
  @IsDateString()
  timestamp?: string;

  @ApiPropertyOptional({ description: 'Заметки к измерению' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: 'Путь к фото' })
  @IsOptional()
  @IsString()
  photoPath?: string;

  @ApiPropertyOptional({ description: 'Настроение 1-5' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(5)
  mood?: number;

  @ApiPropertyOptional({ description: 'Уверенность в точности 0-1' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1)
  confidence?: number;
}

export class UpdateMeasurementDto extends CreateMeasurementDto {}

export class MeasurementFilterDto {
  @ApiPropertyOptional({ description: 'ID типа измерения' })
  @IsOptional()
  @IsString()
  typeId?: string;

  @ApiPropertyOptional({ description: 'Категория измерения', enum: MeasurementCategory })
  @IsOptional()
  @IsEnum(MeasurementCategory)
  category?: MeasurementCategory;

  @ApiPropertyOptional({ description: 'Дата начала периода' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Дата окончания периода' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'Лимит записей' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number;
}

// Health Goal DTOs
export class CreateHealthGoalDto {
  @ApiProperty({ description: 'Название цели' })
  @IsString()
  title: string;

  @ApiProperty({ 
    description: 'Тип цели',
    enum: HealthGoalType
  })
  @IsEnum(HealthGoalType)
  goalType: HealthGoalType;

  @ApiProperty({ description: 'Целевое значение' })
  @IsNumber()
  targetValue: number;

  @ApiPropertyOptional({ description: 'Текущее значение', default: 0 })
  @IsOptional()
  @IsNumber()
  currentValue?: number;

  @ApiProperty({ 
    description: 'Приоритет цели',
    enum: HealthGoalPriority,
    default: HealthGoalPriority.MEDIUM
  })
  @IsEnum(HealthGoalPriority)
  priority: HealthGoalPriority;

  @ApiProperty({ 
    description: 'Частота отслеживания',
    enum: HealthGoalFrequency,
    default: HealthGoalFrequency.WEEKLY
  })
  @IsEnum(HealthGoalFrequency)
  frequency: HealthGoalFrequency;

  @ApiPropertyOptional({ description: 'Дата начала' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Целевая дата' })
  @IsOptional()
  @IsDateString()
  targetDate?: string;

  @ApiPropertyOptional({ description: 'ID типа измерения' })
  @IsOptional()
  @IsString()
  typeId?: string;

  @ApiPropertyOptional({ description: 'Заметки' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: 'Активная цель', default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateHealthGoalDto extends CreateHealthGoalDto {}

export class HealthGoalFilterDto {
  @ApiPropertyOptional({ description: 'Тип цели', enum: HealthGoalType })
  @IsOptional()
  @IsEnum(HealthGoalType)
  goalType?: HealthGoalType;

  @ApiPropertyOptional({ description: 'Приоритет', enum: HealthGoalPriority })
  @IsOptional()
  @IsEnum(HealthGoalPriority)
  priority?: HealthGoalPriority;

  @ApiPropertyOptional({ description: 'Частота', enum: HealthGoalFrequency })
  @IsOptional()
  @IsEnum(HealthGoalFrequency)
  frequency?: HealthGoalFrequency;

  @ApiPropertyOptional({ description: 'Только активные цели' })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

// Statistics DTOs
export class HealthStatsDto {
  @ApiProperty({ description: 'Начальная дата для статистики' })
  @IsString()
  startDate: string;

  @ApiProperty({ description: 'Конечная дата для статистики' })
  @IsString()
  endDate: string;

  @ApiPropertyOptional({ description: 'ID типа измерения' })
  @IsOptional()
  @IsString()
  typeId?: string;

  @ApiPropertyOptional({ description: 'Тип цели здоровья', enum: HealthGoalType })
  @IsOptional()
  @IsEnum(HealthGoalType)
  goalType?: HealthGoalType;
}

// Measurement Type DTOs
export class CreateMeasurementTypeDto {
  @ApiProperty({ description: 'Название типа измерения' })
  @IsString()
  name: string;

  @ApiProperty({ description: 'Короткое название' })
  @IsString()
  shortName: string;

  @ApiPropertyOptional({ description: 'Описание' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ 
    description: 'Категория',
    enum: MeasurementCategory
  })
  @IsEnum(MeasurementCategory)
  category: MeasurementCategory;

  @ApiProperty({ 
    description: 'Единица измерения',
    enum: MeasurementUnit
  })
  @IsEnum(MeasurementUnit)
  unit: MeasurementUnit;

  @ApiPropertyOptional({ description: 'Минимальное значение' })
  @IsOptional()
  @IsNumber()
  minValue?: number;

  @ApiPropertyOptional({ description: 'Максимальное значение' })
  @IsOptional()
  @IsNumber()
  maxValue?: number;

  @ApiPropertyOptional({ description: 'Значение по умолчанию' })
  @IsOptional()
  @IsNumber()
  defaultValue?: number;

  @ApiProperty({ description: 'Название иконки' })
  @IsString()
  iconName: string;

  @ApiPropertyOptional({ description: 'Обязательное поле', default: false })
  @IsOptional()
  @IsBoolean()
  isRequired?: boolean;

  @ApiPropertyOptional({ description: 'Разрешить десятичные', default: true })
  @IsOptional()
  @IsBoolean()
  allowsDecimal?: boolean;

  @ApiPropertyOptional({ description: 'Знаков после запятой', default: 1 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(5)
  decimalPlaces?: number;
}

export class UpdateMeasurementTypeDto extends CreateMeasurementTypeDto {}
