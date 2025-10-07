import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { DashboardService } from './dashboard.service';

@Controller('dashboard')
@UseGuards(AuthGuard('jwt'))
export class DashboardController {
  constructor(private dashboardService: DashboardService) {}

  @Get()
  async getDashboard(@Request() req: any) {
    return this.dashboardService.getDashboardData(req.user.id);
  }

  @Get('weekly-progress')
  async getWeeklyProgress(@Request() req: any) {
    return this.dashboardService.getWeeklyProgress(req.user.id);
  }

  @Get('sphere-progress')
  async getSphereProgress(@Request() req: any) {
    return this.dashboardService.getSphereProgress(req.user.id);
  }

  @Get('quote')
  async getQuote(@Request() req: any) {
    const userProgress = await this.dashboardService.getDashboardData(req.user.id);
    return this.dashboardService.getMotivationalQuote(userProgress.stats.progress.currentZone);
  }
}
