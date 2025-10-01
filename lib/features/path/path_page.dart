import 'package:flutter/material.dart';
import 'dart:async';
import '../shared/bottom_nav_scaffold.dart';
import '../../app/theme.dart';
import 'widgets/six_goals_grid.dart';
import '../gto/gto_page.dart';

class PathPage extends StatefulWidget {
  const PathPage({super.key});

  @override
  State<PathPage> createState() => _PathPageState();
}

class _PathPageState extends State<PathPage> {
  // Состояние привычек
  List<Map<String, dynamic>> habits = [
    {'name': 'Вода 2L', 'progress': '1.2L / 2L', 'done': false},
    {'name': 'Бег 5км', 'progress': '19:00', 'done': false},
    {'name': 'Медитация', 'progress': '5 мин', 'done': true},
  ];

  // Состояние задачи дня
  bool isTaskStarted = false;

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentRoute: '/',
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок PRIME
              Text(
                'PRIME',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              
              // Статус игрока с рамкой и кнопка MY MAP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(color: PRIMETheme.primary, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: PRIMETheme.primary.withOpacity(0.1),
                    ),
                    child: Text(
                      'ВОИН',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: PRIMETheme.primary,
                        fontSize: 24,
                      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

              // Метрики СТРИК и ПРОГРЕСС (кликабельные)
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'СТРИК',
                      value: '12',
                      icon: Icons.local_fire_department,
                      onTap: () => _showStreakDetails(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: 'ПРОГРЕСС',
                      value: '67%',
                      icon: Icons.timeline,
                      onTap: () => _showProgressDetails(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Задача дня
              _TaskCard(
                isStarted: isTaskStarted,
                onStart: () => _startDailyTask(),
              ),
              const SizedBox(height: 24),

              // Сегодня (ближайшее окно)
              Text(
                'Сегодня (ближайшее окно)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              _HabitsList(
                habits: habits,
                onHabitToggle: (index) => _toggleHabit(index),
              ),
              const SizedBox(height: 24),

              // Прогресс недели (кликабельный)
              _WeekProgress(
                onTap: () => _showWeekDetails(),
              ),
              const SizedBox(height: 24),

              // Кнопки действий
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
                  MaterialPageRoute(
                    builder: (context) => const GTOPage(),
                  ),
                ),
                isPrimary: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Переключение состояния привычки
  void _toggleHabit(int index) {
    setState(() {
      habits[index]['done'] = !habits[index]['done'];
    });
    
    // Показать снэкбар с обратной связью
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          habits[index]['done'] 
            ? '${habits[index]['name']} отмечена как выполненная!'
            : '${habits[index]['name']} отмечена как невыполненная',
        ),
        backgroundColor: habits[index]['done'] ? PRIMETheme.success : PRIMETheme.warn,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Запуск задачи дня
  void _startDailyTask() {
    setState(() {
      isTaskStarted = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Задача дня начата! Удачи!'),
        backgroundColor: PRIMETheme.success,
        duration: Duration(seconds: 3),
      ),
    );

    // Через 3 секунды сбросить состояние для демо
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          isTaskStarted = false;
        });
      }
    });
  }

  // Показать детали стрика
  void _showStreakDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Стрик', style: TextStyle(color: PRIMETheme.sand)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Текущий стрик: 12 дней', style: TextStyle(color: PRIMETheme.sandWeak)),
            SizedBox(height: 8),
            Text('Лучший стрик: 25 дней', style: TextStyle(color: PRIMETheme.sandWeak)),
            SizedBox(height: 8),
            Text('До следующей награды: 3 дня', style: TextStyle(color: PRIMETheme.sandWeak)),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.8,
              backgroundColor: PRIMETheme.line,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК', style: TextStyle(color: PRIMETheme.primary)),
          ),
        ],
      ),
    );
  }

  // Показать детали прогресса
  void _showProgressDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Общий прогресс', style: TextStyle(color: PRIMETheme.sand)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Общий прогресс: 67%', style: TextStyle(color: PRIMETheme.sandWeak, fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Прогресс по сферам:', style: TextStyle(color: PRIMETheme.sand, fontSize: 14)),
            SizedBox(height: 12),
            _SphereProgressItem(title: '💪 ТЕЛО', progress: 0.85),
            _SphereProgressItem(title: '🔥 ВОЛЯ', progress: 0.45),
            _SphereProgressItem(title: '🎯 ФОКУС', progress: 0.70),
            _SphereProgressItem(title: '🧠 РАЗУМ', progress: 0.55),
            _SphereProgressItem(title: '🧘 СПОКОЙСТВИЕ', progress: 0.80),
            _SphereProgressItem(title: '💰 ДЕНЬГИ', progress: 0.30),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК', style: TextStyle(color: PRIMETheme.primary)),
          ),
        ],
      ),
    );
  }

  // Показать детали недели
  void _showWeekDetails() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Прогресс недели', style: TextStyle(color: PRIMETheme.sand)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Выполнено: 73%', style: TextStyle(color: PRIMETheme.sandWeak)),
            SizedBox(height: 8),
            Text('Привычки: 22/30', style: TextStyle(color: PRIMETheme.sandWeak)),
            Text('Задачи: 15/20', style: TextStyle(color: PRIMETheme.sandWeak)),
            Text('Фокус-сессии: 8/10', style: TextStyle(color: PRIMETheme.sandWeak)),
            SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.73,
              backgroundColor: PRIMETheme.line,
              valueColor: AlwaysStoppedAnimation<Color>(PRIMETheme.sand),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК', style: TextStyle(color: PRIMETheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showHabitModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _HabitModal(),
    );
  }

  void _showTaskModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TaskModal(),
    );
  }

  void _showFocusTimeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FocusTimeSelector(),
    );
  }
}

