import { Controller, Get, Put, Body, UseGuards, Request, Post, Param } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from './users.service';
import { UpdateUserProfileDto, UpdateUserSettingsDto, UploadAvatarDto, SelectedHabitsDto } from './dto/users.dto';

@Controller('users')
@UseGuards(AuthGuard('jwt'))
export class UsersController {
  constructor(private usersService: UsersService) {}

  @Get('profile')
  async getProfile(@Request() req: any) {
    return this.usersService.findById(req.user.id);
  }

  @Put('profile')
  async updateProfile(@Request() req: any, @Body() updateProfileDto: UpdateUserProfileDto) {
    return this.usersService.updateProfile(req.user.id, updateProfileDto);
  }

  @Put('settings')
  async updateSettings(@Request() req: any, @Body() updateSettingsDto: UpdateUserSettingsDto) {
    return this.usersService.updateSettings(req.user.id, updateSettingsDto);
  }

  @Post('avatar')
  async uploadAvatar(@Request() req: any, @Body() uploadAvatarDto: UploadAvatarDto) {
    return this.usersService.uploadAvatar(req.user.id, uploadAvatarDto.avatarUrl);
  }

  @Post('complete-onboarding')
  async completeOnboarding(@Request() req: any) {
    return this.usersService.completeOnboarding(req.user.id);
  }

  @Post('habits/selected')
  async saveSelectedHabits(@Request() req: any, @Body() dto: SelectedHabitsDto) {
    return this.usersService.saveSelectedHabits(req.user.id, dto.habitIds);
  }

  @Get('stats')
  async getUserStats(@Request() req: any) {
    return this.usersService.getUserStats(req.user.id);
  }

  @Get(':id')
  async getUserById(@Param('id') id: string) {
    return this.usersService.findById(id);
  }
}
