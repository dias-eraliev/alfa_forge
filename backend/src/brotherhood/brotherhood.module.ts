import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { BrotherhoodController } from './brotherhood.controller';
import { BrotherhoodService } from './brotherhood.service';

@Module({
  imports: [PrismaModule, NotificationsModule],
  controllers: [BrotherhoodController],
  providers: [BrotherhoodService],
  exports: [BrotherhoodService],
})
export class BrotherhoodModule {}
