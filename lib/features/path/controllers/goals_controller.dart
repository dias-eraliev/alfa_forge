import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/goal_model.dart';

/// Provider для контроллера целей
final goalsControllerProvider = StateNotifierProvider<GoalsController, List<Goal>>((ref) {
  return GoalsController();
});

/// Контроллер для управления целями пользователя
class GoalsController extends StateNotifier<List<Goal>> {
  static const String _boxName = 'user_goals';
  Box<Goal>? _box;

  GoalsController() : super([]) {
    _initializeHive();
  }

  /// Инициализация Hive базы данных
  Future<void> _initializeHive() async {
    await Hive.initFlutter();
    
    // Регистрируем адаптеры если еще не зарегистрированы
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(GoalAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(GoalTypeAdapter());
    }

    // Открываем бокс
    _box = await Hive.openBox<Goal>(_boxName);
    
    // Загружаем сохраненные цели или создаем демо-данные
    final savedGoals = _box?.values.toList() ?? [];
    if (savedGoals.isNotEmpty) {
      state = savedGoals;
    } else {
      // Создаем демо-цели с прогрессом
      state = _createDemoGoals();
      await _saveAllGoals();
    }
  }

  /// Создать демо-цели с начальным прогрессом
  List<Goal> _createDemoGoals() {
    final goals = GoPRIMEctory.getDefaultGoals();
    
    // Добавляем демо-прогресс
    goals[0].updateCurrentValue(12500); // Деньги: накоплено 12.5K из 50K
    goals[0].daysPassed = 89;
    
    goals[1].updateCurrentValue(122); // Вес: 122кг (цель 100кг, было 127кг)
    goals[1].daysPassed = 45;
    
    goals[2].updateCurrentValue(67); // Воля: 67 дней из 365
    goals[2].daysPassed = 67;
    
    goals[3].updateCurrentValue(156); // Фокус: 156 часов из 1000
    goals[3].daysPassed = 78;
    
    goals[4].updateCurrentValue(12); // Разум: 12 книг из 52
    goals[4].daysPassed = 120;
    
    goals[5].updateCurrentValue(89); // Спокойствие: 89 сессий из 365
    goals[5].daysPassed = 95;
    
    return goals;
  }

  /// Сохранить все цели
  Future<void> _saveAllGoals() async {
    if (_box == null) return;
    
    await _box!.clear();
    for (final goal in state) {
      await _box!.put(goal.id, goal);
    }
  }

  /// Обновить значение цели
  Future<void> updateGoalValue(String goalId, double newValue) async {
    final goals = [...state];
    final goalIndex = goals.indexWhere((g) => g.id == goalId);
    
    if (goalIndex != -1) {
      goals[goalIndex].updateCurrentValue(newValue);
      state = goals;
      await _box?.put(goalId, goals[goalIndex]);
    }
  }

  /// Добавить день прогресса к цели
  Future<void> addDayProgressToGoal(String goalId) async {
    final goals = [...state];
    final goalIndex = goals.indexWhere((g) => g.id == goalId);
    
    if (goalIndex != -1) {
      goals[goalIndex].addDayProgress();
      state = goals;
      await _box?.put(goalId, goals[goalIndex]);
    }
  }

  /// Добавить новую цель
  Future<void> addGoal(Goal goal) async {
    state = [...state, goal];
    await _box?.put(goal.id, goal);
  }

  /// Удалить цель
  Future<void> removeGoal(String goalId) async {
    state = state.where((goal) => goal.id != goalId).toList();
    await _box?.delete(goalId);
  }

  /// Обновить цель
  Future<void> updateGoal(Goal updatedGoal) async {
    final goals = [...state];
    final goalIndex = goals.indexWhere((g) => g.id == updatedGoal.id);
    
    if (goalIndex != -1) {
      goals[goalIndex] = updatedGoal;
      state = goals;
      await _box?.put(updatedGoal.id, updatedGoal);
    }
  }

  /// Получить цель по ID
  Goal? getGoalById(String goalId) {
    try {
      return state.firstWhere((goal) => goal.id == goalId);
    } catch (e) {
      return null;
    }
  }

  /// Получить общую статистику по всем целям
  Map<String, dynamic> getOverallStats() {
    if (state.isEmpty) return {};
    
    double totalProgress = 0.0;
    int completedGoals = 0;
    int totalDays = 0;
    
    for (final goal in state) {
      totalProgress += goal.progressPercent;
      if (goal.progressPercent >= 1.0) completedGoals++;
      totalDays += goal.daysPassed;
    }
    
    final averageProgress = totalProgress / state.length;
    final averageDays = totalDays / state.length;
    
    return {
      'total_goals': state.length,
      'completed_goals': completedGoals,
      'average_progress': averageProgress,
      'average_days': averageDays.round(),
      'overall_progress_percent': (averageProgress * 100).round(),
    };
  }

  /// Получить цели отсортированные по прогрессу (по убыванию)
  List<Goal> getGoalsSortedByProgress() {
    final goals = [...state];
    goals.sort((a, b) => b.progressPercent.compareTo(a.progressPercent));
    return goals;
  }

  /// Получить цели отсортированные по дням (по убыванию)
  List<Goal> getGoalsSortedByDays() {
    final goals = [...state];
    goals.sort((a, b) => b.daysPassed.compareTo(a.daysPassed));
    return goals;
  }

  /// Получить цели с наибольшим прогрессом (топ 3)
  List<Goal> getTopProgressGoals({int limit = 3}) {
    final sortedGoals = getGoalsSortedByProgress();
    return sortedGoals.take(limit).toList();
  }

  /// Проверить есть ли цели требующие внимания (мало прогресса за много дней)
  List<Goal> getGoalsNeedingAttention() {
    return state.where((goal) {
      // Цели которые длятся больше 30 дней, но прогресс меньше 20%
      return goal.daysPassed > 30 && goal.progressPercent < 0.2;
    }).toList();
  }

  /// Сбросить все цели (для тестирования)
  Future<void> resetAllGoals() async {
    await _box?.clear();
    state = [];
  }

  /// Восстановить демо-цели
  Future<void> restoreDemoGoals() async {
    state = _createDemoGoals();
    await _saveAllGoals();
  }

  @override
  void dispose() {
    _box?.close();
    super.dispose();
  }
}

/// Provider для общей статистики целей
final goalsStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final controller = ref.read(goalsControllerProvider.notifier);
  return controller.getOverallStats();
});

/// Provider для топ целей по прогрессу
final topGoalsProvider = Provider<List<Goal>>((ref) {
  final controller = ref.read(goalsControllerProvider.notifier);
  return controller.getTopProgressGoals();
});

/// Provider для целей требующих внимания
final goalsNeedingAttentionProvider = Provider<List<Goal>>((ref) {
  final controller = ref.read(goalsControllerProvider.notifier);
  return controller.getGoalsNeedingAttention();
});
