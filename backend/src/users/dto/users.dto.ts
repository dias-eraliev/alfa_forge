import { IsString, IsEmail, IsOptional, IsBoolean, IsEnum, IsDateString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export enum Theme {
  LIGHT = 'LIGHT',
  DARK = 'DARK',
  SYSTEM = 'SYSTEM',
}

export enum Language {
  RU = 'RU',
  EN = 'EN',
  KZ = 'KZ',
}

export enum Gender {
  MALE = 'MALE',
  FEMALE = 'FEMALE',
  OTHER = 'OTHER',
}

export class UpdateUserProfileDto {
  @ApiProperty({
    description: 'Полное имя пользователя',
    example: 'Иван Иванов',
    required: false
  })
  @IsOptional()
  @IsString({ message: 'Полное имя должно быть строкой' })
  fullName?: string;

  @ApiProperty({
    description: 'Номер телефона пользователя',
    example: '+7 (777) 123-45-67',
    required: false
  })
  @IsOptional()
  @IsString({ message: 'Телефон должен быть строкой' })
  phone?: string;

  @ApiProperty({
    description: 'Город проживания пользователя',
    example: 'Алматы',
    required: false
  })
  @IsOptional()
  @IsString({ message: 'Город должен быть строкой' })
  city?: string;

  @ApiProperty({
    description: 'URL аватара пользователя',
    example: 'https://example.com/avatar.jpg',
    required: false
  })
  @IsOptional()
  @IsString({ message: 'URL аватара должен быть строкой' })
  avatarUrl?: string;

  @ApiProperty({
    description: 'Дата рождения пользователя',
    example: '1990-01-15',
    format: 'date',
    required: false
  })
  @IsOptional()
  @IsDateString({}, { message: 'Неверный формат даты рождения' })
  birthDate?: string;

  @ApiProperty({
    description: 'Пол пользователя',
    enum: Gender,
    example: Gender.MALE,
    required: false
  })
  @IsOptional()
  @IsEnum(Gender, { message: 'Неверный пол' })
  gender?: Gender;
}

export class UpdateUserSettingsDto {
  @ApiProperty({
    description: 'Включены ли уведомления',
    example: true,
    required: false
  })
  @IsOptional()
  @IsBoolean({ message: 'Уведомления должны быть булевым значением' })
  notificationsEnabled?: boolean;

  @ApiProperty({
    description: 'Тема приложения',
    enum: Theme,
    example: Theme.DARK,
    required: false
  })
  @IsOptional()
  @IsEnum(Theme, { message: 'Неверная тема' })
  theme?: Theme;

  @ApiProperty({
    description: 'Язык приложения',
    enum: Language,
    example: Language.RU,
    required: false
  })
  @IsOptional()
  @IsEnum(Language, { message: 'Неверный язык' })
  language?: Language;
}

export class UploadAvatarDto {
  @ApiProperty({
    description: 'URL аватара пользователя',
    example: 'https://example.com/avatar.jpg'
  })
  @IsString({ message: 'URL аватара должен быть строкой' })
  avatarUrl: string;
}
