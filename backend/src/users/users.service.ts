import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateUserProfileDto, UpdateUserSettingsDto } from './dto/users.dto';
import { TaskStatus } from 'generated/prisma';

@Injectable()
export class UsersService {
    constructor(private prisma: PrismaService) { }

    async findById(id: string) {
        const user = await this.prisma.user.findUnique({
            where: { id },
            include: {
                profile: true,
                settings: true,
                progress: true,
            },
        });

        if (!user) {
            throw new NotFoundException('Пользователь не найден');
        }

        // Исключаем пароль из ответа
        const { passwordHash, ...userWithoutPassword } = user;
        return userWithoutPassword;
    }

    async findByEmail(email: string) {
        return this.prisma.user.findUnique({
            where: { email },
            include: {
                profile: true,
                settings: true,
                progress: true,
            },
        });
    }

    async updateProfile(userId: string, updateProfileDto: UpdateUserProfileDto) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { profile: true },
        });

        if (!user) {
            throw new NotFoundException('Пользователь не найден');
        }

        const updatedProfile = await this.prisma.userProfile.update({
            where: { userId },
            data: updateProfileDto,
        });

        return updatedProfile;
    }

    async updateSettings(userId: string, updateSettingsDto: UpdateUserSettingsDto) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { settings: true },
        });

        if (!user) {
            throw new NotFoundException('Пользователь не найден');
        }

        const updatedSettings = await this.prisma.userSettings.update({
            where: { userId },
            data: updateSettingsDto,
        });

        return updatedSettings;
    }

    async uploadAvatar(userId: string, avatarUrl: string) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { profile: true },
        });

        if (!user) {
            throw new NotFoundException('Пользователь не найден');
        }

        const updatedProfile = await this.prisma.userProfile.update({
            where: { userId },
            data: { avatarUrl },
        });

        return updatedProfile;
    }

    async completeOnboarding(userId: string) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: { profile: true },
        });

        if (!user) {
            throw new NotFoundException('Пользователь не найден');
        }

        const updatedProfile = await this.prisma.userProfile.update({
            where: { userId },
            data: { onboardingCompleted: true },
        });

        return updatedProfile;
    }

    async getUserStats(userId: string) {
        const user = await this.prisma.user.findUnique({
            where: { id: userId },
            include: {
                habits: {
                    where: { isActive: true },
                    include: {
                        completions: {
                            where: {
                                date: {
                                    gte: new Date(new Date().setDate(new Date().getDate() - 30)),
                                },
                            },
                        },
                    },
                },
                tasks: {
                    where: {
                        status: 'DONE' as TaskStatus,
                        updatedAt: {
                            gte: new Date(new Date().setDate(new Date().getDate() - 30)),
                        },
                    },
                },
                workoutSessions: {
                    where: {
                        endTime: {
                            gte: new Date(new Date().setDate(new Date().getDate() - 30)),
                        },
                    },
                },
                progress: true,
            },
        });

        if (!user) {
            throw new NotFoundException('Пользователь не найден');
        }

        const totalHabits = user.habits.length;
        const completedHabitsToday = user.habits.filter(habit =>
            habit.completions.some(completion =>
                completion.date.toDateString() === new Date().toDateString()
            )
        ).length;

        const completedTasksLast30Days = user.tasks.length;
        const workoutSessionsLast30Days = user.workoutSessions.length;

        return {
            totalHabits,
            completedHabitsToday,
            completedTasksLast30Days,
            workoutSessionsLast30Days,
            progress: user.progress?.[0] || null,
        };
    }
}
