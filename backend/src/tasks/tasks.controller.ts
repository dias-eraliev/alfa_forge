import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { TasksService } from './tasks.service';
import { CreateTaskDto, UpdateTaskDto, TaskStatsDto, TaskFilterDto } from './dto/tasks.dto';

@ApiTags('tasks')
@Controller('tasks')
@UseGuards(AuthGuard('jwt'))
@ApiBearerAuth('JWT-auth')
export class TasksController {
  constructor(private tasksService: TasksService) {}

  @ApiOperation({ summary: 'Получить все задачи пользователя' })
  @ApiResponse({ status: 200, description: 'Список задач пользователя' })
  @Get()
  async getUserTasks(@Request() req: any, @Query() filters: TaskFilterDto) {
    return this.tasksService.getUserTasks(req.user.id, filters);
  }

  @ApiOperation({ summary: 'Получить задачу по ID' })
  @ApiResponse({ status: 200, description: 'Задача найдена' })
  @ApiResponse({ status: 404, description: 'Задача не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к задаче' })
  @ApiParam({ name: 'id', description: 'ID задачи' })
  @Get(':id')
  async getTaskById(@Param('id') id: string, @Request() req: any) {
    return this.tasksService.getTaskById(id, req.user.id);
  }

  @ApiOperation({ summary: 'Создать новую задачу' })
  @ApiResponse({ status: 201, description: 'Задача успешно создана' })
  @Post()
  async createTask(@Body() createTaskDto: CreateTaskDto, @Request() req: any) {
    return this.tasksService.createTask(req.user.id, createTaskDto);
  }

  @ApiOperation({ summary: 'Обновить задачу' })
  @ApiResponse({ status: 200, description: 'Задача успешно обновлена' })
  @ApiResponse({ status: 404, description: 'Задача не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к задаче' })
  @ApiParam({ name: 'id', description: 'ID задачи' })
  @Put(':id')
  async updateTask(
    @Param('id') id: string,
    @Body() updateTaskDto: UpdateTaskDto,
    @Request() req: any
  ) {
    return this.tasksService.updateTask(id, req.user.id, updateTaskDto);
  }

  @ApiOperation({ summary: 'Удалить задачу' })
  @ApiResponse({ status: 200, description: 'Задача успешно удалена' })
  @ApiResponse({ status: 404, description: 'Задача не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к задаче' })
  @ApiParam({ name: 'id', description: 'ID задачи' })
  @Delete(':id')
  async deleteTask(@Param('id') id: string, @Request() req: any) {
    return this.tasksService.deleteTask(id, req.user.id);
  }

  @ApiOperation({ summary: 'Отметить задачу как выполненную' })
  @ApiResponse({ status: 200, description: 'Задача отмечена как выполненная' })
  @ApiResponse({ status: 404, description: 'Задача не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к задаче' })
  @ApiParam({ name: 'id', description: 'ID задачи' })
  @Post(':id/complete')
  async completeTask(@Param('id') id: string, @Request() req: any) {
    return this.tasksService.completeTask(id, req.user.id);
  }

  @ApiOperation({ summary: 'Отменить выполнение задачи' })
  @ApiResponse({ status: 200, description: 'Выполнение задачи отменено' })
  @ApiResponse({ status: 404, description: 'Задача не найдена' })
  @ApiResponse({ status: 403, description: 'Нет доступа к задаче' })
  @ApiParam({ name: 'id', description: 'ID задачи' })
  @Delete(':id/complete')
  async uncompleteTask(@Param('id') id: string, @Request() req: any) {
    return this.tasksService.uncompleteTask(id, req.user.id);
  }

  @ApiOperation({ summary: 'Получить задачи на сегодня' })
  @ApiResponse({ status: 200, description: 'Задачи на сегодня' })
  @Get('/today/list')
  async getTodayTasks(@Request() req: any) {
    return this.tasksService.getTodayTasks(req.user.id);
  }

  @ApiOperation({ summary: 'Получить просроченные задачи' })
  @ApiResponse({ status: 200, description: 'Просроченные задачи' })
  @Get('/overdue/list')
  async getOverdueTasks(@Request() req: any) {
    return this.tasksService.getOverdueTasks(req.user.id);
  }

  @ApiOperation({ summary: 'Получить задачи по привычке' })
  @ApiResponse({ status: 200, description: 'Задачи связанные с привычкой' })
  @ApiParam({ name: 'habitId', description: 'ID привычки' })
  @Get('/habit/:habitId')
  async getHabitTasks(@Param('habitId') habitId: string, @Request() req: any) {
    return this.tasksService.getHabitTasks(req.user.id, habitId);
  }

  @ApiOperation({ summary: 'Получить статистику задач' })
  @ApiResponse({ status: 200, description: 'Статистика задач' })
  @Get('/stats/overview')
  async getTaskStats(@Query() statsDto: TaskStatsDto, @Request() req: any) {
    return this.tasksService.getTaskStats(req.user.id, statsDto);
  }

  @ApiOperation({ summary: 'Получить предстоящие напоминания' })
  @ApiResponse({ status: 200, description: 'Задачи с напоминаниями на ближайший час' })
  @Get('/reminders/upcoming')
  async getUpcomingReminders(@Request() req: any) {
    return this.tasksService.getUpcomingReminders(req.user.id);
  }
}
