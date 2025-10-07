import 'package:flutter/material.dart';

class HabitModel {
  final String id;
  final String name;
  final String description;
  final String motivation;
  final IconData icon;
  final Color color;
  final HabitCategory category;
  final HabitFrequency frequency;
  final List<int> weekdays; // 1-7 для дней недели
  final TimeOfDay? reminderTime;
  final int? duration; // в минутах
  final HabitDifficulty difficulty;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final int currentStreak;
  final int maxStreak;
  final int strength; // 0-100
  final Map<DateTime, bool> completionHistory;
  final List<String> tags;
  final String? linkedGoal; // связь с целями из других модулей
  final bool enableReminders;
  final List<String> motivationalMessages;
  final HabitProgressionType progressionType;
  final Map<String, dynamic> customSettings;

  HabitModel({
    required this.id,
    required this.name,
    this.description = '',
    this.motivation = '',
    required this.icon,
    required this.color,
    required this.category,
    required this.frequency,
    this.weekdays = const [],
    this.reminderTime,
    this.duration,
    this.difficulty = HabitDifficulty.medium,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.currentStreak = 0,
    this.maxStreak = 0,
    this.strength = 0,
    this.completionHistory = const {},
    this.tags = const [],
    this.linkedGoal,
    this.enableReminders = true,
    this.motivationalMessages = const [],
    this.progressionType = HabitProgressionType.standard,
    this.customSettings = const {},
  });

  // Конвертация в Map для сохранения
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'motivation': motivation,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'color': color.value,
      'category': category.name,
      'frequency': frequency.toMap(),
      'weekdays': weekdays,
      'reminderTime': reminderTime != null 
          ? '${reminderTime!.hour}:${reminderTime!.minute}'
          : null,
      'duration': duration,
      'difficulty': difficulty.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'currentStreak': currentStreak,
      'maxStreak': maxStreak,
      'strength': strength,
      'completionHistory': completionHistory.map(
        (key, value) => MapEntry(key.toIso8601String(), value),
      ),
      'tags': tags,
      'linkedGoal': linkedGoal,
      'enableReminders': enableReminders,
      'motivationalMessages': motivationalMessages,
      'progressionType': progressionType.name,
      'customSettings': customSettings,
    };
  }

  // Создание из Map
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      motivation: map['motivation'] ?? '',
      icon: IconData(
        map['icon'] ?? Icons.circle.codePoint,
        fontFamily: map['iconFontFamily'],
      ),
      color: Color(map['color'] ?? Colors.blue.value),
      category: HabitCategory.fromString(map['category'] ?? 'other'),
      frequency: HabitFrequency.fromMap(map['frequency'] ?? {}),
      weekdays: List<int>.from(map['weekdays'] ?? []),
      reminderTime: map['reminderTime'] != null
          ? _parseTimeOfDay(map['reminderTime'])
          : null,
      duration: map['duration'],
      difficulty: HabitDifficulty.fromString(map['difficulty'] ?? 'medium'),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
      isActive: map['isActive'] ?? true,
      currentStreak: map['currentStreak'] ?? 0,
      maxStreak: map['maxStreak'] ?? 0,
      strength: map['strength'] ?? 0,
      completionHistory: _parseCompletionHistory(map['completionHistory'] ?? {}),
      tags: List<String>.from(map['tags'] ?? []),
      linkedGoal: map['linkedGoal'],
      enableReminders: map['enableReminders'] ?? true,
      motivationalMessages: List<String>.from(map['motivationalMessages'] ?? []),
      progressionType: HabitProgressionType.fromString(map['progressionType'] ?? 'standard'),
      customSettings: Map<String, dynamic>.from(map['customSettings'] ?? {}),
    );
  }

  static TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      return null;
    }
  }

  static Map<DateTime, bool> _parseCompletionHistory(Map<String, dynamic> map) {
    return map.map((key, value) => MapEntry(
      DateTime.tryParse(key) ?? DateTime.now(),
      value as bool,
    ));
  }

  HabitModel copyWith({
    String? id,
    String? name,
    String? description,
    String? motivation,
    IconData? icon,
    Color? color,
    HabitCategory? category,
    HabitFrequency? frequency,
    List<int>? weekdays,
    TimeOfDay? reminderTime,
    int? duration,
    HabitDifficulty? difficulty,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    int? currentStreak,
    int? maxStreak,
    int? strength,
    Map<DateTime, bool>? completionHistory,
    List<String>? tags,
    String? linkedGoal,
    bool? enableReminders,
    List<String>? motivationalMessages,
    HabitProgressionType? progressionType,
    Map<String, dynamic>? customSettings,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      motivation: motivation ?? this.motivation,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      weekdays: weekdays ?? this.weekdays,
      reminderTime: reminderTime ?? this.reminderTime,
      duration: duration ?? this.duration,
      difficulty: difficulty ?? this.difficulty,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      currentStreak: currentStreak ?? this.currentStreak,
      maxStreak: maxStreak ?? this.maxStreak,
      strength: strength ?? this.strength,
      completionHistory: completionHistory ?? this.completionHistory,
      tags: tags ?? this.tags,
      linkedGoal: linkedGoal ?? this.linkedGoal,
      enableReminders: enableReminders ?? this.enableReminders,
      motivationalMessages: motivationalMessages ?? this.motivationalMessages,
      progressionType: progressionType ?? this.progressionType,
      customSettings: customSettings ?? this.customSettings,
    );
  }

  // Вспомогательные методы
  bool shouldShowToday() {
    final today = DateTime.now();
    return frequency.shouldExecuteOn(today, weekdays);
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    final todayKey = DateTime(today.year, today.month, today.day);
    return completionHistory[todayKey] ?? false;
  }

  double getCompletionRate() {
    if (completionHistory.isEmpty) return 0.0;
    final completed = completionHistory.values.where((v) => v).length;
    return completed / completionHistory.length;
  }

  int getDaysInCurrentStreak() {
    // Логика подсчета текущей серии
    return currentStreak;
  }
}

