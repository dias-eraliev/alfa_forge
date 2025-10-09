import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/health_goal_model.dart';
import '../../../app/theme.dart';
import 'goal_priority_selector.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/api_models.dart';
import '../../../core/api/api_client.dart';

class AdvancedHealthGoalsDialog extends StatefulWidget {
  final List<HealthGoal> existingGoals;
  final Function(List<HealthGoal>) onGoalsUpdated;

  const AdvancedHealthGoalsDialog({
    super.key,
    required this.existingGoals,
    required this.onGoalsUpdated,
  });

  @override
  State<AdvancedHealthGoalsDialog> createState() => _AdvancedHealthGoalsDialogState();
}

class _AdvancedHealthGoalsDialogState extends State<AdvancedHealthGoalsDialog>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _tabController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _tabAnimation;

  int _selectedTab = 0;
  final List<String> _tabs = ['Мои цели', 'Добавить цель', 'Статистика'];
  
  List<HealthGoal> _goals = [];
  String _searchQuery = '';
  HealthGoalPriority? _filterPriority;
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _goals = List.from(widget.existingGoals);
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _tabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _tabController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    _tabController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: const BoxDecoration(
          color: PRIMETheme.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Заголовок
            _buildHeader(),
            
            // Табы
            _buildTabs(),
            
            // Контент
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PRIMETheme.primary,
                  PRIMETheme.primary.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.flag,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Цели здоровья',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Управление и отслеживание целей',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PRIMETheme.sandWeak,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: PRIMETheme.sandWeak),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: PRIMETheme.line.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _selectedTab == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
                _tabController.reset();
                _tabController.forward();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected ? LinearGradient(
                    colors: [
                      PRIMETheme.primary,
                      PRIMETheme.primary.withOpacity(0.8),
                    ],
                  ) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? Colors.white : PRIMETheme.sandWeak,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    return AnimatedBuilder(
      animation: _tabAnimation,
      builder: (context, child) {
        switch (_selectedTab) {
          case 0:
            return _buildMyGoalsTab();
          case 1:
            return _buildAddGoalTab();
          case 2:
            return _buildStatisticsTab();
          default:
            return _buildMyGoalsTab();
        }
      },
    );
  }

  Widget _buildMyGoalsTab() {
    final filteredGoals = _goals.where((goal) {
      if (!_showCompleted && goal.isCompleted) return false;
      if (_filterPriority != null && goal.priority != _filterPriority) return false;
      if (_searchQuery.isNotEmpty && 
          !goal.title.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      return goal.isActive;
    }).toList();

    return Column(
      children: [
        // Поиск и фильтры
        _buildSearchAndFilters(),
        
        // Список целей
        Expanded(
          child: filteredGoals.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredGoals.length,
                  itemBuilder: (context, index) {
                    final goal = filteredGoals[index];
                    return _GoalCard(
                      goal: goal,
                      onEdit: () => _editGoal(goal),
                      onDelete: () => _deleteGoal(goal),
                      onToggleComplete: () => _toggleGoalComplete(goal),
                      onUpdateProgress: (value) => _updateGoalProgress(goal, value),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Поиск
          TextField(
            decoration: InputDecoration(
              hintText: 'Поиск целей...',
              prefixIcon: const Icon(Icons.search, color: PRIMETheme.sandWeak),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: PRIMETheme.line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: PRIMETheme.line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.primary),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          
          // Фильтры
          Row(
            children: [
              // Фильтр по приоритету
              Expanded(
                child: DropdownButtonFormField<HealthGoalPriority?>(
                  value: _filterPriority,
                  decoration: InputDecoration(
                    labelText: 'Приоритет',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<HealthGoalPriority?>(
                      value: null,
                      child: Text('Все'),
                    ),
                    ...HealthGoalPriority.values.map((priority) =>
                      DropdownMenuItem<HealthGoalPriority?>(
                        value: priority,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: priority.color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(priority.title),
                          ],
                        ),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterPriority = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              
              // Переключатель показа выполненных
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showCompleted = !_showCompleted;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: _showCompleted ? LinearGradient(
                      colors: [
                        PRIMETheme.success,
                        PRIMETheme.success.withOpacity(0.8),
                      ],
                    ) : null,
                    color: _showCompleted ? null : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _showCompleted ? PRIMETheme.success : PRIMETheme.line,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: _showCompleted ? Colors.white : PRIMETheme.sandWeak,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Выполненные',
                        style: TextStyle(
                          color: _showCompleted ? Colors.white : PRIMETheme.sandWeak,
                          fontSize: 12,
                          fontWeight: _showCompleted ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: PRIMETheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              Icons.flag_outlined,
              size: 48,
              color: PRIMETheme.primary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Нет целей',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте первую цель для отслеживания прогресса',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedTab = 1;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Добавить цель'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMETheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGoalTab() {
    return _AddGoalForm(
      onGoalAdded: (goal) {
        setState(() {
          _goals.add(goal);
          _selectedTab = 0;
        });
        widget.onGoalsUpdated(_goals);
      },
    );
  }

  Widget _buildStatisticsTab() {
    final stats = HealthGoalStatistics.fromGoals(_goals);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Общая статистика
          _buildOverallStats(stats),
          const SizedBox(height: 24),
          
          // Статистика по типам целей
          _buildGoalTypeStats(stats),
          const SizedBox(height: 24),
          
          // Статистика по приоритетам
          _buildPriorityStats(stats),
          const SizedBox(height: 24),
          
          // Прогресс за последние дни
          _buildProgressChart(),
        ],
      ),
    );
  }

  Widget _buildOverallStats(HealthGoalStatistics stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.primary.withOpacity(0.15),
            PRIMETheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Общая статистика',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  title: 'Всего целей',
                  value: stats.totalGoals.toString(),
                  icon: Icons.flag,
                  color: PRIMETheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  title: 'Активных',
                  value: stats.activeGoals.toString(),
                  icon: Icons.play_arrow,
                  color: const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  title: 'Выполнено',
                  value: stats.completedGoals.toString(),
                  icon: Icons.check_circle,
                  color: PRIMETheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatItem(
                  title: 'Просрочено',
                  value: stats.overdueGoals.toString(),
                  icon: Icons.warning,
                  color: PRIMETheme.warn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Средний прогресс
          Text(
            'Средний прогресс',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.averageProgress,
              backgroundColor: PRIMETheme.primary.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(PRIMETheme.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 4),
          
          Text(
            '${(stats.averageProgress * 100).toInt()}% выполнено',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PRIMETheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalTypeStats(HealthGoalStatistics stats) {
    if (stats.goalsByType.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Цели по типам',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...stats.goalsByType.entries.map((entry) {
          final type = entry.key;
          final count = entry.value;
          final percentage = count / stats.activeGoals;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  type.color.withOpacity(0.1),
                  type.color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: type.color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: type.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    type.icon,
                    color: type.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: type.color.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation(type.color),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  count.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: type.color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPriorityStats(HealthGoalStatistics stats) {
    if (stats.goalsByPriority.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Цели по приоритетам',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: HealthGoalPriority.values.map((priority) {
            final count = stats.goalsByPriority[priority] ?? 0;
            
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      priority.color.withOpacity(0.15),
                      priority.color.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: priority.color.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      count.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: priority.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      priority.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: priority.color,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Прогресс за последние 7 дней',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final height = 20 + math.Random().nextDouble() * 60;
                final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: 500 + index * 100),
                      width: 24,
                      height: height * _tabAnimation.value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            PRIMETheme.primary,
                            PRIMETheme.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayNames[index],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                        fontSize: 10,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Методы для работы с целями
  void _editGoal(HealthGoal goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddGoalForm(
        initialGoal: goal,
        onGoalAdded: (updated) {
          setState(() {
            final idx = _goals.indexWhere((g) => g.id == updated.id);
            if (idx >= 0) {
              _goals[idx] = updated;
            }
          });
          widget.onGoalsUpdated(_goals);
        },
      ),
    );
  }

  void _deleteGoal(HealthGoal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить цель?'),
        content: Text('Вы уверены, что хотите удалить цель "${goal.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final res = await ApiService.instance.deleteHealthGoal(goal.id);
                if (res.isSuccess) {
                  setState(() {
                    _goals.removeWhere((g) => g.id == goal.id);
                  });
                  widget.onGoalsUpdated(_goals);
                  if (mounted) Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Цель удалена'),
                        backgroundColor: PRIMETheme.warn,
                      ),
                    );
                  }
                } else {
                  if (mounted) Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ошибка удаления: ${res.error ?? ''}'),
                        backgroundColor: PRIMETheme.warn,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ошибка удаления: $e'),
                      backgroundColor: PRIMETheme.warn,
                    ),
                  );
                }
              }
            },
            child: const Text('Удалить', style: TextStyle(color: PRIMETheme.warn)),
          ),
        ],
      ),
    );
  }

  void _toggleGoalComplete(HealthGoal goal) {
    final newValue = goal.isCompleted ? (goal.targetValue * 0.8) : goal.targetValue;
    _updateGoalProgress(goal, newValue, showToastOnSuccess: true);
  }

  Future<void> _updateGoalProgress(HealthGoal goal, double newValue, {bool showToastOnSuccess = false}) async {
    try {
      final res = await ApiService.instance.updateHealthGoalProgress(goal.id, newValue);
      if (res.isSuccess) {
        final updated = goal.copyWith(currentValue: newValue);
        setState(() {
          final index = _goals.indexWhere((g) => g.id == goal.id);
          if (index >= 0) _goals[index] = updated;
        });
        widget.onGoalsUpdated(_goals);
        if (showToastOnSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(updated.isCompleted ? 'Цель выполнена! 🎉' : 'Прогресс обновлен'),
              backgroundColor: updated.isCompleted ? PRIMETheme.success : PRIMETheme.primary,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Не удалось обновить прогресс: ${res.error ?? ''}'),
              backgroundColor: PRIMETheme.warn,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка обновления: $e'),
            backgroundColor: PRIMETheme.warn,
          ),
        );
      }
    }
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final bool allowNull;

  const _DateSelector({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
    this.allowNull = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        
        GestureDetector(
          onTap: () => _showDatePicker(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: PRIMETheme.line),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: PRIMETheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedDate != null 
                        ? _formatDate(selectedDate!)
                        : 'Выберите дату',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selectedDate != null 
                          ? Theme.of(context).textTheme.bodyMedium?.color
                          : PRIMETheme.sandWeak,
                    ),
                  ),
                ),
                if (allowNull && selectedDate != null)
                  GestureDetector(
                    onTap: () => onDateSelected(DateTime.now()),
                    child: const Icon(
                      Icons.clear,
                      color: PRIMETheme.sandWeak,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Сегодня';
    } else if (selectedDay == tomorrow) {
      return 'Завтра';
    } else {
      final months = [
        'янв', 'фев', 'мар', 'апр', 'май', 'июн',
        'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: PRIMETheme.primary,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateSelected(picked);
    }
  }
}

class _GoalCard extends StatefulWidget {
  final HealthGoal goal;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleComplete;
  final Function(double) onUpdateProgress;

  const _GoalCard({
    required this.goal,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleComplete,
    required this.onUpdateProgress,
  });

  @override
  State<_GoalCard> createState() => _GoalCardState();
}

class _GoalCardState extends State<_GoalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.goal.type.color.withOpacity(0.1),
            widget.goal.type.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.goal.type.color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Основная карточка
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
              if (_isExpanded) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок и статус
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: widget.goal.type.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.goal.type.icon,
                          color: widget.goal.type.color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.goal.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: widget.goal.priority.color,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.goal.priority.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: widget.goal.statusColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.goal.statusText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: PRIMETheme.sandWeak,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Прогресс
                  Text(
                    widget.goal.progressText,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.goal.type.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: widget.goal.progress,
                      backgroundColor: widget.goal.type.color.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(widget.goal.type.color),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  Text(
                    '${(widget.goal.progress * 100).toInt()}% выполнено',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.goal.type.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Развернутое содержимое
          AnimatedBuilder(
            animation: _expandAnimation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: _expandAnimation.value,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Детали цели
                  if (widget.goal.notes != null) ...[
                    Text(
                      'Заметки:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.goal.notes!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Даты
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Начало:',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: PRIMETheme.sandWeak,
                              ),
                            ),
                            Text(
                              '${widget.goal.startDate.day}.${widget.goal.startDate.month}.${widget.goal.startDate.year}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (widget.goal.targetDate != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Цель:',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: PRIMETheme.sandWeak,
                                ),
                              ),
                              Text(
                                '${widget.goal.targetDate!.day}.${widget.goal.targetDate!.month}.${widget.goal.targetDate!.year}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Кнопки действий
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Изменить'),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: widget.goal.type.color),
                            foregroundColor: widget.goal.type.color,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: widget.onToggleComplete,
                          icon: Icon(
                            widget.goal.isCompleted ? Icons.undo : Icons.check,
                            size: 16,
                          ),
                          label: Text(
                            widget.goal.isCompleted ? 'Отменить' : 'Выполнить',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: widget.goal.isCompleted 
                                ? PRIMETheme.warn 
                                : PRIMETheme.success,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: widget.onDelete,
                        icon: const Icon(Icons.delete_outline),
                        color: PRIMETheme.warn,
                      ),
                    ],
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

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AddGoalForm extends StatefulWidget {
  final Function(HealthGoal) onGoalAdded;
  final HealthGoal? initialGoal;

  const _AddGoalForm({required this.onGoalAdded, this.initialGoal});

  @override
  State<_AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends State<_AddGoalForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _notesController = TextEditingController();

  HealthGoalType? _selectedType;
  HealthGoalPriority _selectedPriority = HealthGoalPriority.medium;
  HealthGoalFrequency _selectedFrequency = HealthGoalFrequency.daily;
  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;

  @override
  void dispose() {
    _titleController.dispose();
    _targetValueController.dispose();
    _currentValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Префилл полей при редактировании
    final isEdit = widget.initialGoal != null;
    if (isEdit && _selectedType == null) {
      final g = widget.initialGoal!;
      _selectedType = g.type;
      _titleController.text = g.title;
      _targetValueController.text = g.targetValue.toString();
      _currentValueController.text = g.currentValue.toString();
      _selectedPriority = g.priority;
      _selectedFrequency = g.frequency;
      _startDate = g.startDate;
      _targetDate = g.targetDate;
      _notesController.text = g.notes ?? '';
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Выбор типа цели
            GoalTypeSelector(
              selectedType: _selectedType,
              onTypeSelected: (type) {
                setState(() {
                  _selectedType = type;
                  // Автозаполнение названия
                  if (_titleController.text.isEmpty) {
                    _titleController.text = type.title;
                  }
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Название цели
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Название цели',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(
                  _selectedType?.icon ?? Icons.flag,
                  color: _selectedType?.color ?? PRIMETheme.primary,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Введите название цели';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Целевое и текущее значение
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _targetValueController,
                    decoration: InputDecoration(
                      labelText: 'Целевое значение',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixText: _selectedType?.unit ?? '',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите целевое значение';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Введите корректное число';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _currentValueController,
                    decoration: InputDecoration(
                      labelText: 'Текущее значение',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixText: _selectedType?.unit ?? '',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Введите текущее значение';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Введите корректное число';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Приоритет
            GoalPrioritySelector(
              selectedPriority: _selectedPriority,
              onPrioritySelected: (priority) {
                setState(() {
                  _selectedPriority = priority;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Частота
            GoalFrequencySelector(
              selectedFrequency: _selectedFrequency,
              onFrequencySelected: (frequency) {
                setState(() {
                  _selectedFrequency = frequency;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Даты
            Row(
              children: [
                Expanded(
                  child: _DateSelector(
                    label: 'Дата начала',
                    selectedDate: _startDate,
                    onDateSelected: (date) {
                      setState(() {
                        _startDate = date;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateSelector(
                    label: 'Дата цели (опционально)',
                    selectedDate: _targetDate,
                    onDateSelected: (date) {
                      setState(() {
                        _targetDate = date;
                      });
                    },
                    allowNull: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Заметки
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: 'Заметки (опционально)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            
            // Кнопка создания
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedType == null ? null : () => _submitGoal(isEdit: isEdit),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType?.color ?? PRIMETheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_selectedType?.icon ?? Icons.flag),
                    const SizedBox(width: 8),
                    Text(isEdit ? 'Сохранить цель' : 'Создать цель',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitGoal({required bool isEdit}) async {
    if (!(_formKey.currentState!.validate() && _selectedType != null)) return;

    final dto = <String, dynamic>{
      'title': _titleController.text.trim(),
      'goalType': _goalTypeToBackend(_selectedType!),
      'targetValue': double.parse(_targetValueController.text),
      'currentValue': double.parse(_currentValueController.text),
      'priority': _priorityToBackend(_selectedPriority),
      'frequency': _frequencyToBackend(_selectedFrequency),
      'startDate': _startDate.toIso8601String(),
      if (_targetDate != null) 'targetDate': _targetDate!.toIso8601String(),
      // 'typeId': _measurementTypeIdForGoal(_selectedType!), // опционально
      if (_notesController.text.trim().isNotEmpty) 'notes': _notesController.text.trim(),
    };

    try {
      ApiResponse<ApiHealthGoal> res;
      if (isEdit) {
        res = await ApiService.instance.updateHealthGoal(widget.initialGoal!.id, dto);
      } else {
        res = await ApiService.instance.createHealthGoal(dto);
      }

      if (res.isSuccess && res.data != null) {
        final local = _mapApiGoalToLocal(res.data!);
        widget.onGoalAdded(local);

        if (!isEdit) {
          // Очистка лишь для режима создания
          _titleController.clear();
          _targetValueController.clear();
          _currentValueController.clear();
          _notesController.clear();
          setState(() {
            _selectedType = null;
            _selectedPriority = HealthGoalPriority.medium;
            _selectedFrequency = HealthGoalFrequency.daily;
            _startDate = DateTime.now();
            _targetDate = null;
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEdit ? 'Цель обновлена' : 'Цель создана! 🎯'),
              backgroundColor: PRIMETheme.success,
            ),
          );
        }
        if (isEdit && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка сохранения: ${res.error ?? ''}'),
              backgroundColor: PRIMETheme.warn,
            ),
          );
        }
      }
    } catch (e) {
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
}

// ===== Helpers: mapping enums and models =====

String _goalTypeToBackend(HealthGoalType t) {
  switch (t) {
    case HealthGoalType.weight:
      return 'WEIGHT';
    case HealthGoalType.bodyFat:
      return 'BODY_FAT';
    case HealthGoalType.muscle:
      return 'MUSCLE';
    case HealthGoalType.waist:
      return 'WAIST';
    case HealthGoalType.chest:
      return 'CHEST';
    case HealthGoalType.hips:
      return 'HIPS';
    case HealthGoalType.biceps:
      return 'BICEPS';
    case HealthGoalType.steps:
      return 'STEPS';
    case HealthGoalType.water:
      return 'WATER';
    case HealthGoalType.sleep:
      return 'SLEEP';
    case HealthGoalType.heartRate:
      return 'HEART_RATE';
    case HealthGoalType.bloodPressure:
      return 'BLOOD_PRESSURE';
    case HealthGoalType.calories:
      return 'CALORIES';
  }
}

String _priorityToBackend(HealthGoalPriority p) {
  switch (p) {
    case HealthGoalPriority.low:
      return 'LOW';
    case HealthGoalPriority.medium:
      return 'MEDIUM';
    case HealthGoalPriority.high:
      return 'HIGH';
  }
}

String _frequencyToBackend(HealthGoalFrequency f) {
  switch (f) {
    case HealthGoalFrequency.daily:
      return 'DAILY';
    case HealthGoalFrequency.weekly:
      return 'WEEKLY';
    case HealthGoalFrequency.monthly:
      return 'MONTHLY';
    case HealthGoalFrequency.yearly:
      return 'YEARLY';
  }
}

HealthGoal _mapApiGoalToLocal(ApiHealthGoal g) {
  HealthGoalType mapType(String s) {
    switch (s) {
      case 'WEIGHT':
        return HealthGoalType.weight;
      case 'BODY_FAT':
        return HealthGoalType.bodyFat;
      case 'MUSCLE':
        return HealthGoalType.muscle;
      case 'WAIST':
        return HealthGoalType.waist;
      case 'CHEST':
        return HealthGoalType.chest;
      case 'HIPS':
        return HealthGoalType.hips;
      case 'BICEPS':
        return HealthGoalType.biceps;
      case 'STEPS':
        return HealthGoalType.steps;
      case 'WATER':
        return HealthGoalType.water;
      case 'SLEEP':
        return HealthGoalType.sleep;
      case 'HEART_RATE':
        return HealthGoalType.heartRate;
      case 'BLOOD_PRESSURE':
        return HealthGoalType.bloodPressure;
      case 'CALORIES':
        return HealthGoalType.calories;
      default:
        return HealthGoalType.weight;
    }
  }

  HealthGoalPriority mapPriority(String s) {
    switch (s) {
      case 'LOW':
        return HealthGoalPriority.low;
      case 'HIGH':
        return HealthGoalPriority.high;
      case 'MEDIUM':
      default:
        return HealthGoalPriority.medium;
    }
  }

  HealthGoalFrequency mapFrequency(String s) {
    switch (s) {
      case 'DAILY':
        return HealthGoalFrequency.daily;
      case 'MONTHLY':
        return HealthGoalFrequency.monthly;
      case 'YEARLY':
        return HealthGoalFrequency.yearly;
      case 'WEEKLY':
      default:
        return HealthGoalFrequency.weekly;
    }
  }

  return HealthGoal(
    id: g.id,
    type: mapType(g.goalType),
    title: g.title,
    targetValue: g.targetValue,
    currentValue: g.currentValue,
    priority: mapPriority(g.priority),
    frequency: mapFrequency(g.frequency),
    startDate: g.startDate ?? DateTime.now(),
    targetDate: g.targetDate,
    notes: g.notes,
    isActive: g.isActive,
    createdAt: g.createdAt,
    updatedAt: g.updatedAt,
  );
}
