import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import '../../../app/services/supabase_service.dart';
import '../models/user_progress_model.dart';

/// Provider для контроллера прогресса
final progressControllerProvider =
    StateNotifierProvider<ProgressController, UserProgress>((ref) {
      return ProgressController();
    });

/// Provider для привычек пользователя
final userHabitsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabaseService = SupabaseService();
  return supabaseService.loadUserHabits();
});

/// Provider для привычек пользователя с реальным прогрессом
final userHabitsWithProgressProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final supabaseService = SupabaseService();
  final habitsData = await supabaseService.loadUserHabits();
  // Batched fetch for today's actuals keyed by user_habit_id
  final todayActuals = await supabaseService.getTodayHabitActuals();

  final habitsWithProgress = <Map<String, dynamic>>[];
  for (final userHabit in habitsData) {
    final habit = userHabit['habits'] ?? {};
    final String? userHabitId = (userHabit['id'] as String?);
    final String? habitCatalogId = (userHabit['habit_id'] as String?);
    final int target = (userHabit['target_value'] ?? 1) as int;

    if (userHabitId == null) continue;

    final actual = todayActuals[userHabitId] ?? 0;
    final completed = actual >= target;

    habitsWithProgress.add({
      'name': habit['name'] ?? 'Неизвестная привычка',
      'progress': '$actual / $target',
      'done': completed,
      'user_habit_id': userHabitId,
      'habit_id': habitCatalogId,
      'category': habit['category'],
      'target_value': target,
      'actual_value': actual,
    });
  }

  return habitsWithProgress;
});

/// Контроллер для управления прогрессом пользователя
class ProgressController extends StateNotifier<UserProgress> {
  static const String _boxName = 'user_progress';
  Box<UserProgress>? _box;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SupabaseService _supabaseService = SupabaseService();

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

    // Сначала пытаемся загрузить из Supabase
    final supabaseProgress = await _supabaseService.loadUserProgress();
    if (supabaseProgress != null) {
      // Если это старая демо-запись, сбрасываем на нули
      if (_looksLikeDemoProgress(supabaseProgress)) {
        state = UserProgress();
        await _saveProgress();
      } else {
        state = supabaseProgress;
        // Синхронизируем с локальным хранилищем
        await _saveProgress();
      }
      return;
    }

    // Fallback: загружаем из Hive и, если есть данные, поднимаем их в Supabase
    final savedProgress = _box?.get('current');
    if (savedProgress != null) {
      // Если локально лежит старая демо-запись, игнорируем её
      if (_looksLikeDemoProgress(savedProgress)) {
        state = UserProgress();
      } else {
        state = savedProgress;
      }
      await _saveProgress();
    } else {
      // Без демо: инициализируем нулями и создаём запись на бэке
      state = UserProgress();
      await _saveProgress();
    }
  }

  // Убрали демо-инициализацию: прогресс начинается с нулей и сразу синхронизируется с Supabase

  /// Эвристика для определения старых демо-данных, чтобы не показывать 3 и 40%
  bool _looksLikeDemoProgress(UserProgress p) {
    final sphere = p.sphereProgress;
    final demoSphere = {
      'body': 0.8,
      'will': 0.6,
      'focus': 0.4,
      'mind': 0.3,
      'peace': 0.2,
      'money': 0.1,
    };
    final spheresMatch = sphere.length == demoSphere.length &&
        demoSphere.entries.every((e) => (sphere[e.key] ?? -1) == e.value);

    return p.currentStreak == 3 &&
        p.totalSteps == 47 &&
        p.totalXP == 2847 &&
        p.currentZone == 'ВОЛЯ' &&
        spheresMatch;
  }

  /// Сохранить прогресс в базу
  Future<void> _saveProgress() async {
    await _box?.put('current', state);
    // Синхронизируем с Supabase
    await _supabaseService.saveUserProgress(state);
  }

  /// Добавить выполненную привычку
  Future<void> completeHabit(
    String habitName,
    String habitType, {
    int xpGain = 50,
  }) async {
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
  void _updateTodayProgress(
    UserProgress progress,
    String habitName,
    int xpGain,
  ) {
    final today = DateTime.now();
    final todayIndex = progress.progressHistory.indexWhere(
      (day) =>
          day.date.year == today.year &&
          day.date.month == today.month &&
          day.date.day == today.day,
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
      progress.progressHistory.add(
        DayProgress(
          date: today,
          stepsCompleted: 1,
          completedHabits: [habitName],
          xpEarned: xpGain,
          dailyStats: {},
        ),
      );
    }
  }

  /// Воспроизвести звуковые эффекты успеха
  Future<void> _playSuccessEffects() async {
    try {
      // Тактильная обратная связь
      if (await Vibration.hasVibrator()) {
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
      achievements.add(
        Achievement(
          id: 'first_week',
          title: 'Неделя силы',
          description: '7 дней подряд без пропусков!',
          iconName: '🔥',
          unlockedAt: DateTime.now(),
          xpReward: 200,
        ),
      );
    }

    // Достижения за количество ступенек
    if (state.totalSteps == 50) {
      achievements.add(
        Achievement(
          id: 'fifty_steps',
          title: 'Полсотни',
          description: '50 ступенек пройдено!',
          iconName: '⭐',
          unlockedAt: DateTime.now(),
          xpReward: 150,
        ),
      );
    }

    // Достижения за смену зоны
    if (state.currentZone != _getPreviousZone()) {
      achievements.add(
        Achievement(
          id: 'zone_${state.currentZone.toLowerCase()}',
          title: 'Новая зона: ${state.currentZone}',
          description: 'Добро пожаловать в зону ${state.currentZone}!',
          iconName: '🏆',
          unlockedAt: DateTime.now(),
          xpReward: 300,
        ),
      );
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
        .where((day) => DateTime.now().difference(day.date).inDays <= days)
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

  /// Принудительно синхронизировать прогресс с Supabase
  Future<void> syncWithSupabase() async {
    try {
      await _supabaseService.saveUserProgress(state);
    } catch (e) {
      print('Error syncing with Supabase: $e');
    }
  }

  /// Загрузить прогресс из Supabase и обновить локальное состояние
  Future<void> loadProgressFromSupabase() async {
    try {
      final supabaseProgress = await _supabaseService.loadUserProgress();
      if (supabaseProgress != null) {
        state = supabaseProgress;
        await _saveProgress();
      }
    } catch (e) {
      print('Error loading progress from Supabase: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Provider для статистики за все время
final allTimeStatsProvider = Provider<Map<String, dynamic>>((ref) {
  // Читаем контроллер напрямую; состояние здесь не нужно
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

/// Provider недельной сводки
final weeklyStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final supabaseService = SupabaseService();
  return supabaseService.getWeeklyOverview();
});
