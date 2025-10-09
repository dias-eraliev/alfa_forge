import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/bottom_nav_scaffold.dart';
import '../../app/theme.dart';
import 'widgets/advanced_add_task_dialog.dart';
import '../../core/services/api_service.dart';
import '../../core/services/tasks_service.dart';
import 'utils/task_converter.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> with TickerProviderStateMixin {
  bool isWeekMode = false;
  bool isFocusMode = false;
  int focusTimeRemaining = 25 * 60; // 25 минут в секундах
  Timer? focusTimer;
  late AnimationController _timerAnimationController;
  
  // API Integration
  final ApiService _apiService = ApiService.instance;
  bool _isLoading = true;
  bool _isApiConnected = false;
  String? _errorMessage;
  Map<String, dynamic>? priorityTask;
  
  // Состояние задач с расширенными данными
  List<Map<String, dynamic>> todayTasks = [];
  Map<int, List<Map<String, dynamic>>> weekTasks = {
    1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [],
  };
  
  // Fallback данные держим в конвертере TaskConverter.getFallbackTasks()

  @override
  void initState() {
    super.initState();
    _timerAnimationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _loadTasksFromApi();
  }

  // Загрузка задач из API с fallback на локальные данные
  Future<void> _loadTasksFromApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Пытаемся загрузить задачи сегодня из API
      final response = await _apiService.tasks.getTodayTasks();
      
      if (response.isSuccess && response.data != null) {
        // Успешно получили данные из API
        setState(() {
          todayTasks = TaskConverter.apiTasksToMaps(response.data!);
          priorityTask = _selectPriorityTask(todayTasks);
          _isApiConnected = true;
          _isLoading = false;
        });
      } else {
        // API вернул ошибку, используем fallback
        _handleApiError(response.error ?? 'Неизвестная ошибка API');
      }
    } catch (e) {
      // Сетевая ошибка или другие проблемы
      _handleApiError('Ошибка сети: $e');
    }
  }

  // Обработка ошибок API
  void _handleApiError(String error) {
    setState(() {
      todayTasks = TaskConverter.getFallbackTasks();
      priorityTask = _selectPriorityTask(todayTasks);
      _isApiConnected = false;
      _errorMessage = error;
      _isLoading = false;
    });
    
    // Показываем пользователю, что используются локальные данные
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Используются локальные данные. API недоступен.',
            style: const TextStyle(color: PRIMETheme.sand),
          ),
          backgroundColor: PRIMETheme.warn,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'Повторить',
            textColor: PRIMETheme.sand,
            onPressed: _loadTasksFromApi,
          ),
        ),
      );
    }
  }

  // Выбор приоритетной задачи: high > medium > low, затем ближайший дедлайн
  Map<String, dynamic>? _selectPriorityTask(List<Map<String, dynamic>> tasks) {
    final notDone = tasks.where((t) => (t['done'] as bool?) != true).toList();
    if (notDone.isEmpty) return null;

    int prioScore(String? p) {
      switch (p) {
        case 'high':
          return 3;
        case 'medium':
          return 2;
        case 'low':
          return 1;
        default:
          return 0;
      }
    }

    notDone.sort((a, b) {
      final ap = prioScore(a['priority'] as String?);
      final bp = prioScore(b['priority'] as String?);
      if (ap != bp) return bp.compareTo(ap); // по убыванию приоритета
      final ad = (a['deadline'] as DateTime?) ?? DateTime.now().add(const Duration(days: 3650));
      final bd = (b['deadline'] as DateTime?) ?? DateTime.now().add(const Duration(days: 3650));
      return ad.compareTo(bd); // ближайший раньше
    });

    return notDone.first;
  }

  // Обновление задач (pull-to-refresh)
  Future<void> _refreshTasks() async {
    if (isWeekMode) {
      await _loadWeekTasksFromApi();
    } else {
      await _loadTasksFromApi();
    }
  }

  @override
  void dispose() {
    focusTimer?.cancel();
    _timerAnimationController.dispose();
    super.dispose();
  }

  void _startFocusMode() {
    setState(() {
      isFocusMode = true;
      focusTimeRemaining = 25 * 60;
    });
    
    focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (focusTimeRemaining > 0) {
          focusTimeRemaining--;
        } else {
          _stopFocusMode();
          _showFocusCompleteDialog();
        }
      });
    });
    
    _timerAnimationController.repeat();
  }

  void _stopFocusMode() {
    setState(() {
      isFocusMode = false;
    });
    focusTimer?.cancel();
    _timerAnimationController.stop();
  }

  void _showFocusCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text('Фокус завершен!', style: Theme.of(context).textTheme.titleLarge),
        content: Text('Отличная работа! Время для перерыва.', style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: PRIMETheme.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTask(String taskId) async {
    // Пытаемся найти задачу в сегодняшнем списке
    var idx = todayTasks.indexWhere((t) => t['id'] == taskId);
    bool isWeekItem = false;
    int? weekDayKey;

    // Если не нашли — ищем в недельном списке
    if (idx == -1) {
      for (final entry in weekTasks.entries) {
        final j = entry.value.indexWhere((t) => t['id'] == taskId);
        if (j != -1) {
          isWeekItem = true;
          weekDayKey = entry.key;
          idx = j;
          break;
        }
      }
      if (!isWeekItem) return; // не нашли ни там, ни там
    }

    Map<String, dynamic> prev;
    bool newDone;
    if (isWeekItem) {
      final int key = weekDayKey!;
      final list = weekTasks[key]!;
      prev = Map<String, dynamic>.from(list[idx]);
      newDone = !((list[idx]['done']) as bool? ?? false);
    } else {
      prev = Map<String, dynamic>.from(todayTasks[idx]);
      newDone = !((todayTasks[idx]['done']) as bool? ?? false);
    }

    // Оптимистичное обновление UI
    setState(() {
      if (isWeekItem) {
        final int key = weekDayKey!;
        final list = weekTasks[key]!;
        list[idx]['done'] = newDone;
        list[idx]['status'] = newDone ? 'done' : 'assigned';
        weekTasks[key] = list;
      } else {
        todayTasks[idx]['done'] = newDone;
        todayTasks[idx]['status'] = newDone ? 'done' : 'assigned';
        priorityTask = _selectPriorityTask(todayTasks);
      }
    });

    if (!_isApiConnected) return; // офлайн режим — оставляем локально

    try {
      if (newDone) {
        final res = await _apiService.tasks.completeTask(taskId);
        if (res.isSuccess && res.data != null) {
          final updated = TaskConverter.apiTaskToMap(res.data!);
          setState(() {
            if (isWeekItem) {
              final int key = weekDayKey!;
              final list = weekTasks[key]!;
              list[idx] = updated;
              weekTasks[key] = list;
            } else {
              todayTasks[idx] = updated;
              priorityTask = _selectPriorityTask(todayTasks);
            }
          });
          // Ревалидация после успешного ответа
          _revalidateTasksSilent();
        } else {
          throw Exception(res.error ?? 'Не удалось отметить задачу выполненной');
        }
      } else {
        // Бэк требует обязательные title/priority/deadline при PUT, поэтому отправляем полный DTO
        final String title = prev['text'] as String? ?? '';
        final String apiPriority = TaskConverter.uiPriorityToEnum(prev['priority'] as String? ?? 'medium');
        final DateTime deadline = (prev['deadline'] as DateTime? ?? DateTime.now());
        final res = await _apiService.tasks.updateTask(
          taskId,
          UpdateTaskDto(
            title: title,
            priority: apiPriority,
            deadline: deadline,
            status: TaskConverter.convertStatusToApi('assigned'),
          ),
        );
        if (res.isSuccess && res.data != null) {
          final updated = TaskConverter.apiTaskToMap(res.data!);
          setState(() {
            if (isWeekItem) {
              final int key = weekDayKey!;
              final list = weekTasks[key]!;
              list[idx] = updated;
              weekTasks[key] = list;
            } else {
              todayTasks[idx] = updated;
              priorityTask = _selectPriorityTask(todayTasks);
            }
          });
          // Ревалидация после успешного ответа
          _revalidateTasksSilent();
        } else {
          throw Exception(res.error ?? 'Не удалось обновить статус задачи');
        }
      }
    } catch (e) {
      // Откатываем
      setState(() {
        if (isWeekItem) {
          final int key = weekDayKey!;
          final list = weekTasks[key]!;
          list[idx] = prev;
          weekTasks[key] = list;
        } else {
          todayTasks[idx] = prev;
          priorityTask = _selectPriorityTask(todayTasks);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: PRIMETheme.warn,
          ),
        );
      }
    }
  }

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) => AdvancedAddTaskDialog(
        onTaskAdded: (task) {
          // Если есть соединение с API — создаем задачу на бэке
          if (_isApiConnected) {
            () async {
              try {
                final dto = TaskConverter.createTaskDtoFromUI(
                  title: task.title,
                  description: task.description.isEmpty ? null : task.description,
                  priority: task.priority.name,
                  dueDate: task.deadline,
                  category: null,
                  habitId: task.habitId,
                  habitName: task.habitName,
                  reminderAt: task.reminderAt,
                  isRecurring: task.isRecurring ? true : null,
                  recurringType: task.recurringType != null ? task.recurringType!.name.toUpperCase() : null,
                  subtasks: task.subtasks.isNotEmpty ? task.subtasks : null,
                  tags: task.tags.isNotEmpty ? task.tags : null,
                );
                final res = await _apiService.tasks.createTask(dto);
                if (res.isSuccess && res.data != null) {
                  final created = TaskConverter.apiTaskToMap(res.data!);
                  setState(() {
                    todayTasks.add(created);
                    priorityTask = _selectPriorityTask(todayTasks);
                  });
                } else {
                  throw Exception(res.error ?? 'Не удалось создать задачу');
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка создания задачи: $e'),
                      backgroundColor: PRIMETheme.warn,
                    ),
                  );
                }
                // Фолбэк: добавим локально
                setState(() {
                  todayTasks.add(task.toMap());
                  priorityTask = _selectPriorityTask(todayTasks);
                });
              }
            }();
          } else {
            // офлайн — сохраняем локально
            setState(() {
              todayTasks.add(task.toMap());
              priorityTask = _selectPriorityTask(todayTasks);
            });
          }
        },
      ),
    );
  }

  void _showTaskDetail(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (context) => _TaskDetailDialog(
        task: task,
        onStatusChanged: (taskId, newStatus) async {
          await _changeTaskStatus(taskId, newStatus);
        },
      ),
    );
  }

  // Получение задач по статусу
  List<Map<String, dynamic>> _getTasksByStatus(String status) {
    // В режиме недели учитываем все задачи недели, иначе только сегодняшние
    final Iterable<Map<String, dynamic>> source = isWeekMode
        ? weekTasks.values.expand((list) => list)
        : todayTasks;
    return source.where((task) => task['status'] == status).toList();
  }

  // Обновление статуса задачи из Kanban
  Future<void> _changeTaskStatus(String taskId, String newStatus) async {
    var idx = todayTasks.indexWhere((t) => t['id'] == taskId);
    bool isWeekItem = false;
    int? weekDayKey;

    if (idx == -1) {
      for (final entry in weekTasks.entries) {
        final j = entry.value.indexWhere((t) => t['id'] == taskId);
        if (j != -1) {
          isWeekItem = true;
          weekDayKey = entry.key;
          idx = j;
          break;
        }
      }
      if (!isWeekItem) return;
    }

    Map<String, dynamic> prev;
    if (isWeekItem) {
      final int key = weekDayKey!;
      final list = weekTasks[key]!;
      prev = Map<String, dynamic>.from(list[idx]);
    } else {
      prev = Map<String, dynamic>.from(todayTasks[idx]);
    }

    // Оптимистично меняем статус
    setState(() {
      if (isWeekItem) {
        final int key = weekDayKey!;
        final list = weekTasks[key]!;
        list[idx]['status'] = newStatus;
        list[idx]['done'] = newStatus == 'done';
        weekTasks[key] = list;
      } else {
        todayTasks[idx]['status'] = newStatus;
        todayTasks[idx]['done'] = newStatus == 'done';
        priorityTask = _selectPriorityTask(todayTasks);
      }
    });

    if (!_isApiConnected) return;

    try {
      if (newStatus == 'done') {
        final res = await _apiService.tasks.completeTask(taskId);
        if (res.isSuccess && res.data != null) {
          final updated = TaskConverter.apiTaskToMap(res.data!);
          setState(() {
            if (isWeekItem) {
              final int key = weekDayKey!;
              final list = weekTasks[key]!;
              list[idx] = updated;
              weekTasks[key] = list;
            } else {
              todayTasks[idx] = updated;
              priorityTask = _selectPriorityTask(todayTasks);
            }
          });
          // Ревалидация после успешного ответа
          _revalidateTasksSilent();
        } else {
          throw Exception(res.error ?? 'Не удалось завершить задачу');
        }
      } else {
        // Бэк требует обязательные поля title/priority/deadline при PUT /tasks/:id
        final String title = prev['text'] as String? ?? '';
        final String apiPriority = TaskConverter.uiPriorityToEnum(prev['priority'] as String? ?? 'medium');
        final DateTime deadline = (prev['deadline'] as DateTime? ?? DateTime.now());
        final apiStatus = TaskConverter.convertStatusToApi(newStatus);
        final res = await _apiService.tasks.updateTask(
          taskId,
          UpdateTaskDto(
            title: title,
            priority: apiPriority,
            deadline: deadline,
            status: apiStatus,
          ),
        );
        if (res.isSuccess && res.data != null) {
          final updated = TaskConverter.apiTaskToMap(res.data!);
          setState(() {
            if (isWeekItem) {
              final int key = weekDayKey!;
              final list = weekTasks[key]!;
              list[idx] = updated;
              weekTasks[key] = list;
            } else {
              todayTasks[idx] = updated;
              priorityTask = _selectPriorityTask(todayTasks);
            }
          });
          // Ревалидация после успешного ответа
          _revalidateTasksSilent();
        } else {
          throw Exception(res.error ?? 'Не удалось обновить статус');
        }
      }
    } catch (e) {
      // Откат если ошибка
      setState(() {
        if (isWeekItem) {
          final int key = weekDayKey!;
          final list = weekTasks[key]!;
          list[idx] = prev;
          weekTasks[key] = list;
        } else {
          todayTasks[idx] = prev;
          priorityTask = _selectPriorityTask(todayTasks);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: PRIMETheme.warn,
          ),
        );
      }
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Подгрузка задач недели
  Future<void> _loadWeekTasksFromApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.tasks.getWeekTasks();
      if (response.isSuccess && response.data != null) {
        final maps = TaskConverter.apiTasksToMaps(response.data!);
        final grouped = <int, List<Map<String, dynamic>>>{
          1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [],
        };
        for (final m in maps) {
          final DateTime d = (m['deadline'] as DateTime?) ?? DateTime.now();
          final wd = d.weekday; // 1 (Mon) .. 7 (Sun)
          grouped[wd]!.add(m);
        }
        setState(() {
          weekTasks = grouped;
          _isApiConnected = true;
          _isLoading = false;
        });
      } else {
        _handleApiError(response.error ?? 'Неизвестная ошибка API');
        _fillWeekWithFallback();
      }
    } catch (e) {
      _handleApiError('Ошибка сети: $e');
      _fillWeekWithFallback();
    }
  }

  void _fillWeekWithFallback() {
    final fallback = TaskConverter.getFallbackTasks();
    final grouped = <int, List<Map<String, dynamic>>>{
      1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [],
    };
    for (final m in fallback) {
      final DateTime d = (m['deadline'] as DateTime?) ?? DateTime.now();
      grouped[d.weekday]!.add(m);
    }
    setState(() {
      weekTasks = grouped;
    });
  }

  // Тихая ревалидация: подтянуть актуальные статусы с сервера без мигания лоадера/ошибок
  Future<void> _revalidateTasksSilent() async {
    if (!_isApiConnected) return; // если оффлайн, пропускаем
    try {
      final todayFuture = _apiService.tasks.getTodayTasks();
      final weekFuture = _apiService.tasks.getWeekTasks();
      final results = await Future.wait([todayFuture, weekFuture]);

      if (!mounted) return;

      final todayResp = results[0];
      final weekResp = results[1];

      bool anySuccess = false;

      if (todayResp.isSuccess && todayResp.data != null) {
        final maps = TaskConverter.apiTasksToMaps(todayResp.data!);
        setState(() {
          todayTasks = maps;
          priorityTask = _selectPriorityTask(todayTasks);
        });
        anySuccess = true;
      }

      if (weekResp.isSuccess && weekResp.data != null) {
        final maps = TaskConverter.apiTasksToMaps(weekResp.data!);
        final grouped = <int, List<Map<String, dynamic>>>{
          1: [], 2: [], 3: [], 4: [], 5: [], 6: [], 7: [],
        };
        for (final m in maps) {
          final DateTime d = (m['deadline'] as DateTime?) ?? DateTime.now();
          grouped[d.weekday]!.add(m);
        }
        setState(() {
          weekTasks = grouped;
        });
        anySuccess = true;
      }

      if (anySuccess) {
        setState(() {
          _isApiConnected = true;
        });
      }
    } catch (_) {
      // тихо игнорируем ошибки ревалидации
    }
  }

  void _onModeChanged(bool value) {
    setState(() {
      isWeekMode = value;
    });
    if (value) {
      _loadWeekTasksFromApi();
    } else {
      _loadTasksFromApi();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentRoute: '/tasks',
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshTasks,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoading) ...[
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: CircularProgressIndicator(color: PRIMETheme.primary),
                )),
              ],
              if (_errorMessage != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PRIMETheme.warn.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PRIMETheme.warn),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: PRIMETheme.warn),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Проблема с API: ${_errorMessage}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: PRIMETheme.warn,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _refreshTasks,
                        child: const Text('Повторить', style: TextStyle(color: PRIMETheme.warn)),
                      ),
                    ],
                  ),
                ),
              ],
              // Переключатель Сегодня/Неделя
              _ModeSwitcher(
                isWeekMode: isWeekMode,
                onChanged: _onModeChanged,
              ),
              const SizedBox(height: 24),

              // Приоритет дня
              _PrioritySection(
                isFocusMode: isFocusMode,
                timeRemaining: focusTimeRemaining,
                onStartFocus: _startFocusMode,
                onStopFocus: _stopFocusMode,
                formatTime: _formatTime,
                priorityTitle: priorityTask != null ? (priorityTask!['text'] as String) : null,
              ),
              const SizedBox(height: 24),

              // Список задач
              if (!isWeekMode) ...[
                _TodayTasks(
                  tasks: todayTasks,
                  onTaskToggle: _toggleTask,
                  onAddTask: _addNewTask,
                ),
              ] else ...[
                _WeekTasks(
                  groupedTasks: weekTasks,
                  onTaskToggle: _toggleTask,
                ),
              ],
              const SizedBox(height: 24),

              // Рабочие процессы
              _WorkflowSection(
                assignedTasks: _getTasksByStatus('assigned'),
                inProgressTasks: _getTasksByStatus('in_progress'),
                doneTasks: _getTasksByStatus('done'),
                onTaskTap: _showTaskDetail,
                onStatusChanged: (taskId, status) => _changeTaskStatus(taskId, status),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDetailDialog extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(String, String) onStatusChanged;

  const _TaskDetailDialog({
    required this.task,
    required this.onStatusChanged,
  });

  @override
  State<_TaskDetailDialog> createState() => _TaskDetailDialogState();
}

