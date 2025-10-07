import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { HealthService } from './health.service';
import { 
  CreateMeasurementDto, 
  UpdateMeasurementDto, 
  MeasurementFilterDto,
  CreateHealthGoalDto,
  UpdateHealthGoalDto,
  HealthGoalFilterDto,
  HealthStatsDto,
  CreateMeasurementTypeDto,
  UpdateMeasurementTypeDto
} from './dto/health.dto';

@ApiTags('health')
@Controller('health')
@UseGuards(AuthGuard('jwt'))
@ApiBearerAuth('JWT-auth')
export class HealthController {
  constructor(private healthService: HealthService) {}

  // ========== BODY MEASUREMENTS ==========

  @ApiOperation({ summary: 'Получить все измерения пользователя' })
  @ApiResponse({ status: 200, description: 'Список измерений' })
  @Get('measurements')
  async getUserMeasurements(@Request() req: any, @Query() filters: MeasurementFilterDto) {
    return this.healthService.getUserMeasurements(req.user.id, filters);
  }

  @ApiOperation({ summary: 'Получить измерение по ID' })
  @ApiResponse({ status: 200, description: 'Измерение найдено' })
  @ApiResponse({ status: 404, description: 'Измерение не найдено' })
  @ApiResponse({ status: 403, description: 'Нет доступа к измерению' })
  @ApiParam({ name: 'id', description: 'ID измерения' })
  @Get('measurements/:id')
  async getMeasurementById(@Param('id') id: string, @Request() req: any) {
    return this.healthService.getMeasurementById(id, req.user.id);
  }

  @ApiOperation({ summary: 'Создать новое измерение' })
  @ApiResponse({ status: 201, description: 'Измерение успешно создано' })
  @Post('measurements')
  async createMeasurement(@Body() createMeasurementDto: CreateMeasurementDto, @Request() req: any) {
    return this.healthService.createMeasurement(req.user.id, createMeasurementDto);
  }

  @ApiOperation({ summary: 'Обновить измерение' })
  @ApiResponse({ status: 200, description: 'Измерение успешно обновлено' })
  @ApiResponse({ status: 404, description: 'Измерение не найдено' })
  @ApiResponse({ status: 403, description: 'Нет доступа к измерению' })
  @ApiParam({ name: 'id', description: 'ID измерения' })
  @Put('measurements/:id')
  async updateMeasurement(
    @Param('id') id: string,
    @Body() updateMeasurementDto: UpdateMeasurementDto,
    @Request() req: any
  ) {
    return this.healthService.updateMeasurement(id, req.user.id, updateMeasurementDto);
  }

  @ApiOperation({ summary: 'Удалить измерение' })
  @ApiResponse({ status: 200, description: 'Измерение успешно удалено' })
  @ApiResponse({ status: 404, description: 'Измерение не найдено' })
  @ApiResponse({ status: 403, description: 'Нет доступа к измерению' })
  @ApiParam({ name: 'id', description: 'ID измерения' })
  @Delete('measurements/:id')
  async deleteMeasurement(@Param('id') id: string, @Request() req: any) {
    return this.healthService.deleteMeasurement(id, req.user.id);
  }

  @ApiOperation({ summary: 'Получить последние измерения по типам' })
  @ApiResponse({ status: 200, description: 'Последние измерения' })
  @Get('measurements/latest/all')
  async getLatestMeasurements(@Request() req: any) {
    return this.healthService.getLatestMeasurements(req.user.id);
  }

  @ApiOperation({ summary: 'Получить историю измерений по типу' })
  @ApiResponse({ status: 200, description: 'История измерений' })
  @ApiParam({ name: 'typeId', description: 'ID типа измерения' })
  @Get('measurements/history/:typeId')
  async getMeasurementHistory(
    @Param('typeId') typeId: string, 
    @Query('days') days: number = 30,
    @Request() req: any
  ) {
    return this.healthService.getMeasurementHistory(req.user.id, typeId, days);
  }

  // ========== HEALTH GOALS ==========

  @ApiOperation({ summary: 'Получить все цели здоровья пользователя' })
  @ApiResponse({ status: 200, description: 'Список целей здоровья' })
  @Get('goals')
  async getUserHealthGoals(@Request() req: any, @Query() filters: HealthGoalFilterDto) {
    return this.healthService.getUserHealthGoals(req.user.id, filters);
  }

  @ApiOperation({ summary: 'Получить цель здоровья по ID' })
  @ApiResponse({ status: 200, description: 'Цель найдена' })
  @ApiResponse({ status: 404, description: 'Цель не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к цели' })
  @ApiParam({ name: 'id', description: 'ID цели' })
  @Get('goals/:id')
  async getHealthGoalById(@Param('id') id: string, @Request() req: any) {
    return this.healthService.getHealthGoalById(id, req.user.id);
  }