enum HabitCategory {
  health,
  fitness,
  productivity,
  learning,
  social,
  creative,
  financial,
  spiritual,
  other;

  static HabitCategory fromString(String value) {
    return values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitCategory.other,
    );
  }

  String get displayName {
    switch (this) {
      case HabitCategory.health:
        return 'Здоровье';
      case HabitCategory.fitness:
        return 'Фитнес';
      case HabitCategory.productivity:
        return 'Продуктивность';
      case HabitCategory.learning:
        return 'Обучение';
      case HabitCategory.social:
        return 'Социальные';
      case HabitCategory.creative:
        return 'Творчество';
      case HabitCategory.financial:
        return 'Финансы';
      case HabitCategory.spiritual:
        return 'Духовность';
      case HabitCategory.other:
        return 'Другое';
    }
  }

  IconData get icon {
    switch (this) {
      case HabitCategory.health:
        return Icons.health_and_safety;
      case HabitCategory.fitness:
        return Icons.fitness_center;
      case HabitCategory.productivity:
        return Icons.trending_up;
      case HabitCategory.learning:
        return Icons.school;
      case HabitCategory.social:
        return Icons.people;
      case HabitCategory.creative:
        return Icons.palette;
      case HabitCategory.financial:
        return Icons.account_balance_wallet;
      case HabitCategory.spiritual:
        return Icons.self_improvement;
      case HabitCategory.other:
        return Icons.category;
    }
  }

  Color get color {
    switch (this) {
      case HabitCategory.health:
        return const Color(0xFF4CAF50);
      case HabitCategory.fitness:
        return const Color(0xFFFF5722);
      case HabitCategory.productivity:
        return const Color(0xFF2196F3);
      case HabitCategory.learning:
        return const Color(0xFF9C27B0);
      case HabitCategory.social:
        return const Color(0xFFFF9800);
      case HabitCategory.creative:
        return const Color(0xFFE91E63);
      case HabitCategory.financial:
        return const Color(0xFF009688);
      case HabitCategory.spiritual:
        return const Color(0xFF673AB7);
      case HabitCategory.other:
        return const Color(0xFF607D8B);
    }
  }
}

class HabitFrequency {
  final HabitFrequencyType type;
  final int? timesPerWeek;
  final int? timesPerMonth;
  final List<int>? specificDays; // дни недели для weekly
  final bool? everyday;