class _TaskDetailDialogState extends State<_TaskDetailDialog> {
  late String currentStatus;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.task['status'] as String;
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return PRIMETheme.warn;
      case 'medium':
        return PRIMETheme.primary;
      case 'low':
        return PRIMETheme.success;
      default:
        return PRIMETheme.sandWeak;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'high':
        return 'Высокий';
      case 'medium':
        return 'Средний';
      case 'low':
        return 'Низкий';
      default:
        return 'Не указан';
    }
  }

  // _getStatusText удален как неиспользуемый

  String _formatDeadline(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    
    if (difference.isNegative) {
      final daysPast = difference.inDays.abs();
      if (daysPast == 0) {
        return 'Просрочено сегодня';
      }
      return 'Просрочено на $daysPast дн.';
    } else {
      final daysLeft = difference.inDays;
      if (daysLeft == 0) {
        return 'Сегодня';
      } else if (daysLeft == 1) {
        return 'Завтра';
      }
      return 'Через $daysLeft дн.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final deadline = widget.task['deadline'] as DateTime;
    final isOverdue = deadline.isBefore(DateTime.now());

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isSmallScreen ? screenWidth * 0.9 : 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: PRIMETheme.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Детали задачи',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: isSmallScreen ? 18 : 20,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: PRIMETheme.sandWeak),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),

            // Контент
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Название задачи
                    Text(
                      widget.task['text'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: isSmallScreen ? 16 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Описание
                    Container(
                      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                      decoration: BoxDecoration(
                        color: PRIMETheme.bg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PRIMETheme.line),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Описание',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.task['description'] as String,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: isSmallScreen ? 13 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Информационные блоки
                    Row(
                      children: [
                        // Приоритет
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(widget.task['priority'] as String).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _getPriorityColor(widget.task['priority'] as String)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Приоритет',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: isSmallScreen ? 10 : 11,
                                    color: PRIMETheme.sandWeak,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getPriorityText(widget.task['priority'] as String),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: isSmallScreen ? 12 : 13,
                                    color: _getPriorityColor(widget.task['priority'] as String),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        // Дедлайн
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                            decoration: BoxDecoration(
                              color: isOverdue ? PRIMETheme.warn.withOpacity(0.1) : PRIMETheme.bg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isOverdue ? PRIMETheme.warn : PRIMETheme.line),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Дедлайн',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: isSmallScreen ? 10 : 11,
                                    color: PRIMETheme.sandWeak,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDeadline(deadline),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: isSmallScreen ? 12 : 13,
                                    color: isOverdue ? PRIMETheme.warn : PRIMETheme.sand,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Связанная привычка
                    if (widget.task['habit'] != null) ...[
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                        decoration: BoxDecoration(
                          color: PRIMETheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: PRIMETheme.primary),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.repeat,
                              color: PRIMETheme.primary,
                              size: isSmallScreen ? 16 : 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Связано с привычкой: ${widget.task['habit']}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: isSmallScreen ? 12 : 13,
                                color: PRIMETheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Изменение статуса
                    Text(
                      'Статус задачи',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: PRIMETheme.line),
                      ),
                      child: Column(
                        children: [
                          _StatusOption(
                            title: 'Назначено',
                            subtitle: 'Задача ожидает выполнения',
                            value: 'assigned',
                            groupValue: currentStatus,
                            color: PRIMETheme.sandWeak,
                            onChanged: (value) {
                              setState(() {
                                currentStatus = value!;
                              });
                            },
                          ),
                          const Divider(height: 1, color: PRIMETheme.line),
                          _StatusOption(
                            title: 'В работе',
                            subtitle: 'Задача выполняется',
                            value: 'in_progress',
                            groupValue: currentStatus,
                            color: PRIMETheme.warn,
                            onChanged: (value) {
                              setState(() {
                                currentStatus = value!;
                              });
                            },
                          ),
                          const Divider(height: 1, color: PRIMETheme.line),
                          _StatusOption(
                            title: 'Готово',
                            subtitle: 'Задача выполнена',
                            value: 'done',
                            groupValue: currentStatus,
                            color: PRIMETheme.success,
                            onChanged: (value) {
                              setState(() {
                                currentStatus = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Кнопки действий
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: PRIMETheme.line)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                      ),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          color: PRIMETheme.sandWeak,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onStatusChanged(widget.task['id'] as String, currentStatus);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMETheme.primary,
                        foregroundColor: PRIMETheme.sand,
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Сохранить',
                        style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                      ),
                    ),
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

class _StatusOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String groupValue;
  final Color color;
  final ValueChanged<String?> onChanged;

  const _StatusOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : PRIMETheme.sandWeak,
                  width: 2,
                ),
                color: isSelected ? color : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 12,
                      color: PRIMETheme.sand,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PRIMETheme.sandWeak,
                    ),
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

class _ModeSwitcher extends StatelessWidget {
  final bool isWeekMode;
  final ValueChanged<bool> onChanged;

  const _ModeSwitcher({
    required this.isWeekMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isWeekMode ? PRIMETheme.primary : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'Сегодня',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: !isWeekMode ? PRIMETheme.sand : PRIMETheme.sandWeak,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isWeekMode ? PRIMETheme.primary : Colors.transparent,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Text(
                  'Неделя',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isWeekMode ? PRIMETheme.sand : PRIMETheme.sandWeak,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrioritySection extends StatelessWidget {
  final bool isFocusMode;
  final int timeRemaining;
  final VoidCallback onStartFocus;
  final VoidCallback onStopFocus;
  final String Function(int) formatTime;
  final String? priorityTitle;

  const _PrioritySection({
    required this.isFocusMode,
    required this.timeRemaining,
    required this.onStartFocus,
    required this.onStopFocus,
    required this.formatTime,
    this.priorityTitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и таймер
          if (isSmallScreen) ...[
            // Мобильная компоновка - два ряда
            Text(
              'Приоритет дня',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isSmallScreen ? 18 : null,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isFocusMode ? PRIMETheme.primary : PRIMETheme.line,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isFocusMode ? formatTime(timeRemaining) : '25:00',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'monospace',
                  color: isFocusMode ? PRIMETheme.sand : null,
                ),
              ),
            ),
          ] else ...[
            // Десктопная компоновка - один ряд
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Приоритет дня',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isFocusMode ? PRIMETheme.primary : PRIMETheme.line,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isFocusMode ? formatTime(timeRemaining) : '25:00',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'monospace',
                      color: isFocusMode ? PRIMETheme.sand : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (priorityTitle != null) ...[
            Text(
              priorityTitle!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: isSmallScreen ? 14 : null,
              ),
            ),
          ] else ...[
            Text(
              'Нет приоритетной задачи на сегодня',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: PRIMETheme.sandWeak,
                fontSize: isSmallScreen ? 14 : null,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isFocusMode ? onStopFocus : onStartFocus,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFocusMode ? PRIMETheme.warn : PRIMETheme.primary,
                foregroundColor: PRIMETheme.sand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 12 : 16,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFocusMode ? Icons.stop : Icons.play_arrow,
                    size: isSmallScreen ? 18 : 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFocusMode ? 'Стоп фокус' : 'Старт фокус',
                    style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayTasks extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final Function(String) onTaskToggle;
  final VoidCallback onAddTask;

  const _TodayTasks({
    required this.tasks,
    required this.onTaskToggle,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Сегодня',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isSmallScreen ? 20 : null,
              ),
            ),
            IconButton(
              onPressed: onAddTask,
              icon: Icon(
                Icons.add_circle_outline,
                color: PRIMETheme.primary,
                size: isSmallScreen ? 20 : 24,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => _TaskItem(
          text: task['text'] as String,
          isDone: task['done'] as bool,
          habitName: task['habit'] as String?,
          taskId: task['id'] as String,
          task: task,
          onToggle: onTaskToggle,
        )),
        if (tasks.isEmpty) ...[
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PRIMETheme.line),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.task_alt,
                  size: isSmallScreen ? 32 : 48,
                  color: PRIMETheme.sandWeak,
                ),
                const SizedBox(height: 8),
                Text(
                  'Нет задач на сегодня',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PRIMETheme.sandWeak,
                    fontSize: isSmallScreen ? 14 : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onAddTask,
                  icon: const Icon(Icons.add, color: PRIMETheme.primary),
                  label: Text(
                    'Добавить задачу',
                    style: TextStyle(
                      color: PRIMETheme.primary,
                      fontSize: isSmallScreen ? 14 : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _WeekTasks extends StatelessWidget {
  final Map<int, List<Map<String, dynamic>>> groupedTasks;
  final Function(String) onTaskToggle;

  const _WeekTasks({
    required this.groupedTasks,
    required this.onTaskToggle,
  });

  @override
  Widget build(BuildContext context) {
    final weekDays = {
      1: 'ПН', 2: 'ВТ', 3: 'СР', 4: 'ЧТ', 5: 'ПТ', 6: 'СБ', 7: 'ВС'
    };
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Неделя',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...weekDays.entries.map((entry) {
          final wd = entry.key;
          final label = entry.value;
          final items = groupedTasks[wd] ?? const [];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  Text(
                    'Нет задач',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PRIMETheme.sandWeak,
                    ),
                  )
                else
                  ...items.map((task) => _TaskItem(
                        text: task['text'] as String,
                        isDone: task['done'] as bool? ?? false,
                        habitName: task['habit'] as String?,
                        taskId: task['id'] as String,
                        task: task,
                        onToggle: onTaskToggle,
                      )),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TaskItem extends StatelessWidget {
  final String text;
  final bool isDone;
  final String? habitName;
  final String? taskId;
  final Map<String, dynamic>? task;
  final Function(String)? onToggle;

  const _TaskItem({
    required this.text,
    required this.isDone,
    this.habitName,
    this.taskId,
    this.task,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (taskId != null && onToggle != null) {
                onToggle!(taskId!);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(
                isDone ? Icons.check_box : Icons.check_box_outline_blank,
                color: isDone ? PRIMETheme.success : PRIMETheme.sandWeak,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Показываем детальную информацию о задаче, если есть полные данные
                if (task != null) {
                  final tasksPageState = context.findAncestorStateOfType<_TasksPageState>();
                  if (tasksPageState != null) {
                    tasksPageState._showTaskDetail(task!);
                  }
                } else if (taskId != null && onToggle != null) {
                  // Иначе просто переключаем состояние задачи
                  onToggle!(taskId!);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? PRIMETheme.sandWeak : PRIMETheme.sand,
                      fontSize: isSmallScreen ? 14 : null,
                    ),
                  ),
                  if (habitName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'связано с: $habitName',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PRIMETheme.primary,
                        fontSize: isSmallScreen ? 11 : 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkflowSection extends StatelessWidget {
  final List<Map<String, dynamic>> assignedTasks;
  final List<Map<String, dynamic>> inProgressTasks;
  final List<Map<String, dynamic>> doneTasks;
  final Function(Map<String, dynamic>) onTaskTap;
  final Function(String, String) onStatusChanged;

  const _WorkflowSection({
    required this.assignedTasks,
    required this.inProgressTasks,
    required this.doneTasks,
    required this.onTaskTap,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Рабочие процессы',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: isSmallScreen ? 20 : null,
          ),
        ),
        const SizedBox(height: 12),
        
        // Мини-колонки Kanban с адаптивностью
        if (isSmallScreen) ...[
          // Мобильная версия - горизонтальная прокрутка
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WorkflowColumn(
                  title: 'Назначено', 
                  tasks: assignedTasks, 
                  color: PRIMETheme.sandWeak, 
                  isCompact: true,
                  columnStatus: 'assigned',
                  onTaskTap: onTaskTap,
                  onStatusChanged: onStatusChanged,
                ),
                const SizedBox(width: 8),
                _WorkflowColumn(
                  title: 'В работе', 
                  tasks: inProgressTasks, 
                  color: PRIMETheme.warn, 
                  isCompact: true,
                  columnStatus: 'in_progress',
                  onTaskTap: onTaskTap,
                  onStatusChanged: onStatusChanged,
                ),
                const SizedBox(width: 8),
                _WorkflowColumn(
                  title: 'Готово', 
                  tasks: doneTasks, 
                  color: PRIMETheme.success, 
                  isCompact: true,
                  columnStatus: 'done',
                  onTaskTap: onTaskTap,
                  onStatusChanged: onStatusChanged,
                ),
                const SizedBox(width: 16), // Дополнительный отступ в конце
              ],
            ),
          ),
        ] else ...[
          // Десктопная версия - обычная сетка
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _WorkflowColumn(
                  title: 'Назначено', 
                  tasks: assignedTasks, 
                  color: PRIMETheme.sandWeak,
                  columnStatus: 'assigned',
                  onTaskTap: onTaskTap,
                  onStatusChanged: onStatusChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WorkflowColumn(
                  title: 'В работе', 
                  tasks: inProgressTasks, 
                  color: PRIMETheme.warn,
                  columnStatus: 'in_progress',
                  onTaskTap: onTaskTap,
                  onStatusChanged: onStatusChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _WorkflowColumn(
                  title: 'Готово', 
                  tasks: doneTasks, 
                  color: PRIMETheme.success,
                  columnStatus: 'done',
                  onTaskTap: onTaskTap,
                  onStatusChanged: onStatusChanged,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _WorkflowColumn extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> tasks;
  final Color color;
  final bool isCompact;
  final Function(Map<String, dynamic>) onTaskTap;
  final Function(String, String) onStatusChanged;
  final String columnStatus;

  const _WorkflowColumn({
    required this.title,
    required this.tasks,
    required this.color,
    required this.onTaskTap,
    required this.onStatusChanged,
    required this.columnStatus,
    this.isCompact = false,
  });


  @override
  Widget build(BuildContext context) {
    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        final data = details.data;
        final draggedId = data['id'] as String?;
        if (draggedId != null) {
          onStatusChanged(draggedId, columnStatus);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        return Container(
          width: isCompact ? 140 : null,
          padding: EdgeInsets.all(isCompact ? 8 : 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isHovering ? color : PRIMETheme.line, width: isHovering ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Заголовок колонки
          Row(
            children: [
              Container(
                width: isCompact ? 6 : 8,
                height: isCompact ? 6 : 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: isCompact ? 12 : 14,
                  ),
                ),
              ),
              // Счетчик задач
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 4 : 6, 
                  vertical: isCompact ? 2 : 3,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${tasks.length}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isCompact ? 9 : 10,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 6 : 8),
          
          // Карточки задач с drag-and-drop
      ...tasks.map((task) => _KanbanTaskCard(
                task: task,
                isCompact: isCompact,
                color: color,
                onTap: () => onTaskTap(task),
        onQuickChangeStatus: (status) => onStatusChanged(task['id'] as String, status),
              )),
          
          // Подсказка если колонка пустая
          if (tasks.isEmpty) ...[
            Container(
              padding: EdgeInsets.all(isCompact ? 8 : 12),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox,
                    size: isCompact ? 16 : 20,
                    color: PRIMETheme.sandWeak,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Пусто',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: isCompact ? 9 : 10,
                      color: PRIMETheme.sandWeak,
                    ),
                  ),
                ],
              ),
            ),
          ],
            ],
          ),
        );
      },
    );
  }
  
  // Вспомогательные методы в этом виджете не используются — удалены
}

class _KanbanTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool isCompact;
  final Color color;
  final VoidCallback onTap;
  final Function(String) onQuickChangeStatus;

  const _KanbanTaskCard({
    required this.task,
    required this.isCompact,
    required this.color,
    required this.onTap,
    required this.onQuickChangeStatus,
  });

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return PRIMETheme.warn;
      case 'medium':
        return PRIMETheme.primary;
      case 'low':
        return PRIMETheme.success;
      default:
        return PRIMETheme.sandWeak;
    }
  }

  bool _isDeadlineClose(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays <= 1;
  }

  bool _isOverdue(DateTime deadline) {
    return deadline.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Draggable<Map<String, dynamic>>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: isCompact ? 130 : 200,
          padding: EdgeInsets.all(isCompact ? 6 : 8),
          decoration: BoxDecoration(
            color: PRIMETheme.bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: PRIMETheme.primary, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _buildCardContent(context, true),
        ),
      ),
      childWhenDragging: Container(
        margin: EdgeInsets.only(bottom: isCompact ? 4 : 6),
        padding: EdgeInsets.all(isCompact ? 6 : 8),
        decoration: BoxDecoration(
          color: PRIMETheme.bg.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: PRIMETheme.line.withOpacity(0.5)),
        ),
        child: _buildCardContent(context, true),
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showQuickActions(context),
        child: Container(
          margin: EdgeInsets.only(bottom: isCompact ? 4 : 6),
          padding: EdgeInsets.all(isCompact ? 6 : 8),
          decoration: BoxDecoration(
            color: PRIMETheme.bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: PRIMETheme.line,
              width: 1,
            ),
          ),
          child: _buildCardContent(context, false),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, bool isDragging) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Название задачи
        Text(
          task['text'] as String,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: isCompact ? 10 : 12,
            fontWeight: FontWeight.w500,
            color: isDragging ? PRIMETheme.sand : null,
          ),
          maxLines: isCompact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        
        // Индикаторы приоритета и дедлайна
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Индикатор приоритета
            Container(
              width: isCompact ? 6 : 8,
              height: isCompact ? 6 : 8,
              decoration: BoxDecoration(
                color: _getPriorityColor(task['priority'] as String),
                shape: BoxShape.circle,
              ),
            ),
            
            // Дедлайн (если близкий)
            if (_isDeadlineClose(task['deadline'] as DateTime)) ...[
              Icon(
                Icons.access_time,
                size: isCompact ? 8 : 10,
                color: _isOverdue(task['deadline'] as DateTime) 
                    ? PRIMETheme.warn 
                    : PRIMETheme.sandWeak,
              ),
            ],
            
            // Иконка связанной привычки
            if (task['habit'] != null) ...[
              Icon(
                Icons.repeat,
                size: isCompact ? 8 : 10,
                color: PRIMETheme.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _QuickActionsSheet(
        task: task,
        onStatusChanged: onQuickChangeStatus,
      ),
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  final Map<String, dynamic> task;
  final Function(String) onStatusChanged;

  const _QuickActionsSheet({
    required this.task,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final currentStatus = task['status'] as String;
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Expanded(
                child: Text(
                  task['text'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: PRIMETheme.sandWeak),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'Переместить в:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
          ),
          const SizedBox(height: 12),
          
          // Быстрые действия
          if (currentStatus != 'assigned') ...[
            _QuickActionButton(
              icon: Icons.assignment,
              title: 'Назначено',
              subtitle: 'Вернуть к выполнению',
              color: PRIMETheme.sandWeak,
              onTap: () {
                onStatusChanged('assigned');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
          
          if (currentStatus != 'in_progress') ...[
            _QuickActionButton(
              icon: Icons.play_circle,
              title: 'В работе',
              subtitle: 'Начать выполнение',
              color: PRIMETheme.warn,
              onTap: () {
                onStatusChanged('in_progress');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
          
          if (currentStatus != 'done') ...[
            _QuickActionButton(
              icon: Icons.check_circle,
              title: 'Готово',
              subtitle: 'Отметить выполненной',
              color: PRIMETheme.success,
              onTap: () {
                onStatusChanged('done');
                Navigator.pop(context);
              },
            ),
          ],
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PRIMETheme.sandWeak,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
