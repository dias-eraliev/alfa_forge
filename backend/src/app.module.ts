import { Module } from '@nestjs/common';
import { ServeStaticModule } from '@nestjs/serve-static';
import { join } from 'path';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { DashboardModule } from './dashboard/dashboard.module';
import { HabitsModule } from './habits/habits.module';
import { TasksModule } from './tasks/tasks.module';
import { HealthModule } from './health/health.module';
import { ExercisesModule } from './exercises/exercises.module';
import { ProgressModule } from './progress/progress.module';
import { NotificationsModule } from './notifications/notifications.module';
import { BrotherhoodModule } from './brotherhood/brotherhood.module';
import { AppSchedulerModule } from './scheduler/scheduler.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    // Раздача статического Flutter web билда (исключая /api*)
    ServeStaticModule.forRoot({
      rootPath: join(__dirname, '..', '..', '..', 'build', 'web'),
      serveRoot: '/',
      exclude: ['/api', '/api/:rest*'],
      serveStaticOptions: { index: 'index.html' },
    }),
    PrismaModule,
    AuthModule,
    UsersModule,
    DashboardModule,
    HabitsModule,
    TasksModule,
    HealthModule,
    ExercisesModule,
    ProgressModule,
    NotificationsModule,
    BrotherhoodModule,
    AppSchedulerModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
