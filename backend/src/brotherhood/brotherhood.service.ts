import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePostDto, CreateReplyDto, ToggleReactionDto } from './brotherhood.dto';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class BrotherhoodService {
  constructor(private prisma: PrismaService, private notifications: NotificationsService) {}

  async getFeed(userId: string) {
    // Простая лента: последние посты, с агрегацией реакций и первыми 2 ответами
    const posts = await this.prisma.brotherhoodPost.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, profile: true, username: true } },
        replies: {
          orderBy: { createdAt: 'desc' },
          take: 2,
          include: { user: { select: { id: true, profile: true, username: true } } },
        },
        reactions: true,
      },
      take: 100,
    });

    return posts.map(p => ({
      id: p.id,
      author: p.user.profile?.fullName || p.user.username,
  authorInitials: (p.user.profile?.fullName || p.user.username).split(' ').map((s: string) => s[0]).slice(0,2).join(''),
      time: p.createdAt,
      text: p.text,
      topic: p.topic,
      fireReactions: p.reactions.filter(r => r.type === 'FIRE').length,
      thumbsUpReactions: p.reactions.filter(r => r.type === 'THUMBS_UP').length,
      userReactions: {
        fire: p.reactions.some(r => r.userId === userId && r.type === 'FIRE'),
        thumbs: p.reactions.some(r => r.userId === userId && r.type === 'THUMBS_UP'),
      },
      replies: p.replies.map(r => ({
        author: r.user.profile?.fullName || r.user.username,
  authorInitials: (r.user.profile?.fullName || r.user.username).split(' ').map((s: string) => s[0]).slice(0,2).join(''),
        time: r.createdAt,
        text: r.text,
      }))
    }));
  }

  async getTopicFeed(userId: string, topic: string) {
    const posts = await this.prisma.brotherhoodPost.findMany({
      where: { topic },
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, profile: true, username: true } },
        replies: {
          orderBy: { createdAt: 'desc' },
          take: 2,
          include: { user: { select: { id: true, profile: true, username: true } } },
        },
        reactions: true,
      },
      take: 100,
    });
    return this.mapPosts(posts, userId);
  }

  async getMyPosts(userId: string) {
    const posts = await this.prisma.brotherhoodPost.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, profile: true, username: true } },
        replies: {
          orderBy: { createdAt: 'desc' },
          take: 2,
          include: { user: { select: { id: true, profile: true, username: true } } },
        },
        reactions: true,
      },
    });
    return this.mapPosts(posts, userId);
  }

  private mapPosts(posts: any[], userId: string) {
    return posts.map(p => ({
      id: p.id,
      author: p.user.profile?.fullName || p.user.username,
      authorInitials: (p.user.profile?.fullName || p.user.username).split(' ').map((s: string) => s[0]).slice(0,2).join(''),
      time: p.createdAt,
      text: p.text,
      topic: p.topic,
      fireReactions: p.reactions.filter((r: any) => r.type === 'FIRE').length,
      thumbsUpReactions: p.reactions.filter((r: any) => r.type === 'THUMBS_UP').length,
      userReactions: {
        fire: p.reactions.some((r: any) => r.userId === userId && r.type === 'FIRE'),
        thumbs: p.reactions.some((r: any) => r.userId === userId && r.type === 'THUMBS_UP'),
      },
      replies: p.replies.map((r: any) => ({
        author: r.user.profile?.fullName || r.user.username,
        authorInitials: (r.user.profile?.fullName || r.user.username).split(' ').map((s: string) => s[0]).slice(0,2).join(''),
        time: r.createdAt,
        text: r.text,
      }))
    }));
  }

  async createPost(userId: string, dto: CreatePostDto) {
    const post = await this.prisma.brotherhoodPost.create({
      data: {
        userId,
        text: dto.text,
        topic: dto.topic,
      },
    });
    return post;
  }

  async replyToPost(userId: string, postId: string, dto: CreateReplyDto) {
    // ensure post exists
    const post = await this.prisma.brotherhoodPost.findUnique({ where: { id: postId } });
    if (!post) throw new NotFoundException('Пост не найден');

    const reply = await this.prisma.brotherhoodReply.create({
      data: {
        postId,
        userId,
        text: dto.text,
      },
      include: { user: true },
    });

    // Notify post author (skip self-notify)
    try {
      await this.notifications.notifyBrotherhoodReply(post.userId, userId, dto.text, postId);
  } catch {
      // не падаем из-за уведомлений
    }
    return reply;
  }

  async toggleReaction(userId: string, postId: string, dto: ToggleReactionDto) {
    const existing = await this.prisma.brotherhoodReaction.findUnique({
      where: { post_user_type_unique: { postId, userId, type: dto.type } },
    });

    if (existing) {
      await this.prisma.brotherhoodReaction.delete({ where: { id: existing.id } });
      return { removed: true };
    }

    await this.prisma.brotherhoodReaction.create({
      data: { postId, userId, type: dto.type },
    });

    // Notify post author about reaction
    try {
      const post = await this.prisma.brotherhoodPost.findUnique({ where: { id: postId }, select: { userId: true } });
      if (post) {
        await this.notifications.notifyBrotherhoodReaction(post.userId, userId, dto.type, postId);
      }
  } catch {
      // глушим ошибки нотификаций
    }
    return { removed: false };
  }
}
