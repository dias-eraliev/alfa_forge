import { IsEmail, IsString, MinLength, MaxLength, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({
    description: 'Email пользователя',
    example: 'user@example.com',
    format: 'email'
  })
  @IsEmail({}, { message: 'Неверный формат email' })
  email: string;

  @ApiProperty({
    description: 'Уникальное имя пользователя',
    example: 'john_doe',
    minLength: 3,
    maxLength: 20
  })
  @IsString({ message: 'Username должен быть строкой' })
  @MinLength(3, { message: 'Username должен содержать минимум 3 символа' })
  @MaxLength(20, { message: 'Username должен содержать максимум 20 символов' })
  username: string;

  @ApiProperty({
    description: 'Пароль пользователя',
    example: 'mySecretPassword123',
    minLength: 6
  })
  @IsString({ message: 'Пароль должен быть строкой' })
  @MinLength(6, { message: 'Пароль должен содержать минимум 6 символов' })
  password: string;

  @ApiProperty({
    description: 'Полное имя пользователя',
    example: 'Иван Иванов',
    minLength: 2
  })
  @IsString({ message: 'Полное имя должно быть строкой' })
  @MinLength(2, { message: 'Полное имя должно содержать минимум 2 символа' })
  fullName: string;

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
}

export class LoginDto {
  @ApiProperty({
    description: 'Email пользователя',
    example: 'user@example.com',
    format: 'email'
  })
  @IsEmail({}, { message: 'Неверный формат email' })
  email: string;

  @ApiProperty({
    description: 'Пароль пользователя',
    example: 'mySecretPassword123'
  })
  @IsString({ message: 'Пароль должен быть строкой' })
  password: string;
}

export class RefreshTokenDto {
  @ApiProperty({
    description: 'Refresh токен для обновления access токена',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  })
  @IsString({ message: 'Refresh token должен быть строкой' })
  refreshToken: string;
}
