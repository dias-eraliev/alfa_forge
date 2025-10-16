import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Все API маршруты будут начинаться с /api
  app.setGlobalPrefix('api');

  // Глобальная валидация
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    forbidNonWhitelisted: true,
    transform: true,
  }));

  // CORS для фронтенда
  app.enableCors({
    origin: "*",
    credentials: true,
  });

  // Swagger документация
  const config = new DocumentBuilder()
    .setTitle('AlFA Forge API')
    .setDescription('API для приложения личного развития AlFA Forge')
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT token',
        in: 'header',
      },
      'JWT-auth',
    )
    .addTag('auth', 'Аутентификация и авторизация')
    .addTag('users', 'Управление пользователями')
    .addTag('dashboard', 'Главная страница и аналитика')
    .addTag('habits', 'Управление привычками')
    .addTag('tasks', 'Управление задачами')
    .addTag('body', 'Измерения тела и здоровье')
    .addTag('gto', 'Упражнения и тренировки')
    .addTag('notifications', 'Уведомления и настройки')
    .build();

  const documentFactory = () => SwaggerModule.createDocument(app, config);
  // Путь к Swagger будет /api/docs благодаря глобальному префиксу
  SwaggerModule.setup('docs', app, documentFactory, {
    swaggerOptions: {
      persistAuthorization: true,
    },
  });

  // SPA fallback: отдаём index.html только для HTML-навигации, НЕ для статических файлов
  const server = (app as any).getHttpAdapter().getInstance();
  // В Express 5 нельзя использовать строковый путь '*', используем регэксп /.*/
  server.get(/.*/, (req: any, res: any, next: any) => {
    const url: string = req.originalUrl || req.url || '';
    const accept: string = req.headers?.accept || '';

    // 1) Пропускаем API
    if (url.startsWith('/api')) return next();

    // 2) Пропускаем явные статические пути
    const isAsset =
      url.startsWith('/assets/') ||
      url.startsWith('/canvaskit/') ||
      url.startsWith('/icons/') ||
      url === '/flutter.js' ||
      url === '/flutter_bootstrap.js' ||
      url === '/main.dart.js' ||
      url === '/manifest.json' ||
      url.startsWith('/favicon') ||
      url === '/version.json' ||
      url === '/OneSignalSDKWorker.js' ||
      url === '/OneSignalSDKUpdaterWorker.js' ||
      url === '/app_config.js' ||
      url === '/onesignal_web.js';
    if (isAsset) return next();

    // 3) Отдаём index.html только для навигации браузера (Accept содержит text/html)
    if (!accept.includes('text/html')) return next();

    const indexPath = join(__dirname, '..', '..', '..', 'build', 'web', 'index.html');
    return res.sendFile(indexPath);
  });

  const port = process.env.PORT || 3000;
  await app.listen(port);
  
  console.log(`🚀 Application is running on: http://localhost:${port}`);
  console.log(`📖 Swagger docs available at: http://localhost:${port}/api/docs`);
}

void bootstrap();
