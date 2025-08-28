import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'goal_model.g.dart';

/// Модель цели для системы "6 Лестниц Целей"
@HiveType(typeId: 10)
class Goal extends HiveObject {
  /// Уникальный ID цели
  @HiveField(0)
  final String id;
  
  /// Название цели
  @HiveField(1)
  final String name;
  
  /// Эмодзи для визуализации
  @HiveField(2)
  final String emoji;
  
  /// Текущее значение
  @HiveField(3)
  double currentValue;
  
  /// Целевое значение
  @HiveField(4)
  final double targetValue;
  
  /// Единица измерения (кг, $, страниц и т.д.)
  @HiveField(5)
  final String unit;
  
  /// Дней прошло с начала цели
  @HiveField(6)
  int daysPassed;
  
  /// Тип цели (decrease - уменьшение, increase - увеличение)
  @HiveField(7)
  final GoalType type;
  
  /// Цвет темы для визуализации (hex строка)
  @HiveField(8)
  final String colorHex;
  
  /// Дата создания цели
  @HiveField(9)
  final DateTime createdAt;
  
  /// Дата последнего обновления
  @HiveField(10)
  DateTime lastUpdated;
  
  /// История ежедневных значений для графика
  @HiveField(11)
  List<DailyGoalValue> dailyHistory;

  Goal({
    required this.id,
    required this.name,
    required this.emoji,
    required this.currentValue,
    required this.targetValue,
    required this.unit,
    this.daysPassed = 0,
    required this.type,
    required this.colorHex,
    DateTime? createdAt,
    DateTime? lastUpdated,
    List<DailyGoalValue>? dailyHistory,
  }) : createdAt = createdAt ?? DateTime.now(),
       lastUpdated = lastUpdated ?? DateTime.now(),
       dailyHistory = dailyHistory ?? [];

  /// Получить прогресс в процентах (0.0 - 1.0)
  double get progressPercent {
    if (targetValue == 0) return 0.0;
    
    switch (type) {
      case GoalType.increase:
        return (currentValue / targetValue).clamp(0.0, 1.0);
      case GoalType.decrease:
        // Для целей уменьшения, прогресс = (стартовое - текущее) / (стартовое - цель)
        final startValue = targetValue + currentValue; // примерное стартовое значение
        return ((startValue - currentValue) / (startValue - targetValue)).clamp(0.0, 1.0);
    }
  }

  /// Получить прогресс в виде ступенек (количество дней с прогрессом)
  int get stepsCompleted {
    return (progressPercent * daysPassed).round().clamp(0, daysPassed);
  }

  /// Получить оставшуюся разницу до цели
  double get remainingValue {
    switch (type) {
      case GoalType.increase:
        return (targetValue - currentValue).clamp(0.0, double.infinity);
      case GoalType.decrease:
        return (currentValue - targetValue).clamp(0.0, double.infinity);
    }
  }

  /// Получить форматированное текущее значение
  String get formattedCurrentValue {
    return _formatValue(currentValue);
  }

  /// Получить форматированное целевое значение
  String get formattedTargetValue {
    return _formatValue(targetValue);
  }

  /// Получить форматированную оставшуюся разницу
  String get formattedRemainingValue {
    return _formatValue(remainingValue);
  }

  /// Получить цвет как Color объект
  Color get color {
    try {
      final hexCode = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return const Color(0xFFE9E1D1); // Fallback к песочному цвету
    }
  }

  /// Форматировать значение с единицей измерения
  String _formatValue(double value) {
    String formattedNumber;
    
    if (value >= 1000000) {
      formattedNumber = '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      formattedNumber = '${(value / 1000).toStringAsFixed(1)}K';
    } else if (value % 1 == 0) {
      formattedNumber = value.toInt().toString();
    } else {
      formattedNumber = value.toStringAsFixed(1);
    }
    
    return '$formattedNumber$unit';
  }

  /// Обновить текущее значение
  void updateCurrentValue(double newValue) {
    currentValue = newValue;
    lastUpdated = DateTime.now();
    save(); // Сохраняем в Hive
  }

