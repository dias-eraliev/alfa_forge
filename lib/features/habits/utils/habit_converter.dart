import '../../../core/models/api_models.dart';
import '../models/habit_model.dart';
import 'package:flutter/material.dart';

class HabitConverter {
  // Конвертация ApiHabit в Map для существующего UI
  static Map<String, dynamic> apiHabitToMap(ApiHabit apiHabit) {
    return {
      'id': apiHabit.id,
      'name': apiHabit.name,
      'icon': _getIconFromCategory(apiHabit.category),
      'frequency': apiHabit.frequency,
      'description': apiHabit.description ?? 'API привычка',
      'streak': _calculateStreak(apiHabit.completions),
      'maxStreak': _calculateMaxStreak(apiHabit.completions),
      'strength': _calculateStrength(apiHabit.completions),
      'color': _getColorFromCategory(apiHabit.category),
    };
  }

  // Конвертация списка ApiHabit в список Map
  static List<Map<String, dynamic>> apiHabitsToMaps(List<ApiHabit> apiHabits) {
    return apiHabits.map((habit) => apiHabitToMap(habit)).toList();
  }

  // Получить иконку по категории
  static IconData _getIconFromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return Icons.favorite;
      case 'fitness':
        return Icons.fitness_center;
      case 'mindfulness':
        return Icons.self_improvement;
      case 'productivity':
        return Icons.work;
      case 'learning':
        return Icons.book;
      case 'lifestyle':
        return Icons.restaurant;
      case 'wellness':
        return Icons.spa;
      case 'social':
        return Icons.people;
      case 'creative':
        return Icons.palette;
      case 'financial':
        return Icons.account_balance_wallet;
      default:
        return Icons.star;
    }
  }

  // Получить цвет по категории
  static Color _getColorFromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return const Color(0xFF4FC3F7);
      case 'fitness':
        return const Color(0xFFFF7043);
      case 'mindfulness':
        return const Color(0xFF9C27B0);
      case 'productivity':
        return const Color(0xFF66BB6A);
      case 'learning':
        return const Color(0xFFFFB74D);
      case 'lifestyle':
        return const Color(0xFFAB47BC);
      case 'wellness':
        return const Color(0xFF26C6DA);
      case 'social':
        return const Color(0xFFEF5350);
      case 'creative':
        return const Color(0xFFEC407A);
      case 'financial':
        return const Color(0xFF42A5F5);
      default:
        return const Color(0xFF7986CB);
    }
  }

  // Расчет текущей серии
  static int _calculateStreak(List<ApiHabitCompletion> completions) {
    if (completions.isEmpty) return 0;
    
    // Сортируем по дате (новые сначала)
    final sortedCompletions = completions
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (final completion in sortedCompletions) {
      final completionDate = DateTime(
        completion.date.year,
        completion.date.month,
        completion.date.day,
      );
      final checkDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      
      if (completionDate == checkDate) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    
    return streak;
  }

  // Расчет максимальной серии
  static int _calculateMaxStreak(List<ApiHabitCompletion> completions) {
    if (completions.isEmpty) return 0;
    
    // Группируем по дням и считаем максимальную последовательность
    final dateSet = completions
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet()
        .toList()
        ..sort();
    
    if (dateSet.isEmpty) return 0;
    
    int maxStreak = 1;
    int currentStreak = 1;
    
    for (int i = 1; i < dateSet.length; i++) {
      final diff = dateSet[i].difference(dateSet[i - 1]).inDays;
      
      if (diff == 1) {
        currentStreak++;
        maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      } else {
        currentStreak = 1;
      }
    }
    
    return maxStreak;
  }

  // Расчет силы привычки (процент выполнения за последние 30 дней)
  static int _calculateStrength(List<ApiHabitCompletion> completions) {
    if (completions.isEmpty) return 0;
    
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    
    final recentCompletions = completions.where((c) => 
        c.date.isAfter(thirtyDaysAgo) && 
        c.date.isBefore(now.add(const Duration(days: 1)))
    ).length;
    
    final maxPossible = 30; // За 30 дней максимум 30 выполнений
    return ((recentCompletions / maxPossible) * 100).round().clamp(0, 100);
  }

  // Конвертация HabitModel в CreateHabitDto для API
  static CreateHabitDto habitModelToCreateDto(HabitModel habit) {
    return CreateHabitDto(
      name: habit.name,
      description: habit.description.isNotEmpty ? habit.description : null,
      category: _getCategoryFromIcon(habit.icon),
      frequency: habit.frequency.displayText,
      targetCount: 1, // По умолчанию 1 раз в день
      iconName: habit.icon.codePoint.toString(),
      color: '#${habit.color.value.toRadixString(16).substring(2)}',
    );
  }

  // Определяем категорию по иконке (обратная конвертация)
  static String _getCategoryFromIcon(IconData icon) {
    if (icon == Icons.favorite) return 'health';
    if (icon == Icons.fitness_center) return 'fitness';
    if (icon == Icons.self_improvement) return 'mindfulness';
    if (icon == Icons.work) return 'productivity';
    if (icon == Icons.book) return 'learning';
    if (icon == Icons.restaurant) return 'lifestyle';
    if (icon == Icons.spa) return 'wellness';
    if (icon == Icons.people) return 'social';
    if (icon == Icons.palette) return 'creative';
    if (icon == Icons.account_balance_wallet) return 'financial';
    return 'other';
  }

  // Получить fallback данные при ошибке API
  static List<Map<String, dynamic>> getFallbackHabits() {
    return [
      {
        'id': 'cold_shower',
        'name': 'Холодный душ',
        'icon': Icons.ac_unit,
        'frequency': 'ежедневно',
        'description': 'Укрепляет силу воли и иммунитет',
        'streak': 12,
        'maxStreak': 45,
        'strength': 78,
        'color': const Color(0xFF4FC3F7),
      },
      {
        'id': 'gym',
        'name': 'Тренировка',
        'icon': Icons.fitness_center,
        'frequency': '4 раза в неделю',
        'description': 'Строительство мужского тела',
        'streak': 8,
        'maxStreak': 28,
        'strength': 65,
        'color': const Color(0xFFFF7043),
      },
      {
        'id': 'meditation',
        'name': 'Медитация',
        'icon': Icons.self_improvement,
        'frequency': 'ежедневно 10 мин',
        'description': 'Контроль ума и эмоций',
        'streak': 5,
        'maxStreak': 21,
        'strength': 42,
        'color': const Color(0xFF9C27B0),
      },
      {
        'id': 'reading',
        'name': 'Чтение',
        'icon': Icons.book,
        'frequency': '30 мин/день',
        'description': 'Развитие интеллекта',
        'streak': 15,
        'maxStreak': 67,
        'strength': 89,
        'color': const Color(0xFF66BB6A),
      },
      {
        'id': 'no_fap',
        'name': 'NoFap',
        'icon': Icons.block,
        'frequency': 'постоянно',
        'description': 'Сохранение мужской энергии',
        'streak': 23,
        'maxStreak': 89,
        'strength': 91,
        'color': const Color(0xFFFFB74D),
      },
    ];
  }

  // Генерация данных привычки для календаря на основе API completions
  static List<bool?> generateHabitCalendarData(
    List<ApiHabitCompletion> completions, 
    int daysInMonth,
  ) {
    final data = <bool?>[];
    final now = DateTime.now();
    
    // Создаем Set дат выполнения для быстрого поиска
    final completionDates = completions
        .map((c) => DateTime(c.date.year, c.date.month, c.date.day))
        .toSet();
    
    for (int i = 1; i <= daysInMonth; i++) {
      final dayDate = DateTime(now.year, now.month, i);
      
      // Если день в будущем - null
      if (dayDate.isAfter(DateTime(now.year, now.month, now.day))) {
        data.add(null);
      } else {
        // Проверяем, есть ли выполнение в этот день
        data.add(completionDates.contains(dayDate));
      }
    }
    
    return data;
  }

  // Создание completion через API
  static Future<bool> markHabitCompletion(
    String habitId, 
    DateTime date, 
    bool completed,
  ) async {
    try {
      // Здесь будет вызов API для создания/удаления completion
      // Пока возвращаем true как заглушку
      return true;
    } catch (e) {
      print('Ошибка отметки привычки: $e');
      return false;
    }
  }
}