  HabitFrequency({
    required this.type,
    this.timesPerWeek,
    this.timesPerMonth,
    this.specificDays,
    this.everyday,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'timesPerWeek': timesPerWeek,
      'timesPerMonth': timesPerMonth,
      'specificDays': specificDays,
      'everyday': everyday,
    };
  }

  factory HabitFrequency.fromMap(Map<String, dynamic> map) {
    return HabitFrequency(
      type: HabitFrequencyType.fromString(map['type'] ?? 'daily'),
      timesPerWeek: map['timesPerWeek'],
      timesPerMonth: map['timesPerMonth'],
      specificDays: map['specificDays'] != null 
          ? List<int>.from(map['specificDays'])
          : null,
      everyday: map['everyday'],
    );
  }

  bool shouldExecuteOn(DateTime date, List<int> weekdays) {
    switch (type) {
      case HabitFrequencyType.daily:
        return true;
      case HabitFrequencyType.weekly:
        return weekdays.contains(date.weekday);
      case HabitFrequencyType.monthly:
        // Логика для месячной частоты
        return true; // упрощенно
      case HabitFrequencyType.custom:
        return specificDays?.contains(date.weekday) ?? false;
    }
  }

  String get displayText {
    switch (type) {
      case HabitFrequencyType.daily:
        return 'Ежедневно';
      case HabitFrequencyType.weekly:
        if (timesPerWeek != null) {
          return '$timesPerWeek раз в неделю';
        }
        return 'Еженедельно';
      case HabitFrequencyType.monthly:
        if (timesPerMonth != null) {
          return '$timesPerMonth раз в месяц';
        }
        return 'Ежемесячно';
      case HabitFrequencyType.custom:
        return 'Настраиваемая';
    }
  }
}

enum HabitFrequencyType {
  daily,
  weekly,
  monthly,
  custom;

  static HabitFrequencyType fromString(String value) {
    return values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitFrequencyType.daily,
    );
  }
}

enum HabitDifficulty {
  easy,
  medium,
  hard;

  static HabitDifficulty fromString(String value) {
    return values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitDifficulty.medium,
    );
  }

  String get displayName {
    switch (this) {
      case HabitDifficulty.easy:
        return 'Легкая';
      case HabitDifficulty.medium:
        return 'Средняя';
      case HabitDifficulty.hard:
        return 'Сложная';
    }
  }

  Color get color {
    switch (this) {
      case HabitDifficulty.easy:
        return const Color(0xFF4CAF50);
      case HabitDifficulty.medium:
        return const Color(0xFFFF9800);
      case HabitDifficulty.hard:
        return const Color(0xFFF44336);
    }
  }
}

enum HabitProgressionType {
  standard,
  incremental,
  target;

  static HabitProgressionType fromString(String value) {
    return values.firstWhere(
      (e) => e.name == value,
      orElse: () => HabitProgressionType.standard,
    );
  }

  String get displayName {
    switch (this) {
      case HabitProgressionType.standard:
        return 'Стандартная';
      case HabitProgressionType.incremental:
        return 'Постепенная';
      case HabitProgressionType.target:
        return 'Целевая';
    }
  }
}

class HabitTemplate {
  final String id;
  final String name;
  final String description;
  final String motivation;
  final IconData icon;
  final Color color;
  final HabitCategory category;
  final HabitFrequency defaultFrequency;
  final int? defaultDuration;
  final HabitDifficulty defaultDifficulty;
  final List<String> defaultTags;
  final List<String> tips;
  final bool isPopular;

  HabitTemplate({
    required this.id,
    required this.name,
    required this.description,
    this.motivation = '',
    required this.icon,
    required this.color,
    required this.category,
    required this.defaultFrequency,
    this.defaultDuration,
    this.defaultDifficulty = HabitDifficulty.medium,
    this.defaultTags = const [],
    this.tips = const [],
    this.isPopular = false,
  });

  HabitModel toHabit() {
    return HabitModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      motivation: motivation,
      icon: icon,
      color: color,
      category: category,
      frequency: defaultFrequency,
      duration: defaultDuration,
      difficulty: defaultDifficulty,
      tags: List.from(defaultTags),
      createdAt: DateTime.now(),
    );
  }
}
