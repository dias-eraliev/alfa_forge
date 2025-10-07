import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/services/habits_service.dart';
import '../../../core/services/tasks_service.dart';
import '../../../core/models/api_models.dart';
import '../../../core/providers/auth_provider.dart';

// Создаем instance сервиса прогресса
final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

// ========== DASHBOARD DATA ==========

/// Провайдер для получения данных дашборда
final dashboardProvider = FutureProvider<ApiDashboard>((ref) async {
  final progressService = ref.watch(progressServiceProvider);
  final response = await progressService.getDashboard();
  
  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(response.error);
  }
});

/// Провайдер для статистики дашборда 
final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final progressService = ref.watch(progressServiceProvider);
  final response = await progressService.getDashboardStats();
  
  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(response.error);
  }
});

/// Провайдер для прогресса по сферам
final sphereProgressProvider = FutureProvider<Map<String, double>>((ref) async {
  final progressService = ref.watch(progressServiceProvider);
  final response = await progressService.getSphereProgress();
  
  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(response.error);
  }
});

/// Провайдер для дневной цитаты
final dailyQuoteProvider = FutureProvider<String>((ref) async {
  final progressService = ref.watch(progressServiceProvider);
  final response = await progressService.getDailyQuote();
  
  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(response.error);
  }
});

// ========== TODAY'S DATA ==========

// Создаем providers для сервисов
final habitsServiceProvider = Provider<HabitsService>((ref) {
  return HabitsService();
});

final tasksServiceProvider = Provider<TasksService>((ref) {
  return TasksService();
});

/// Провайдер для сегодняшних привычек
final todayHabitsProvider = FutureProvider<List<ApiHabit>>((ref) async {
  final habitsService = ref.watch(habitsServiceProvider);
  final response = await habitsService.getTodayHabits();
  
  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(response.error);
  }
});

/// Провайдер для быстрых задач
final quickTasksProvider = FutureProvider<List<ApiTask>>((ref) async {
  final tasksService = ref.watch(tasksServiceProvider);
  final response = await tasksService.getQuickTasks();
  
  if (response.isSuccess) {
    return response.data!;
  } else {
    throw Exception(response.error);
  }
});

// ========== USER PROGRESS ==========

/// Провайдер для прогресса пользователя из AuthProvider
final userProgressProvider = Provider<ApiUserProgress?>((ref) {
  // Получаем пользователя из AuthProvider
  final authProviderState = ref.watch(authProviderNotifier);
  return authProviderState.user?.progress.isNotEmpty == true 
      ? authProviderState.user!.progress.first 
      : null;
});

/// Провайдер для основных метрик
final userMetricsProvider = Provider<Map<String, dynamic>>((ref) {
  final userProgress = ref.watch(userProgressProvider);
  
  if (userProgress == null) {
    return {
      'streak': 0,
      'totalPoints': 0,
      'nextLevelPoints': 100,
      'currentRank': 'НОВИЧОК',
      'currentZone': 'BODY',
    };
  }
  
  // Расчет следующего уровня (простая логика)
  final currentPoints = userProgress.totalXP;
  final nextLevelPoints = ((currentPoints ~/ 100) + 1) * 100;
  
  return {
    'streak': userProgress.currentStreak,
    'totalPoints': currentPoints,
    'nextLevelPoints': nextLevelPoints,
    'currentRank': userProgress.currentRank,
    'currentZone': userProgress.currentZone,
  };
});

// ========== PATH PAGE STATE ==========

/// Состояние PathPage
class PathPageState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? dashboardStats;
  final List<ApiHabit> todayHabits;
  final List<ApiTask> quickTasks;
  final Map<String, double> sphereProgress;
  final String? dailyQuote;

  const PathPageState({
    this.isLoading = false,
    this.error,
    this.dashboardStats,
    this.todayHabits = const [],
    this.quickTasks = const [],
    this.sphereProgress = const {},
    this.dailyQuote,
  });

  PathPageState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? dashboardStats,
    List<ApiHabit>? todayHabits,
    List<ApiTask>? quickTasks,
    Map<String, double>? sphereProgress,
    String? dailyQuote,
  }) {
    return PathPageState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      dashboardStats: dashboardStats ?? this.dashboardStats,
      todayHabits: todayHabits ?? this.todayHabits,
      quickTasks: quickTasks ?? this.quickTasks,
      sphereProgress: sphereProgress ?? this.sphereProgress,
      dailyQuote: dailyQuote ?? this.dailyQuote,
    );
  }
}

/// Контроллер PathPage
class PathPageController extends StateNotifier<PathPageState> {
  final ProgressService _progressService;
  final HabitsService _habitsService;
  final TasksService _tasksService;

  PathPageController(
    this._progressService,
    this._habitsService,
    this._tasksService,
  ) : super(const PathPageState());

