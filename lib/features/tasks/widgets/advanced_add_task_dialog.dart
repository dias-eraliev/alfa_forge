import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../models/task_model.dart';
import 'date_time_picker.dart';
import 'priority_selector.dart';

class AdvancedAddTaskDialog extends StatefulWidget {
  final Function(TaskModel) onTaskAdded;
  final TaskModel? initialTask;

  const AdvancedAddTaskDialog({
    super.key,
    required this.onTaskAdded,
    this.initialTask,
  });

  @override
  State<AdvancedAddTaskDialog> createState() => _AdvancedAddTaskDialogState();
}

class _AdvancedAddTaskDialogState extends State<AdvancedAddTaskDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pageController = PageController();
  
  late DateTime _selectedDeadline;
  late TaskPriority _selectedPriority;
  late TaskStatus _selectedStatus;
  String? _selectedHabit;
  List<String> _selectedTags = [];
  bool _isRecurring = false;
  RecurringType? _recurringType;
  DateTime? _reminderAt;
  
  int _currentPage = 0;
  final int _totalPages = 3;
  
  late AnimationController _progressAnimationController;
  late Animation<double> _progressAnimation;

  // Список доступных привычек (можно загружать из базы данных)
  final List<String> _availableHabits = [
    'Бег',
    'Чтение',
    'Медитация',
    'Спорт',
    'Изучение языков',
    'Программирование',
  ];

  // Список популярных тегов
  final List<String> _availableTags = [
    'Работа',
    'Личное',
    'Здоровье',
    'Учеба',
    'Семья',
    'Проект',
    'Покупки',
    'Важное',
  ];

  @override
  void initState() {
    super.initState();
    
    // Инициализация значений
    if (widget.initialTask != null) {
      final task = widget.initialTask!;
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _selectedDeadline = task.deadline;
      _selectedPriority = task.priority;
      _selectedStatus = task.status;
      _selectedHabit = task.habitName;
      _selectedTags = List.from(task.tags);
      _isRecurring = task.isRecurring;
      _recurringType = task.recurringType;
      _reminderAt = task.reminderAt;
    } else {
      _selectedDeadline = DateTime.now().add(const Duration(days: 1));
      _selectedPriority = TaskPriority.medium;
      _selectedStatus = TaskStatus.assigned;
    }

    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _updateProgress();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  void _updateProgress() {
    final progress = (_currentPage + 1) / _totalPages;
    _progressAnimationController.animateTo(progress);
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _currentPage++;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }

  void _saveTask() {
    if (_formKey.currentState?.validate() ?? false) {
      final task = TaskModel(
        id: widget.initialTask?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        deadline: _selectedDeadline,
        priority: _selectedPriority,
        status: _selectedStatus,
        habitName: _selectedHabit,
        tags: _selectedTags,
        createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isRecurring: _isRecurring,
        recurringType: _recurringType,
        reminderAt: _reminderAt,
      );
      
      widget.onTaskAdded(task);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSmallScreen ? 20 : 40,
      ),
      child: Container(
        height: screenHeight * (isSmallScreen ? 0.9 : 0.8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: Column(
          children: [
            // Заголовок с прогрессом
            _buildHeader(),
            
            // Основной контент
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildBasicInfoPage(),
                    _buildDetailsPage(),
                    _buildAdvancedOptionsPage(),
                  ],
                ),
              ),
            ),
            
            // Кнопки навигации
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: PRIMETheme.line)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.initialTask != null ? 'Редактировать задачу' : 'Новая задача',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: PRIMETheme.sandWeak),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Индикатор прогресса
          Row(
            children: [
              Expanded(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: PRIMETheme.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_currentPage + 1} из $_totalPages',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Основная информация',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Название задачи
          _buildTextField(
            controller: _titleController,
            label: 'Название задачи',
            isRequired: true,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Название задачи обязательно';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Описание
          _buildTextField(
            controller: _descriptionController,
            label: 'Описание',
            maxLines: 4,
            hintText: 'Добавьте подробное описание задачи...',
          ),
          const SizedBox(height: 20),
          
          // Быстрые шаблоны
          _buildQuickTemplates(),
        ],
      ),
    );
  }

  Widget _buildDetailsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Детали задачи',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Дедлайн
          DateTimePicker(
            selectedDateTime: _selectedDeadline,
            onDateTimeChanged: (dateTime) {
              setState(() {
                _selectedDeadline = dateTime;
              });
            },
            isRequired: true,
          ),
          const SizedBox(height: 20),
          
          // Приоритет
          CompactPrioritySelector(
            selectedPriority: _selectedPriority,
            onPriorityChanged: (priority) {
              setState(() {
                _selectedPriority = priority;
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Статус
          _buildStatusSelector(),
          const SizedBox(height: 20),
          
          // Связь с привычкой
          _buildHabitSelector(),
        ],
      ),
    );
  }

  Widget _buildAdvancedOptionsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Дополнительные настройки',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Теги
          _buildTagsSelector(),
          const SizedBox(height: 20),
          
          // Повторение
          _buildRecurringOptions(),
          const SizedBox(height: 20),
          
          // Напоминание
          _buildReminderOptions(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: PRIMETheme.warn),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: PRIMETheme.sandWeak),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PRIMETheme.line),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PRIMETheme.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: PRIMETheme.warn),
            ),
            filled: true,
            fillColor: PRIMETheme.bg,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickTemplates() {
    final templates = [
      TaskTemplate(
        id: '1',
        title: 'Встреча',
        description: 'Важная встреча с командой',
        defaultPriority: TaskPriority.high,
        defaultDeadlineOffset: const Duration(hours: 2),
      ),
      TaskTemplate(
        id: '2',
        title: 'Покупки',
        description: 'Список покупок в магазине',
        defaultPriority: TaskPriority.low,
        defaultTags: ['Личное', 'Покупки'],
      ),
      TaskTemplate(
        id: '3',
        title: 'Тренировка',
        description: 'Ежедневная физическая активность',
        defaultPriority: TaskPriority.medium,
        habitName: 'Спорт',
        defaultTags: ['Здоровье'],
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрые шаблоны',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: PRIMETheme.sandWeak,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: templates.map((template) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _titleController.text = template.title;
                  _descriptionController.text = template.description;
                  _selectedPriority = template.defaultPriority;
                  _selectedDeadline = DateTime.now().add(template.defaultDeadlineOffset);
                  _selectedTags = List.from(template.defaultTags);
                  _selectedHabit = template.habitName;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: PRIMETheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flash_on,
                      size: 16,
                      color: PRIMETheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      template.title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildStatusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Статус',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: TaskStatus.values.map((status) {
            final isSelected = status == _selectedStatus;
            final color = _getStatusColor(status);
            
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedStatus = status;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? color : color.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    status.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? PRIMETheme.sand : color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHabitSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Связь с привычкой',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: PRIMETheme.line),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: _selectedHabit,
              isExpanded: true,
              hint: const Text('Выберите привычку (опционально)'),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Без привычки'),
                ),
                ..._availableHabits.map((habit) {
                  return DropdownMenuItem<String>(
                    value: habit,
                    child: Text(habit),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedHabit = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Теги',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableTags.map((tag) {
            final isSelected = _selectedTags.contains(tag);
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedTags.remove(tag);
                  } else {
                    _selectedTags.add(tag);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? PRIMETheme.primary : PRIMETheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: PRIMETheme.primary,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected ? PRIMETheme.sand : PRIMETheme.primary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecurringOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Повторяющаяся задача',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Switch(
              value: _isRecurring,
              onChanged: (value) {
                setState(() {
                  _isRecurring = value;
                  if (!value) {
                    _recurringType = null;
                  }
                });
              },
              activeColor: PRIMETheme.primary,
            ),
          ],
        ),
        if (_isRecurring) ...[
          const SizedBox(height: 8),
          Row(
            children: RecurringType.values.map((type) {
              final isSelected = type == _recurringType;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _recurringType = type;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? PRIMETheme.primary : PRIMETheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: PRIMETheme.primary,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      type.displayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isSelected ? PRIMETheme.sand : PRIMETheme.primary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildReminderOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Напоминание',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Switch(
              value: _reminderAt != null,
              onChanged: (value) {
                setState(() {
                  if (value) {
                    _reminderAt = _selectedDeadline.subtract(const Duration(hours: 1));
                  } else {
                    _reminderAt = null;
                  }
                });
              },
              activeColor: PRIMETheme.primary,
            ),
          ],
        ),
        if (_reminderAt != null) ...[
          const SizedBox(height: 8),
          Text(
            'Напомнить за час до дедлайна',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: PRIMETheme.line)),
      ),
      child: Row(
        children: [
          if (_currentPage > 0) ...[
            Expanded(
              child: TextButton(
                onPressed: _previousPage,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Назад',
                  style: TextStyle(
                    color: PRIMETheme.sandWeak,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ] else ...[
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Отмена',
                  style: TextStyle(
                    color: PRIMETheme.sandWeak,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _currentPage == _totalPages - 1 ? _saveTask : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMETheme.primary,
                foregroundColor: PRIMETheme.sand,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == _totalPages - 1 ? 'Создать задачу' : 'Далее',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.assigned:
        return PRIMETheme.sandWeak;
      case TaskStatus.inProgress:
        return PRIMETheme.warn;
      case TaskStatus.done:
        return PRIMETheme.success;
    }
  }
}
