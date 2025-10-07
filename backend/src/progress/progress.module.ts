import { Module } from '@nestjs/common';
import { ProgressController } from './progress.controller';
import { ProgressService } from './progress.service';
import { PrismaModule } from '../prisma/prisma.module';
import { HabitsModule } from '../habits/habits.module';
import { TasksModule } from '../tasks/tasks.module';
import { HealthModule } from '../health/health.module';
import { ExercisesModule } from '../exercises/exercises.module';

@Module({
  imports: [
    PrismaModule,
    HabitsModule,
    TasksModule,
    HealthModule,
    ExercisesModule,
  ],
  controllers: [ProgressController],
  providers: [ProgressService],
  exports: [ProgressService],
})
export class ProgressModule {}
