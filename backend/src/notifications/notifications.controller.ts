import { Controller, Get, Post, Put, Delete, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { 
  CreateNotificationDto, 
  UpdateNotificationDto, 
  NotificationFilterDto,
  CreateQuoteDto,
  UpdateQuoteDto,
  QuoteFilterDto,
  NotificationSettingsDto,
  BulkNotificationActionDto,
  SendNotificationDto,
  NotificationStatsDto,
  QuoteCategory
} from './dto/notifications.dto';
import { Post as HttpPost } from '@nestjs/common';

@ApiTags('notifications')
@Controller('notifications')
@UseGuards(AuthGuard('jwt'))
@ApiBearerAuth('JWT-auth')
export class NotificationsController {
  constructor(private notificationsService: NotificationsService) {}

  // ========== NOTIFICATIONS ==========

  @ApiOperation({ summary: 'Получить уведомления пользователя' })
  @ApiResponse({ status: 200, description: 'Список уведомлений' })
  @Get()
  async getUserNotifications(@Request() req: any, @Query() filters: NotificationFilterDto) {
    return this.notificationsService.getUserNotifications(req.user.id, filters);
  }

  @ApiOperation({ summary: 'Создать уведомление' })
  @ApiResponse({ status: 201, description: 'Уведомление создано' })
  @Post()
  async createNotification(@Body() createNotificationDto: CreateNotificationDto, @Request() req: any) {
    return this.notificationsService.createNotification(req.user.id, createNotificationDto);
  }

  @ApiOperation({ summary: 'Обновить уведомление' })
  @ApiResponse({ status: 200, description: 'Уведомление обновлено' })
  @ApiResponse({ status: 404, description: 'Уведомление не найдено' })
  @ApiResponse({ status: 403, description: 'Нет доступа к уведомлению' })
  @ApiParam({ name: 'id', description: 'ID уведомления' })
  @Put(':id')
  async updateNotification(
    @Param('id') id: string,
    @Body() updateNotificationDto: UpdateNotificationDto,
    @Request() req: any
  ) {
    return this.notificationsService.updateNotification(id, req.user.id, updateNotificationDto);
  }

  @ApiOperation({ summary: 'Удалить уведомление' })
  @ApiResponse({ status: 200, description: 'Уведомление удалено' })
  @ApiResponse({ status: 404, description: 'Уведомление не найдено' })
  @ApiResponse({ status: 403, description: 'Нет доступа к уведомлению' })
  @ApiParam({ name: 'id', description: 'ID уведомления' })
  @Delete(':id')
  async deleteNotification(@Param('id') id: string, @Request() req: any) {
    return this.notificationsService.deleteNotification(id, req.user.id);
  }

  @ApiOperation({ summary: 'Отметить уведомление как прочитанное' })
  @ApiResponse({ status: 200, description: 'Уведомление отмечено как прочитанное' })
  @ApiResponse({ status: 404, description: 'Уведомление не найдено' })
  @ApiResponse({ status: 403, description: 'Нет доступа к уведомлению' })
  @ApiParam({ name: 'id', description: 'ID уведомления' })
  @Post(':id/read')
  async markAsRead(@Param('id') id: string, @Request() req: any) {
    return this.notificationsService.markAsRead(id, req.user.id);
  }

  @ApiOperation({ summary: 'Отметить все уведомления как прочитанные' })
  @ApiResponse({ status: 200, description: 'Все уведомления отмечены как прочитанные' })
  @Post('mark-all-read')
  async markAllAsRead(@Request() req: any) {
    return this.notificationsService.markAllAsRead(req.user.id);
  }

  @ApiOperation({ summary: 'Массовые операции с уведомлениями' })
  @ApiResponse({ status: 200, description: 'Операция выполнена' })
  @Post('bulk-action')
  async bulkNotificationAction(@Body() bulkActionDto: BulkNotificationActionDto, @Request() req: any) {
    return this.notificationsService.bulkNotificationAction(req.user.id, bulkActionDto);
  }

  // ========== QUOTES ==========

  @ApiOperation({ summary: 'Получить цитаты' })
  @ApiResponse({ status: 200, description: 'Список цитат' })
  @Get('quotes')
  async getQuotes(@Query() filters: QuoteFilterDto) {
    return this.notificationsService.getQuotes(filters);
  }

  @ApiOperation({ summary: 'Получить случайную цитату' })
  @ApiResponse({ status: 200, description: 'Случайная цитата' })
  @Get('quotes/random')
  async getRandomQuote(@Query('category') category?: QuoteCategory) {
    return this.notificationsService.getRandomQuote(category);
  }

  @ApiOperation({ summary: 'Создать цитату (только админы)' })
  @ApiResponse({ status: 201, description: 'Цитата создана' })
  @Post('quotes')
  async createQuote(@Body() createQuoteDto: CreateQuoteDto) {
    return this.notificationsService.createQuote(createQuoteDto);
  }

  @ApiOperation({ summary: 'Обновить цитату (только админы)' })
  @ApiResponse({ status: 200, description: 'Цитата обновлена' })
  @ApiResponse({ status: 404, description: 'Цитата не найдена' })
  @ApiParam({ name: 'id', description: 'ID цитаты' })
  @Put('quotes/:id')
  async updateQuote(@Param('id') id: string, @Body() updateQuoteDto: UpdateQuoteDto) {
    return this.notificationsService.updateQuote(id, updateQuoteDto);
  }

  @ApiOperation({ summary: 'Удалить цитату (только админы)' })
  @ApiResponse({ status: 200, description: 'Цитата удалена' })
  @ApiResponse({ status: 404, description: 'Цитата не найдена' })
  @ApiParam({ name: 'id', description: 'ID цитаты' })
  @Delete('quotes/:id')
  async deleteQuote(@Param('id') id: string) {
    return this.notificationsService.deleteQuote(id);
  }

  // ========== SETTINGS ==========

  @ApiOperation({ summary: 'Получить настройки уведомлений' })
  @ApiResponse({ status: 200, description: 'Настройки уведомлений' })
  @Get('settings')
  async getNotificationSettings(@Request() req: any) {
    return this.notificationsService.getNotificationSettings(req.user.id);
  }

  @ApiOperation({ summary: 'Обновить настройки уведомлений' })
  @ApiResponse({ status: 200, description: 'Настройки обновлены' })
  @Put('settings')
  async updateNotificationSettings(@Body() settingsDto: NotificationSettingsDto, @Request() req: any) {
    return this.notificationsService.updateNotificationSettings(req.user.id, settingsDto);
  }

  // ========== STATISTICS ==========

  @ApiOperation({ summary: 'Получить статистику уведомлений' })
  @ApiResponse({ status: 200, description: 'Статистика уведомлений' })
  @Get('stats')
  async getNotificationStats(@Query() statsDto: NotificationStatsDto, @Request() req: any) {
    return this.notificationsService.getNotificationStats(req.user.id, statsDto);
  }

  // ========== ADMIN OPERATIONS ==========

  @ApiOperation({ summary: 'Отправить уведомление пользователям (только админы)' })
  @ApiResponse({ status: 200, description: 'Уведомление отправлено' })
  @Post('send')
  async sendNotification(@Body() sendNotificationDto: SendNotificationDto) {
    return this.notificationsService.sendNotification(sendNotificationDto);
  }

  // ========== TEST (E2E) ==========
  @ApiOperation({ summary: 'Тестовая отправка уведомления текущему пользователю' })
  @ApiResponse({ status: 200, description: 'Результат тестовой отправки' })
  @Post('test')
  async sendTest(@Request() req: any) {
    const payload: SendNotificationDto = {
      userIds: req.user.id,
      notification: {
        title: 'Test push',
        message: 'Hello from OneSignal!',
        type: undefined as any, // тип сейчас не используется при отправке
      } as any,
      immediate: true,
    };
    return this.notificationsService.sendNotification(payload);
  }

  // ========== DEVICE TOKEN REGISTRATION (OneSignal) ==========

  @ApiOperation({ summary: 'Зарегистрировать OneSignal playerId устройства' })
  @ApiResponse({ status: 200, description: 'Токен зарегистрирован' })
  @HttpPost('device/register')
  async registerDevice(@Request() req: any, @Body() body: { playerId: string; platform: string }) {
    return this.notificationsService.registerDevice(req.user.id, body.playerId, body.platform);
  }

  @ApiOperation({ summary: 'Отвязать OneSignal playerId устройства' })
  @ApiResponse({ status: 200, description: 'Токен удалён' })
  @HttpPost('device/unregister')
  async unregisterDevice(@Request() req: any, @Body() body: { playerId: string }) {
    return this.notificationsService.unregisterDevice(req.user.id, body.playerId);
  }
}
