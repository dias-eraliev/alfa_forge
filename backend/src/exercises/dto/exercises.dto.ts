import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, IsNumber, IsDateString, IsBoolean, IsArray, Min, Max } from 'class-validator';

export enum ExerciseType {
  PUSHUPS = 'PUSHUPS',
  SQUATS = 'SQUATS',
  JUMPING_JACKS = 'JUMPING_JACKS',
  PLANKS = 'PLANKS',
  PULL_UPS = 'PULL_UPS',
  RUNNING = 'RUNNING',
  WALKING = 'WALKING',
  CYCLING = 'CYCLING',
  SWIMMING = 'SWIMMING',
  YOGA = 'YOGA',
  STRETCHING = 'STRETCHING',
  CARDIO = 'CARDIO',
  STRENGTH = 'STRENGTH',
  FLEXIBILITY = 'FLEXIBILITY'
}

export enum ExerciseCategory {
  GTO = 'GTO',
  CARDIO = 'CARDIO',
  STRENGTH = 'STRENGTH',
  FLEXIBILITY = 'FLEXIBILITY',
  BALANCE = 'BALANCE',
  ENDURANCE = 'ENDURANCE'
}

export enum DifficultyLevel {
  BEGINNER = 'BEGINNER',
  INTERMEDIATE = 'INTERMEDIATE',
  ADVANCED = 'ADVANCED',
  EXPERT = 'EXPERT'
}

export enum WorkoutStatus {
  PLANNED = 'PLANNED',
  IN_PROGRESS = 'IN_PROGRESS',
  COMPLETED = 'COMPLETED',
  PAUSED = 'PAUSED',
  CANCELLED = 'CANCELLED'
}

export enum GTOGrade {
  BRONZE = 'BRONZE',
  SILVER = 'SILVER',
  GOLD = 'GOLD'
}

// Exercise DTOs
export class CreateExerciseDto {
  @ApiProperty({ description: 'Название упражнения' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ description: 'Описание упражнения' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ 
    description: 'Тип упражнения',
    enum: ExerciseType
  })
  @IsEnum(ExerciseType)
  type: ExerciseType;

  @ApiProperty({ 
    description: 'Категория упражнения',
    enum: ExerciseCategory
  })
  @IsEnum(ExerciseCategory)
  category: ExerciseCategory;

  @ApiProperty({ 
    description: 'Уровень сложности',
    enum: DifficultyLevel,
    default: DifficultyLevel.BEGINNER
  })
  @IsEnum(DifficultyLevel)
  difficulty: DifficultyLevel;

  @ApiPropertyOptional({ description: 'Инструкции по выполнению' })
  @IsOptional()
  @IsString()
  instructions?: string;

