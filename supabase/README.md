# Alfa Forge Database Schema

## Обзор

Эта схема базы данных разработана для приложения Alfa Forge - комплексной системы персонального развития, включающей фитнес, привычки, цели и социальные функции.

## Основные таблицы

### 👤 Пользователи (users)
Хранит профильные данные пользователей, включая информацию из онбординга.

**Ключевые поля:**
- `id` - UUID первичный ключ
- `email` - уникальный email
- `username` - уникальное имя пользователя
- `full_name`, `phone`, `city` - профильная информация
- `onboarding_completed` - статус завершения онбординга

### 🎯 Привычки (habits, user_habits, habit_logs)
Система отслеживания привычек пользователей.

**habits** - справочник доступных привычек
**user_habits** - привязка привычек к пользователям
**habit_logs** - ежедневные записи выполнения привычек

### 🏆 Цели (goals, goal_history)
Система "6 Лестниц Целей" для долгосрочного планирования.

**goals** - основные цели пользователей
**goal_history** - ежедневная история прогресса по целям

### 📊 Прогресс (user_progress, progress_history, sphere_progress)
Отслеживание общего прогресса пользователя.

**user_progress** - суммарная статистика
**progress_history** - ежедневный прогресс
**sphere_progress** - прогресс по сферам развития

### 💪 Тренировки (exercises, workout_sessions, workout_exercises)
Система фитнеса и GTO нормативов.

**exercises** - справочник упражнений
**workout_sessions** - сессии тренировок
**workout_exercises** - упражнения в конкретной тренировке

### ✅ Задачи (tasks)
Система управления задачами с приоритетами и сроками.

### 👥 Братство (brotherhood_posts, brotherhood_comments, brotherhood_likes)
Социальные функции приложения.

## Безопасность

- **Row Level Security (RLS)** включена на всех таблицах
- Пользователи могут видеть только свои данные
- Политики доступа настроены для каждой таблицы

## Индексы

Оптимизированные индексы для:
- Поиска по email и username
- Фильтрации по датам
- Связи между таблицами

## Начальные данные

Миграция включает:
- 4 предустановленные привычки
- 3 базовых упражнения
- Необходимые функции для расчетов

## Запуск миграции

```bash
# Через Supabase CLI
supabase db push

# Или через SQL редактор в Supabase Dashboard
# Выполнить содержимое файла 20241002_initial_schema.sql
```

## Файлы в репозитории

- `migrations/20241002_initial_schema.sql` - основная миграция схемы
- `queries.sql` - примеры запросов и тестовые данные
- `types.ts` - TypeScript типы для Supabase клиента
- `README.md` - эта документация

## Использование в Flutter

### 1. Установка типов (опционально)
```bash
# Скопировать types.ts в ваш проект
cp supabase/types.ts lib/types/supabase_types.dart
```

### 2. Примеры запросов

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Получить профиль пользователя
final userProfile = await supabase
  .from('users')
  .select()
  .eq('id', userId)
  .single();

// Создать новую цель
await supabase.from('goals').insert({
  'user_id': userId,
  'name': 'Прочитать 12 книг',
  'target_value': 12,
  'unit': 'книг',
  'goal_type': 'increase',
});

// Записать выполнение привычки
await supabase.from('habit_logs').insert({
  'user_habit_id': habitId,
  'user_id': userId,
  'logged_date': DateTime.now().toIso8601String().split('T')[0],
  'actual_value': 1,
});
```

## Полезные функции

- `update_user_streak(user_uuid)` - обновление серии активных дней
- `calculate_goal_progress(goal_uuid)` - расчет прогресса по цели

## Следующие миграции

Планируемые улучшения:
- Система достижений
- Групповые вызовы
- Интеграция с внешними сервисами
- Аналитика и отчеты