  /// Загрузить все данные для PathPage
  Future<void> loadAllData() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Загружаем все данные параллельно
      final results = await Future.wait([
        _loadDashboardStats(),
        _loadTodayHabits(),
        _loadQuickTasks(),
        _loadSphereProgress(),
        _loadDailyQuote(),
      ]);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Ошибка загрузки данных: $e',
      );
    }
  }

  /// Загрузить статистику дашборда
  Future<void> _loadDashboardStats() async {
    final response = await _progressService.getDashboardStats();
    if (response.isSuccess) {
      state = state.copyWith(dashboardStats: response.data);
    }
  }

  /// Загрузить сегодняшние привычки
  Future<void> _loadTodayHabits() async {
    final response = await _habitsService.getTodayHabits();
    if (response.isSuccess) {
      state = state.copyWith(todayHabits: response.data ?? []);
    }
  }

  /// Загрузить быстрые задачи
  Future<void> _loadQuickTasks() async {
    final response = await _tasksService.getQuickTasks();
    if (response.isSuccess) {
      state = state.copyWith(quickTasks: response.data ?? []);
    }
  }

  /// Загрузить прогресс по сферам
  Future<void> _loadSphereProgress() async {
    final response = await _progressService.getSphereProgress();
    if (response.isSuccess) {
      state = state.copyWith(sphereProgress: response.data ?? {});
    }
  }

  /// Загрузить дневную цитату
  Future<void> _loadDailyQuote() async {
    final response = await _progressService.getDailyQuote();
    if (response.isSuccess) {
      state = state.copyWith(dailyQuote: response.data);
    }
  }

  /// Переключить статус привычки
  Future<void> toggleHabit(String habitId) async {
    try {
      final response = await _habitsService.toggleHabitCompletion(habitId);
      if (response.isSuccess) {
        // Обновляем локальное состояние
        final updatedHabits = state.todayHabits.map((habit) {
          if (habit.id == habitId) {
            // Создаем обновленную привычку (упрощенно)
            // В реальности нужно получить обновленные данные с сервера
            return habit;
          }
          return habit;
        }).toList();
        
        state = state.copyWith(todayHabits: updatedHabits);
        
        // Перезагружаем статистику
        await _loadDashboardStats();
      }
    } catch (e) {
      state = state.copyWith(error: 'Ошибка обновления привычки: $e');
    }
  }

  /// Переключить статус задачи
  Future<void> toggleTask(String taskId) async {
    try {
      final response = await _tasksService.toggleTaskCompletion(taskId);
      if (response.isSuccess) {
        // Обновляем локальное состояние
        final updatedTasks = state.quickTasks.map((task) {
          if (task.id == taskId) {
            // Создаем обновленную задачу
            return ApiTask(
              id: task.id,
              title: task.title,
              description: task.description,
              priority: task.priority,
              status: task.isCompleted ? 'pending' : 'completed',
              dueDate: task.dueDate,
              category: task.category,
              isCompleted: !task.isCompleted,
              createdAt: task.createdAt,
            );
          }
          return task;
        }).toList();
        
        state = state.copyWith(quickTasks: updatedTasks);
        
        // Перезагружаем статистику
        await _loadDashboardStats();
      }
    } catch (e) {
      state = state.copyWith(error: 'Ошибка обновления задачи: $e');
    }
  }

  /// Обновить данные
  Future<void> refresh() async {
    await loadAllData();
  }

  /// Очистить ошибку
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Провайдер контроллера PathPage
final pathPageControllerProvider = StateNotifierProvider<PathPageController, PathPageState>((ref) {
  final progressService = ref.watch(progressServiceProvider);
  final habitsService = ref.watch(habitsServiceProvider);
  final tasksService = ref.watch(tasksServiceProvider);
  
  return PathPageController(progressService, habitsService, tasksService);
});

// ========== COMPUTED PROVIDERS ==========

/// Провайдер для общей статистики дня
final dailyStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final pathState = ref.watch(pathPageControllerProvider);
  final userMetrics = ref.watch(userMetricsProvider);
  
  final completedHabits = pathState.todayHabits.where((h) => 
    h.completions.any((c) => 
      c.date.day == DateTime.now().day &&
      c.date.month == DateTime.now().month &&
      c.date.year == DateTime.now().year
    )
  ).length;
  
  final completedTasks = pathState.quickTasks.where((t) => t.isCompleted).length;
  
  final totalProgress = pathState.todayHabits.isEmpty && pathState.quickTasks.isEmpty
      ? 0.0
      : (completedHabits + completedTasks) / (pathState.todayHabits.length + pathState.quickTasks.length);
  
  return {
    'completedHabits': completedHabits,
    'totalHabits': pathState.todayHabits.length,
    'completedTasks': completedTasks,
    'totalTasks': pathState.quickTasks.length,
    'totalProgress': totalProgress,
    'streak': userMetrics['streak'] ?? 0,
    'totalPoints': userMetrics['totalPoints'] ?? 0,
    'currentRank': userMetrics['currentRank'] ?? 'НОВИЧОК',
  };
});

/// Провайдер для проверки загрузки
final isPathPageLoadingProvider = Provider<bool>((ref) {
  final pathState = ref.watch(pathPageControllerProvider);
  return pathState.isLoading;
});

/// Провайдер для ошибок
final pathPageErrorProvider = Provider<String?>((ref) {
  final pathState = ref.watch(pathPageControllerProvider);
  return pathState.error;
});
