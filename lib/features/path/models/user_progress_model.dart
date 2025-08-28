import 'package:hive/hive.dart';

part 'user_progress_model.g.dart';

/// Модель данных для отслеживания прогресса пользователя
@HiveType(typeId: 0)
class UserProgress extends HiveObject {
  @HiveField(0)
  int totalSteps;              // Всего ступенек пройдено

  @HiveField(1)
  int currentStreak;           // Текущий стрик дней

  @HiveField(2)
  int longestStreak;           // Самый длинный стрик

  @HiveField(3)
  Map<String, int> totalStats;  // Общая статистика (калории, задачи и т.д.)

  @HiveField(4)
  List<DayProgress> progressHistory; // История прогресса по дням

  @HiveField(5)
  String currentZone;          // Текущая зона (ТЕЛО, ВОЛЯ и т.д.)

  @HiveField(6)
  int totalXP;                 // Общий опыт

  @HiveField(7)
  DateTime lastActiveDate;     // Последний активный день

  @HiveField(8)
  Map<String, double> sphereProgress; // Прогресс по сферам (0.0-1.0)

  UserProgress({
    this.totalSteps = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    Map<String, int>? totalStats,
    List<DayProgress>? progressHistory,
    this.currentZone = 'ТЕЛО',
    this.totalXP = 0,
    DateTime? lastActiveDate,
    Map<String, double>? sphereProgress,
  }) : totalStats = totalStats ?? _defaultStats(),
       progressHistory = progressHistory ?? [],
       lastActiveDate = lastActiveDate ?? DateTime.now(),
       sphereProgress = sphereProgress ?? _defaultSphereProgress();

  static Map<String, int> _defaultStats() => {
    'calories_burned': 0,
    'tasks_completed': 0,
    'water_liters': 0,
    'books_read': 0,
    'meditation_hours': 0,
    'workouts_done': 0,
    'focus_sessions': 0,
  };

  static Map<String, double> _defaultSphereProgress() => {
    'body': 0.0,
    'will': 0.0,
    'focus': 0.0,
    'mind': 0.0,
    'peace': 0.0,
    'money': 0.0,
  };

  /// Получить текущий ранг пользователя
  String get currentRank {
    final overallProgress = getOverallProgress();
    if (overallProgress < 0.15) return 'НОВИЧОК';
    if (overallProgress < 0.35) return 'УЧЕНИК';
    if (overallProgress < 0.55) return 'ВОИН';
    if (overallProgress < 0.75) return 'ГЕРОЙ';
    if (overallProgress < 0.90) return 'МАСТЕР';
    return 'АЛЬФА';
  }

  /// Получить общий прогресс (0.0-1.0)
  double getOverallProgress() {
    if (sphereProgress.isEmpty) return 0.0;
    final total = sphereProgress.values.reduce((a, b) => a + b);
    return total / sphereProgress.length;
  }

  /// Получить прогресс в текущей зоне
  String getCurrentZoneInfo() {
    final progress = (getOverallProgress() * 600).toInt(); // 600 = общее количество ступенек
    final zoneSteps = progress % 100; // 100 ступенек на зону
    return 'Ступенька $zoneSteps/100 в зоне $currentZone';
  }

  /// Добавить шаг (выполненную привычку)
  void addStep(String habitType, int xpGain) {
    totalSteps++;
    totalXP += xpGain;
    
    // Обновляем прогресс сферы
    final sphereKey = _getSphereKey(habitType);
    if (sphereProgress.containsKey(sphereKey)) {
      sphereProgress[sphereKey] = (sphereProgress[sphereKey]! + 0.01).clamp(0.0, 1.0);
    }

    // Проверяем смену зоны
    _updateCurrentZone();
    
    // Обновляем дату активности
    final today = DateTime.now();
    if (!_isSameDay(lastActiveDate, today)) {
      if (_isConsecutiveDay(lastActiveDate, today)) {
        currentStreak++;
      } else {
        currentStreak = 1; // Сброс стрика
      }
      lastActiveDate = today;
      
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    }
  }

  /// Получить ключ сферы по типу привычки
  String _getSphereKey(String habitType) {
    switch (habitType.toLowerCase()) {
      case 'workout': case 'run': case 'gym': return 'body';
      case 'meditation': case 'breathing': return 'peace';  
      case 'reading': case 'learning': return 'mind';
      case 'work': case 'business': return 'money';
      case 'focus': case 'deep_work': return 'focus';
      default: return 'will';
    }
  }

  /// Обновить текущую зону
  void _updateCurrentZone() {
    final progress = getOverallProgress();
    if (progress < 0.17) currentZone = 'ТЕЛО';
    else if (progress < 0.34) currentZone = 'ВОЛЯ';
    else if (progress < 0.51) currentZone = 'ФОКУС';
    else if (progress < 0.68) currentZone = 'РАЗУМ';
    else if (progress < 0.85) currentZone = 'СПОКОЙСТВИЕ';
    else currentZone = 'ДЕНЬГИ';
  }

  /// Проверить, тот ли день
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  /// Проверить, следующий ли день
  bool _isConsecutiveDay(DateTime lastDate, DateTime currentDate) {
    final difference = currentDate.difference(lastDate).inDays;
    return difference == 1;
  }
}

/// Модель прогресса за день
@HiveType(typeId: 1)
class DayProgress extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int stepsCompleted;

  @HiveField(2)
  List<String> completedHabits;

  @HiveField(3)
  int xpEarned;

  @HiveField(4)
  Map<String, int> dailyStats;

  DayProgress({
    required this.date,
    this.stepsCompleted = 0,
    List<String>? completedHabits,
    this.xpEarned = 0,
    Map<String, int>? dailyStats,
  }) : completedHabits = completedHabits ?? [],
       dailyStats = dailyStats ?? {};

  /// Процент выполнения дня (0.0-1.0)
  double get completionPercentage {
    // Предполагаем, что в день нужно выполнить 5-7 привычек
    const targetHabits = 6;
    return (completedHabits.length / targetHabits).clamp(0.0, 1.0);
  }

  /// Получить цвет дня для визуализации
  String get dayColor {
    final completion = completionPercentage;
    if (completion >= 0.8) return 'gold';      // Отличный день
    if (completion >= 0.6) return 'green';     // Хороший день
    if (completion >= 0.4) return 'yellow';    // Средний день
    if (completion >= 0.2) return 'orange';    // Плохой день
    return 'red';                              // Очень плохой день
  }
}

/// Модель достижения
@HiveType(typeId: 2)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String iconName;

  @HiveField(4)
  DateTime unlockedAt;

  @HiveField(5)
  int xpReward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.unlockedAt,
    this.xpReward = 100,
  });
}
