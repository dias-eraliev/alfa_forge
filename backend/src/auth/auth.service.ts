import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import * as bcrypt from 'bcrypt';
import { RegisterDto, LoginDto } from './dto/auth.dto';
import { JwtPayload } from './interfaces/jwt-payload.interface';

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const { email, username, password, fullName, phone, city } = registerDto;
    
    // Проверяем, не существует ли уже пользователь
    const existingUser = await this.prisma.user.findFirst({
      where: {
        OR: [{ email }, { username }],
      },
    });

    if (existingUser) {
      throw new ConflictException('Пользователь с таким email или username уже существует');
    }

    // Хешируем пароль
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Создаем пользователя с профилем, настройками и прогрессом
    const user = await this.prisma.user.create({
      data: {
        email,
        username,
        passwordHash: hashedPassword,
        profile: {
          create: {
            fullName,
            phone,
            city,
          },
        },
        settings: {
          create: {
            notificationsEnabled: true,
            theme: 'DARK',
            language: 'RU',
          },
        },
        progress: {
          create: {
            totalSteps: 0,
            totalXP: 0,
            currentStreak: 0,
            longestStreak: 0,
            currentZone: 'WILL',
            currentRank: 'NOVICE',
            sphereProgress: {
              body: 0,
              will: 0,
              focus: 0,
              mind: 0,
              peace: 0,
              money: 0,
            },
            totalStats: {
              habits_completed: 0,
              tasks_completed: 0,
              workouts_completed: 0,
            },
          },
        },
      },
      include: {
        profile: true,
        settings: true,
        progress: true,
      },
    });

    // Генерируем токены
    const payload: JwtPayload = { userId: user.id, username: user.username };
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });

    // Убираем пароль из ответа
    const { passwordHash, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      tokens: {
        access: accessToken,
        refresh: refreshToken,
      },
    };
  }

  async login(loginDto: LoginDto) {
    const { email, password } = loginDto;

    // Находим пользователя
    const user = await this.prisma.user.findUnique({
      where: { email },
      include: {
        profile: true,
        settings: true,
        progress: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Неверный email или пароль');
    }

    // Проверяем пароль
    const isPasswordValid = await bcrypt.compare(password, user.passwordHash);
    if (!isPasswordValid) {
      throw new UnauthorizedException('Неверный email или пароль');
    }

    // Генерируем токены
    const payload: JwtPayload = { userId: user.id, username: user.username };
    const accessToken = this.jwtService.sign(payload);
    const refreshToken = this.jwtService.sign(payload, { expiresIn: '7d' });

    // Убираем пароль из ответа
    const { passwordHash, ...userWithoutPassword } = user;

    return {
      user: userWithoutPassword,
      tokens: {
        access: accessToken,
        refresh: refreshToken,
      },
    };
  }

  async refreshToken(refreshToken: string) {
    try {
      const payload = this.jwtService.verify(refreshToken);
      const user = await this.prisma.user.findUnique({
        where: { id: payload.userId },
        include: {
          profile: true,
          settings: true,
          progress: true,
        },
      });

      if (!user) {
        throw new UnauthorizedException('Пользователь не найден');
      }

      // Генерируем новые токены
      const newPayload: JwtPayload = { userId: user.id, username: user.username };
      const newAccessToken = this.jwtService.sign(newPayload);
      const newRefreshToken = this.jwtService.sign(newPayload, { expiresIn: '7d' });

      return {
        tokens: {
          access: newAccessToken,
          refresh: newRefreshToken,
        },
      };
    } catch (error) {
      throw new UnauthorizedException('Недействительный refresh token');
    }
  }

  async validateUser(payload: JwtPayload) {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.userId },
      include: {
        profile: true,
        settings: true,
        progress: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Пользователь не найден');
    }

    const { passwordHash, ...userWithoutPassword } = user;
    return userWithoutPassword;
  }

  async logout() {
    // В реальном приложении здесь можно добавить логику
    // для занесения токена в черный список
    return { message: 'Выход выполнен успешно' };
  }
}
