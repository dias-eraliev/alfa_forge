import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { BrotherhoodController } from './brotherhood.controller';
import { BrotherhoodService } from './brotherhood.service';

@Module({
  imports: [PrismaModule],
  controllers: [BrotherhoodController],
  providers: [BrotherhoodService],
  exports: [BrotherhoodService],
})
export class BrotherhoodModule {}
