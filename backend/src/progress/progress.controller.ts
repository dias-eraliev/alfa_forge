import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { ProgressService } from './progress.service';
import { 
  CreateProgressEntryDto, 
  UpdateProgressEntryDto, 
  ProgressFilterDto,
  CreateGoalDto,
  UpdateGoalDto,
  GoalFilterDto,
  CreateAchievementDto,
  AchievementFilterDto,
  ProgressStatsDto,
  DashboardStatsDto
} from './dto/progress.dto';

@ApiTags('progress')
@Controller('progress')
@UseGuards(AuthGuard('jwt'))
@ApiBearerAuth('JWT-auth')
export class ProgressController {
  constructor(private progressService: ProgressService) {}

  // ========== PROGRESS TRACKING ==========

  @ApiOperation({ summary: 'Получить записи прогресса пользователя' })
  @ApiResponse({ status: 200, description: 'Записи прогресса' })
  @Get('entries')
  async getUserProgress(@Request() req: any, @Query() filters: ProgressFilterDto) {
    return this.progressService.getUserProgress(req.user.id, filters);
  }

  @ApiOperation({ summary: 'Создать запись прогресса' })
  @ApiResponse({ status: 201, description: 'Запись прогресса создана' })
  @Post('entries')
  async createProgressEntry(@Body() createProgressDto: CreateProgressEntryDto, @Request() req: any) {
    return this.progressService.createProgressEntry(req.user.id, createProgressDto);
  }

  @ApiOperation({ summary: 'Обновить запись прогресса' })
  @ApiResponse({ status: 200, description: 'Запись прогресса обновлена' })
  @ApiResponse({ status: 404, description: 'Запись не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к записи' })
  @ApiParam({ name: 'id', description: 'ID записи прогресса' })
  @Put('entries/:id')
  async updateProgressEntry(
    @Param('id') id: string,
    @Body() updateProgressDto: UpdateProgressEntryDto,
    @Request() req: any
  ) {
    return this.progressService.updateProgressEntry(id, req.user.id, updateProgressDto);
  }

  @ApiOperation({ summary: 'Удалить запись прогресса' })
  @ApiResponse({ status: 200, description: 'Запись прогресса удалена' })
  @ApiResponse({ status: 404, description: 'Запись не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к записи' })
  @ApiParam({ name: 'id', description: 'ID записи прогресса' })
  @Delete('entries/:id')
  async deleteProgressEntry(@Param('id') id: string, @Request() req: any) {
    return this.progressService.deleteProgressEntry(id, req.user.id);
  }

  // ========== GOALS MANAGEMENT ==========

  @ApiOperation({ summary: 'Получить цели пользователя' })
  @ApiResponse({ status: 200, description: 'Список целей' })
  @Get('goals')
  async getUserGoals(@Request() req: any, @Query() filters: GoalFilterDto) {
    return this.progressService.getUserGoals(req.user.id, filters);
  }

  @ApiOperation({ summary: 'Создать цель' })
  @ApiResponse({ status: 201, description: 'Цель создана' })
  @Post('goals')
  async createGoal(@Body() createGoalDto: CreateGoalDto, @Request() req: any) {
    return this.progressService.createGoal(req.user.id, createGoalDto);
  }

  @ApiOperation({ summary: 'Обновить цель' })
  @ApiResponse({ status: 200, description: 'Цель обновлена' })
  @ApiResponse({ status: 404, description: 'Цель не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к цели' })
  @ApiParam({ name: 'id', description: 'ID цели' })
  @Put('goals/:id')
  async updateGoal(
    @Param('id') id: string,
    @Body() updateGoalDto: UpdateGoalDto,
    @Request() req: any
  ) {
    return this.progressService.updateGoal(id, req.user.id, updateGoalDto);
  }

  @ApiOperation({ summary: 'Удалить цель' })
  @ApiResponse({ status: 200, description: 'Цель удалена' })
  @ApiResponse({ status: 404, description: 'Цель не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к цели' })
  @ApiParam({ name: 'id', description: 'ID цели' })
  @Delete('goals/:id')
  async deleteGoal(@Param('id') id: string, @Request() req: any) {
    return this.progressService.deleteGoal(id, req.user.id);
  }

  // ========== ACHIEVEMENTS ==========

  @ApiOperation({ summary: 'Получить достижения пользователя' })
  @ApiResponse({ status: 200, description: 'Список достижений' })
  @Get('achievements')
  async getUserAchievements(@Request() req: any, @Query() filters: AchievementFilterDto) {
    return this.progressService.getUserAchievements(req.user.id, filters);
  }

  @ApiOperation({ summary: 'Создать достижение (только админы)' })
  @ApiResponse({ status: 201, description: 'Достижение создано' })
  @Post('achievements')
  async createAchievement(@Body() createAchievementDto: CreateAchievementDto) {
    return this.progressService.createAchievement(createAchievementDto);
  }

  @ApiOperation({ summary: 'Присвоить достижение пользователю' })
  @ApiResponse({ status: 200, description: 'Достижение присвоено' })
  @ApiResponse({ status: 404, description: 'Достижение не найдено' })
  @ApiParam({ name: 'achievementId', description: 'ID достижения' })
  @Post('achievements/:achievementId/grant')
  async grantAchievement(@Param('achievementId') achievementId: string, @Request() req: any) {
    return this.progressService.grantAchievement(req.user.id, achievementId);
  }

  // ========== STATISTICS ==========

  @ApiOperation({ summary: 'Получить статистику прогресса' })
  @ApiResponse({ status: 200, description: 'Статистика прогресса' })
  @Get('stats')
  async getProgressStats(@Query() statsDto: ProgressStatsDto, @Request() req: any) {
    return this.progressService.getProgressStats(req.user.id, statsDto);
  }

  @ApiOperation({ summary: 'Получить данные дашборда' })
  @ApiResponse({ status: 200, description: 'Данные дашборда' })
  @Get('dashboard')
  async getDashboardStats(@Query() dashboardDto: DashboardStatsDto, @Request() req: any) {
    return this.progressService.getDashboardStats(req.user.id, dashboardDto);
  }
}
