import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../models/user_progress_model.dart';

/// Provider для контроллера прогресса
final progressControllerProvider = StateNotifierProvider<ProgressController, UserProgress>((ref) {
  return ProgressController();
});

/// Контроллер для управления прогрессом пользователя
class ProgressController extends StateNotifier<UserProgress> {
  static const String _boxName = 'user_progress';
  Box<UserProgress>? _box;
  final AudioPlayer _audioPlayer = AudioPlayer();

  ProgressController() : super(UserProgress()) {
    _initializeHive();
  }

  /// Инициализация Hive базы данных
  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    
    // Регистрируем адаптеры
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DayProgressAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(AchievementAdapter());
    }

    // Открываем бокс
    _box = await Hive.openBox<UserProgress>(_boxName);
    
    // Загружаем сохраненный прогресс или создаем новый
    final savedProgress = _box?.get('current');
    if (savedProgress != null) {
      state = savedProgress;
    } else {
      // Создаем демо-данные для показа
      state = _createDemoProgress();
      await _saveProgress();
    }
  }

  /// Создать демо-данные для демонстрации
  UserProgress _createDemoProgress() {
    final demoProgress = UserProgress(
      totalSteps: 47,
      currentStreak: 3,
      longestStreak: 12,
      totalXP: 2847,
      currentZone: 'ВОЛЯ',
    );

    // Заполняем статистику
    demoProgress.totalStats.addAll({
      'calories_burned': 15420,
      'tasks_completed': 234,
      'water_liters': 486,
      'books_read': 12,
      'meditation_hours': 45,
      'workouts_done': 89,
      'focus_sessions': 156,
    });

    // Устанавливаем прогресс по сферам
    demoProgress.sphereProgress.addAll({
      'body': 0.8,
      'will': 0.6,
      'focus': 0.4,
      'mind': 0.3,
      'peace': 0.2,
      'money': 0.1,
    });

    // Добавляем историю последних дней
    final today = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final completedHabits = i == 0 ? ['Вода 2L', 'Медитация'] : 
                             i <= 3 ? ['Вода 2L', 'Бег 5км', 'Медитация', 'Чтение', 'Работа'] :
                             ['Вода 2L', 'Медитация', 'Чтение'];
      
      demoProgress.progressHistory.add(DayProgress(
        date: date,
        stepsCompleted: completedHabits.length,
        completedHabits: completedHabits,
        xpEarned: completedHabits.length * 50,
        dailyStats: {
          'calories': i <= 3 ? 400 : 0,
          'water': 2000,
          'meditation': 300,
        },
      ));
    }

    return demoProgress;
  }

  /// Сохранить прогресс в базу
  Future<void> _saveProgress() async {
    await _box?.put('current', state);
  }

  /// Добавить выполненную привычку
  Future<void> completeHabit(String habitName, String habitType, {int xpGain = 50}) async {
    final newState = UserProgress(
      totalSteps: state.totalSteps + 1,
      currentStreak: state.currentStreak,
      longestStreak: state.longestStreak,
      totalStats: Map.from(state.totalStats),
      progressHistory: List.from(state.progressHistory),
      currentZone: state.currentZone,
      totalXP: state.totalXP + xpGain,
      lastActiveDate: state.lastActiveDate,
      sphereProgress: Map.from(state.sphereProgress),
    );

    // Обновляем прогресс через метод модели
    newState.addStep(habitType, xpGain);

    // Обновляем сегодняшний прогресс
    _updateTodayProgress(newState, habitName, xpGain);

    state = newState;
    await _saveProgress();

    // Проигрываем звук и вибрацию
    await _playSuccessEffects();

    // Проверяем достижения
    _checkAchievements();
  }

  /// Обновить прогресс за сегодня
  void _updateTodayProgress(UserProgress progress, String habitName, int xpGain) {
    final today = DateTime.now();
    final todayIndex = progress.progressHistory.indexWhere((day) => 
      day.date.year == today.year && 
      day.date.month == today.month && 
      day.date.day == today.day
    );

    if (todayIndex != -1) {
      // Обновляем существующий день
      final todayProgress = progress.progressHistory[todayIndex];
      if (!todayProgress.completedHabits.contains(habitName)) {
        todayProgress.completedHabits.add(habitName);
        todayProgress.stepsCompleted++;
        todayProgress.xpEarned += xpGain;
      }
    } else {
      // Создаем новый день
      progress.progressHistory.add(DayProgress(
        date: today,
        stepsCompleted: 1,
        completedHabits: [habitName],
        xpEarned: xpGain,
        dailyStats: {},
      ));
    }
  }

  /// Воспроизвести звуковые эффекты успеха
  Future<void> _playSuccessEffects() async {
    try {
      // Тактильная обратная связь
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 100, amplitude: 128);
      }

      // Звуковой эффект (можно добавить файл в assets/sounds/)
      // await _audioPlayer.play(AssetSource('sounds/step_complete.mp3'));
    } catch (e) {
      // Игнорируем ошибки звука/вибрации
      print('Sound/Vibration error: $e');
    }
  }

  /// Проверить и разблокировать достижения
  void _checkAchievements() {
    final achievements = <Achievement>[];

    // Достижения за стрики
    if (state.currentStreak == 7) {
      achievements.add(Achievement(
        id: 'first_week',
        title: 'Неделя силы',
        description: '7 дней подряд без пропусков!',
        iconName: '🔥',
        unlockedAt: DateTime.now(),
        xpReward: 200,
      ));
    }

    // Достижения за количество ступенек
    if (state.totalSteps == 50) {
      achievements.add(Achievement(
        id: 'fifty_steps',
        title: 'Полсотни',
        description: '50 ступенек пройдено!',
        iconName: '⭐',
        unlockedAt: DateTime.now(),
        xpReward: 150,
      ));
    }

    // Достижения за смену зоны
    if (state.currentZone != _getPreviousZone()) {
      achievements.add(Achievement(
        id: 'zone_${state.currentZone.toLowerCase()}',
        title: 'Новая зона: ${state.currentZone}',
        description: 'Добро пожаловать в зону ${state.currentZone}!',
        iconName: '🏆',
        unlockedAt: DateTime.now(),
        xpReward: 300,
      ));
    }

    // Показать достижения (можно добавить уведомления)
    for (final achievement in achievements) {
      _showAchievementNotification(achievement);
    }
  }

  /// Получить предыдущую зону (упрощенная логика)
  String _getPreviousZone() {
    // Логика определения предыдущей зоны на основе прогресса
    return 'ТЕЛО'; // Заглушка
  }

  /// Показать уведомление о достижении
  void _showAchievementNotification(Achievement achievement) {
    // Здесь можно добавить логику показа уведомлений
    print('🏆 Достижение разблокировано: ${achievement.title}');
  }

  /// Получить статистику за все время
  Map<String, dynamic> getAllTimeStats() {
    return {
      'total_steps': state.totalSteps,
      'total_xp': state.totalXP,
      'current_streak': state.currentStreak,
      'longest_streak': state.longestStreak,
      'current_rank': state.currentRank,
      'overall_progress': (state.getOverallProgress() * 100).toInt(),
      'zone_info': state.getCurrentZoneInfo(),
      'detailed_stats': state.totalStats,
    };
  }

  /// Получить прогресс за последние дни
  List<DayProgress> getRecentProgress({int days = 7}) {
    final recent = state.progressHistory
        .where((day) => 
            DateTime.now().difference(day.date).inDays <= days)
        .toList();
    recent.sort((a, b) => b.date.compareTo(a.date));
    return recent;
  }

  /// Получить прогресс по сферам для визуализации
  Map<String, double> getSphereProgress() {
    return Map.from(state.sphereProgress);
  }

  /// Сбросить прогресс (для тестирования)
  Future<void> resetProgress() async {
    state = UserProgress();
    await _saveProgress();
  }

  /// Получить данные для Альфа-лестницы
  Map<String, dynamic> getStairData() {
    final spheres = ['ТЕЛО', 'ВОЛЯ', 'ФОКУС', 'РАЗУМ', 'СПОКОЙСТВИЕ', 'ДЕНЬГИ'];
    final currentStepInZone = (state.totalSteps % 100);
    final completedZones = (state.totalSteps ~/ 100);
    
    return {
      'character_position': state.totalSteps,
      'current_zone': state.currentZone,
      'current_step_in_zone': currentStepInZone,
      'completed_zones': completedZones,
      'next_zone': completedZones < 5 ? spheres[completedZones + 1] : 'АЛЬФА',
      'progress_to_next_zone': currentStepInZone / 100.0,
      'overall_progress': state.getOverallProgress(),
      'character_rank': state.currentRank,
    };
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Provider для статистики за все время
final allTimeStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final progress = ref.watch(progressControllerProvider);
  final controller = ref.read(progressControllerProvider.notifier);
  return controller.getAllTimeStats();
});

/// Provider для данных лестницы
final stairDataProvider = Provider<Map<String, dynamic>>((ref) {
  final controller = ref.read(progressControllerProvider.notifier);
  return controller.getStairData();
});

/// Provider для недавнего прогресса
final recentProgressProvider = Provider<List<DayProgress>>((ref) {
  final controller = ref.read(progressControllerProvider.notifier);
  return controller.getRecentProgress();
});
