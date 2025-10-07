import 'package:flutter/material.dart';

enum HealthGoalType {
  weight('Вес', 'кг', Icons.monitor_weight, Colors.blue),
  bodyFat('Процент жира', '%', Icons.water_drop, Color(0xFFFF7043)),
  muscle('Мышечная масса', 'кг', Icons.fitness_center, Color(0xFF4CAF50)),
  waist('Талия', 'см', Icons.straighten, Color(0xFF9C27B0)),
  chest('Грудь', 'см', Icons.fitness_center, Color(0xFF2196F3)),
  hips('Бедра', 'см', Icons.accessibility, Color(0xFFE91E63)),
  biceps('Бицепс', 'см', Icons.sports_martial_arts, Color(0xFFFF5722)),
  steps('Шаги в день', '', Icons.directions_walk, Color(0xFF00BCD4)),
  water('Потребление воды', 'л', Icons.water_drop, Color(0xFF03A9F4)),
  sleep('Сон', 'ч', Icons.bedtime, Color(0xFF673AB7)),
  heartRate('Пульс покоя', 'уд/мин', Icons.favorite, Color(0xFFF44336)),
  bloodPressure('Давление', 'мм рт.ст.', Icons.bloodtype, Color(0xFF795548)),
  calories('Калории в день', 'ккал', Icons.local_fire_department, Color(0xFFFF9800));

  const HealthGoalType(this.title, this.unit, this.icon, this.color);

  final String title;
  final String unit;
  final IconData icon;
  final Color color;
}

enum HealthGoalFrequency {
  daily('Ежедневно'),
  weekly('Еженедельно'),
  monthly('Ежемесячно'),
  yearly('Ежегодно');

  const HealthGoalFrequency(this.title);
  final String title;
}

enum HealthGoalPriority {
  low('Низкий', Color(0xFF9E9E9E)),
  medium('Средний', Color(0xFFFF9800)),
  high('Высокий', Color(0xFFF44336));

  const HealthGoalPriority(this.title, this.color);
  final String title;
  final Color color;
}

