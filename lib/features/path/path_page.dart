import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/services/supabase_service.dart';
import '../../app/theme.dart';
import '../gto/gto_page.dart';
import '../shared/bottom_nav_scaffold.dart';
import '../tasks/tasks_page.dart';
import 'controllers/progress_controller.dart';
import 'models/user_progress_model.dart';
import 'widgets/six_goals_grid.dart';

class PathPage extends ConsumerStatefulWidget {
  const PathPage({super.key});

  @override
  ConsumerState<PathPage> createState() => _PathPageState();
}

class _PathPageState extends ConsumerState<PathPage> {
  bool isTaskStarted = false;
  Map<String, dynamic>? _dailyTask;

  @override
  void initState() {
    super.initState();
    _loadDailyTask();
  }

  int _calculateOverallProgress(UserProgress progress) {
    if (progress.sphereProgress.isEmpty) return 0;
    final total = progress.sphereProgress.values.reduce((a, b) => a + b);
    return ((total / progress.sphereProgress.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressControllerProvider);
    final habitsAsync = ref.watch(userHabitsWithProgressProvider);

    return BottomNavScaffold(
      currentRoute: '/',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: PRIMETheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: PRIMETheme.primary.withOpacity(0.1),
                    ),
                    child: Text(
                      progress.currentZone,
                      style: Theme.of(context).textTheme.displayMedium
                          ?.copyWith(color: PRIMETheme.primary, fontSize: 24),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SixGoalsGrid(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: PRIMETheme.sand, width: 1),
                        borderRadius: BorderRadius.circular(6),
                        color: PRIMETheme.sand.withOpacity(0.1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.grid_view,
                            color: PRIMETheme.sand,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'МОИ ЦЕЛИ',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: PRIMETheme.sand,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'СТРИК',
                      value: progress.currentStreak.toString(),
                      icon: Icons.local_fire_department,
                      onTap: _showStreakDetails,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: 'ПРОГРЕСС',
                      value: '${_calculateOverallProgress(progress)}%',
                      icon: Icons.timeline,
                      onTap: _showProgressDetails,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _TaskCard(
                hasTask: _dailyTask != null,
                title:
                    (_dailyTask != null
                            ? (_dailyTask!['title'] ?? 'Задача дня')
                            : 'Нет задачи на сегодня')
                        .toString(),
                isStarted:
                    isTaskStarted ||
                    ((_dailyTask?['status'] ?? '') == 'in_progress'),
                onStart: _startDailyTask,
                onComplete: _completeDailyTask,
                onRefresh: _loadDailyTask,
                dueDate: (_dailyTask?['due_date'] as String?)?.toString(),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TasksPage()),
                    );
                  },
                  icon: const Icon(Icons.list_alt, color: PRIMETheme.sand),
                  label: const Text('Все задачи', style: TextStyle(color: PRIMETheme.sand)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Сегодня (ближайшее окно)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              habitsAsync.when(
                data: (habitsData) => _HabitsList(
                  habits: habitsData,
                  onIncrement: (h) => _changeHabit(h, 1),
                  onDecrement: (h) => _changeHabit(h, -1),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Text('Ошибка загрузки привычек: $error'),
              ),
              const SizedBox(height: 24),
              _WeekProgress(onTap: _showWeekDetails),
              const SizedBox(height: 24),
              _RecentProgressSection(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      text: '+ Привычка',
                      onTap: () => _showHabitModal(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionButton(
                      text: '+ Задача',
                      onTap: () => _showTaskModal(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ActionButton(
                text: 'ГТО',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GTOPage()),
                ),
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _habitBusy = false;
  Future<void> _changeHabit(Map<String, dynamic> habit, int delta) async {
    if (_habitBusy) return;
    setState(() => _habitBusy = true);
    final service = SupabaseService();
    final String name = (habit['name'] ?? 'Привычка').toString();
    final String userHabitId = (habit['user_habit_id'] ?? '').toString();
    final String category = (habit['category'] ?? 'will').toString();
    final int target = (habit['target_value'] ?? 1) as int;
    final int actual = (habit['actual_value'] ?? 0) as int;

    try {
      int newActual;
      if (delta > 0) {
        newActual = await service.incrementHabitStep(userHabitId, delta: delta);
      } else {
        newActual = await service.decrementHabitStep(userHabitId);
      }

      // Обновляем локальный стрик/XP только при первом достижении шага сегодня:
      // простая эвристика — если стало >= 1 и было 0, считаем как шаг.
      if (actual == 0 && newActual > 0 && delta > 0) {
        ref
            .read(progressControllerProvider.notifier)
            .completeHabit(name, category);
      }

      if (!mounted) return;
      ref.invalidate(userHabitsWithProgressProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('$name: $newActual / $target')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: PRIMETheme.warn),
      );
    } finally {
      if (mounted) setState(() => _habitBusy = false);
    }
  }

  void _startDailyTask() {
    if (_dailyTask == null) return;
    setState(() => isTaskStarted = true);
    SupabaseService()
        .updateTaskStatus((_dailyTask!['id'] as String), 'in_progress')
        .then((_) => _loadDailyTask())
        .whenComplete(() {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Задача дня начата! Удачи!'),
              backgroundColor: PRIMETheme.success,
              duration: Duration(seconds: 2),
            ),
          );
          Timer(const Duration(seconds: 2), () {
            if (!mounted) return;
            setState(() => isTaskStarted = false);
          });
        });
  }

  void _showStreakDetails() {
    final p = ref.read(progressControllerProvider);
    final currentStreak = p.currentStreak;
    final longestStreak = p.longestStreak;
    final toNextReward = (currentStreak > 0 && longestStreak > currentStreak)
        ? (longestStreak - currentStreak)
        : 0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Стрик', style: TextStyle(color: PRIMETheme.sand)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Текущий стрик: $currentStreak дней',
              style: const TextStyle(color: PRIMETheme.sandWeak),
            ),
            const SizedBox(height: 8),
            Text(
              'Лучший стрик: $longestStreak дней',
              style: const TextStyle(color: PRIMETheme.sandWeak),
            ),
            const SizedBox(height: 8),
            Text(
              'До следующей награды: $toNextReward дней',
              style: const TextStyle(color: PRIMETheme.sandWeak),
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (currentStreak > 0 && longestStreak > 0)
                  ? (currentStreak / longestStreak).clamp(0.0, 1.0)
                  : 0.0,
              backgroundColor: PRIMETheme.line,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ОК',
              style: TextStyle(color: PRIMETheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showProgressDetails() {
    final p = ref.read(progressControllerProvider);
    final overall = _calculateOverallProgress(p);
    final spheres = p.sphereProgress;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Общий прогресс',
          style: TextStyle(color: PRIMETheme.sand),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общий прогресс: $overall%',
              style: const TextStyle(
                color: PRIMETheme.sandWeak,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Прогресс по сферам:',
              style: TextStyle(color: PRIMETheme.sand, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...spheres.entries
                .map(
                  (e) => _SphereProgressItem(title: e.key, progress: e.value),
                )
                .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'ОК',
              style: TextStyle(color: PRIMETheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showWeekDetails() {
    final weeklyAsync = ref.read(weeklyStatsProvider.future);
    showDialog(
      context: context,
      builder: (_) {
        return FutureBuilder<Map<String, dynamic>>(
          future: weeklyAsync,
          builder: (context, snapshot) {
            final data =
                snapshot.data ??
                {
                  'habits_completed': 0,
                  'habits_planned': 0,
                  'tasks_completed': 0,
                  'week_percent': 0,
                };
            final weekPercent = (data['week_percent'] ?? 0) as int;
            final habitsCompleted = (data['habits_completed'] ?? 0) as int;
            final habitsPlanned = (data['habits_planned'] ?? 0) as int;
            final tasksCompleted = (data['tasks_completed'] ?? 0) as int;

            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: const Text(
                'Прогресс недели',
                style: TextStyle(color: PRIMETheme.sand),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!snapshot.hasData)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: LinearProgressIndicator(),
                      ),
                    Text(
                      'Выполнено: $weekPercent%',
                      style: const TextStyle(color: PRIMETheme.sandWeak),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Привычки: $habitsCompleted / $habitsPlanned',
                      style: const TextStyle(color: PRIMETheme.sandWeak),
                    ),
                    Text(
                      'Задачи: $tasksCompleted',
                      style: const TextStyle(color: PRIMETheme.sandWeak),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (weekPercent / 100.0).clamp(0.0, 1.0),
                      backgroundColor: PRIMETheme.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        PRIMETheme.sand,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'ОК',
                    style: TextStyle(color: PRIMETheme.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showDragHandle: true,
      builder: (_) => _AddHabitSheet(
        onAdded: () {
          // После добавления обновляем список привычек
          ref.invalidate(userHabitsWithProgressProvider);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      showDragHandle: true,
      builder: (_) => _AddTaskSheet(
        onAdded: () async {
          // Обновляем карточку «Задача дня»
          await _loadDailyTask();
          if (!mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _loadDailyTask() async {
    final task = await SupabaseService().getDailyTask();
    if (!mounted) return;
    setState(() => _dailyTask = task);
  }

  Future<void> _completeDailyTask() async {
    if (_dailyTask == null) return;
    try {
      await SupabaseService().updateTaskStatus(
        _dailyTask!['id'] as String,
        'completed',
      );
      await _loadDailyTask();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Задача дня выполнена!'),
          backgroundColor: PRIMETheme.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: PRIMETheme.warn),
      );
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: Row(
          children: [
            Icon(icon, color: PRIMETheme.sand),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(color: PRIMETheme.sand),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final bool hasTask;
  final String title;
  final bool isStarted;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback? onRefresh;
  final String? dueDate;

  const _TaskCard({
    required this.hasTask,
    required this.title,
    required this.isStarted,
    required this.onStart,
    required this.onComplete,
    this.onRefresh,
    this.dueDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.flag, color: PRIMETheme.sand),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Задача дня',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  hasTask ? title : 'Задача не найдена',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (hasTask && (dueDate != null && dueDate!.isNotEmpty)) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Дедлайн: $dueDate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PRIMETheme.sandWeak),
                  ),
                ],
              ],
            ),
          ),
          if (hasTask)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onRefresh != null) ...[
                  IconButton(
                    tooltip: 'Обновить',
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh, color: PRIMETheme.sand),
                  ),
                  const SizedBox(width: 4),
                ],
                if (!isStarted)
                  ElevatedButton(
                    onPressed: onStart,
                    child: const Text('Старт'),
                  ),
                if (isStarted) const SizedBox(width: 8),
                if (isStarted)
                  OutlinedButton(
                    onPressed: onComplete,
                    child: const Text('Завершить'),
                  ),
              ],
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class _HabitsList extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final Future<void> Function(Map<String, dynamic> habit) onIncrement;
  final Future<void> Function(Map<String, dynamic> habit) onDecrement;

  _HabitsList({
    required this.habits,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: const Text('Нет привычек на сегодня'),
      );
    }

    return Column(
      children: [
        for (final habit in habits)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PRIMETheme.line),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (habit['name'] ?? '—').toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (habit['progress'] ?? '').toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _IncDec(
                  habit: habit,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _IncDec extends StatefulWidget {
  final Map<String, dynamic> habit;
  final Future<void> Function(Map<String, dynamic> habit) onIncrement;
  final Future<void> Function(Map<String, dynamic> habit) onDecrement;
  _IncDec({
    required this.habit,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  State<_IncDec> createState() => _IncDecState();
}

class _IncDecState extends State<_IncDec> {
  bool _busy = false;
  @override
  Widget build(BuildContext context) {
    final actual = (widget.habit['actual_value'] ?? 0) as int;
    final target = (widget.habit['target_value'] ?? 1) as int;
    final done = actual >= target;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: PRIMETheme.sand,
          onPressed: _busy || actual == 0
              ? null
              : () async {
                  setState(() => _busy = true);
                  await widget.onDecrement(widget.habit);
                  if (mounted) setState(() => _busy = false);
                },
        ),
        SizedBox(
          width: 56,
          child: Center(
            child: _busy
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('$actual / $target'),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: PRIMETheme.sand,
          onPressed: _busy || done
              ? null
              : () async {
                  setState(() => _busy = true);
                  await widget.onIncrement(widget.habit);
                  if (mounted) setState(() => _busy = false);
                },
        ),
      ],
    );
  }
}

class _WeekProgress extends StatelessWidget {
  final VoidCallback onTap;
  const _WeekProgress({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month, color: PRIMETheme.sand),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Прогресс недели',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Нажмите, чтобы посмотреть детали',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ActionButton({
    required this.text,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isPrimary ? PRIMETheme.sand : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isPrimary ? Colors.black : null,
        ),
      ),
    );

    return InkWell(onTap: onTap, child: child);
  }
}

class _RecentProgressSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentProgressProvider);
    if (recent.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: const Text(
          'Недавний прогресс пока пуст. Начните с первой привычки!',
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Недавний прогресс',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          for (final d in recent.take(7))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${d.date.toLocal().toString().split(' ').first}',
                    ),
                  ),
                  Text('+${d.stepsCompleted} шаг(ов) • ${d.xpEarned} XP'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddTaskSheet({required this.onAdded});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _titleCtrl = TextEditingController();
  DateTime? _dueDate;
  String _priority = 'medium';
  final _tagsCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    setState(() => _saving = true);
    final tags = _tagsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final res = await SupabaseService().createTask(
      title: _titleCtrl.text.trim(),
      priority: _priority,
      dueDate: _dueDate,
      tags: tags.isEmpty ? null : tags,
    );
    setState(() => _saving = false);
    if (res != null && mounted) {
      // Сначала показываем уведомление, затем закрываем модалку через колбек
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Задача добавлена')));
      widget.onAdded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Новая задача', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Название'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    decoration: const InputDecoration(labelText: 'Приоритет'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Низкий')),
                      DropdownMenuItem(value: 'medium', child: Text('Средний')),
                      DropdownMenuItem(value: 'high', child: Text('Высокий')),
                      DropdownMenuItem(value: 'urgent', child: Text('Срочно')),
                    ],
                    onChanged: (v) => setState(() => _priority = v ?? 'medium'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Дедлайн'),
                      child: Text(
                        _dueDate != null
                            ? _dueDate!.toLocal().toString().split(' ').first
                            : 'Не задан',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _tagsCtrl,
              decoration: const InputDecoration(
                labelText: 'Теги (через запятую)',
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Сохранить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddHabitSheet extends StatefulWidget {
  final VoidCallback onAdded;
  const _AddHabitSheet({required this.onAdded});

  @override
  State<_AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<_AddHabitSheet> {
  final _searchCtrl = TextEditingController();
  String? _selectedHabitId;
  int _target = 1;
  String _frequency = 'daily';
  bool _loading = true;
  List<Map<String, dynamic>> _catalog = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load([String? s]) async {
    setState(() => _loading = true);
    final res = await SupabaseService().listHabits(search: s);
    setState(() {
      _catalog = res;
      _loading = false;
    });
  }

  Future<void> _apply() async {
    if (_selectedHabitId == null) return;
    setState(() => _saving = true);
    final res = await SupabaseService().upsertUserHabit(
      habitId: _selectedHabitId!,
      targetValue: _target,
      frequency: _frequency,
    );
    setState(() => _saving = false);
    if (res != null && mounted) {
      // Сначала показываем уведомление, затем закрываем модалку через колбек
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Привычка добавлена')));
      widget.onAdded();
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Новая привычка',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: 'Поиск',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _load(_searchCtrl.text),
                ),
              ),
              onSubmitted: (v) => _load(v),
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              SizedBox(
                height: 240,
                child: ListView.builder(
                  itemCount: _catalog.length,
                  itemBuilder: (context, i) {
                    final h = _catalog[i];
                    final id = (h['id'] ?? '').toString();
                    final selected = _selectedHabitId == id;
                    return ListTile(
                      title: Text((h['name'] ?? '—').toString()),
                      subtitle: Text((h['category'] ?? '').toString()),
                      trailing: selected
                          ? const Icon(Icons.check, color: PRIMETheme.sand)
                          : null,
                      onTap: () => setState(() => _selectedHabitId = id),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: '1',
                    decoration: const InputDecoration(labelText: 'Цель в день'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _target = int.tryParse(v) ?? 1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _frequency,
                    decoration: const InputDecoration(labelText: 'Частота'),
                    items: const [
                      DropdownMenuItem(
                        value: 'daily',
                        child: Text('Ежедневно'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _frequency = v ?? 'daily'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _saving ? null : _apply,
                child: _saving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Добавить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SphereProgressItem extends StatelessWidget {
  final String title;
  final double progress;

  const _SphereProgressItem({required this.title, required this.progress});

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).toInt();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: PRIMETheme.line,
              valueColor: const AlwaysStoppedAnimation<Color>(PRIMETheme.sand),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 32,
            child: Text(
              '$percent%',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
