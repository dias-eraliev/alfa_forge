import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { ExercisesService } from './exercises.service';
import { 
  CreateExerciseDto, 
  UpdateExerciseDto, 
  ExerciseFilterDto,
  CreateWorkoutSessionDto,
  UpdateWorkoutSessionDto,
  WorkoutFilterDto,
  CreateGTOResultDto,
  UpdateGTOResultDto,
  GTOFilterDto,
  ExerciseStatsDto
} from './dto/exercises.dto';

@ApiTags('exercises')
@Controller('exercises')
@UseGuards(AuthGuard('jwt'))
@ApiBearerAuth('JWT-auth')
export class ExercisesController {
  constructor(private exercisesService: ExercisesService) {}

  // ========== EXERCISES ==========

  @ApiOperation({ summary: 'Получить все упражнения' })
  @ApiResponse({ status: 200, description: 'Список упражнений' })
  @Get()
  async getExercises(@Query() filters: ExerciseFilterDto) {
    return this.exercisesService.getExercises(filters);
  }

  @ApiOperation({ summary: 'Получить упражнение по ID' })
  @ApiResponse({ status: 200, description: 'Упражнение найдено' })
  @ApiResponse({ status: 404, description: 'Упражнение не найдено' })
  @ApiParam({ name: 'id', description: 'ID упражнения' })
  @Get(':id')
  async getExerciseById(@Param('id') id: string) {
    return this.exercisesService.getExerciseById(id);
  }

  @ApiOperation({ summary: 'Создать упражнение (только админы)' })
  @ApiResponse({ status: 201, description: 'Упражнение создано' })
  @Post()
  async createExercise(@Body() createExerciseDto: CreateExerciseDto) {
    return this.exercisesService.createExercise(createExerciseDto);
  }

  @ApiOperation({ summary: 'Обновить упражнение (только админы)' })
  @ApiResponse({ status: 200, description: 'Упражнение обновлено' })
  @ApiResponse({ status: 404, description: 'Упражнение не найдено' })
  @ApiParam({ name: 'id', description: 'ID упражнения' })
  @Put(':id')
  async updateExercise(@Param('id') id: string, @Body() updateExerciseDto: UpdateExerciseDto) {
    return this.exercisesService.updateExercise(id, updateExerciseDto);
  }

  @ApiOperation({ summary: 'Удалить упражнение (только админы)' })
  @ApiResponse({ status: 200, description: 'Упражнение удалено' })
  @ApiResponse({ status: 404, description: 'Упражнение не найдено' })
  @ApiParam({ name: 'id', description: 'ID упражнения' })
  @Delete(':id')
  async deleteExercise(@Param('id') id: string) {
    return this.exercisesService.deleteExercise(id);
  }

  @ApiOperation({ summary: 'Получить упражнения ГТО' })
  @ApiResponse({ status: 200, description: 'Упражнения ГТО' })
  @Get('gto/list')
  async getGTOExercises() {
    return this.exercisesService.getGTOExercises();
  }

  @ApiOperation({ summary: 'Получить рекомендованные упражнения' })
  @ApiResponse({ status: 200, description: 'Рекомендованные упражнения' })
  @Get('recommended/list')
  async getRecommendedExercises(@Request() req: any, @Query('category') category?: string) {
    return this.exercisesService.getRecommendedExercises(req.user.id, category);
  }

  // ========== WORKOUT SESSIONS ==========

  @ApiOperation({ summary: 'Получить тренировки пользователя' })
  @ApiResponse({ status: 200, description: 'Список тренировок' })
  @Get('workouts/my')
  async getUserWorkouts(@Request() req: any, @Query() filters: WorkoutFilterDto) {
    return this.exercisesService.getUserWorkouts(req.user.id, filters);
  }

  @ApiOperation({ summary: 'Получить тренировку по ID' })
  @ApiResponse({ status: 200, description: 'Тренировка найдена' })
  @ApiResponse({ status: 404, description: 'Тренировка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к тренировке' })
  @ApiParam({ name: 'id', description: 'ID тренировки' })
  @Get('workouts/:id')
  async getWorkoutById(@Param('id') id: string, @Request() req: any) {
    return this.exercisesService.getWorkoutById(id, req.user.id);
  }

  @ApiOperation({ summary: 'Создать тренировку' })
  @ApiResponse({ status: 201, description: 'Тренировка создана' })
  @Post('workouts')
  async createWorkout(@Body() createWorkoutDto: CreateWorkoutSessionDto, @Request() req: any) {
    return this.exercisesService.createWorkout(req.user.id, createWorkoutDto);
  }