// Виджет элемента прогресса сферы
class _SphereProgressItem extends StatelessWidget {
  final String title;
  final double progress;

  const _SphereProgressItem({
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: PRIMETheme.sandWeak,
                  fontSize: 12,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  color: PRIMETheme.sandWeak,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: PRIMETheme.line,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(progress),
            ),
          ),
        ],
      ),
    );
  }

  // Получить цвет прогресс-бара в зависимости от прогресса
  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return PRIMETheme.success;
    if (progress >= 0.6) return Colors.lightGreen;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: PRIMETheme.sand, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (onTap != null)
                  const Icon(Icons.info_outline, color: PRIMETheme.sandWeak, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 32,
                color: PRIMETheme.sand,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final bool isStarted;
  final VoidCallback onStart;

  const _TaskCard({
    required this.isStarted,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Задача дня',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'Завершить презентацию для клиента и отправить на ревью',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isStarted ? null : onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: isStarted ? PRIMETheme.success : PRIMETheme.primary,
                foregroundColor: PRIMETheme.sand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(isStarted ? 'В процессе...' : 'Старт'),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsList extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final Function(int) onHabitToggle;

  const _HabitsList({
    required this.habits,
    required this.onHabitToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: habits.asMap().entries.map((entry) {
        final index = entry.key;
        final habit = entry.value;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onHabitToggle(index),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: habit['done'] ? PRIMETheme.success : PRIMETheme.line,
                    width: habit['done'] ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        habit['done'] as bool ? Icons.check_circle : Icons.circle_outlined,
                        color: habit['done'] as bool ? PRIMETheme.success : PRIMETheme.sandWeak,
                        key: ValueKey(habit['done']),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit['name'] as String,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              decoration: habit['done'] ? TextDecoration.lineThrough : null,
                              color: habit['done'] ? PRIMETheme.sandWeak : PRIMETheme.sand,
                            ),
                          ),
                          Text(
                            habit['progress'] as String,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.touch_app,
                      color: PRIMETheme.sandWeak,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekProgress extends StatelessWidget {
  final VoidCallback? onTap;

  const _WeekProgress({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Прогресс недели',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (onTap != null)
                  const Icon(Icons.info_outline, color: PRIMETheme.sandWeak, size: 16),
              ],
            ),
            const SizedBox(height: 12),
            const LinearProgressIndicator(
              value: 0.73,
              backgroundColor: PRIMETheme.line,
              valueColor: AlwaysStoppedAnimation<Color>(PRIMETheme.sand),
            ),
            const SizedBox(height: 8),
            Text(
              '73% выполнено',
              style: Theme.of(context).textTheme.bodyMedium,
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? PRIMETheme.primary : Theme.of(context).cardColor,
          foregroundColor: PRIMETheme.sand,
          side: isPrimary ? null : const BorderSide(color: PRIMETheme.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(text),
      ),
    );
  }
}

// Модалка выбора времени для фокуса
class _FocusTimeSelector extends StatelessWidget {
  final List<int> timeOptions = [15, 25, 45, 60];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Выберите время фокуса',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          ...timeOptions.map((minutes) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FocusTimerPage(minutes: minutes),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: PRIMETheme.sand,
                side: const BorderSide(color: PRIMETheme.line),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                '$minutes минут',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          )),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: PRIMETheme.sandWeak),
            ),
          ),
        ],
      ),
    );
  }
}

// Модалка добавления привычки
class _HabitModal extends StatefulWidget {
  @override
  State<_HabitModal> createState() => _HabitModalState();
}

