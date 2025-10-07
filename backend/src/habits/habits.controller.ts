import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { HabitsService } from './habits.service';
import { CreateHabitDto, UpdateHabitDto, CompleteHabitDto, HabitStatsDto } from './dto/habits.dto';

@ApiTags('habits')
@Controller('habits')
@UseGuards(AuthGuard('jwt'))
@ApiBearerAuth('JWT-auth')
export class HabitsController {
  constructor(private habitsService: HabitsService) {}

  @ApiOperation({ summary: 'Получить все привычки пользователя' })
  @ApiResponse({ status: 200, description: 'Список привычек пользователя' })
  @Get()
  async getUserHabits(@Request() req: any) {
    return this.habitsService.getUserHabits(req.user.id);
  }

  @ApiOperation({ summary: 'Получить привычку по ID' })
  @ApiResponse({ status: 200, description: 'Привычка найдена' })
  @ApiResponse({ status: 404, description: 'Привычка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к привычке' })
  @ApiParam({ name: 'id', description: 'ID привычки' })
  @Get(':id')
  async getHabitById(@Param('id') id: string, @Request() req: any) {
    return this.habitsService.getHabitById(id, req.user.id);
  }

  @ApiOperation({ summary: 'Создать новую привычку' })
  @ApiResponse({ status: 201, description: 'Привычка успешно создана' })
  @ApiResponse({ status: 404, description: 'Категория или шаблон не найдены' })
  @Post()
  async createHabit(@Body() createHabitDto: CreateHabitDto, @Request() req: any) {
    return this.habitsService.createHabit(req.user.id, createHabitDto);
  }

  @ApiOperation({ summary: 'Обновить привычку' })
  @ApiResponse({ status: 200, description: 'Привычка успешно обновлена' })
  @ApiResponse({ status: 404, description: 'Привычка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к привычке' })
  @ApiParam({ name: 'id', description: 'ID привычки' })
  @Put(':id')
  async updateHabit(
    @Param('id') id: string,
    @Body() updateHabitDto: UpdateHabitDto,
    @Request() req: any
  ) {
    return this.habitsService.updateHabit(id, req.user.id, updateHabitDto);
  }

  @ApiOperation({ summary: 'Удалить привычку' })
  @ApiResponse({ status: 200, description: 'Привычка успешно удалена' })
  @ApiResponse({ status: 404, description: 'Привычка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к привычке' })
  @ApiParam({ name: 'id', description: 'ID привычки' })
  @Delete(':id')
  async deleteHabit(@Param('id') id: string, @Request() req: any) {
    return this.habitsService.deleteHabit(id, req.user.id);
  }

  @ApiOperation({ summary: 'Отметить выполнение привычки' })
  @ApiResponse({ status: 201, description: 'Выполнение привычки отмечено' })
  @ApiResponse({ status: 404, description: 'Привычка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к привычке' })
  @ApiParam({ name: 'id', description: 'ID привычки' })
  @Post(':id/complete')
  async completeHabit(
    @Param('id') id: string,
    @Body() completeHabitDto: CompleteHabitDto,
    @Request() req: any
  ) {
    return this.habitsService.completeHabit(id, req.user.id, completeHabitDto);
  }

  @ApiOperation({ summary: 'Отменить выполнение привычки' })
  @ApiResponse({ status: 200, description: 'Выполнение привычки отменено' })
  @ApiResponse({ status: 404, description: 'Привычка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к привычке' })
  @ApiParam({ name: 'id', description: 'ID привычки' })
  @ApiParam({ name: 'date', description: 'Дата в формате YYYY-MM-DD' })
  @Delete(':id/complete/:date')
  async uncompleteHabit(
    @Param('id') id: string,
    @Param('date') date: string,
    @Request() req: any
  ) {
    return this.habitsService.uncompleteHabit(id, req.user.id, date);
  }

  @ApiOperation({ summary: 'Получить статистику привычки' })
  @ApiResponse({ status: 200, description: 'Статистика привычки' })
  @ApiResponse({ status: 404, description: 'Привычка не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к привычке' })
  @ApiParam({ name: 'id', description: 'ID привычки' })
  @Get(':id/stats')
  async getHabitStats(
    @Param('id') id: string,
    @Query() statsDto: HabitStatsDto,
    @Request() req: any
  ) {
    return this.habitsService.getHabitStats(id, req.user.id, statsDto);
  }

  @ApiOperation({ summary: 'Получить все категории привычек' })
  @ApiResponse({ status: 200, description: 'Список категорий' })
  @Get('/categories/list')
  async getCategories() {
    return this.habitsService.getCategories();
  }

  @ApiOperation({ summary: 'Получить все шаблоны привычек' })
  @ApiResponse({ status: 200, description: 'Список шаблонов' })
  @ApiQuery({ name: 'categoryId', required: false, description: 'ID категории для фильтрации' })
  @Get('/templates/list')
  async getTemplates(@Query('categoryId') categoryId?: string) {
    return this.habitsService.getTemplates(categoryId);
  }
}
