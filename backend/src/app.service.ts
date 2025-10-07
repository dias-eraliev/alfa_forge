import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma/prisma.service';

@Injectable()
export class AppService {
  constructor(private readonly prisma: PrismaService) { }
  getHello() {
    try {
      return this.prisma.user.findMany();
    } catch (error) {
      console.error('Error fetching users:', error);
      return 'Error fetching users';
    }
  }
}
