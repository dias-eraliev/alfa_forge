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
    // Уберём поле с паролем из ответа
    const userWithoutPassword: any = { ...user } as any;
    delete userWithoutPassword.passwordHash;
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

        /**
         * Сохранить выбранные в онбординге привычки.
         * Принимает IDs предустановленных привычек (frontend: early_rise, reading, workout, meditation)
         * и создает реальные Habit записи пользователю, избегая дублей по имени.
         */
        async saveSelectedHabits(userId: string, habitIds: string[]) {
            // Карта предустановленных привычек (соответствие ID → параметры Habit)
            const presetMap: Record<string, {
                name: string;
                description?: string;
                iconName: string;
                colorHex: string;
                categoryId: string;
            }> = {
                early_rise: {
                    name: 'Ранний подъём',
                    description: 'Просыпаться в 6:00',
                    iconName: 'wb_sunny',
                    colorHex: '#FFC107',
                    categoryId: 'mind',
                },
                reading: {
                    name: 'Чтение',
                    description: '30 минут чтения',
                    iconName: 'menu_book',
                    colorHex: '#3F51B5',
                    categoryId: 'mind',
                },
                workout: {
                    name: 'Тренировка',
                    description: 'Физические упражнения',
                    iconName: 'fitness_center',
                    colorHex: '#FF5722',
                    categoryId: 'fitness',
                },
                meditation: {
                    name: 'Медитация',
                    description: '10 минут медитации',
                    iconName: 'self_improvement',
                    colorHex: '#9C27B0',
                    categoryId: 'mind',
                },
            };

            const createdOrExisting: any[] = [];
            for (const id of habitIds) {
                const preset = presetMap[id];
                if (!preset) continue; // пропускаем неизвестные ID

                // Проверяем, есть ли у пользователя уже привычка с таким именем
                const existing = await this.prisma.habit.findFirst({
                    where: {
                        userId,
                        name: preset.name,
                    },
                });

                if (existing) {
                    createdOrExisting.push(existing);
                    continue;
                }

                const habit = await this.prisma.habit.create({
                    data: {
                        userId,
                        name: preset.name,
                        description: preset.description,
                        iconName: preset.iconName,
                        colorHex: preset.colorHex,
                        categoryId: preset.categoryId,
                        frequencyType: 'DAILY' as any,
                        isActive: true,
                        currentStreak: 0,
                        maxStreak: 0,
                        strength: 0,
                        specificWeekdays: [],
                        tags: [],
                        motivationalMessages: [],
                    },
                });
                createdOrExisting.push(habit);
            }

            return { count: createdOrExisting.length, habits: createdOrExisting };
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