  /// Добавить один день прогресса
  void addDayProgress() {
    daysPassed++;
    lastUpdated = DateTime.now();
    save();
  }

  /// Добавить ежедневное значение в историю
  void addDailyValue(double value, {String? note}) {
    final today = DateTime.now();
    final dailyValue = DailyGoalValue(
      date: DateTime(today.year, today.month, today.day),
      value: value,
      note: note,
    );
    
    // Удаляем запись за сегодня, если она уже существует
    dailyHistory.removeWhere((item) => 
      item.date.year == today.year && 
      item.date.month == today.month && 
      item.date.day == today.day
    );
    
    // Добавляем новую запись
    dailyHistory.add(dailyValue);
    
    // Сортируем по дате
    dailyHistory.sort((a, b) => a.date.compareTo(b.date));
    
    // Оставляем только последние 30 дней для оптимизации
    if (dailyHistory.length > 30) {
      dailyHistory = dailyHistory.sublist(dailyHistory.length - 30);
    }
    
    lastUpdated = DateTime.now();
    save();
  }

  /// Получить данные для графика за последние N дней
  List<DailyGoalValue> getGraphData({int days = 7}) {
    if (dailyHistory.isEmpty) return [];
    
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days - 1));
    
    return dailyHistory.where((item) => 
      item.date.isAfter(startDate.subtract(const Duration(days: 1)))
    ).toList();
  }

  /// Создать копию с новыми значениями
  Goal copyWith({
    String? name,
    String? emoji,
    double? currentValue,
    double? targetValue,
    String? unit,
    int? daysPassed,
    GoalType? type,
    String? colorHex,
  }) {
    return Goal(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      daysPassed: daysPassed ?? this.daysPassed,
      type: type ?? this.type,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Тип цели
@HiveType(typeId: 11)
enum GoalType {
  @HiveField(0)
  increase, // Увеличение значения (накопить деньги, набрать вес и т.д.)
  
  @HiveField(1)
  decrease, // Уменьшение значения (сбросить вес, сократить расходы и т.д.)
}

/// Фабрика для создания предустановленных целей
class GoPRIMEctory {
  /// Создать цель "Накопить деньги"
  static Goal createMoneyGoal({
    double targetAmount = 50000,
    double currentAmount = 0,
  }) {
    return Goal(
      id: 'money_goal',
      name: 'ДЕНЬГИ',
      emoji: '💰',
      currentValue: currentAmount,
      targetValue: targetAmount,
      unit: '\$',
      type: GoalType.increase,
      colorHex: '#FFD700', // Золотой
    );
  }

  /// Создать цель "Похудеть"
  static Goal createWeightLossGoal({
    double targetWeight = 100,
    double currentWeight = 127,
  }) {
    return Goal(
      id: 'weight_goal',
      name: 'ТЕЛО',
      emoji: '🏃',
      currentValue: currentWeight,
      targetValue: targetWeight,
      unit: 'кг',
      type: GoalType.decrease,
      colorHex: '#FF6B6B', // Красный
    );
  }

  /// Создать цель "Развить силу воли"
  static Goal createWillpowerGoal({
    double targetDays = 365,
    double currentDays = 0,
  }) {
    return Goal(
      id: 'will_goal',
      name: 'ВОЛЯ',
      emoji: '💪',
      currentValue: currentDays,
      targetValue: targetDays,
      unit: ' дней',
      type: GoalType.increase,
      colorHex: '#4ECDC4', // Бирюзовый
    );
  }

  /// Создать цель "Улучшить фокус"
  static Goal createFocusGoal({
    double targetHours = 1000,
    double currentHours = 0,
  }) {
    return Goal(
      id: 'focus_goal',
      name: 'ФОКУС',
      emoji: '🎯',
      currentValue: currentHours,
      targetValue: targetHours,
      unit: 'ч',
      type: GoalType.increase,
      colorHex: '#45B7D1', // Синий
    );
  }

  /// Создать цель "Развить разум"
  static Goal createMindGoal({
    double targetBooks = 52,
    double currentBooks = 0,
  }) {
    return Goal(
      id: 'mind_goal',
      name: 'РАЗУМ',
      emoji: '🧠',
      currentValue: currentBooks,
      targetValue: targetBooks,
      unit: ' книг',
      type: GoalType.increase,
      colorHex: '#9B59B6', // Фиолетовый
    );
  }

  /// Создать цель "Обрести спокойствие"
  static Goal createPeaceGoal({
    double targetSessions = 365,
    double currentSessions = 0,
  }) {
    return Goal(
      id: 'peace_goal',
      name: 'СПОКОЙСТВИЕ',
      emoji: '🧘',
      currentValue: currentSessions,
      targetValue: targetSessions,
      unit: ' сессий',
      type: GoalType.increase,
      colorHex: '#2ECC71', // Зеленый
    );
  }

  /// Получить список всех предустановленных целей
  static List<Goal> getDefaultGoals() {
    return [
      createMoneyGoal(),
      createWeightLossGoal(),
      createWillpowerGoal(),
      createFocusGoal(),
      createMindGoal(),
      createPeaceGoal(),
    ];
  }

  /// Получить список всех целей с демо-данными для графиков
  static List<Goal> getDefaultGoalsWithDemoData() {
    final goals = [
      createMoneyGoal(currentAmount: 12500),
      createWeightLossGoal(currentWeight: 122),
      createWillpowerGoal(currentDays: 67),
      createFocusGoal(currentHours: 156),
      createMindGoal(currentBooks: 12),
      createPeaceGoal(currentSessions: 89),
    ];
    
    // Устанавливаем дни прогресса
    goals[0].daysPassed = 89;
    goals[1].daysPassed = 45;
    goals[2].daysPassed = 67;
    goals[3].daysPassed = 78;
    goals[4].daysPassed = 120;
    goals[5].daysPassed = 95;
    
    // Добавляем демо-данные для каждой цели
    for (final goal in goals) {
      _addDemoHistoryData(goal);
    }
    
    return goals;
  }

  /// Добавить демо-данные истории для цели
  static void _addDemoHistoryData(Goal goal) {
    final now = DateTime.now();
    final history = <DailyGoalValue>[];
    
    // Генерируем данные за последние 7 дней
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      double value;
      
      switch (goal.type) {
        case GoalType.increase:
          // Постепенный рост к текущему значению
          value = goal.currentValue * (1.0 - (i * 0.05));
          break;
        case GoalType.decrease:
          // Постепенное снижение к текущему значению
          value = goal.currentValue * (1.0 + (i * 0.02));
          break;
      }
      
      // Добавляем немного случайности для реалистичности
      value += (i % 2 == 0 ? 1 : -1) * (value * 0.01);
      
      history.add(DailyGoalValue(
        date: DateTime(date.year, date.month, date.day),
        value: value,
        note: i == 0 ? 'Сегодня' : null,
      ));
    }
    
    goal.dailyHistory.addAll(history);
  }
}

/// Модель ежедневного значения цели для графика прогресса
@HiveType(typeId: 12)
class DailyGoalValue extends HiveObject {
  /// Дата записи
  @HiveField(0)
  final DateTime date;
  
  /// Значение на эту дату
  @HiveField(1)
  final double value;
  
  /// Дополнительная заметка (опционально)
  @HiveField(2)
  final String? note;

  DailyGoalValue({
    required this.date,
    required this.value,
    this.note,
  });

  /// Создать копию с новыми значениями
  DailyGoalValue copyWith({
    DateTime? date,
    double? value,
    String? note,
  }) {
    return DailyGoalValue(
      date: date ?? this.date,
      value: value ?? this.value,
      note: note ?? this.note,
    );
  }

  @override
  String toString() {
    return 'DailyGoalValue(date: $date, value: $value, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyGoalValue &&
        other.date == date &&
        other.value == value &&
        other.note == note;
  }

  @override
  int get hashCode => date.hashCode ^ value.hashCode ^ note.hashCode;
}
