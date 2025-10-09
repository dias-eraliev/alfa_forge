import { Controller, Get, Post, Body, Param, Query, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AuthGuard } from '@nestjs/passport';
import { BrotherhoodService } from './brotherhood.service';
import { CreatePostDto, CreateReplyDto, ToggleReactionDto } from './brotherhood.dto';

@ApiTags('brotherhood')
@ApiBearerAuth()
@UseGuards(AuthGuard('jwt'))
@Controller('brotherhood')
export class BrotherhoodController {
  constructor(private service: BrotherhoodService) {}

  @Get('feed')
  async getFeed(@Request() req: any) {
    return this.service.getFeed(req.user.id);
  }

  @Get('topics')
  @ApiQuery({ name: 'topic', required: true })
  async getTopic(@Request() req: any, @Query('topic') topic: string) {
    return this.service.getTopicFeed(req.user.id, topic);
  }

  @Get('mine')
  async getMine(@Request() req: any) {
    return this.service.getMyPosts(req.user.id);
  }

  @Post('posts')
  async createPost(@Request() req: any, @Body() dto: CreatePostDto) {
    return this.service.createPost(req.user.id, dto);
  }

  @Post('posts/:id/replies')
  async reply(@Request() req: any, @Param('id') id: string, @Body() dto: CreateReplyDto) {
    return this.service.replyToPost(req.user.id, id, dto);
  }

  @Post('posts/:id/reactions/toggle')
  async toggleReaction(@Request() req: any, @Param('id') id: string, @Body() dto: ToggleReactionDto) {
    return this.service.toggleReaction(req.user.id, id, dto);
  }
}
