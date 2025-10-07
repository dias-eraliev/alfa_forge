import 'package:hive/hive.dart';

part 'quote_model.g.dart';

/// Категории цитат для мужской мотивации
enum QuoteCategory {
  money,      // Деньги и финансы
  discipline, // Дисциплина
  will,       // Воля и характер
  focus,      // Фокус и концентрация
  strength,   // Сила и выносливость
  success,    // Успех и достижения
  mindset,    // Мышление и психология
  leadership, // Лидерство
  work,       // Работа и карьера
  health,     // Здоровье
}

/// Контекст времени для цитат
enum TimeContext {
  morning,    // Утро (7:00-9:00)
  workday,    // Рабочий день (10:00-18:00)
  evening,    // Вечер (19:00-22:00)
  any,        // Любое время
}

@HiveType(typeId: 10)
class Quote extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final QuoteCategory category;

  @HiveField(4)
  final TimeContext timeContext;

  @HiveField(5)
  final int priority; // 1-10, где 10 - самый высокий приоритет

  @HiveField(6)
  final List<String> tags;

  @HiveField(7)
  final List<String> targetZones; // ТЕЛО, ВОЛЯ, ФОКУС, etc.

  @HiveField(8)
  final bool isPremium;

  @HiveField(9)
  final DateTime? lastShown;

  Quote({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
    this.timeContext = TimeContext.any,
    this.priority = 5,
    this.tags = const [],
    this.targetZones = const [],
    this.isPremium = false,
    this.lastShown,
  });

  /// Создать копию с обновленными полями
  Quote copyWith({
    String? id,
    String? text,
    String? author,
    QuoteCategory? category,
    TimeContext? timeContext,
    int? priority,
    List<String>? tags,
    List<String>? targetZones,
    bool? isPremium,
    DateTime? lastShown,
  }) {
    return Quote(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      category: category ?? this.category,
      timeContext: timeContext ?? this.timeContext,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      targetZones: targetZones ?? this.targetZones,
      isPremium: isPremium ?? this.isPremium,
      lastShown: lastShown ?? this.lastShown,
    );
  }

  /// Проверить, подходит ли цитата для текущего времени
  bool isAppropriateForTime(DateTime time) {
    final hour = time.hour;
    switch (timeContext) {
      case TimeContext.morning:
        return hour >= 7 && hour <= 9;
      case TimeContext.workday:
        return hour >= 10 && hour <= 18;
      case TimeContext.evening:
        return hour >= 19 && hour <= 22;
      case TimeContext.any:
        return hour >= 7 && hour <= 22;
    }
  }

  /// Проверить, подходит ли цитата для зоны пользователя
  bool isAppropriateForZone(String userZone) {
    if (targetZones.isEmpty) return true;
    return targetZones.contains(userZone.toUpperCase());
  }

  /// Получить эмодзи для категории
  String get categoryEmoji {
    switch (category) {
      case QuoteCategory.money:
        return '💰';
      case QuoteCategory.discipline:
        return '⚡';
      case QuoteCategory.will:
        return '💪';
      case QuoteCategory.focus:
        return '🎯';
      case QuoteCategory.strength:
        return '🔥';
      case QuoteCategory.success:
        return '🏆';
      case QuoteCategory.mindset:
        return '🧠';
      case QuoteCategory.leadership:
        return '👑';
      case QuoteCategory.work:
        return '💼';
      case QuoteCategory.health:
        return '🏃';
    }
  }

  /// Получить название категории на русском
  String get categoryName {
    switch (category) {
      case QuoteCategory.money:
        return 'Деньги';
      case QuoteCategory.discipline:
        return 'Дисциплина';
      case QuoteCategory.will:
        return 'Воля';
      case QuoteCategory.focus:
        return 'Фокус';
      case QuoteCategory.strength:
        return 'Сила';
      case QuoteCategory.success:
        return 'Успех';
      case QuoteCategory.mindset:
        return 'Мышление';
      case QuoteCategory.leadership:
        return 'Лидерство';
      case QuoteCategory.work:
        return 'Работа';
      case QuoteCategory.health:
        return 'Здоровье';
    }
  }

  @override
  String toString() {
    return 'Quote{id: $id, text: $text, author: $author, category: $category}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
