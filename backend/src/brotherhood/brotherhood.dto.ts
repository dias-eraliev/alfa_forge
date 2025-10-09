import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, MaxLength, IsEnum } from 'class-validator';
import { ReactionType } from 'generated/prisma';

export class CreatePostDto {
  @ApiProperty({ description: 'Текст поста', maxLength: 240 })
  @IsString()
  @MaxLength(240)
  text: string;

  @ApiPropertyOptional({ description: 'Тема (например, Здоровье, Деньги)' })
  @IsOptional()
  @IsString()
  topic?: string;
}

export class CreateReplyDto {
  @ApiProperty({ description: 'Текст ответа', maxLength: 240 })
  @IsString()
  @MaxLength(240)
  text: string;
}

export class ToggleReactionDto {
  @ApiProperty({ description: 'Тип реакции', enum: ReactionType })
  @IsEnum(ReactionType)
  type: ReactionType;
}
