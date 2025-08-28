import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Современные минималистичные иконки целей из Lucide Icons
/// Замена "ужасных" brutal icons на брутальные минималистичные иконки
class ModernGoalIcons {
  
  /// Получить иконку по ID цели
  static IconData getIconById(String goalId) {
    switch (goalId) {
      case 'money_goal':
        return LucideIcons.dollarSign;   // Знак доллара - символ финансов
      case 'weight_goal':
        return LucideIcons.dumbbell;     // Гантель - символ физической силы
      case 'will_goal':
        return LucideIcons.flame;        // Пламя - символ воли и страсти
      case 'focus_goal':
        return LucideIcons.target;       // Мишень - символ концентрации
      case 'mind_goal':
        return LucideIcons.brain;        // Мозг - символ интеллекта
      case 'peace_goal':
        return LucideIcons.compass;      // Компас - символ внутреннего покоя
      // Дополнительные варианты для обратной совместимости
      case 'body':
        return LucideIcons.dumbbell;
      case 'willpower':
        return LucideIcons.flame;
      case 'focus':
        return LucideIcons.target;
      case 'mind':
        return LucideIcons.brain;
      case 'peace':
        return LucideIcons.compass;
      case 'money':
        return LucideIcons.dollarSign;
      default:
        return LucideIcons.circle;       // Круг по умолчанию
    }
  }

  /// Создать виджет иконки с заданным цветом и размером
  static Widget getIconWidget({
    required String goalId,
    required Color color,
    double size = 24,
  }) {
    return Icon(
      getIconById(goalId),
      color: color,
      size: size,
    );
  }
}