  @ApiOperation({ summary: 'Обновить тренировку' })
  @ApiResponse({ status: 200, description: 'Тренировка обновлена' })
  @ApiResponse({ status: 404, description: 'Тренировка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к тренировке' })
  @ApiParam({ name: 'id', description: 'ID тренировки' })
  @Put('workouts/:id')
  async updateWorkout(
    @Param('id') id: string,
    @Body() updateWorkoutDto: UpdateWorkoutSessionDto,
    @Request() req: any
  ) {
    return this.exercisesService.updateWorkout(id, req.user.id, updateWorkoutDto);
  }

  @ApiOperation({ summary: 'Удалить тренировку' })
  @ApiResponse({ status: 200, description: 'Тренировка удалена' })
  @ApiResponse({ status: 404, description: 'Тренировка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к тренировке' })
  @ApiParam({ name: 'id', description: 'ID тренировки' })
  @Delete('workouts/:id')
  async deleteWorkout(@Param('id') id: string, @Request() req: any) {
    return this.exercisesService.deleteWorkout(id, req.user.id);
  }

  @ApiOperation({ summary: 'Начать тренировку' })
  @ApiResponse({ status: 200, description: 'Тренировка начата' })
  @ApiResponse({ status: 404, description: 'Тренировка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к тренировке' })
  @ApiParam({ name: 'id', description: 'ID тренировки' })
  @Post('workouts/:id/start')
  async startWorkout(@Param('id') id: string, @Request() req: any) {
    return this.exercisesService.startWorkout(id, req.user.id);
  }

  @ApiOperation({ summary: 'Завершить тренировку' })
  @ApiResponse({ status: 200, description: 'Тренировка завершена' })
  @ApiResponse({ status: 404, description: 'Тренировка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к тренировке' })
  @ApiParam({ name: 'id', description: 'ID тренировки' })
  @Post('workouts/:id/complete')
  async completeWorkout(
    @Param('id') id: string,
    @Body('caloriesBurned') caloriesBurned: number,
    @Request() req: any
  ) {
    return this.exercisesService.completeWorkout(id, req.user.id, caloriesBurned);
  }

  // ========== GTO RESULTS ==========

  @ApiOperation({ summary: 'Получить результаты ГТО пользователя' })
  @ApiResponse({ status: 200, description: 'Результаты ГТО' })
  @Get('gto/results')
  async getUserGTOResults(@Request() req: any, @Query() filters: GTOFilterDto) {
    return this.exercisesService.getUserGTOResults(req.user.id, filters);
  }

  @ApiOperation({ summary: 'Создать результат ГТО' })
  @ApiResponse({ status: 201, description: 'Результат ГТО создан' })
  @Post('gto/results')
  async createGTOResult(@Body() createGTOResultDto: CreateGTOResultDto, @Request() req: any) {
    return this.exercisesService.createGTOResult(req.user.id, createGTOResultDto);
  }

  @ApiOperation({ summary: 'Обновить результат ГТО' })
  @ApiResponse({ status: 200, description: 'Результат ГТО обновлен' })
  @ApiResponse({ status: 404, description: 'Результат не найден' })
  @ApiResponse({ status: 403, description: 'Нет доступа к результату' })
  @ApiParam({ name: 'id', description: 'ID результата ГТО' })
  @Put('gto/results/:id')
  async updateGTOResult(
    @Param('id') id: string,
    @Body() updateGTOResultDto: UpdateGTOResultDto,
    @Request() req: any
  ) {
    return this.exercisesService.updateGTOResult(id, req.user.id, updateGTOResultDto);
  }

  @ApiOperation({ summary: 'Удалить результат ГТО' })
  @ApiResponse({ status: 200, description: 'Результат ГТО удален' })
  @ApiResponse({ status: 404, description: 'Результат не найден' })
  @ApiResponse({ status: 403, description: 'Нет доступа к результату' })
  @ApiParam({ name: 'id', description: 'ID результата ГТО' })
  @Delete('gto/results/:id')
  async deleteGTOResult(@Param('id') id: string, @Request() req: any) {
    return this.exercisesService.deleteGTOResult(id, req.user.id);
  }

  // ========== STATISTICS ==========

  @ApiOperation({ summary: 'Получить статистику упражнений' })
  @ApiResponse({ status: 200, description: 'Статистика упражнений' })
  @Get('stats/overview')
  async getExerciseStats(@Query() statsDto: ExerciseStatsDto, @Request() req: any) {
    return this.exercisesService.getExerciseStats(req.user.id, statsDto);
  }

  @ApiOperation({ summary: 'Получить прогресс по упражнению' })
  @ApiResponse({ status: 200, description: 'Прогресс по упражнению' })
  @ApiParam({ name: 'exerciseId', description: 'ID упражнения' })
  @Get('progress/:exerciseId')
  async getExerciseProgress(
    @Param('exerciseId') exerciseId: string,
    @Query('days') days: number = 30,
    @Request() req: any
  ) {
    return this.exercisesService.getExerciseProgress(req.user.id, exerciseId, days);
  }
}