  @ApiPropertyOptional({ description: 'Длительность в секундах' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  duration?: number;

  @ApiPropertyOptional({ description: 'Количество повторений' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  repetitions?: number;

  @ApiPropertyOptional({ description: 'Количество подходов' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  sets?: number;

  @ApiPropertyOptional({ description: 'Сожженные калории за минуту' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  caloriesPerMinute?: number;

  @ApiPropertyOptional({ description: 'Требуется оборудование' })
  @IsOptional()
  @IsBoolean()
  requiresEquipment?: boolean;

  @ApiPropertyOptional({ description: 'Список оборудования', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  equipment?: string[];

  @ApiPropertyOptional({ description: 'Работающие мышцы', type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  muscleGroups?: string[];

  @ApiPropertyOptional({ description: 'Путь к видео' })
  @IsOptional()
  @IsString()
  videoUrl?: string;

  @ApiPropertyOptional({ description: 'Путь к изображению' })
  @IsOptional()
  @IsString()
  imageUrl?: string;

  @ApiPropertyOptional({ description: 'Упражнение ГТО', default: false })
  @IsOptional()
  @IsBoolean()
  isGTO?: boolean;
}

export class UpdateExerciseDto extends CreateExerciseDto {}

export class ExerciseFilterDto {
  @ApiPropertyOptional({ description: 'Тип упражнения', enum: ExerciseType })
  @IsOptional()
  @IsEnum(ExerciseType)
  type?: ExerciseType;

  @ApiPropertyOptional({ description: 'Категория', enum: ExerciseCategory })
  @IsOptional()
  @IsEnum(ExerciseCategory)
  category?: ExerciseCategory;

  @ApiPropertyOptional({ description: 'Уровень сложности', enum: DifficultyLevel })
  @IsOptional()
  @IsEnum(DifficultyLevel)
  difficulty?: DifficultyLevel;

  @ApiPropertyOptional({ description: 'Только упражнения ГТО' })
  @IsOptional()
  @IsBoolean()
  isGTO?: boolean;

  @ApiPropertyOptional({ description: 'Требует оборудование' })
  @IsOptional()
  @IsBoolean()
  requiresEquipment?: boolean;

  @ApiPropertyOptional({ description: 'Поиск по названию' })
  @IsOptional()
  @IsString()
  search?: string;
}

// Workout Session DTOs
export class CreateWorkoutSessionDto {
  @ApiProperty({ description: 'Название тренировки' })
  @IsString()
  name: string;

  @ApiPropertyOptional({ description: 'Описание тренировки' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: 'Список упражнений с параметрами' })
  @IsArray()
  exercises: WorkoutExerciseDto[];

  @ApiPropertyOptional({ description: 'Запланированная дата' })
  @IsOptional()
  @IsDateString()
  scheduledDate?: string;

  @ApiPropertyOptional({ description: 'Заметки' })
  @IsOptional()
  @IsString()
  notes?: string;
}

export class WorkoutExerciseDto {
  @ApiProperty({ description: 'ID упражнения' })
  @IsString()
  exerciseId: string;

  @ApiPropertyOptional({ description: 'Количество повторений' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  repetitions?: number;

  @ApiPropertyOptional({ description: 'Количество подходов' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  sets?: number;

  @ApiPropertyOptional({ description: 'Длительность в секундах' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  duration?: number;

  @ApiPropertyOptional({ description: 'Вес в кг' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  weight?: number;

  @ApiPropertyOptional({ description: 'Дистанция в метрах' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  distance?: number;

  @ApiPropertyOptional({ description: 'Порядок в тренировке' })
  @IsOptional()
  @IsNumber()
  @Min(1)
  order?: number;
}

export class UpdateWorkoutSessionDto extends CreateWorkoutSessionDto {
  @ApiPropertyOptional({ 
    description: 'Статус тренировки',
    enum: WorkoutStatus
  })
  @IsOptional()
  @IsEnum(WorkoutStatus)
  status?: WorkoutStatus;

  @ApiPropertyOptional({ description: 'Время начала' })
  @IsOptional()
  @IsDateString()
  startedAt?: string;

  @ApiPropertyOptional({ description: 'Время окончания' })
  @IsOptional()
  @IsDateString()
  completedAt?: string;

  @ApiPropertyOptional({ description: 'Общая длительность в секундах' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  totalDuration?: number;

  @ApiPropertyOptional({ description: 'Сожженные калории' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  caloriesBurned?: number;
}

export class WorkoutFilterDto {
  @ApiPropertyOptional({ description: 'Статус тренировки', enum: WorkoutStatus })
  @IsOptional()
  @IsEnum(WorkoutStatus)
  status?: WorkoutStatus;

  @ApiPropertyOptional({ description: 'Дата начала периода' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Дата окончания периода' })
  @IsOptional()
  @IsDateString()
  endDate?: string;

  @ApiPropertyOptional({ description: 'ID упражнения' })
  @IsOptional()
  @IsString()
  exerciseId?: string;
}

// GTO Results DTOs
export class CreateGTOResultDto {
  @ApiProperty({ description: 'ID упражнения ГТО' })
  @IsString()
  exerciseId: string;

  @ApiProperty({ description: 'Результат' })
  @IsNumber()
  result: number;

  @ApiProperty({ description: 'Единица измерения (сек, раз, см, м)' })
  @IsString()
  unit: string;

  @ApiPropertyOptional({ description: 'Дата выполнения' })
  @IsOptional()
  @IsDateString()
  performedAt?: string;

  @ApiPropertyOptional({ description: 'Заметки' })
  @IsOptional()
  @IsString()
  notes?: string;

  @ApiPropertyOptional({ description: 'Является ли официальным результатом' })
  @IsOptional()
  @IsBoolean()
  isOfficial?: boolean;
}

export class UpdateGTOResultDto extends CreateGTOResultDto {
  @ApiPropertyOptional({ 
    description: 'Достигнутый значок',
    enum: GTOGrade
  })
  @IsOptional()
  @IsEnum(GTOGrade)
  achievedGrade?: GTOGrade;

  @ApiPropertyOptional({ description: 'Соответствует нормативу' })
  @IsOptional()
  @IsBoolean()
  meetsStandard?: boolean;
}

export class GTOFilterDto {
  @ApiPropertyOptional({ description: 'ID упражнения' })
  @IsOptional()
  @IsString()
  exerciseId?: string;

  @ApiPropertyOptional({ description: 'Достигнутый значок', enum: GTOGrade })
  @IsOptional()
  @IsEnum(GTOGrade)
  achievedGrade?: GTOGrade;

  @ApiPropertyOptional({ description: 'Только официальные результаты' })
  @IsOptional()
  @IsBoolean()
  isOfficial?: boolean;

  @ApiPropertyOptional({ description: 'Дата начала периода' })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ description: 'Дата окончания периода' })
  @IsOptional()
  @IsDateString()
  endDate?: string;
}

// Statistics DTOs
export class ExerciseStatsDto {
  @ApiProperty({ description: 'Начальная дата для статистики' })
  @IsString()
  startDate: string;

  @ApiProperty({ description: 'Конечная дата для статистики' })
  @IsString()
  endDate: string;

  @ApiPropertyOptional({ description: 'Тип упражнения', enum: ExerciseType })
  @IsOptional()
  @IsEnum(ExerciseType)
  exerciseType?: ExerciseType;

  @ApiPropertyOptional({ description: 'Категория', enum: ExerciseCategory })
  @IsOptional()
  @IsEnum(ExerciseCategory)
  category?: ExerciseCategory;
}
