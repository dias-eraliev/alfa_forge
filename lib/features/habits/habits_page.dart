import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../shared/bottom_nav_scaffold.dart';
import '../../app/theme.dart';
import 'models/habit_model.dart';
import 'widgets/advanced_add_habit_dialog.dart';
import '../../core/services/api_service.dart';
import '../../core/models/api_models.dart';
import 'utils/habit_converter.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> with TickerProviderStateMixin {
  int currentMonth = DateTime.now().month;
  int currentYear = DateTime.now().year;
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // API данные
  final ApiService _apiService = ApiService.instance;
  List<ApiHabit> _apiHabits = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Состояние привычек для каждого дня месяца (теперь из API)
  Map<String, List<bool?>> habitsData = {};

  // Резервные моковые данные на случай отсутствия API
  final List<Map<String, dynamic>> _fallbackHabits = [
    {
      'id': 'cold_shower',
      'name': 'Холодный душ',
      'icon': Icons.ac_unit,
      'frequency': 'ежедневно',
      'description': 'Укрепляет силу воли и иммунитет',
      'streak': 12,
      'maxStreak': 45,
      'strength': 78,
      'color': const Color(0xFF4FC3F7),
    },
    {
      'id': 'gym',
      'name': 'Тренировка',
      'icon': Icons.fitness_center,
      'frequency': '4 раза в неделю',
      'description': 'Строительство мужского тела',
      'streak': 8,
      'maxStreak': 28,
      'strength': 65,
      'color': const Color(0xFFFF7043),
    },
    {
      'id': 'meditation',
      'name': 'Медитация',
      'icon': Icons.self_improvement,
      'frequency': 'ежедневно 10 мин',
      'description': 'Контроль ума и эмоций',
      'streak': 5,
      'maxStreak': 21,
      'strength': 42,
      'color': const Color(0xFF9C27B0),
    },
    {
      'id': 'reading',
      'name': 'Чтение',
      'icon': Icons.book,
      'frequency': '30 мин/день',
      'description': 'Развитие интеллекта',
      'streak': 15,
      'maxStreak': 67,
      'strength': 89,
      'color': const Color(0xFF66BB6A),
    },
    {
      'id': 'no_fap',
      'name': 'NoFap',
      'icon': Icons.block,
      'frequency': 'постоянно',
      'description': 'Сохранение мужской энергии',
      'streak': 23,
      'maxStreak': 89,
      'strength': 91,
      'color': const Color(0xFFFFB74D),
    },
  ];

  // Геттер для получения текущих привычек (API или моковые)
  List<Map<String, dynamic>> get habits {
    if (_apiHabits.isNotEmpty) {
      return _apiHabits.map((apiHabit) => _convertApiHabitToMap(apiHabit)).toList();
    }
    return _fallbackHabits;
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _initializeApi();
    _fadeController.forward();
    _scaleController.forward();
  }

  // Инициализация API и загрузка данных
  Future<void> _initializeApi() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Инициализируем API сервис
      await _apiService.initialize();

      // Загружаем привычки из API
      await _loadHabitsFromApi();

      // Инициализируем данные привычек
      _initializeHabitsData();
    } catch (e) {
      setState(() {
        _errorMessage = 'Ошибка загрузки: $e';
        // Используем моковые данные при ошибке
        _initializeHabitsData();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Загружаем привычки из API
  Future<void> _loadHabitsFromApi() async {
    try {
      final response = await _apiService.habits.getHabits();
      
      if (response.isSuccess && response.data != null) {
        setState(() {
          _apiHabits = response.data!;
          _errorMessage = null;
        });
      } else {
        throw Exception(response.error ?? 'Неизвестная ошибка API');
      }
    } catch (e) {
      // При ошибке API используем моковые данные
      print('Ошибка загрузки привычек из API: $e');
      setState(() {
        _apiHabits = [];
        _errorMessage = 'Используются локальные данные';
      });
    }
  }

  // Конвертируем API привычку в формат для UI используя HabitConverter
  Map<String, dynamic> _convertApiHabitToMap(ApiHabit apiHabit) {
    return HabitConverter.apiHabitToMap(apiHabit);
  }

  void _initializeHabitsData() {
    for (var habit in habits) {
      habitsData[habit['id']] = _generateHabitData(habit['id']);
    }
  }

  List<bool?> _generateHabitData(String habitId) {
    final data = <bool?>[];
    final random = math.Random(habitId.hashCode);
    
    for (int i = 1; i <= 31; i++) {
      if (i > 25) {
        data.add(null); // Будущие дни
      } else {
        // Генерируем данные на основе силы привычки
        final habit = habits.firstWhere((h) => h['id'] == habitId);
        final strength = habit['strength'] as int;
        final chance = strength / 100.0;
        data.add(random.nextDouble() < chance);
      }
    }
    return data;
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentRoute: '/habits',
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Шапка
              _Header(
                month: currentMonth,
                year: currentYear,
                onPrevMonth: () => _changeMonth(-1),
                onNextMonth: () => _changeMonth(1),
                onAddHabit: _showAddHabitDialog,
                onFilter: _showFilterDialog,
              ),
              
              // Сетка привычек
              Expanded(
                child: SingleChildScrollView(
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _HabitsGrid(
                      habits: habits,
                      habitsData: habitsData,
                      onToggleHabit: _toggleHabit,
                      onShowAnalytics: _showDetailedAnalytics,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      currentMonth += delta;
      if (currentMonth > 12) {
        currentMonth = 1;
        currentYear++;
      } else if (currentMonth < 1) {
        currentMonth = 12;
        currentYear--;
      }
    });
    
    // Перезагружаем анимацию при смене месяца
    _scaleController.reset();
    _scaleController.forward();
  }

  void _toggleHabit(String habitId, int day) {
    setState(() {
      if (habitsData[habitId] != null && day < habitsData[habitId]!.length) {
        final currentValue = habitsData[habitId]![day];
        if (currentValue != null) {
          habitsData[habitId]![day] = !currentValue;
          
          // Показываем feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                habitsData[habitId]![day]! 
                  ? 'Привычка отмечена! 💪'
                  : 'Привычка снята',
                style: const TextStyle(color: PRIMETheme.sand),
              ),
              backgroundColor: habitsData[habitId]![day]! 
                ? PRIMETheme.primary 
                : PRIMETheme.line,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    });
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) => AdvancedAddHabitDialog(
        onHabitAdded: (habit) {
          setState(() {
            habits.add({
              'id': habit.id,
              'name': habit.name,
              'icon': habit.icon,
              'frequency': habit.frequency.displayText,
              'description': habit.description ?? 'Новая привычка',
              'streak': 0,
              'maxStreak': 0,
              'strength': 0,
              'color': habit.color,
            });
            
            // Инициализируем данные для новой привычки
            habitsData[habit.id] = _generateHabitData(habit.id);
          });

          // Показываем уведомление об успешном добавлении
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    habit.icon,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Привычка "${habit.name}" добавлена! 🎉',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: habit.color,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: PRIMETheme.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PRIMETheme.primary.withOpacity(0.1),
                    PRIMETheme.primary.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: isSmallScreen ? 40 : 48,
                    height: isSmallScreen ? 40 : 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PRIMETheme.primary,
                          PRIMETheme.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Text(
                      'Фильтры привычек',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 18 : 22,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: PRIMETheme.sand),
                  ),
                ],
              ),
            ),
            
            // Содержимое
            Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Показать привычки',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  
                  // Фильтры
                  _FilterOption(
                    title: 'Завершенные',
                    subtitle: 'Привычки с отметками выполнения',
                    icon: Icons.check_circle,
                    value: true,
                    onChanged: (value) {},
                    isSmallScreen: isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  
                  _FilterOption(
                    title: 'Незавершенные',
                    subtitle: 'Привычки без отметок',
                    icon: Icons.radio_button_unchecked,
                    value: true,
                    onChanged: (value) {},
                    isSmallScreen: isSmallScreen,
                  ),
                  const SizedBox(height: 12),
                  
                  _FilterOption(
                    title: 'Высокая сила',
                    subtitle: 'Привычки с силой выше 70%',
                    icon: Icons.trending_up,
                    value: false,
                    onChanged: (value) {},
                    isSmallScreen: isSmallScreen,
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),
                  
                  // Кнопки
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 20,
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                            decoration: BoxDecoration(
                              color: PRIMETheme.line.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: PRIMETheme.line),
                            ),
                            child: Text(
                              'Отмена',
                              style: TextStyle(
                                color: PRIMETheme.sand,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 20,
                              vertical: isSmallScreen ? 12 : 14,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  PRIMETheme.primary,
                                  PRIMETheme.primary.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: PRIMETheme.primary.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Применить фильтры',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isSmallScreen ? 16 : 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailedAnalytics(Map<String, dynamic> habit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _DetailedAnalyticsSheet(
        habit: habit,
        data: habitsData[habit['id']] ?? [],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int month;
  final int year;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onAddHabit;
  final VoidCallback onFilter;

  const _Header({
    required this.month,
    required this.year,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onAddHabit,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    const monthNames = [
      '', 'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
      'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 380;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmallScreen ? 8 : (isSmallScreen ? 12 : 16),
        vertical: isSmallScreen ? 12 : 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [PRIMETheme.bg, PRIMETheme.bg.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: const Border(bottom: BorderSide(color: PRIMETheme.line)),
      ),
      child: Column(
        children: [
          // Верхняя строка с навигацией по месяцам
          Row(
            children: [
              InkWell(
                onTap: onPrevMonth,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: PRIMETheme.line.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chevron_left, 
                    color: PRIMETheme.sand, 
                    size: isSmallScreen ? 20 : 24
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  '${monthNames[month]} $year',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isVerySmallScreen ? 16 : (isSmallScreen ? 18 : 22),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              InkWell(
                onTap: onNextMonth,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: PRIMETheme.line.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chevron_right, 
                    color: PRIMETheme.sand, 
                    size: isSmallScreen ? 20 : 24
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Мобильная строка с кнопками действий
          Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: onAddHabit,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16, 
                      vertical: isSmallScreen ? 12 : 14
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PRIMETheme.primary,
                          PRIMETheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: PRIMETheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_circle_outline, 
                          color: Colors.white, 
                          size: isSmallScreen ? 18 : 20
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Text(
                          isVerySmallScreen ? 'Добавить' : 'Новая привычка',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: onFilter,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 14),
                  decoration: BoxDecoration(
                    color: PRIMETheme.line.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PRIMETheme.line),
                  ),
                  child: Icon(
                    Icons.tune, 
                    color: PRIMETheme.sand,
                    size: isSmallScreen ? 18 : 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HabitsGrid extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final Map<String, List<bool?>> habitsData;
  final Function(String, int) onToggleHabit;
  final Function(Map<String, dynamic>) onShowAnalytics;

  const _HabitsGrid({
    required this.habits,
    required this.habitsData,
    required this.onToggleHabit,
    required this.onShowAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Заголовки дней
          _DaysHeader(),
          const SizedBox(height: 16),
          
          // Строки привычек
          ...habits.asMap().entries.map((entry) {
            final index = entry.key;
            final habit = entry.value;
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + index * 100),
              curve: Curves.easeOutBack,
              child: _HabitRow(
                habit: habit,
                data: habitsData[habit['id']] ?? [],
                onToggleDay: (day) => onToggleHabit(habit['id'], day),
                onShowAnalytics: () => onShowAnalytics(habit),
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Общая аналитика
          _OverallAnalytics(habits: habits, habitsData: habitsData),
        ],
      ),
    );
  }
}

class _DaysHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final dayWidth = isSmallScreen ? 20.0 : 24.0;
    final fontSize = isSmallScreen ? 8.0 : 10.0;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 120 : 140,
              alignment: Alignment.center,
              child: Text(
                'Привычка',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: PRIMETheme.sandWeak,
                ),
              ),
            ),
            ...List.generate(31, (index) {
              final day = index + 1;
              final isToday = day == DateTime.now().day;
              
              return Container(
                width: dayWidth,
                height: dayWidth,
                margin: const EdgeInsets.only(right: 1),
                decoration: BoxDecoration(
                  color: isToday ? PRIMETheme.primary.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: isToday ? Border.all(color: PRIMETheme.primary, width: 2) : null,
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: fontSize,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      color: isToday ? PRIMETheme.primary : PRIMETheme.sandWeak,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _HabitRow extends StatefulWidget {
  final Map<String, dynamic> habit;
  final List<bool?> data;
  final Function(int) onToggleDay;
  final VoidCallback onShowAnalytics;

  const _HabitRow({
    required this.habit,
    required this.data,
    required this.onToggleDay,
    required this.onShowAnalytics,
  });

  @override
  State<_HabitRow> createState() => _HabitRowState();
}

class _HabitRowState extends State<_HabitRow> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedDays = widget.data.where((d) => d == true).length;
    final totalDays = widget.data.where((d) => d != null).length;
    final completionRate = totalDays > 0 ? (completedDays / totalDays * 100).round() : 0;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isVerySmallScreen = screenWidth < 380;
    
    // Адаптивные размеры для лучшего мобильного опыта
    final daySize = isVerySmallScreen ? 16.0 : (isSmallScreen ? 20.0 : 24.0);
    final iconSize = isSmallScreen ? 36.0 : 44.0;
    final habitWidth = isVerySmallScreen ? 100.0 : (isSmallScreen ? 120.0 : 140.0);
    final cardPadding = isVerySmallScreen ? 8.0 : (isSmallScreen ? 12.0 : 16.0);

    return InkWell(
      onTap: () {
        _pulseController.forward().then((_) => _pulseController.reverse());
        widget.onShowAnalytics();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).cardColor,
                    Theme.of(context).cardColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.habit['color'].withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.habit['color'].withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Заголовок привычки
                  Container(
                    padding: EdgeInsets.all(cardPadding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.habit['color'].withOpacity(0.1),
                          widget.habit['color'].withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        // Иконка
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.habit['color'],
                                widget.habit['color'].withOpacity(0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: widget.habit['color'].withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            widget.habit['icon'],
                            color: Colors.white,
                            size: isSmallScreen ? 18 : 22,
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 12 : 16),
                        
                        // Информация о привычке
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.habit['name'],
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isVerySmallScreen ? 14 : (isSmallScreen ? 16 : 18),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.habit['frequency'],
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                                  color: PRIMETheme.sandWeak,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Процент выполнения
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12, 
                            vertical: isSmallScreen ? 4 : 6
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                widget.habit['color'].withOpacity(0.2),
                                widget.habit['color'].withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: widget.habit['color'].withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            '$completionRate%',
                            style: TextStyle(
                              fontSize: isVerySmallScreen ? 11 : (isSmallScreen ? 13 : 15),
                              color: widget.habit['color'],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Сетка дней
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.all(cardPadding),
                    child: Row(
                      children: widget.data.asMap().entries.map((entry) {
                        final dayIndex = entry.key;
                        final dayData = entry.value;
                        final day = dayIndex + 1;
                        final isToday = day == DateTime.now().day;
                        
                        return Padding(
                          padding: EdgeInsets.only(right: isSmallScreen ? 2 : 4),
                          child: GestureDetector(
                            onTap: () {
                              if (dayData != null) {
                                widget.onToggleDay(dayIndex);
                              }
                            },
                            child: SizedBox(
                              width: daySize + 4,
                              child: Column(
                                children: [
                                  // Номер дня
                                  Text(
                                    '$day',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: isVerySmallScreen ? 8 : (isSmallScreen ? 9 : 10),
                                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                      color: isToday ? widget.habit['color'] : PRIMETheme.sandWeak,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  
                                  // Ячейка дня
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: daySize,
                                    height: daySize,
                                    decoration: BoxDecoration(
                                      color: _getDayColor(dayData),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isToday 
                                          ? widget.habit['color']
                                          : dayData == null 
                                            ? PRIMETheme.line.withOpacity(0.5)
                                            : dayData 
                                              ? widget.habit['color'] 
                                              : PRIMETheme.line.withOpacity(0.5),
                                        width: isToday ? 2.5 : (dayData == true ? 2 : 1),
                                      ),
                                      boxShadow: dayData == true ? [
                                        BoxShadow(
                                          color: widget.habit['color'].withOpacity(0.4),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ] : isToday ? [
                                        BoxShadow(
                                          color: widget.habit['color'].withOpacity(0.3),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ] : null,
                                    ),
                                    child: dayData == true
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                            size: isVerySmallScreen ? 10 : (isSmallScreen ? 12 : 14),
                                          )
                                        : dayData == false 
                                          ? Icon(
                                              Icons.cancel_outlined,
                                              color: PRIMETheme.sandWeak.withOpacity(0.7),
                                              size: isVerySmallScreen ? 8 : (isSmallScreen ? 10 : 12),
                                            )
                                          : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getDayColor(bool? dayData) {
    if (dayData == null) return Colors.transparent;
    if (dayData) return widget.habit['color'];
    return PRIMETheme.line.withOpacity(0.3);
  }
}

class _OverallAnalytics extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final Map<String, List<bool?>> habitsData;

  const _OverallAnalytics({
    required this.habits,
    required this.habitsData,
  });

  @override
  Widget build(BuildContext context) {
    final totalCompleted = habitsData.values
        .expand((data) => data)
        .where((d) => d == true)
        .length;
    
    final totalPossible = habitsData.values
        .expand((data) => data)
        .where((d) => d != null)
        .length;
    
    final overallProgress = totalPossible > 0 ? (totalCompleted / totalPossible * 100).round() : 0;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.primary.withOpacity(0.1),
            PRIMETheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Общий прогресс',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 18 : 24,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Адаптивная сетка статистики
          if (isSmallScreen) ...[
            // Для маленьких экранов показываем в колонку
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Завершено',
                        value: '$totalCompleted',
                        color: PRIMETheme.primary,
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        title: 'Прогресс',
                        value: '$overallProgress%',
                        color: const Color(0xFF66BB6A),
                        isCompact: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Привычек',
                        value: '${habits.length}',
                        color: const Color(0xFFFFB74D),
                        isCompact: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(), // Заглушка для симметрии
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            // Для больших экранов оставляем в ряд
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  title: 'Завершено',
                  value: '$totalCompleted',
                  color: PRIMETheme.primary,
                ),
                _StatCard(
                  title: 'Прогресс',
                  value: '$overallProgress%',
                  color: const Color(0xFF66BB6A),
                ),
                _StatCard(
                  title: 'Привычек',
                  value: '${habits.length}',
                  color: const Color(0xFFFFB74D),
                ),
              ],
            ),
          ],
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          InkWell(
            onTap: () => _showGlobalAnalytics(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 16 : 20, 
                vertical: isSmallScreen ? 10 : 12
              ),
              decoration: BoxDecoration(
                color: PRIMETheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics, 
                    color: Colors.white, 
                    size: isSmallScreen ? 18 : 20
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Показать аналитику',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGlobalAnalytics(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _GlobalAnalyticsSheet(
        habits: habits,
        habitsData: habitsData,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isCompact;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 18 : 24,
            ),
          ),
          SizedBox(height: isCompact ? 2 : 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: isCompact ? 11 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DetailedAnalyticsSheet extends StatefulWidget {
  final Map<String, dynamic> habit;
  final List<bool?> data;

  const _DetailedAnalyticsSheet({
    required this.habit,
    required this.data,
  });

  @override
  State<_DetailedAnalyticsSheet> createState() => _DetailedAnalyticsSheetState();
}

class _DetailedAnalyticsSheetState extends State<_DetailedAnalyticsSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _chartController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeInOut),
    );

    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _chartController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final completedDays = widget.data.where((d) => d == true).length;
    final totalDays = widget.data.where((d) => d != null).length;
    final completionRate = totalDays > 0 ? (completedDays / totalDays * 100).round() : 0;

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: PRIMETheme.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          children: [
            // Заголовок
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.habit['color'].withOpacity(0.2),
                    widget.habit['color'].withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: widget.habit['color'].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.habit['icon'],
                      color: widget.habit['color'],
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.habit['name'],
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.habit['description'],
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PRIMETheme.sandWeak,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: PRIMETheme.sand),
                  ),
                ],
              ),
            ),
            
            // Содержимое
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Основные метрики
                    Row(
                      children: [
                        Expanded(
                          child: _AnimatedMetricCard(
                            title: 'Текущая серия',
                            value: '${widget.habit['streak']}',
                            subtitle: 'дней',
                            color: widget.habit['color'],
                            delay: 0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _AnimatedMetricCard(
                            title: 'Лучшая серия',
                            value: '${widget.habit['maxStreak']}',
                            subtitle: 'дней',
                            color: const Color(0xFF66BB6A),
                            delay: 200,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _AnimatedMetricCard(
                            title: 'Сила привычки',
                            value: '${widget.habit['strength']}',
                            subtitle: '/100',
                            color: const Color(0xFFFFB74D),
                            delay: 400,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _AnimatedMetricCard(
                            title: 'Выполнение',
                            value: '$completionRate',
                            subtitle: '%',
                            color: PRIMETheme.primary,
                            delay: 600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // График прогресса
                    AnimatedBuilder(
                      animation: _chartAnimation,
                      builder: (context, child) {
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
                                'График прогресса',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _ProgressChart(
                                data: widget.data,
                                color: widget.habit['color'],
                                animation: _chartAnimation,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Insights
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.habit['color'].withOpacity(0.1),
                            widget.habit['color'].withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: widget.habit['color'].withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color: widget.habit['color'],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Анализ и советы',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.habit['color'],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getInsight(widget.habit, completionRate),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
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

  String _getInsight(Map<String, dynamic> habit, int completionRate) {
    final strength = habit['strength'] as int;
    
    if (completionRate >= 80) {
      return 'Отличная работа! Ваша привычка укрепляется. Продолжайте в том же духе! 💪';
    } else if (completionRate >= 60) {
      return 'Хороший прогресс, но есть куда расти. Попробуйте установить напоминания в телефоне.';
    } else if (completionRate >= 40) {
      return 'Не сдавайтесь! Начните с малого - даже 1 минута в день лучше, чем ничего.';
    } else {
      return 'Время пересмотреть подход. Возможно, стоит упростить привычку или найти мотивацию.';
    }
  }
}

class _AnimatedMetricCard extends StatefulWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final int delay;

  const _AnimatedMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.delay,
  });

  @override
  State<_AnimatedMetricCard> createState() => _AnimatedMetricCardState();
}

class _AnimatedMetricCardState extends State<_AnimatedMetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        widget.value,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: widget.color.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final List<bool?> data;
  final Color color;
  final Animation<double> animation;

  const _ProgressChart({
    required this.data,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: CustomPaint(
        painter: _ProgressChartPainter(
          data: data,
          color: color,
          animation: animation.value,
        ),
        size: const Size(double.infinity, 120),
      ),
    );
  }
}

class _ProgressChartPainter extends CustomPainter {
  final List<bool?> data;
  final Color color;
  final double animation;

  _ProgressChartPainter({
    required this.data,
    required this.color,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    
    final dataPoints = data.where((d) => d != null).toList();
    if (dataPoints.isEmpty) return;

    final stepX = size.width / (dataPoints.length - 1);
    final animatedLength = (dataPoints.length * animation).floor();

    // Создаем путь для линии
    for (int i = 0; i < animatedLength; i++) {
      final x = i * stepX;
      final y = dataPoints[i] == true 
        ? size.height * 0.2 
        : size.height * 0.8;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Заливка
    fillPath.lineTo(animatedLength * stepX, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Линия
    canvas.drawPath(path, paint);

    // Точки
    for (int i = 0; i < animatedLength; i++) {
      final x = i * stepX;
      final y = dataPoints[i] == true 
        ? size.height * 0.2 
        : size.height * 0.8;
      
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = dataPoints[i] == true ? color : color.withOpacity(0.5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _GlobalAnalyticsSheet extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final Map<String, List<bool?>> habitsData;

  const _GlobalAnalyticsSheet({
    required this.habits,
    required this.habitsData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: PRIMETheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PRIMETheme.primary.withOpacity(0.2),
                  PRIMETheme.primary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics,
                  color: PRIMETheme.primary,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Общая аналитика',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: PRIMETheme.sand),
                ),
              ],
            ),
          ),
          
          // Содержимое
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Рейтинг привычек',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Рейтинг привычек
                  ...habits.asMap().entries.map((entry) {
                    final index = entry.key;
                    final habit = entry.value;
                    final data = habitsData[habit['id']] ?? [];
                    final completed = data.where((d) => d == true).length;
                    final total = data.where((d) => d != null).length;
                    final rate = total > 0 ? (completed / total * 100).round() : 0;
                    
                    return _RankingCard(
                      rank: index + 1,
                      habit: habit,
                      completionRate: rate,
                      isTop: index < 2,
                    );
                  }),
                  
                  const SizedBox(height: 32),
                  
                  Text(
                    'Недельная статистика',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _WeeklyChart(habits: habits, habitsData: habitsData),
                  
                  const SizedBox(height: 32),
                  
                  // Достижения
                  _AchievementsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> habit;
  final int completionRate;
  final bool isTop;

  const _RankingCard({
    required this.rank,
    required this.habit,
    required this.completionRate,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isTop 
          ? habit['color'].withOpacity(0.1)
          : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isTop 
            ? habit['color'].withOpacity(0.3)
            : PRIMETheme.line,
        ),
      ),
      child: Row(
        children: [
          // Ранг
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTop ? habit['color'] : PRIMETheme.line,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: isTop ? Colors.white : PRIMETheme.sand,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Иконка
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: habit['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              habit['icon'],
              color: habit['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          
          // Информация
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit['name'],
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  habit['frequency'],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PRIMETheme.sandWeak,
                  ),
                ),
              ],
            ),
          ),
          
          // Процент
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: habit['color'].withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$completionRate%',
              style: TextStyle(
                color: habit['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final Map<String, List<bool?>> habitsData;

  const _WeeklyChart({
    required this.habits,
    required this.habitsData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        children: [
          Text(
            'Активность по дням недели',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                final activity = _getWeekdayActivity(index);
                final height = (activity / 100) * 60 + 10;
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 24,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            PRIMETheme.primary,
                            PRIMETheme.primary.withOpacity(0.6),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[index],
                      style: Theme.of(context).textTheme.bodySmall,
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

  double _getWeekdayActivity(int weekday) {
    // Эмуляция активности по дням недели
    final activities = [85, 90, 75, 80, 70, 45, 55]; // Пн-Вс
    return activities[weekday].toDouble();
  }
}

class _FilterOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final Function(bool?) onChanged;
  final bool isSmallScreen;

  const _FilterOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: value 
            ? PRIMETheme.primary.withOpacity(0.1)
            : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value 
              ? PRIMETheme.primary.withOpacity(0.3)
              : PRIMETheme.line.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 36 : 40,
              height: isSmallScreen ? 36 : 40,
              decoration: BoxDecoration(
                color: value 
                  ? PRIMETheme.primary.withOpacity(0.2)
                  : PRIMETheme.line.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: value ? PRIMETheme.primary : PRIMETheme.sandWeak,
                size: isSmallScreen ? 18 : 20,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 14 : 16,
                      color: value ? PRIMETheme.primary : PRIMETheme.sand,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: PRIMETheme.sandWeak,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSmallScreen ? 20 : 24,
              height: isSmallScreen ? 20 : 24,
              decoration: BoxDecoration(
                color: value ? PRIMETheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? PRIMETheme.primary : PRIMETheme.line,
                  width: 2,
                ),
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: isSmallScreen ? 12 : 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final achievements = [
      {
        'title': 'Железная воля',
        'description': 'Выполнили все привычки 7 дней подряд',
        'icon': Icons.military_tech,
        'color': const Color(0xFFFFD700),
        'achieved': true,
      },
      {
        'title': 'Спартанец',
        'description': 'Холодный душ 30 дней подряд',
        'icon': Icons.ac_unit,
        'color': const Color(0xFF4FC3F7),
        'achieved': false,
      },
      {
        'title': 'Книжный червь',
        'description': 'Читали каждый день месяц',
        'icon': Icons.book,
        'color': const Color(0xFF66BB6A),
        'achieved': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Достижения',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...achievements.map((achievement) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: achievement['achieved'] as bool
              ? (achievement['color'] as Color).withOpacity(0.1)
              : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: achievement['achieved'] as bool
                ? (achievement['color'] as Color).withOpacity(0.3)
                : PRIMETheme.line,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (achievement['color'] as Color).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  achievement['icon'] as IconData,
                  color: achievement['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement['title'] as String,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      achievement['description'] as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                  ],
                ),
              ),
              if (achievement['achieved'] as bool)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: achievement['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
            ],
          ),
        )),
      ],
    );
  }
}
