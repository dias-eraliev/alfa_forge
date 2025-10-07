import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/path/models/user_progress_model.dart';
import '../../features/path/models/goal_model.dart';

/// Сервис для работы с Supabase
class SupabaseService {
  /// Сохранить профиль пользователя в таблицу users
  Future<void> saveUserProfile({
    required String fullName,
    required String email,
    required String phone,
    required String city,
    required String username,
  }) async {
    if (currentUserId == null) return;

    try {
      final response = await _client.from('users').upsert({
        'id': currentUserId!,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'city': city,
        'username': username,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      debugPrint('User profile saved: $response');
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  final GoTrueClient auth= Supabase.instance.client.auth;

  /// Получить ID текущего пользователя
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Загрузить прогресс пользователя из Supabase
  Future<UserProgress?> loadUserProgress() async {
    if (currentUserId == null) return null;

    try {
      final response = await _client
          .from('user_progress')
          .select('''
            *,
            progress_history (*),
            sphere_progress (*)
          ''')
          .eq('user_id', currentUserId!)
          .maybeSingle();

      if (response == null) return null;

      // Преобразовать данные из Supabase в UserProgress
      return UserProgress(
        totalSteps: response['total_steps'] ?? 0,
        currentStreak: response['current_streak'] ?? 0,
        longestStreak: response['longest_streak'] ?? 0,
        totalXP: response['total_xp'] ?? 0,
        currentZone: response['current_zone'] ?? 'ТЕЛО',
        lastActiveDate: response['last_active_date'] != null
            ? DateTime.tryParse(response['last_active_date']) ?? DateTime.now()
            : DateTime.now(),
        totalStats: _getDefaultStats(), // Пока используем дефолтные
        progressHistory: _parseProgressHistory(response['progress_history'] ?? []),
        sphereProgress: _parseSphereProgress(response['sphere_progress'] ?? []),
      );
    } catch (e) {
      return null;
    }
  }

  /// Сохранить прогресс пользователя в Supabase
  Future<void> saveUserProgress(UserProgress progress) async {
    if (currentUserId == null) return;

    try {
      // Обновляем или вставляем запись прогресса
      final upserted = await _client.from('user_progress').upsert({
        'user_id': currentUserId!,
        'total_steps': progress.totalSteps,
        'current_streak': progress.currentStreak,
        'longest_streak': progress.longestStreak,
        'total_xp': progress.totalXP,
        'current_zone': progress.currentZone,
        'last_active_date': progress.lastActiveDate.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id').select('id').maybeSingle();

      final userProgressId = await _resolveUserProgressId(cachedId: upserted?['id'] as String?);

      // Сохраняем прогресс по сферам
      if (userProgressId != null) {
        await _saveSphereProgress(progress.sphereProgress, userProgressId);
        await _upsertTodayProgressHistory(progress, userProgressId);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Временно не сохраняем totalStats в БД (в схеме нет поля). Можно вынести в отдельную таблицу при необходимости.

  /// Сохранить прогресс по сферам
  Future<void> _saveSphereProgress(Map<String, double> sphereProgress, String userProgressId) async {
    if (currentUserId == null) return;

    try {
      // Удаляем старые записи
      await _client
          .from('sphere_progress')
          .delete()
          .eq('user_progress_id', userProgressId)
          .eq('user_id', currentUserId!);

      // Вставляем новые
      final inserts = sphereProgress.entries
          .map(
            (entry) => {
              'user_id': currentUserId!,
              'user_progress_id': userProgressId,
              'sphere_name': entry.key,
              'progress_percentage': entry.value,
              'updated_at': DateTime.now().toIso8601String(),
            },
          )
          .toList();

      if (inserts.isNotEmpty) {
        await _client.from('sphere_progress').insert(inserts);
      }
    } catch (e) {
      debugPrint('Error saving sphere_progress: $e');
      rethrow;
    }
  }

  /// Получить id записи user_progress для текущего пользователя
  Future<String?> _resolveUserProgressId({String? cachedId}) async {
    if (cachedId != null) return cachedId;
    if (currentUserId == null) return null;
    try {
      final res = await _client
          .from('user_progress')
          .select('id')
          .eq('user_id', currentUserId!)
          .maybeSingle();
      return res?['id'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Залогировать выполнение привычки (увеличить фактическое значение за сегодня)
  Future<void> logHabitCompletion(
    String userHabitId, {
    int actualValue = 1,
  }) async {
    await incrementHabitStep(userHabitId, delta: actualValue);
  }

  /// Увеличить фактическое значение привычки за сегодня (инкремент +delta)
  Future<int> incrementHabitStep(String userHabitId, {int delta = 1}) async {
    if (currentUserId == null) return 0;

    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      // Пытаемся найти запись за сегодня
      final existing = await _client
          .from('habit_logs')
          .select('id, actual_value')
          .eq('user_habit_id', userHabitId)
          .eq('user_id', currentUserId!)
          .eq('logged_date', today)
          .maybeSingle();

      if (existing != null) {
        final current = (existing['actual_value'] ?? 0) as int;
        final next = current + delta;
        await _client
            .from('habit_logs')
            .update({
              'actual_value': next,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', existing['id']);
        return next;
      } else {
        final insert = {
          'user_habit_id': userHabitId,
          'user_id': currentUserId!,
          'logged_date': today,
          'actual_value': delta,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        };
        final res = await _client.from('habit_logs').insert(insert).select('actual_value').maybeSingle();
        return (res?['actual_value'] ?? delta) as int;
      }
    } catch (e) {
      debugPrint('Error incrementing habit step: $e');
      rethrow;
    }
  }

  /// Уменьшить фактическое значение привычки за сегодня (декремент -1, но не ниже 0)
  Future<int> decrementHabitStep(String userHabitId) async {
    if (currentUserId == null) return 0;
    final today = DateTime.now().toIso8601String().split('T')[0];
    try {
      final existing = await _client
          .from('habit_logs')
          .select('id, actual_value')
          .eq('user_habit_id', userHabitId)
          .eq('user_id', currentUserId!)
          .eq('logged_date', today)
          .maybeSingle();

      if (existing == null) return 0;
      final current = (existing['actual_value'] ?? 0) as int;
      final next = current - 1;
      final safe = next < 0 ? 0 : next;
      await _client
          .from('habit_logs')
          .update({
            'actual_value': safe,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existing['id']);
      return safe;
    } catch (e) {
      debugPrint('Error decrementing habit step: $e');
      rethrow;
    }
  }

  /// Проверить, выполнена ли привычка сегодня
  Future<bool> isHabitCompletedToday(String userHabitId) async {
    if (currentUserId == null) return false;

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _client
          .from('habit_logs')
          .select('id')
          .eq('user_habit_id', userHabitId)
          .eq('logged_date', today)
          .limit(1);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Получить прогресс привычки за сегодня
  Future<Map<String, dynamic>> getHabitProgressToday(String userHabitId) async {
    if (currentUserId == null) return {'completed': false, 'progress': '0 / 1'};

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _client
          .from('habit_logs')
          .select('actual_value, user_habits(target_value)')
          .eq('user_habit_id', userHabitId)
          .eq('logged_date', today)
          .maybeSingle();

      if (response != null) {
        final actualValue = response['actual_value'] ?? 0;
        final targetValue = response['user_habits']?['target_value'] ?? 1;
        return {
          'completed': actualValue >= targetValue,
          'progress': '$actualValue / $targetValue',
        };
      }

      // Если нет логов на сегодня
      final habitResponse = await _client
          .from('user_habits')
          .select('target_value')
          .eq('id', userHabitId)
          .maybeSingle();

      final targetValue = habitResponse?['target_value'] ?? 1;
      return {'completed': false, 'progress': '0 / $targetValue'};
    } catch (e) {
      return {'completed': false, 'progress': '0 / 1'};
    }
  }

  /// Получить фактические значения всех привычек за сегодня одной выборкой
  /// Возвращает мапу { user_habit_id: actual_value }
  Future<Map<String, int>> getTodayHabitActuals() async {
    if (currentUserId == null) return {};
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final rows = await _client
          .from('habit_logs')
          .select('user_habit_id, actual_value')
          .eq('user_id', currentUserId!)
          .eq('logged_date', today);
      final map = <String, int>{};
      for (final r in rows as List) {
        final id = (r['user_habit_id'] ?? '').toString();
        final val = (r['actual_value'] ?? 0) as int;
        // На случай, если существует несколько строк в день — суммируем
        map[id] = (map[id] ?? 0) + val;
      }
      return map;
    } catch (e) {
      debugPrint('Error fetching today habit actuals: $e');
      return {};
    }
  }

  /// Загрузить привычки пользователя
  Future<List<Map<String, dynamic>>> loadUserHabits() async {
    if (currentUserId == null) return [];

    try {
      final response = await _client
          .from('user_habits')
          .select('''
            *,
            habits (*)
          ''')
          .eq('user_id', currentUserId!)
          .eq('is_active', true);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // ============================
  // Tasks API
  // ============================

  /// Список задач пользователя c возможной фильтрацией по дате
  /// Если [forDate] задан, вернём задачи с due_date = этой дате
  Future<List<Map<String, dynamic>>> listTasks({DateTime? forDate, String? status, List<String>? statuses}) async {
    if (currentUserId == null) return [];
    try {
      var query = _client
          .from('tasks')
          .select('*')
          .eq('user_id', currentUserId!);

      if (forDate != null) {
        // due_date в БД имеет тип DATE, поэтому фильтруем по 'YYYY-MM-DD'
        final dayStr = DateUtils.dateOnly(forDate).toIso8601String().split('T')[0];
        query = query.eq('due_date', dayStr);
      }

      if (statuses != null && statuses.isNotEmpty) {
        // Некоторые версии postgrest не экспонируют in_, используем OR
        final orExpr = statuses.map((s) => 'status.eq.$s').join(',');
        query = query.or(orExpr);
      } else if (status != null) {
        query = query.eq('status', status);
      }

      final response = await query.order('created_at');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error listing tasks: $e');
      return [];
    }
  }

  /// Создать задачу
  Future<Map<String, dynamic>?> createTask({
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
    List<String>? tags,
  }) async {
    if (currentUserId == null) return null;
    try {
      final insert = {
        'user_id': currentUserId!,
        'title': title,
        if (description != null) 'description': description,
        if (priority != null) 'priority': priority,
        // due_date (DATE) сохраняем как строку 'YYYY-MM-DD'
        if (dueDate != null) 'due_date': DateUtils.dateOnly(dueDate).toIso8601String().split('T')[0],
        if (tags != null) 'tags': tags,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      final res = await _client.from('tasks').insert(insert).select().maybeSingle();
      return res != null ? Map<String, dynamic>.from(res) : null;
    } catch (e) {
      debugPrint('Error creating task: $e');
      return null;
    }
  }

  /// Обновить статус задачи
  Future<void> updateTaskStatus(String taskId, String status) async {
    if (currentUserId == null) return;
    try {
      await _client
          .from('tasks')
          .update({
            'status': status,
            'completed_at': status == 'completed' ? DateTime.now().toIso8601String() : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', taskId)
          .eq('user_id', currentUserId!);
    } catch (e) {
      debugPrint('Error updating task status: $e');
      rethrow;
    }
  }

  /// Переключить задачу в статус выполнено/не выполнено
  Future<void> toggleTaskDone(String taskId, bool done) async {
    await updateTaskStatus(taskId, done ? 'completed' : 'pending');
  }

  /// Удалить задачу
  Future<void> deleteTask(String taskId) async {
    if (currentUserId == null) return;
    try {
      await _client.from('tasks').delete().eq('id', taskId).eq('user_id', currentUserId!);
    } catch (e) {
      debugPrint('Error deleting task: $e');
      rethrow;
    }
  }

  /// Получить ближайшую задачу на день (daily task)
  Future<Map<String, dynamic>?> getDailyTask({DateTime? forDate}) async {
    // 1) Пытаемся взять задачи на сегодня со статусами pending или in_progress
    var list = await listTasks(
      forDate: forDate ?? DateTime.now(),
      statuses: const ['pending', 'in_progress'],
    );
    // 2) Если на сегодня пусто — показываем любые in_progress (как приоритет)
    if (list.isEmpty) {
      list = await listTasks(statuses: const ['in_progress']);
    }
    // 3) Если и начатых нет — любые pending
    if (list.isEmpty) {
      list = await listTasks(status: 'pending');
    }
    if (list.isEmpty) return null;
    list.sort((a, b) {
      final ad = a['due_date'] != null ? DateTime.tryParse(a['due_date']) : null;
      final bd = b['due_date'] != null ? DateTime.tryParse(b['due_date']) : null;
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    });
    return list.first;
  }

  // ============================
  // Habits Catalog & Single Add API
  // ============================

  /// Каталог привычек (можно добавить поиск)
  Future<List<Map<String, dynamic>>> listHabits({String? search}) async {
    try {
      final hasSearch = search != null && search.trim().isNotEmpty;
      final res = hasSearch
          ? await _client
              .from('habits')
              .select('*')
              .filter('name', 'ilike', '%${search.trim()}%')
              .order('name')
          : await _client
              .from('habits')
              .select('*')
              .order('name');
      return List<Map<String, dynamic>>.from(res);
    } catch (e) {
      debugPrint('Error listing habits: $e');
      return [];
    }
  }

  /// Upsert одной пользовательской привычки, не деактивируя остальные
  Future<Map<String, dynamic>?> upsertUserHabit({
    required String habitId,
    int targetValue = 1,
    String frequency = 'daily',
  }) async {
    if (currentUserId == null) return null;
    try {
      final payload = {
        'user_id': currentUserId!,
        'habit_id': habitId,
        'target_value': targetValue,
        'frequency': frequency,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
    final res = await _client
      .from('user_habits')
      .upsert(payload, onConflict: 'user_id,habit_id')
      .select('*, habits(*)')
      .maybeSingle();
      return res != null ? Map<String, dynamic>.from(res) : null;
    } catch (e) {
      debugPrint('Error upserting user_habit: $e');
      return null;
    }
  }

  /// Сохранить выбранные привычки пользователя (используется при онбординге)
  Future<void> saveUserHabits(List<Map<String, dynamic>> habitsData) async {
    if (currentUserId == null) return;

    try {
      // Сначала деактивируем все существующие привычки пользователя
      await _client
          .from('user_habits')
          .update({'is_active': false})
          .eq('user_id', currentUserId!);

      // Затем добавляем новые выбранные привычки
      for (final habitData in habitsData) {
        await _client.from('user_habits').upsert({
          'user_id': currentUserId!,
          'habit_id': habitData['id'],
          'target_value': habitData['target_value'] ?? 1,
          'frequency': habitData['frequency'] ?? 'daily',
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id,habit_id');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Получить профиль пользователя
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) return null;

    try {
      final response = await _client
          .from('users')
          .select('*')
          .eq('id', currentUserId!)
          .single();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Преобразовать sphere_progress из Supabase
  Map<String, double> _parseSphereProgress(List<dynamic> spheres) {
    final result = <String, double>{};
    for (final sphere in spheres) {
      result[sphere['sphere_name']] = (sphere['progress_percentage'] as num)
          .toDouble();
    }
    return result;
  }

  /// Преобразовать progress_history из Supabase
  List<DayProgress> _parseProgressHistory(List<dynamic> rows) {
    final result = <DayProgress>[];
    for (final row in rows) {
      final dateStr = row['date'] as String?;
      final date = dateStr != null ? DateTime.tryParse(dateStr) : null;
      if (date == null) continue;
      result.add(
        DayProgress(
          date: date,
          stepsCompleted: (row['steps_completed'] ?? 0) as int,
          xpEarned: (row['xp_earned'] ?? 0) as int,
          dailyStats: {
            'calories': (row['calories_burned'] ?? 0) as int,
            'tasks_completed': (row['tasks_completed'] ?? 0) as int,
          },
        ),
      );
    }
    return result;
  }

  /// Сохранить/обновить строку истории прогресса за сегодня
  Future<void> _upsertTodayProgressHistory(UserProgress progress, String userProgressId) async {
    if (currentUserId == null) return;
    final today = DateUtils.dateOnly(DateTime.now());
    // Ищем локальную запись за сегодня
    DayProgress? todayProgress;
    for (final d in progress.progressHistory) {
      if (d.date.year == today.year && d.date.month == today.month && d.date.day == today.day) {
        todayProgress = d; break;
      }
    }
    // Если локально нет отдельной записи, используем агрегаты из прогресса (минимально)
    final steps = todayProgress?.stepsCompleted ?? 0;
    final xp = todayProgress?.xpEarned ?? 0;
    final calories = todayProgress?.dailyStats['calories'] ?? 0;
    final tasksCompleted = todayProgress?.dailyStats['tasks_completed'] ?? 0;
    try {
      await _client.from('progress_history').upsert({
        'user_progress_id': userProgressId,
        'user_id': currentUserId!,
        'date': today.toIso8601String(),
        'steps_completed': steps,
        'xp_earned': xp,
        'calories_burned': calories,
        'tasks_completed': tasksCompleted,
        'zone': progress.currentZone,
      }, onConflict: 'user_progress_id,date');
    } catch (_) {}
  }

  /// Недельная сводка: выполненные привычки, задачи и процент выполнения плана
  Future<Map<String, dynamic>> getWeeklyOverview() async {
    if (currentUserId == null) return {
      'habits_completed': 0,
      'habits_planned': 0,
      'tasks_completed': 0,
      'week_percent': 0,
    };
    try {
      final now = DateTime.now();
      final start = DateUtils.dateOnly(now.subtract(const Duration(days: 6)));
      final end = DateUtils.dateOnly(now).add(const Duration(days: 1));

      // habits_completed за 7 дней
    final habitsCompletedRes = await _client
      .from('habit_logs')
      .select('id')
          .eq('user_id', currentUserId!)
          .gte('logged_date', start.toIso8601String())
          .lt('logged_date', end.toIso8601String());
      final habitsCompleted = (habitsCompletedRes as List).length;

      // План по привычкам на неделю: считаем по частоте
      final activeHabits = await _client
          .from('user_habits')
          .select('target_value, frequency')
          .eq('user_id', currentUserId!)
          .eq('is_active', true);
      int planned = 0;
      for (final h in activeHabits as List) {
        final target = (h['target_value'] ?? 1) as int;
        final freq = ((h['frequency'] ?? 'daily') as String).toLowerCase();
        int daysPlanned = 0;
        if (freq == 'daily') {
          daysPlanned = 7;
        } else if (freq == 'weekdays') {
          // Считаем будние дни в окне
          daysPlanned = 0;
          for (int i = 0; i < 7; i++) {
            final d = DateUtils.dateOnly(start.add(Duration(days: i)));
            if (d.weekday >= DateTime.monday && d.weekday <= DateTime.friday) {
              daysPlanned++;
            }
          }
        } else if (freq == 'weekly') {
          // Раз в неделю: считаем как целевое значение за неделю
          planned += target;
          continue;
        } else {
          // Неизвестная частота — fallback: daily
          daysPlanned = 7;
        }
        planned += daysPlanned * target;
      }

      // tasks_completed за 7 дней
      final tasksCompletedRes = await _client
          .from('tasks')
          .select('id')
          .eq('user_id', currentUserId!)
          .eq('status', 'completed')
          .gte('completed_at', start.toIso8601String())
          .lt('completed_at', end.toIso8601String());
      final tasksCompleted = (tasksCompletedRes as List).length;

      final weekPercent = planned > 0
          ? (habitsCompleted * 100 ~/ planned).clamp(0, 100)
          : 0;

      return {
        'habits_completed': habitsCompleted,
        'habits_planned': planned,
        'tasks_completed': tasksCompleted,
        'week_percent': weekPercent,
      };
    } catch (e) {
      return {
        'habits_completed': 0,
        'habits_planned': 0,
        'tasks_completed': 0,
        'week_percent': 0,
      };
    }
  }

  /// Детализация недели по дням из progress_history
  Future<List<Map<String, dynamic>>> getWeeklyBreakdown() async {
    if (currentUserId == null) return [];
    try {
      final now = DateTime.now();
      final start = DateUtils.dateOnly(now.subtract(const Duration(days: 6)));
      final end = DateUtils.dateOnly(now).add(const Duration(days: 1));

      final rows = await _client
          .from('progress_history')
          .select('date, steps_completed, xp_earned, tasks_completed, zone')
          .eq('user_id', currentUserId!)
          .gte('date', start.toIso8601String())
          .lt('date', end.toIso8601String())
          .order('date');
      return List<Map<String, dynamic>>.from(rows as List);
    } catch (e) {
      debugPrint('Error fetching weekly breakdown: $e');
      return [];
    }
  }

  /// Дефолтные статистики
  Map<String, int> _getDefaultStats() => {
    'калории': 0,
    'задачи': 0,
    'тренировки': 0,
  };

  // ============================
  // Goals API
  // ============================

  /// Загрузить активные цели пользователя вместе с историей за [days] дней
  Future<List<Goal>> listGoalsWithHistory({int days = 7}) async {
    if (currentUserId == null) return [];
    try {
      final rows = await _client
          .from('goals')
          .select('*')
          .eq('user_id', currentUserId!)
          .eq('is_active', true)
          .order('created_at');

      final goals = <Goal>[];
      for (final r in (rows as List)) {
        final goal = _mapGoalFromRow(r as Map<String, dynamic>);
        // подгружаем историю для графика
        goal.dailyHistory = await _fetchGoalHistory(goal.id, days: days);
        goals.add(goal);
      }
      return goals;
    } catch (e) {
      debugPrint('Error listing goals: $e');
      return [];
    }
  }

  /// Получить историю цели за последние [days] дней
  Future<List<DailyGoalValue>> _fetchGoalHistory(String goalId, {int days = 7}) async {
    if (currentUserId == null) return [];
    try {
      final start = DateUtils
          .dateOnly(DateTime.now().subtract(Duration(days: days - 1)))
          .toIso8601String();
      final history = await _client
          .from('goal_history')
          .select('date, value, notes, goal_id')
          .eq('goal_id', goalId)
          .gte('date', start)
          .order('date');
      final list = <DailyGoalValue>[];
      for (final h in (history as List)) {
        final m = h as Map<String, dynamic>;
        final dateStr = (m['date'] ?? '').toString();
        final dt = DateTime.tryParse(dateStr);
        if (dt == null) continue;
        list.add(
          DailyGoalValue(
            date: DateTime(dt.year, dt.month, dt.day),
            value: (m['value'] as num).toDouble(),
            note: (m['notes'] as String?),
          ),
        );
      }
      return list;
    } catch (e) {
      debugPrint('Error fetching goal history: $e');
      return [];
    }
  }

  Goal _mapGoalFromRow(Map<String, dynamic> r) {
    final id = (r['id'] ?? '').toString();
    final name = (r['name'] ?? '—').toString();
    final emoji = (r['emoji'] ?? '').toString();
    final currentValue = ((r['current_value'] ?? 0) as num).toDouble();
    final targetValue = ((r['target_value'] ?? 0) as num).toDouble();
    final unit = (r['unit'] ?? '').toString();
    final goalTypeStr = (r['goal_type'] ?? 'increase').toString();
    final type = goalTypeStr == 'decrease' ? GoalType.decrease : GoalType.increase;
    final colorHex = (r['color_hex'] ?? '#E9E1D1').toString();
    final daysPassed = (r['days_passed'] ?? 0) as int;
    final createdAt = DateTime.tryParse((r['created_at'] ?? '').toString());
    final updatedAt = DateTime.tryParse((r['updated_at'] ?? '').toString());

    return Goal(
      id: id,
      name: name,
      emoji: emoji,
      currentValue: currentValue,
      targetValue: targetValue,
      unit: unit,
      daysPassed: daysPassed,
      type: type,
      colorHex: colorHex,
      createdAt: createdAt,
      lastUpdated: updatedAt,
    );
  }
}