class HealthGoal {
  final String id;
  final HealthGoalType type;
  final String title;
  final double targetValue;
  final double currentValue;
  final HealthGoalPriority priority;
  final HealthGoalFrequency frequency;
  final DateTime startDate;
  final DateTime? targetDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  HealthGoal({
    required this.id,
    required this.type,
    required this.title,
    required this.targetValue,
    required this.currentValue,
    required this.priority,
    required this.frequency,
    required this.startDate,
    this.targetDate,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  double get progress {
    if (targetValue == 0) return 0;
    
    // For goals where lower is better (weight loss, body fat reduction)
    if (type == HealthGoalType.weight || type == HealthGoalType.bodyFat || type == HealthGoalType.waist) {
      if (currentValue <= targetValue) return 1.0;
      return 1.0 - ((currentValue - targetValue) / currentValue).clamp(0.0, 1.0);
    }
    
    // For goals where higher is better (muscle gain, steps, water, sleep)
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  bool get isCompleted => progress >= 1.0;

  bool get isOverdue {
    if (targetDate == null) return false;
    return DateTime.now().isAfter(targetDate!) && !isCompleted;
  }

  int get daysLeft {
    if (targetDate == null) return -1;
    final difference = targetDate!.difference(DateTime.now());
    return difference.inDays;
  }

  String get progressText {
    return '${currentValue.toStringAsFixed(1)}${type.unit} / ${targetValue.toStringAsFixed(1)}${type.unit}';
  }

  String get statusText {
    if (isCompleted) return 'Выполнено';
    if (isOverdue) return 'Просрочено';
    if (daysLeft > 0) return '$daysLeft дн. осталось';
    return 'В процессе';
  }

  Color get statusColor {
    if (isCompleted) return const Color(0xFF4CAF50);
    if (isOverdue) return const Color(0xFFF44336);
    if (daysLeft <= 3 && daysLeft > 0) return const Color(0xFFFF9800);
    return type.color;
  }

  HealthGoal copyWith({
    String? id,
    HealthGoalType? type,
    String? title,
    double? targetValue,
    double? currentValue,
    HealthGoalPriority? priority,
    HealthGoalFrequency? frequency,
    DateTime? startDate,
    DateTime? targetDate,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HealthGoal(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      priority: priority ?? this.priority,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      targetDate: targetDate ?? this.targetDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'priority': priority.name,
      'frequency': frequency.name,
      'startDate': startDate.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'notes': notes,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HealthGoal.fromJson(Map<String, dynamic> json) {
    return HealthGoal(
      id: json['id'],
      type: HealthGoalType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      targetValue: json['targetValue'].toDouble(),
      currentValue: json['currentValue'].toDouble(),
      priority: HealthGoalPriority.values.firstWhere((e) => e.name == json['priority']),
      frequency: HealthGoalFrequency.values.firstWhere((e) => e.name == json['frequency']),
      startDate: DateTime.parse(json['startDate']),
      targetDate: json['targetDate'] != null ? DateTime.parse(json['targetDate']) : null,
      notes: json['notes'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  // Предустановленные цели
  static List<HealthGoal> getTemplateGoals() {
    final now = DateTime.now();
    
    return [
      HealthGoal(
        id: 'weight_loss',
        type: HealthGoalType.weight,
        title: 'Снижение веса',
        targetValue: 75.0,
        currentValue: 78.5,
        priority: HealthGoalPriority.high,
        frequency: HealthGoalFrequency.weekly,
        startDate: now,
        targetDate: now.add(const Duration(days: 90)),
        notes: 'Здоровое снижение веса за 3 месяца',
        createdAt: now,
        updatedAt: now,
      ),
      HealthGoal(
        id: 'body_fat_reduction',
        type: HealthGoalType.bodyFat,
        title: 'Снижение процента жира',
        targetValue: 12.0,
        currentValue: 15.2,
        priority: HealthGoalPriority.high,
        frequency: HealthGoalFrequency.weekly,
        startDate: now,
        targetDate: now.add(const Duration(days: 120)),
        notes: 'Достижение спортивной формы',
        createdAt: now,
        updatedAt: now,
      ),
      HealthGoal(
        id: 'muscle_gain',
        type: HealthGoalType.muscle,
        title: 'Набор мышечной массы',
        targetValue: 72.0,
        currentValue: 68.3,
        priority: HealthGoalPriority.medium,
        frequency: HealthGoalFrequency.monthly,
        startDate: now,
        targetDate: now.add(const Duration(days: 180)),
        notes: 'Увеличение мышечной массы на 3.7 кг',
        createdAt: now,
        updatedAt: now,
      ),
      HealthGoal(
        id: 'daily_steps',
        type: HealthGoalType.steps,
        title: '10 000 шагов в день',
        targetValue: 10000,
        currentValue: 8247,
        priority: HealthGoalPriority.medium,
        frequency: HealthGoalFrequency.daily,
        startDate: now,
        notes: 'Ежедневная активность для здоровья',
        createdAt: now,
        updatedAt: now,
      ),
      HealthGoal(
        id: 'water_intake',
        type: HealthGoalType.water,
        title: 'Достаточное потребление воды',
        targetValue: 3.0,
        currentValue: 2.1,
        priority: HealthGoalPriority.medium,
        frequency: HealthGoalFrequency.daily,
        startDate: now,
        notes: '3 литра воды в день для оптимального здоровья',
        createdAt: now,
        updatedAt: now,
      ),
      HealthGoal(
        id: 'quality_sleep',
        type: HealthGoalType.sleep,
        title: 'Качественный сон',
        targetValue: 8.0,
        currentValue: 7.5,
        priority: HealthGoalPriority.high,
        frequency: HealthGoalFrequency.daily,
        startDate: now,
        notes: '8 часов сна для восстановления',
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }
}

class HealthGoalStatistics {
  final int totalGoals;
  final int activeGoals;
  final int completedGoals;
  final int overdueGoals;
  final double averageProgress;
  final Map<HealthGoalType, int> goalsByType;
  final Map<HealthGoalPriority, int> goalsByPriority;

  HealthGoalStatistics({
    required this.totalGoals,
    required this.activeGoals,
    required this.completedGoals,
    required this.overdueGoals,
    required this.averageProgress,
    required this.goalsByType,
    required this.goalsByPriority,
  });

  factory HealthGoalStatistics.fromGoals(List<HealthGoal> goals) {
    final activeGoals = goals.where((g) => g.isActive).toList();
    final completedGoals = activeGoals.where((g) => g.isCompleted).length;
    final overdueGoals = activeGoals.where((g) => g.isOverdue).length;
    
    final averageProgress = activeGoals.isEmpty 
        ? 0.0 
        : activeGoals.map((g) => g.progress).reduce((a, b) => a + b) / activeGoals.length;

    final goalsByType = <HealthGoalType, int>{};
    final goalsByPriority = <HealthGoalPriority, int>{};

    for (final goal in activeGoals) {
      goalsByType[goal.type] = (goalsByType[goal.type] ?? 0) + 1;
      goalsByPriority[goal.priority] = (goalsByPriority[goal.priority] ?? 0) + 1;
    }

    return HealthGoalStatistics(
      totalGoals: goals.length,
      activeGoals: activeGoals.length,
      completedGoals: completedGoals,
      overdueGoals: overdueGoals,
      averageProgress: averageProgress,
      goalsByType: goalsByType,
      goalsByPriority: goalsByPriority,
    );
  }
}
