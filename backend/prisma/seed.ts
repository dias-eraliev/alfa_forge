import { PrismaClient } from 'generated/prisma';
import { hash } from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
    console.log('🌱 Starting seed...');

    // 1. Создаем категории привычек
    console.log('📋 Creating habit categories...');
    const categories = await Promise.all([
        prisma.habitCategory.upsert({
            where: { id: 'health' },
            update: {},
            create: {
                id: 'health',
                name: 'Здоровье',
                displayName: 'Здоровье',
                iconName: 'favorite',
                colorHex: '#E91E63',
            },
        }),
        prisma.habitCategory.upsert({
            where: { id: 'fitness' },
            update: {},
            create: {
                id: 'fitness',
                name: 'Фитнес',
                displayName: 'Фитнес',
                iconName: 'fitness_center',
                colorHex: '#FF5722',
            },
        }),
        prisma.habitCategory.upsert({
            where: { id: 'mind' },
            update: {},
            create: {
                id: 'mind',
                name: 'Разум',
                displayName: 'Разум',
                iconName: 'psychology',
                colorHex: '#9C27B0',
            },
        }),
    ]);

    // 2. Создаем шаблоны привычек
    console.log('📝 Creating habit templates...');
    const templates = await Promise.all([
        prisma.habitTemplate.create({
            data: {
                name: 'Пить воду',
                description: 'Выпивать достаточное количество воды в день',
                iconName: 'water_drop',
                colorHex: '#2196F3',
                categoryId: 'health',
                defaultFrequencyType: 'DAILY',
                isPopular: true,
                tips: ['Носите бутылку с водой', 'Ставьте напоминания'],
            },
        }),
        prisma.habitTemplate.create({
            data: {
                name: 'Медитация',
                description: 'Практика осознанности и концентрации',
                iconName: 'self_improvement',
                colorHex: '#9C27B0',
                categoryId: 'mind',
                defaultFrequencyType: 'DAILY',
                isPopular: true,
                tips: ['Начните с 5 минут', 'Найдите тихое место'],
            },
        }),
    ]);

    // 3. Создаем типы измерений (используем правильные enum)
    console.log('📏 Creating measurement types...');
    const measurementTypes = await Promise.all([
        prisma.measurementType.create({
            data: {
                id: 'weight',
                name: 'Вес',
                shortName: 'Вес',
                category: 'COMPOSITION',
                unit: 'KG',
                minValue: 30,
                maxValue: 200,
                iconName: 'monitor_weight',
            },
        }),
        prisma.measurementType.create({
            data: {
                id: 'height',
                name: 'Рост',
                shortName: 'Рост',
                category: 'BODY',
                unit: 'CM',
                minValue: 100,
                maxValue: 250,
                iconName: 'height',
            },
        }),
    ]);

    // 4. Создаем упражнения (используем правильные enum)
    console.log('💪 Creating exercises...');
    const exercises = await Promise.all([
        prisma.exercise.create({
            data: {
                name: 'Отжимания',
                description: 'Классические отжимания от пола',
                instructions: [
                    'Примите упор лежа',
                    'Руки на ширине плеч',
                    'Опускайтесь до касания грудью пола'
                ],
                iconEmoji: '💪',
                difficulty: 'EASY',
                category: 'STRENGTH',
                muscleGroups: ['CHEST'],
                hasAIDetection: true,
            },
        }),
        prisma.exercise.create({
            data: {
                name: 'Приседания',
                description: 'Базовые приседания с собственным весом',
                instructions: [
                    'Встаньте прямо, ноги на ширине плеч',
                    'Опускайтесь, сгибая колени'
                ],
                iconEmoji: '🦵',
                difficulty: 'EASY',
                category: 'STRENGTH',
                muscleGroups: ['LEGS'],
                hasAIDetection: true,
            },
        }),
    ]);

    // 5. Создаем мотивационные цитаты (используем правильные enum и числовые priority)
    console.log('💬 Creating quotes...');
    const quotes = await Promise.all([
        prisma.quote.create({
            data: {
                text: 'Дисциплина - это мост между целями и достижениями.',
                author: 'Джим Рон',
                category: 'DISCIPLINE',
                timeContext: 'MORNING',
                priority: 10,
                tags: ['мотивация', 'дисциплина'],
                targetZones: ['WILL'],
                isPremium: false,
            },
        }),
        prisma.quote.create({
            data: {
                text: 'Успех - это сумма маленьких усилий, повторяемых день за днем.',
                author: 'Роберт Кольер',
                category: 'SUCCESS',
                timeContext: 'EVENING',
                priority: 8,
                tags: ['успех', 'постоянство'],
                targetZones: ['WILL', 'FOCUS'],
                isPremium: false,
            },
        }),
    ]);

    // 6. Создаем тестового пользователя
    console.log('👤 Creating test user...');
    const testUser = await prisma.user.create({
        data: {
            email: 'test@example.com',
            username: 'testuser',
            passwordHash: await hash('password123', 10),
            profile: {
                create: {
                    fullName: 'Тестовый Пользователь',
                    phone: '+7 900 123 45 67',
                    city: 'Алматы',
                    avatarUrl: null,
                },
            },
            settings: {
                create: {
                    notificationsEnabled: true,
                    theme: 'DARK',
                    language: 'RU',
                },
            },
        },
    });

    // 7. Создаем прогресс пользователя отдельно
    console.log('📊 Creating user progress...');
    await prisma.userProgress.create({
        data: {
            userId: testUser.id,
            totalSteps: 47,
            totalXP: 2847,
            currentStreak: 12,
            longestStreak: 25,
            currentZone: 'WILL',
            currentRank: 'WARRIOR',
            sphereProgress: {
                body: 0.8,
                will: 0.6,
                focus: 0.4,
                mind: 0.3,
                peace: 0.2,
                money: 0.1,
            },
            totalStats: {
                habits_completed: 47,
                tasks_completed: 23,
                workouts_completed: 15,
                calories_burned: 2400,
                water_drunk: 36,
                meditation_minutes: 180,
            },
        },
    });

    // 8. Создаем примеры привычек для тестового пользователя
    console.log('✅ Creating test user habits...');
    await Promise.all([
        prisma.habit.create({
            data: {
                userId: testUser.id,
                name: 'Пить воду 2L',
                description: 'Выпивать 2 литра воды в день',
                iconName: 'water_drop',
                colorHex: '#2196F3',
                categoryId: 'health',
                frequencyType: 'DAILY',
                reminderTime: '08:00',
                isActive: true,
                currentStreak: 12,
                maxStreak: 25,
                strength: 85,
            },
        }),
        prisma.habit.create({
            data: {
                userId: testUser.id,
                name: 'Утренняя медитация',
                description: '10 минут медитации каждое утро',
                iconName: 'self_improvement',
                colorHex: '#9C27B0',
                categoryId: 'mind',
                frequencyType: 'DAILY',
                reminderTime: '07:00',
                isActive: true,
                currentStreak: 15,
                maxStreak: 20,
                strength: 92,
            },
        }),
    ]);

    console.log('✅ Seed completed successfully!');
    console.log(`📊 Created:
  - ${categories.length} habit categories
  - ${templates.length} habit templates  
  - ${measurementTypes.length} measurement types
  - ${exercises.length} exercises
  - ${quotes.length} quotes
  - 1 test user with habits and progress`);
}

main()
    .catch((e) => {
        console.error('❌ Seed failed:', e);
        process.exit(1);
    })
    .finally(async () => {
        await prisma.$disconnect();
    });