class _HabitModalState extends State<_HabitModal> {
  final _nameController = TextEditingController();
  String _frequency = 'Ежедневно';
  final List<String> _frequencies = ['Ежедневно', 'Еженедельно', '3 раза в неделю', '2 раза в неделю'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Новая привычка',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _nameController,
            style: const TextStyle(color: PRIMETheme.sand),
            decoration: InputDecoration(
              labelText: 'Название привычки',
              labelStyle: const TextStyle(color: PRIMETheme.sandWeak),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.primary),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Частота',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          
          DropdownButtonFormField<String>(
            initialValue: _frequency,
            dropdownColor: Theme.of(context).cardColor,
            style: const TextStyle(color: PRIMETheme.sand),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _frequencies.map((freq) => DropdownMenuItem(
              value: freq,
              child: Text(freq),
            )).toList(),
            onChanged: (value) => setState(() => _frequency = value!),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(color: PRIMETheme.sandWeak),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Привычка "${_nameController.text}" добавлена'),
                          backgroundColor: PRIMETheme.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMETheme.primary,
                    foregroundColor: PRIMETheme.sand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Создать'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Модалка добавления задачи
class _TaskModal extends StatefulWidget {
  @override
  State<_TaskModal> createState() => _TaskModalState();
}

class _TaskModalState extends State<_TaskModal> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _priority = 'Средний';
  final List<String> _priorities = ['Низкий', 'Средний', 'Высокий'];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Новая задача',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          
          TextField(
            controller: _titleController,
            style: const TextStyle(color: PRIMETheme.sand),
            decoration: InputDecoration(
              labelText: 'Название задачи',
              labelStyle: const TextStyle(color: PRIMETheme.sandWeak),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.primary),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          TextField(
            controller: _descriptionController,
            style: const TextStyle(color: PRIMETheme.sand),
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Описание (опционально)',
              labelStyle: const TextStyle(color: PRIMETheme.sandWeak),
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.primary),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Приоритет',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          
          DropdownButtonFormField<String>(
            initialValue: _priority,
            dropdownColor: Theme.of(context).cardColor,
            style: const TextStyle(color: PRIMETheme.sand),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: PRIMETheme.line),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: _priorities.map((priority) => DropdownMenuItem(
              value: priority,
              child: Text(priority),
            )).toList(),
            onChanged: (value) => setState(() => _priority = value!),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Отмена',
                    style: TextStyle(color: PRIMETheme.sandWeak),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Задача "${_titleController.text}" добавлена'),
                          backgroundColor: PRIMETheme.success,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMETheme.primary,
                    foregroundColor: PRIMETheme.sand,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Создать'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Страница таймера фокуса
class FocusTimerPage extends StatefulWidget {
  final int minutes;

  const FocusTimerPage({super.key, required this.minutes});

  @override
  State<FocusTimerPage> createState() => _FocusTimerPageState();
}

class _FocusTimerPageState extends State<FocusTimerPage> {
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.minutes * 60;
    _remainingSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isPaused = false;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _showCompletionDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    setState(() {
      _isPaused = true;
      _isRunning = false;
    });
    _timer?.cancel();
  }

  void _stopTimer() {
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      _isPaused = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('Сессия завершена!', style: TextStyle(color: PRIMETheme.sand)),
        content: const Text('Отличная работа! Фокус сессия завершена.', style: TextStyle(color: PRIMETheme.sandWeak)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('ОК', style: TextStyle(color: PRIMETheme.primary)),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_totalSeconds - _remainingSeconds) / _totalSeconds;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Фокус ${widget.minutes} мин', style: const TextStyle(color: PRIMETheme.sand)),
        iconTheme: const IconThemeData(color: PRIMETheme.sand),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Круглый прогресс-бар
            SizedBox(
              width: 250,
              height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: PRIMETheme.line,
                      valueColor: const AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 48,
                          color: PRIMETheme.sand,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isPaused ? 'Пауза' : _isRunning ? 'Фокус' : 'Готов',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: PRIMETheme.sandWeak,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            
            // Кнопки управления
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!_isRunning && !_isPaused)
                  ElevatedButton(
                    onPressed: _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMETheme.primary,
                      foregroundColor: PRIMETheme.sand,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.play_arrow, size: 32),
                  ),
                
                if (_isRunning)
                  ElevatedButton(
                    onPressed: _pauseTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMETheme.warn,
                      foregroundColor: PRIMETheme.sand,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.pause, size: 32),
                  ),
                
                if (_isPaused)
                  ElevatedButton(
                    onPressed: _startTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMETheme.primary,
                      foregroundColor: PRIMETheme.sand,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.play_arrow, size: 32),
                  ),
                
                ElevatedButton(
                  onPressed: _stopTimer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMETheme.primary,
                    foregroundColor: PRIMETheme.sand,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(Icons.stop, size: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
