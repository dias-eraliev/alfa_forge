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

    // 2. Создаем шаблоны привычек (идемпотентно)
    console.log('📝 Creating habit templates...');
    let templatesCreated = 0;
    const ensureHabitTemplate = async (data: Parameters<typeof prisma.habitTemplate.create>[0]['data']) => {
        const exists = await prisma.habitTemplate.findFirst({ where: { name: data.name } });
        if (!exists) {
            await prisma.habitTemplate.create({ data });
            templatesCreated++;
        }
    };
    await ensureHabitTemplate({
        name: 'Пить воду',
        description: 'Выпивать достаточное количество воды в день',
        iconName: 'water_drop',
        colorHex: '#2196F3',
        categoryId: 'health',
        defaultFrequencyType: 'DAILY',
        isPopular: true,
        tips: ['Носите бутылку с водой', 'Ставьте напоминания'],
    });
    await ensureHabitTemplate({
        name: 'Медитация',
        description: 'Практика осознанности и концентрации',
        iconName: 'self_improvement',
        colorHex: '#9C27B0',
        categoryId: 'mind',
        defaultFrequencyType: 'DAILY',
        isPopular: true,
        tips: ['Начните с 5 минут', 'Найдите тихое место'],
    });

    // 3. Создаем типы измерений (идемпотентно через upsert)
    console.log('📏 Creating measurement types...');

    const upsertMeasurementType = (m: {
        id: string;
        name: string;
        shortName: string;
        category: 'BASIC' | 'BODY' | 'COMPOSITION' | 'VITAL';
        unit: 'KG' | 'CM' | 'PERCENT' | 'BPM' | 'MMHG' | 'CELSIUS' | 'KCAL';
        minValue?: number;
        maxValue?: number;
        defaultValue?: number;
        iconName: string;
        isRequired?: boolean;
        allowsDecimal?: boolean;
        decimalPlaces?: number;
        description?: string;
    }) =>
        prisma.measurementType.upsert({
            where: { id: m.id },
            create: {
                id: m.id,
                name: m.name,
                shortName: m.shortName,
                category: m.category,
                unit: m.unit,
                minValue: m.minValue,
                maxValue: m.maxValue,
                defaultValue: m.defaultValue,
                iconName: m.iconName,
                isRequired: m.isRequired ?? false,
                allowsDecimal: m.allowsDecimal ?? true,
                decimalPlaces: m.decimalPlaces ?? 1,
                description: m.description,
            },
            update: {
                name: m.name,
                shortName: m.shortName,
                category: m.category,
                unit: m.unit,
                minValue: m.minValue,
                maxValue: m.maxValue,
                defaultValue: m.defaultValue,
                iconName: m.iconName,
                isRequired: m.isRequired ?? false,
                allowsDecimal: m.allowsDecimal ?? true,
                decimalPlaces: m.decimalPlaces ?? 1,
                description: m.description,
            },
        });

    const measurementTypes = await Promise.all([
        // Основные показатели
        upsertMeasurementType({
            id: 'weight',
            name: 'Вес',
            shortName: 'Вес',
            category: 'BASIC',
            unit: 'KG',
            minValue: 30,
            maxValue: 200,
            iconName: 'monitor_weight',
            isRequired: true,
            allowsDecimal: true,
            decimalPlaces: 1,
            description: 'Общая масса тела',
        }),
        upsertMeasurementType({
            id: 'height',
            name: 'Рост',
            shortName: 'Рост',
            category: 'BASIC',
            unit: 'CM',
            minValue: 100,
            maxValue: 250,
            iconName: 'height',
            allowsDecimal: false,
            decimalPlaces: 0,
            description: 'Рост в полный рост',
        }),

        // Объемы тела
        upsertMeasurementType({ id: 'chest', name: 'Грудь/Бюст', shortName: 'Грудь', category: 'BODY', unit: 'CM', minValue: 60, maxValue: 150, iconName: 'fitness_center', description: 'Обхват груди/бюста' }),
        upsertMeasurementType({ id: 'waist', name: 'Талия', shortName: 'Талия', category: 'BODY', unit: 'CM', minValue: 50, maxValue: 150, iconName: 'straighten', description: 'Обхват талии в самой узкой части' }),
        upsertMeasurementType({ id: 'hips', name: 'Бедра', shortName: 'Бедра', category: 'BODY', unit: 'CM', minValue: 60, maxValue: 150, iconName: 'accessibility', description: 'Обхват бедер в самой широкой части' }),
        upsertMeasurementType({ id: 'bicep_left', name: 'Бицепс (левый)', shortName: 'Бицепс Л', category: 'BODY', unit: 'CM', minValue: 15, maxValue: 60, iconName: 'sports_martial_arts', description: 'Обхват левого бицепса' }),
        upsertMeasurementType({ id: 'bicep_right', name: 'Бицепс (правый)', shortName: 'Бицепс П', category: 'BODY', unit: 'CM', minValue: 15, maxValue: 60, iconName: 'sports_martial_arts', description: 'Обхват правого бицепса' }),
        upsertMeasurementType({ id: 'thigh_left', name: 'Бедро (левое)', shortName: 'Бедро Л', category: 'BODY', unit: 'CM', minValue: 30, maxValue: 80, iconName: 'directions_run', description: 'Обхват левого бедра' }),
        upsertMeasurementType({ id: 'thigh_right', name: 'Бедро (правое)', shortName: 'Бедро П', category: 'BODY', unit: 'CM', minValue: 30, maxValue: 80, iconName: 'directions_run', description: 'Обхват правого бедра' }),
        upsertMeasurementType({ id: 'neck', name: 'Шея', shortName: 'Шея', category: 'BODY', unit: 'CM', minValue: 25, maxValue: 50, iconName: 'person', description: 'Обхват шеи' }),
        upsertMeasurementType({ id: 'forearm_left', name: 'Предплечье (левое)', shortName: 'Предпл. Л', category: 'BODY', unit: 'CM', minValue: 15, maxValue: 40, iconName: 'sports_handball', description: 'Обхват левого предплечья' }),
        upsertMeasurementType({ id: 'forearm_right', name: 'Предплечье (правое)', shortName: 'Предпл. П', category: 'BODY', unit: 'CM', minValue: 15, maxValue: 40, iconName: 'sports_handball', description: 'Обхват правого предплечья' }),
        upsertMeasurementType({ id: 'calf_left', name: 'Икра (левая)', shortName: 'Икра Л', category: 'BODY', unit: 'CM', minValue: 20, maxValue: 50, iconName: 'directions_walk', description: 'Обхват левой икры' }),
        upsertMeasurementType({ id: 'calf_right', name: 'Икра (правая)', shortName: 'Икра П', category: 'BODY', unit: 'CM', minValue: 20, maxValue: 50, iconName: 'directions_walk', description: 'Обхват правой икры' }),

        // Композиция тела
        upsertMeasurementType({ id: 'body_fat', name: 'Процент жира', shortName: 'Жир', category: 'COMPOSITION', unit: 'PERCENT', minValue: 3, maxValue: 50, iconName: 'water_drop', description: 'Процент жировой ткани' }),
        upsertMeasurementType({ id: 'muscle_mass', name: 'Мышечная масса', shortName: 'Мышцы', category: 'COMPOSITION', unit: 'KG', minValue: 15, maxValue: 100, iconName: 'fitness_center', description: 'Масса мышечной ткани' }),
        upsertMeasurementType({ id: 'bone_mass', name: 'Костная масса', shortName: 'Кости', category: 'COMPOSITION', unit: 'KG', minValue: 1, maxValue: 10, iconName: 'account_tree', description: 'Масса костной ткани' }),
        upsertMeasurementType({ id: 'water_percent', name: 'Вода в организме', shortName: 'Вода', category: 'COMPOSITION', unit: 'PERCENT', minValue: 45, maxValue: 75, iconName: 'opacity', description: 'Процент воды в организме' }),
        upsertMeasurementType({ id: 'bmr', name: 'Базальный метаболизм', shortName: 'БМР', category: 'COMPOSITION', unit: 'KCAL', minValue: 800, maxValue: 3000, iconName: 'local_fire_department', allowsDecimal: false, decimalPlaces: 0, description: 'Калорий сжигается в покое' }),

        // Витальные показатели
        upsertMeasurementType({ id: 'heart_rate', name: 'Пульс в покое', shortName: 'Пульс', category: 'VITAL', unit: 'BPM', minValue: 40, maxValue: 120, iconName: 'favorite', allowsDecimal: false, decimalPlaces: 0, description: 'ЧСС в покое' }),
        upsertMeasurementType({ id: 'blood_pressure_systolic', name: 'Давление (верхнее)', shortName: 'Сист.', category: 'VITAL', unit: 'MMHG', minValue: 80, maxValue: 200, iconName: 'water_drop', allowsDecimal: false, decimalPlaces: 0, description: 'Систолическое АД' }),
        upsertMeasurementType({ id: 'blood_pressure_diastolic', name: 'Давление (нижнее)', shortName: 'Диаст.', category: 'VITAL', unit: 'MMHG', minValue: 40, maxValue: 120, iconName: 'water_drop', allowsDecimal: false, decimalPlaces: 0, description: 'Диастолическое АД' }),
        upsertMeasurementType({ id: 'body_temperature', name: 'Температура тела', shortName: 'Темп.', category: 'VITAL', unit: 'CELSIUS', minValue: 35, maxValue: 42, iconName: 'thermostat', allowsDecimal: true, decimalPlaces: 1, description: 'Температура тела' }),
    ]);

    // 4. Создаем упражнения (идемпотентно, уникальное поле name)
    console.log('💪 Creating exercises...');
    const upsertExercise = (data: Parameters<typeof prisma.exercise.create>[0]['data']) =>
        prisma.exercise.upsert({
            where: { name: data.name },
            update: {
                description: data.description,
                instructions: data.instructions,
                iconEmoji: data.iconEmoji,
                difficulty: data.difficulty as any,
                category: data.category as any,
                muscleGroups: data.muscleGroups,
                hasAIDetection: data.hasAIDetection,
            },
            create: data,
        });
    await Promise.all([
        upsertExercise({
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
        }),
        upsertExercise({
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
        }),
    ]);

    // 5. Создаем мотивационные цитаты (идемпотентно)
    console.log('💬 Creating quotes...');
    let quotesCreated = 0;
    const ensureQuote = async (data: Parameters<typeof prisma.quote.create>[0]['data']) => {
        const exists = await prisma.quote.findFirst({ where: { text: data.text, author: data.author } });
        if (!exists) {
            await prisma.quote.create({ data });
            quotesCreated++;
        }
    };
    await ensureQuote({
        text: 'Дисциплина - это мост между целями и достижениями.',
        author: 'Джим Рон',
        category: 'DISCIPLINE',
        timeContext: 'MORNING',
        priority: 10,
        tags: ['мотивация', 'дисциплина'],
        targetZones: ['WILL'],
        isPremium: false,
    });
    await ensureQuote({
        text: 'Успех - это сумма маленьких усилий, повторяемых день за днем.',
        author: 'Роберт Кольер',
        category: 'SUCCESS',
        timeContext: 'EVENING',
        priority: 8,
        tags: ['успех', 'постоянство'],
        targetZones: ['WILL', 'FOCUS'],
        isPremium: false,
    });

    // 6. Создаем тестового пользователя
    console.log('👤 Creating test user...');
    const testUser = await prisma.user.upsert({
        where: { email: 'test@example.com' },
        update: {},
        create: {
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
    await prisma.userProgress.upsert({
        where: { userId: testUser.id },
        update: {
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
            } as any,
            totalStats: {
                habits_completed: 47,
                tasks_completed: 23,
                workouts_completed: 15,
                calories_burned: 2400,
                water_drunk: 36,
                meditation_minutes: 180,
            } as any,
        },
        create: {
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
            } as any,
            totalStats: {
                habits_completed: 47,
                tasks_completed: 23,
                workouts_completed: 15,
                calories_burned: 2400,
                water_drunk: 36,
                meditation_minutes: 180,
            } as any,
        },
    });

    // 8. Создаем примеры привычек для тестового пользователя
    console.log('✅ Creating test user habits...');
    const ensureHabitForUser = async (data: Parameters<typeof prisma.habit.create>[0]['data']) => {
        const exists = await prisma.habit.findFirst({ where: { userId: data.userId, name: data.name } });
        if (!exists) {
            await prisma.habit.create({ data });
        }
    };
    await Promise.all([
        ensureHabitForUser({
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
        }),
        ensureHabitForUser({
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
        }),
    ]);

        console.log('✅ Seed completed successfully!');
        console.log(`📊 Ensured records:
    - ${categories.length} habit categories
    - ${templatesCreated} habit templates (newly created)
    - ${measurementTypes.length} measurement types
    - 2 exercises (upsert)
    - ${quotesCreated} quotes (newly created)
    - 1 test user with habits and progress`);
}

main()
    .catch((e) => {
        console.error('❌ Seed failed:', e);
        process.exit(1);
    })
    .finally(() => {
        void prisma.$disconnect();
    });