  @ApiOperation({ summary: 'Создать новую цель здоровья' })
  @ApiResponse({ status: 201, description: 'Цель успешно создана' })
  @Post('goals')
  async createHealthGoal(@Body() createHealthGoalDto: CreateHealthGoalDto, @Request() req: any) {
    return this.healthService.createHealthGoal(req.user.id, createHealthGoalDto);
  }

  @ApiOperation({ summary: 'Обновить цель здоровья' })
  @ApiResponse({ status: 200, description: 'Цель успешно обновлена' })
  @ApiResponse({ status: 404, description: 'Цель не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к цели' })
  @ApiParam({ name: 'id', description: 'ID цели' })
  @Put('goals/:id')
  async updateHealthGoal(
    @Param('id') id: string,
    @Body() updateHealthGoalDto: UpdateHealthGoalDto,
    @Request() req: any
  ) {
    return this.healthService.updateHealthGoal(id, req.user.id, updateHealthGoalDto);
  }

  @ApiOperation({ summary: 'Удалить цель здоровья' })
  @ApiResponse({ status: 200, description: 'Цель успешно удалена' })
  @ApiResponse({ status: 404, description: 'Цель не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к цели' })
  @ApiParam({ name: 'id', description: 'ID цели' })
  @Delete('goals/:id')
  async deleteHealthGoal(@Param('id') id: string, @Request() req: any) {
    return this.healthService.deleteHealthGoal(id, req.user.id);
  }

  @ApiOperation({ summary: 'Обновить прогресс цели' })
  @ApiResponse({ status: 200, description: 'Прогресс обновлен' })
  @ApiResponse({ status: 404, description: 'Цель не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к цели' })
  @ApiParam({ name: 'id', description: 'ID цели' })
  @Put('goals/:id/progress')
  async updateGoalProgress(
    @Param('id') id: string,
    @Body('currentValue') currentValue: number,
    @Request() req: any
  ) {
    return this.healthService.updateGoalProgress(id, req.user.id, currentValue);
  }

  // ========== MEASUREMENT TYPES ==========

  @ApiOperation({ summary: 'Получить все типы измерений' })
  @ApiResponse({ status: 200, description: 'Список типов измерений' })
  @Get('measurement-types')
  async getMeasurementTypes() {
    return this.healthService.getMeasurementTypes();
  }

  @ApiOperation({ summary: 'Получить типы измерений по категории' })
  @ApiResponse({ status: 200, description: 'Типы измерений категории' })
  @ApiParam({ name: 'category', description: 'Категория измерений' })
  @Get('measurement-types/category/:category')
  async getMeasurementTypesByCategory(@Param('category') category: string) {
    return this.healthService.getMeasurementTypesByCategory(category);
  }

  @ApiOperation({ summary: 'Создать тип измерения (только админы)' })
  @ApiResponse({ status: 201, description: 'Тип измерения создан' })
  @Post('measurement-types')
  async createMeasurementType(@Body() createMeasurementTypeDto: CreateMeasurementTypeDto) {
    return this.healthService.createMeasurementType(createMeasurementTypeDto);
  }

  @ApiOperation({ summary: 'Обновить тип измерения (только админы)' })
  @ApiResponse({ status: 200, description: 'Тип измерения обновлен' })
  @ApiResponse({ status: 404, description: 'Тип измерения не найден' })
  @ApiParam({ name: 'id', description: 'ID типа измерения' })
  @Put('measurement-types/:id')
  async updateMeasurementType(
    @Param('id') id: string,
    @Body() updateMeasurementTypeDto: UpdateMeasurementTypeDto
  ) {
    return this.healthService.updateMeasurementType(id, updateMeasurementTypeDto);
  }

  // ========== STATISTICS ==========

  @ApiOperation({ summary: 'Получить статистику здоровья' })
  @ApiResponse({ status: 200, description: 'Статистика здоровья' })
  @Get('stats')
  async getHealthStats(@Query() statsDto: HealthStatsDto, @Request() req: any) {
    return this.healthService.getHealthStats(req.user.id, statsDto);
  }

  @ApiOperation({ summary: 'Получить достижения в области здоровья' })
  @ApiResponse({ status: 200, description: 'Достижения в области здоровья' })
  @Get('achievements')
  async getHealthAchievements(@Request() req: any) {
    return this.healthService.getHealthAchievements(req.user.id);
  }
}
