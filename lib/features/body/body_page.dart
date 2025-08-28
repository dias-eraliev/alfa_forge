import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../shared/bottom_nav_scaffold.dart';
import '../../app/theme.dart';

class BodyPage extends StatefulWidget {
  const BodyPage({super.key});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Данные о здоровье
  final Map<String, dynamic> healthData = {
    'weight': 78.5,
    'height': 180,
    'bodyFat': 15.2,
    'muscle': 68.3,
    'heartRate': 72,
    'bloodPressure': {'systolic': 120, 'diastolic': 80},
    'sleep': 7.5,
    'steps': 8247,
    'calories': 2340,
    'water': 2.1,
  };

  // Измерения тела
  final Map<String, double> bodyMeasurements = {
    'chest': 102.5,
    'waist': 84.0,
    'hips': 98.0,
    'biceps': 36.5,
    'thighs': 58.0,
    'neck': 38.0,
  };

  // Цели
  final Map<String, dynamic> goals = {
    'weight': {'current': 78.5, 'target': 75.0},
    'bodyFat': {'current': 15.2, 'target': 12.0},
    'steps': {'current': 8247, 'target': 10000},
    'water': {'current': 2.1, 'target': 3.0},
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  double get bmi => healthData['weight'] / math.pow(healthData['height'] / 100, 2);

  String get bmiCategory {
    if (bmi < 18.5) return 'Недостаток веса';
    if (bmi < 25) return 'Нормальный вес';
    if (bmi < 30) return 'Избыточный вес';
    return 'Ожирение';
  }

  Color get bmiColor {
    if (bmi < 18.5) return PRIMETheme.warn;
    if (bmi < 25) return PRIMETheme.success;
    if (bmi < 30) return PRIMETheme.warn;
    return const Color(0xFFE53E3E);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentRoute: '/body',
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  _Header(),
                  const SizedBox(height: 24),

                  // Основные метрики
                  _MainMetrics(
                    weight: healthData['weight'],
                    bmi: bmi,
                    bmiCategory: bmiCategory,
                    bmiColor: bmiColor,
                    bodyFat: healthData['bodyFat'],
                    muscle: healthData['muscle'],
                  ),
                  const SizedBox(height: 24),

                  // Витальные показатели
                  _VitalSigns(
                    heartRate: healthData['heartRate'],
                    bloodPressure: healthData['bloodPressure'],
                    sleep: healthData['sleep'],
                  ),
                  const SizedBox(height: 24),

                  // Ежедневная активность
                  _DailyActivity(
                    steps: healthData['steps'],
                    calories: healthData['calories'],
                    water: healthData['water'],
                    goals: goals,
                  ),
                  const SizedBox(height: 24),

                  // Измерения тела
                  _BodyMeasurements(measurements: bodyMeasurements),
                  const SizedBox(height: 24),

                  // Прогресс целей
                  _ProgressGoals(goals: goals),
                  const SizedBox(height: 24),

                  // Кнопки действий
                  _ActionButtons(
                    onAddMeasurement: _showAddMeasurementDialog,
                    onViewHistory: _showHistoryDialog,
                    onSetGoals: _showGoalsDialog,
                  ),
                  const SizedBox(height: 16),

                  // Кнопка Аналитика
                  _AnalyticsButton(
                    onPressed: _showAnalyticsDialog,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMeasurementDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AddMeasurementSheet(
        onMeasurementAdded: (measurements) {
          setState(() {
            bodyMeasurements.addAll(measurements);
            // Обновляем основные показатели если есть вес
            if (measurements.containsKey('weight')) {
              healthData['weight'] = measurements['weight'];
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Измерения добавлены! 📊'),
              backgroundColor: PRIMETheme.success,
            ),
          );
        },
      ),
    );
  }

  void _showHistoryDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _HistorySheet(healthData: healthData),
    );
  }

  void _showGoalsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _GoalsSheet(
        goals: goals,
        onGoalsUpdated: (newGoals) {
          setState(() {
            goals.addAll(newGoals);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Цели обновлены! 🎯'),
              backgroundColor: PRIMETheme.primary,
            ),
          );
        },
      ),
    );
  }

  void _showAnalyticsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _AnalyticsSheet(
        healthData: healthData,
        bodyMeasurements: bodyMeasurements,
        goals: goals,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final date = '${now.day}.${now.month.toString().padLeft(2, '0')}.${now.year}';
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Тело',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: PRIMETheme.sandWeak,
              ),
            ),
          ],
        ),
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
            Icons.favorite,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _MainMetrics extends StatelessWidget {
  final double weight;
  final double bmi;
  final String bmiCategory;
  final Color bmiColor;
  final double bodyFat;
  final double muscle;

  const _MainMetrics({
    required this.weight,
    required this.bmi,
    required this.bmiCategory,
    required this.bmiColor,
    required this.bodyFat,
    required this.muscle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Основные показатели',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 22,
          ),
        ),
        const SizedBox(height: 16),
        
        // Главная карточка BMI
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                bmiColor.withOpacity(0.15),
                bmiColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: bmiColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    decoration: BoxDecoration(
                      color: bmiColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.monitor_weight,
                      color: bmiColor,
                      size: isSmallScreen ? 24 : 32,
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Индекс массы тела',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bmiCategory,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: bmiColor,
                            fontWeight: FontWeight.bold,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${weight.toStringAsFixed(1)} кг',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: bmiColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 20 : 24,
                        ),
                      ),
                      Text(
                        'BMI ${bmi.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PRIMETheme.sandWeak,
                          fontSize: isSmallScreen ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Прогресс бар BMI
              _BMIProgressBar(bmi: bmi, bmiColor: bmiColor),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        // Композиция тела
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Жир',
                value: '${bodyFat.toStringAsFixed(1)}%',
                icon: Icons.water_drop,
                color: const Color(0xFFFF7043),
                progress: bodyFat / 25,
                isCompact: isSmallScreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Мышцы',
                value: '${muscle.toStringAsFixed(1)} кг',
                icon: Icons.fitness_center,
                color: PRIMETheme.success,
                progress: muscle / 80,
                isCompact: isSmallScreen,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BMIProgressBar extends StatefulWidget {
  final double bmi;
  final Color bmiColor;

  const _BMIProgressBar({required this.bmi, required this.bmiColor});

  @override
  State<_BMIProgressBar> createState() => _BMIProgressBarState();
}

class _BMIProgressBarState extends State<_BMIProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: widget.bmi / 35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('15', style: Theme.of(context).textTheme.bodySmall),
            Text('BMI Шкала', style: Theme.of(context).textTheme.bodySmall),
            Text('35', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(double.infinity, 20),
              painter: _BMIBarPainter(
                progress: _animation.value,
                bmiValue: widget.bmi,
                bmiColor: widget.bmiColor,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _BMIBarPainter extends CustomPainter {
  final double progress;
  final double bmiValue;
  final Color bmiColor;

  _BMIBarPainter({
    required this.progress,
    required this.bmiValue,
    required this.bmiColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    
    // Фон
    paint.color = PRIMETheme.line.withOpacity(0.3);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(10),
      ),
      paint,
    );

    // Цветные зоны BMI
    final zones = [
      {'start': 0.0, 'end': 0.529, 'color': PRIMETheme.warn}, // < 18.5
      {'start': 0.529, 'end': 0.714, 'color': PRIMETheme.success}, // 18.5-25
      {'start': 0.714, 'end': 0.857, 'color': PRIMETheme.warn}, // 25-30
      {'start': 0.857, 'end': 1.0, 'color': const Color(0xFFE53E3E)}, // > 30
    ];

    for (final zone in zones) {
      paint.color = (zone['color'] as Color).withOpacity(0.3);
      final startX = (zone['start'] as double) * size.width;
      final endX = (zone['end'] as double) * size.width;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(startX, 0, endX - startX, size.height),
          const Radius.circular(10),
        ),
        paint,
      );
    }

    // Индикатор текущего BMI
    final currentX = progress * size.width;
    paint.color = bmiColor;
    canvas.drawCircle(
      Offset(currentX, size.height / 2),
      8,
      paint,
    );

    // Белая обводка
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(
      Offset(currentX, size.height / 2),
      8,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MetricCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final double progress;
  final bool isCompact;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.progress,
    this.isCompact = false,
  });

  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: widget.progress).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    
    Future.delayed(Duration(milliseconds: math.Random().nextInt(300)), () {
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
          child: Container(
            padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withOpacity(0.15),
                  widget.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.color.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(widget.isCompact ? 6 : 8),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.color,
                        size: widget.isCompact ? 16 : 20,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: widget.isCompact ? 24 : 32,
                      height: widget.isCompact ? 24 : 32,
                      child: CircularProgressIndicator(
                        value: _progressAnimation.value,
                        strokeWidth: 3,
                        backgroundColor: widget.color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(widget.color),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: widget.isCompact ? 8 : 12),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.color,
                    fontSize: widget.isCompact ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isCompact ? 16 : 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _VitalSigns extends StatelessWidget {
  final int heartRate;
  final Map<String, int> bloodPressure;
  final double sleep;

  const _VitalSigns({
    required this.heartRate,
    required this.bloodPressure,
    required this.sleep,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Витальные показатели',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 22,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _VitalCard(
                title: 'Пульс',
                value: '$heartRate',
                unit: 'уд/мин',
                icon: Icons.favorite,
                color: const Color(0xFFE53E3E),
                isNormal: heartRate >= 60 && heartRate <= 100,
                isCompact: isSmallScreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _VitalCard(
                title: 'Давление',
                value: '${bloodPressure['systolic']}/${bloodPressure['diastolic']}',
                unit: 'мм рт.ст.',
                icon: Icons.water_drop,
                color: PRIMETheme.primary,
                isNormal: bloodPressure['systolic']! <= 120 && bloodPressure['diastolic']! <= 80,
                isCompact: isSmallScreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        _VitalCard(
          title: 'Сон',
          value: sleep.toStringAsFixed(1),
          unit: 'часов',
          icon: Icons.bedtime,
          color: const Color(0xFF9C27B0),
          isNormal: sleep >= 7 && sleep <= 9,
          isWide: true,
          isCompact: isSmallScreen,
        ),
      ],
    );
  }
}

class _VitalCard extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;
  final bool isNormal;
  final bool isWide;
  final bool isCompact;

  const _VitalCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
    required this.isNormal,
    this.isWide = false,
    this.isCompact = false,
  });

  @override
  State<_VitalCard> createState() => _VitalCardState();
}

class _VitalCardState extends State<_VitalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    Future.delayed(Duration(milliseconds: math.Random().nextInt(400)), () {
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
      animation: _bounceAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value,
          child: Container(
            padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.color.withOpacity(0.15),
                  widget.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.color.withOpacity(0.3)),
            ),
            child: widget.isWide ? _buildWideLayout() : _buildCompactLayout(),
          ),
        );
      },
    );
  }

  Widget _buildCompactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(widget.isCompact ? 6 : 8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.isCompact ? 16 : 20,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: widget.isNormal ? PRIMETheme.success : PRIMETheme.warn,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.isNormal ? 'Норма' : 'Внимание',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.isCompact ? 8 : 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: widget.isCompact ? 8 : 12),
        Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: widget.color,
            fontSize: widget.isCompact ? 12 : 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: widget.color,
                fontWeight: FontWeight.bold,
                fontSize: widget.isCompact ? 16 : 20,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              widget.unit,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: PRIMETheme.sandWeak,
                fontSize: widget.isCompact ? 10 : 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(widget.isCompact ? 8 : 12),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            widget.icon,
            color: widget.color,
            size: widget.isCompact ? 20 : 28,
          ),
        ),
        SizedBox(width: widget.isCompact ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: widget.color,
                  fontSize: widget.isCompact ? 12 : 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    widget.value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: widget.color,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.isCompact ? 18 : 24,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.unit,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PRIMETheme.sandWeak,
                      fontSize: widget.isCompact ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.isNormal ? PRIMETheme.success : PRIMETheme.warn,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.isNormal ? 'Норма' : 'Внимание',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isCompact ? 10 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyActivity extends StatelessWidget {
  final int steps;
  final int calories;
  final double water;
  final Map<String, dynamic> goals;

  const _DailyActivity({
    required this.steps,
    required this.calories,
    required this.water,
    required this.goals,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ежедневная активность',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 22,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _ActivityCard(
                title: 'Шаги',
                value: steps,
                target: goals['steps']['target'],
                icon: Icons.directions_walk,
                color: const Color(0xFF4FC3F7),
                unit: '',
                isCompact: isSmallScreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActivityCard(
                title: 'Калории',
                value: calories,
                target: 2500,
                icon: Icons.local_fire_department,
                color: const Color(0xFFFF7043),
                unit: 'ккал',
                isCompact: isSmallScreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        _ActivityCard(
          title: 'Вода',
          value: (water * 1000).toInt(),
          target: (goals['water']['target'] * 1000).toInt(),
          icon: Icons.water_drop,
          color: const Color(0xFF42A5F5),
          unit: 'мл',
          isWide: true,
          isCompact: isSmallScreen,
        ),
      ],
    );
  }
}

class _ActivityCard extends StatefulWidget {
  final String title;
  final int value;
  final int target;
  final IconData icon;
  final Color color;
  final String unit;
  final bool isWide;
  final bool isCompact;

  const _ActivityCard({
    required this.title,
    required this.value,
    required this.target,
    required this.icon,
    required this.color,
    required this.unit,
    this.isWide = false,
    this.isCompact = false,
  });

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (widget.value / widget.target).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    
    Future.delayed(Duration(milliseconds: math.Random().nextInt(500)), () {
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
    final progress = (widget.value / widget.target).clamp(0.0, 1.0);
    final isCompleted = progress >= 1.0;

    return Container(
      padding: EdgeInsets.all(widget.isCompact ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color.withOpacity(0.15),
            widget.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.color.withOpacity(0.3)),
      ),
      child: widget.isWide ? _buildWideLayout() : _buildCompactLayout(),
    );
  }

  Widget _buildCompactLayout() {
    final progress = (widget.value / widget.target).clamp(0.0, 1.0);
    final isCompleted = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(widget.isCompact ? 6 : 8),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.isCompact ? 16 : 20,
              ),
            ),
            const Spacer(),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: PRIMETheme.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: widget.isCompact ? 12 : 16,
                ),
              ),
          ],
        ),
        SizedBox(height: widget.isCompact ? 8 : 12),
        Text(
          widget.title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: widget.color,
            fontSize: widget.isCompact ? 12 : 14,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              widget.value.toString(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: widget.color,
                fontWeight: FontWeight.bold,
                fontSize: widget.isCompact ? 16 : 20,
              ),
            ),
            if (widget.unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(
                widget.unit,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak,
                  fontSize: widget.isCompact ? 10 : 12,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        // Прогресс бар
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: widget.color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(widget.color),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(_progressAnimation.value * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.color,
                        fontWeight: FontWeight.bold,
                        fontSize: widget.isCompact ? 10 : 12,
                      ),
                    ),
                    Text(
                      'Цель: ${widget.target}${widget.unit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                        fontSize: widget.isCompact ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildWideLayout() {
    final progress = (widget.value / widget.target).clamp(0.0, 1.0);
    final isCompleted = progress >= 1.0;

    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(widget.isCompact ? 8 : 12),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.isCompact ? 20 : 28,
              ),
            ),
            SizedBox(width: widget.isCompact ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: widget.color,
                      fontSize: widget.isCompact ? 12 : 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        widget.value.toString(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                          fontSize: widget.isCompact ? 18 : 24,
                        ),
                      ),
                      if (widget.unit.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Text(
                          widget.unit,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PRIMETheme.sandWeak,
                            fontSize: widget.isCompact ? 12 : 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: PRIMETheme.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: widget.isCompact ? 16 : 20,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.color,
                    fontWeight: FontWeight.bold,
                    fontSize: widget.isCompact ? 14 : 16,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Прогресс бар
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: widget.color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(widget.color),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Выполнено',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                        fontSize: widget.isCompact ? 10 : 12,
                      ),
                    ),
                    Text(
                      'Цель: ${widget.target}${widget.unit}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                        fontSize: widget.isCompact ? 10 : 12,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BodyMeasurements extends StatelessWidget {
  final Map<String, double> measurements;

  const _BodyMeasurements({required this.measurements});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Измерения тела',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 22,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PRIMETheme.line),
          ),
          child: Column(
            children: [
              // Первый ряд
              Row(
                children: [
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Грудь',
                      value: measurements['chest']!,
                      icon: Icons.fitness_center,
                      isCompact: isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Талия',
                      value: measurements['waist']!,
                      icon: Icons.straighten,
                      isCompact: isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Бедра',
                      value: measurements['hips']!,
                      icon: Icons.accessibility,
                      isCompact: isSmallScreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Второй ряд
              Row(
                children: [
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Бицепс',
                      value: measurements['biceps']!,
                      icon: Icons.sports_martial_arts,
                      isCompact: isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Бедро',
                      value: measurements['thighs']!,
                      icon: Icons.directions_run,
                      isCompact: isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Шея',
                      value: measurements['neck']!,
                      icon: Icons.person,
                      isCompact: isSmallScreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MeasurementItem extends StatelessWidget {
  final String title;
  final double value;
  final IconData icon;
  final bool isCompact;

  const _MeasurementItem({
    required this.title,
    required this.value,
    required this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(isCompact ? 6 : 8),
          decoration: BoxDecoration(
            color: PRIMETheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: PRIMETheme.primary,
            size: isCompact ? 16 : 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: PRIMETheme.sandWeak,
            fontSize: isCompact ? 11 : 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(1)} см',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isCompact ? 12 : 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProgressGoals extends StatelessWidget {
  final Map<String, dynamic> goals;

  const _ProgressGoals({required this.goals});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Прогресс целей',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 22,
          ),
        ),
        const SizedBox(height: 16),
        
        ...goals.entries.where((entry) => entry.key != 'steps' && entry.key != 'water').map((entry) {
          final goal = entry.value as Map<String, dynamic>;
          final current = goal['current'] as double;
          final target = goal['target'] as double;
          final progress = (current / target).clamp(0.0, 1.0);
          final isReached = current <= target;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getGoalTitle(entry.key),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ),
                    if (isReached)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: PRIMETheme.success,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: isSmallScreen ? 12 : 16,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Text(
                      'Текущий: ${current.toStringAsFixed(1)}${_getGoalUnit(entry.key)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Цель: ${target.toStringAsFixed(1)}${_getGoalUnit(entry.key)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PRIMETheme.primary,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: PRIMETheme.primary.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(
                      isReached ? PRIMETheme.success : PRIMETheme.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 4),
                
                Text(
                  '${(progress * 100).toInt()}% выполнено',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isReached ? PRIMETheme.success : PRIMETheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getGoalTitle(String key) {
    switch (key) {
      case 'weight':
        return 'Вес';
      case 'bodyFat':
        return 'Процент жира';
      default:
        return key;
    }
  }

  String _getGoalUnit(String key) {
    switch (key) {
      case 'weight':
        return ' кг';
      case 'bodyFat':
        return '%';
      default:
        return '';
    }
  }
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onAddMeasurement;
  final VoidCallback onViewHistory;
  final VoidCallback onSetGoals;

  const _ActionButtons({
    required this.onAddMeasurement,
    required this.onViewHistory,
    required this.onSetGoals,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      children: [
        // Основная кнопка
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onAddMeasurement,
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMETheme.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: isSmallScreen ? 20 : 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Добавить измерения',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // Дополнительные кнопки
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onViewHistory,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: PRIMETheme.primary),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      color: PRIMETheme.primary,
                      size: isSmallScreen ? 16 : 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'История',
                      style: TextStyle(
                        color: PRIMETheme.primary,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onSetGoals,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: PRIMETheme.success),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12 : 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag,
                      color: PRIMETheme.success,
                      size: isSmallScreen ? 16 : 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Цели',
                      style: TextStyle(
                        color: PRIMETheme.success,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Диалоги будут добавлены в следующих файлах
class _AddMeasurementSheet extends StatelessWidget {
  final Function(Map<String, double>) onMeasurementAdded;

  const _AddMeasurementSheet({required this.onMeasurementAdded});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: PRIMETheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Center(
        child: Text(
          'Форма добавления измерений\n(в разработке)',
          textAlign: TextAlign.center,
          style: TextStyle(color: PRIMETheme.sand),
        ),
      ),
    );
  }
}

class _HistorySheet extends StatelessWidget {
  final Map<String, dynamic> healthData;

  const _HistorySheet({required this.healthData});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: PRIMETheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Center(
        child: Text(
          'История измерений\n(в разработке)',
          textAlign: TextAlign.center,
          style: TextStyle(color: PRIMETheme.sand),
        ),
      ),
    );
  }
}

class _GoalsSheet extends StatelessWidget {
  final Map<String, dynamic> goals;
  final Function(Map<String, dynamic>) onGoalsUpdated;

  const _GoalsSheet({required this.goals, required this.onGoalsUpdated});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: PRIMETheme.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: const Center(
        child: Text(
          'Настройка целей\n(в разработке)',
          textAlign: TextAlign.center,
          style: TextStyle(color: PRIMETheme.sand),
        ),
      ),
    );
  }
}

class _AnalyticsButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnalyticsButton({required this.onPressed});

  @override
  State<_AnalyticsButton> createState() => _AnalyticsButtonState();
}

class _AnalyticsButtonState extends State<_AnalyticsButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  PRIMETheme.primary.withOpacity(0.2 * _glowAnimation.value),
                  PRIMETheme.primary.withOpacity(0.1 * _glowAnimation.value),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: PRIMETheme.primary.withOpacity(0.3 * _glowAnimation.value),
                width: 2,
              ),
            ),
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: PRIMETheme.primary,
                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 18 : 22),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
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
                      Icons.analytics,
                      color: Colors.white,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Аналитика',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: PRIMETheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: PRIMETheme.primary.withOpacity(0.7),
                    size: isSmallScreen ? 16 : 18,
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

class _AnalyticsSheet extends StatefulWidget {
  final Map<String, dynamic> healthData;
  final Map<String, double> bodyMeasurements;
  final Map<String, dynamic> goals;

  const _AnalyticsSheet({
    required this.healthData,
    required this.bodyMeasurements,
    required this.goals,
  });

  @override
  State<_AnalyticsSheet> createState() => _AnalyticsSheetState();
}

class _AnalyticsSheetState extends State<_AnalyticsSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _chartController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _chartAnimation;

  int _selectedTab = 0;
  final List<String> _tabs = ['Обзор', 'Тренды', 'Достижения'];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
    
    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartController, curve: Curves.easeOutQuart),
    );

    _slideController.forward();
    _chartController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.9,
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
              Icons.analytics,
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
                  'Аналитика здоровья',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Детальная статистика и тренды',
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
                _chartController.reset();
                _chartController.forward();
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
      animation: _chartAnimation,
      builder: (context, child) {
        switch (_selectedTab) {
          case 0:
            return _buildOverviewTab();
          case 1:
            return _buildTrendsTab();
          case 2:
            return _buildAchievementsTab();
          default:
            return _buildOverviewTab();
        }
      },
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Общий счет здоровья
          _buildHealthScore(),
          const SizedBox(height: 24),
          
          // Ключевые метрики
          _buildKeyMetrics(),
          const SizedBox(height: 24),
          
          // Круговые диаграммы
          _buildCircularCharts(),
        ],
      ),
    );
  }

  Widget _buildHealthScore() {
    final healthScore = _calculateHealthScore();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.primary.withOpacity(0.15),
            PRIMETheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Общий показатель здоровья',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              children: [
                // Фоновый круг
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 12,
                  backgroundColor: PRIMETheme.primary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(PRIMETheme.primary.withOpacity(0.2)),
                ),
                // Анимированный прогресс
                CircularProgressIndicator(
                  value: (healthScore / 100) * _chartAnimation.value,
                  strokeWidth: 12,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation(PRIMETheme.primary),
                ),
                // Центральный текст
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(healthScore * _chartAnimation.value).toInt()}',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: PRIMETheme.primary,
                        ),
                      ),
                      Text(
                        'из 100',
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
          const SizedBox(height: 16),
          
          Text(
            _getHealthScoreDescription(healthScore),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PRIMETheme.primary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ключевые метрики',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricChart(
                title: 'BMI',
                value: widget.healthData['weight'] / math.pow(widget.healthData['height'] / 100, 2),
                unit: '',
                color: PRIMETheme.primary,
                icon: Icons.monitor_weight,
                min: 18,
                max: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricChart(
                title: 'Пульс',
                value: widget.healthData['heartRate'].toDouble(),
                unit: 'уд/мин',
                color: const Color(0xFFE53E3E),
                icon: Icons.favorite,
                min: 60,
                max: 100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildMetricChart(
                title: 'Жир',
                value: widget.healthData['bodyFat'],
                unit: '%',
                color: const Color(0xFFFF7043),
                icon: Icons.water_drop,
                min: 10,
                max: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricChart(
                title: 'Сон',
                value: widget.healthData['sleep'],
                unit: 'ч',
                color: const Color(0xFF9C27B0),
                icon: Icons.bedtime,
                min: 6,
                max: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricChart({
    required String title,
    required double value,
    required String unit,
    required Color color,
    required IconData icon,
    required double min,
    required double max,
  }) {
    final progress = ((value - min) / (max - min)).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(1)}$unit',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress * _chartAnimation.value,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularCharts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Прогресс целей',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: _buildCircularChart(
                title: 'Шаги',
                current: widget.healthData['steps'],
                target: widget.goals['steps']['target'],
                color: const Color(0xFF4FC3F7),
                icon: Icons.directions_walk,
                unit: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCircularChart(
                title: 'Вода',
                current: (widget.healthData['water'] * 1000).toInt(),
                target: (widget.goals['water']['target'] * 1000).toInt(),
                color: const Color(0xFF42A5F5),
                icon: Icons.water_drop,
                unit: 'мл',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularChart({
    required String title,
    required int current,
    required int target,
    required Color color,
    required IconData icon,
    required String unit,
  }) {
    final progress = (current / target).clamp(0.0, 1.0);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 8,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(color.withOpacity(0.2)),
                ),
                CircularProgressIndicator(
                  value: progress * _chartAnimation.value,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
                Center(
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          Text(
            '$current$unit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'из $target$unit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с выбором периода
          _buildTrendsHeader(),
          const SizedBox(height: 20),
          
          // График веса
          _buildWeightTrendChart(),
          const SizedBox(height: 20),
          
          // График BMI
          _buildBMITrendChart(),
          const SizedBox(height: 20),
          
          // График активности
          _buildActivityTrendChart(),
          const SizedBox(height: 20),
          
          // График сна
          _buildSleepTrendChart(),
          const SizedBox(height: 20),
          
          // Сравнительный анализ
          _buildComparisonAnalysis(),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Общий прогресс
          _buildOverallProgress(),
          const SizedBox(height: 24),
          
          // Недавние достижения
          _buildRecentAchievements(),
          const SizedBox(height: 24),
          
          // Активные челленджи
          _buildActiveChallenges(),
          const SizedBox(height: 24),
          
          // Стрики
          _buildStreaks(),
          const SizedBox(height: 24),
          
          // Статистика
          _buildAchievementStats(),
        ],
      ),
    );
  }

  double _calculateHealthScore() {
    double score = 0;
    
    // BMI score (25%)
    final bmi = widget.healthData['weight'] / math.pow(widget.healthData['height'] / 100, 2);
    if (bmi >= 18.5 && bmi <= 25) {
      score += 25;
    } else if (bmi >= 17 && bmi <= 30) {
      score += 15;
    } else {
      score += 5;
    }
    
    // Heart rate score (20%)
    final heartRate = widget.healthData['heartRate'];
    if (heartRate >= 60 && heartRate <= 100) {
      score += 20;
    } else if (heartRate >= 50 && heartRate <= 110) {
      score += 15;
    } else {
      score += 5;
    }
    
    // Sleep score (20%)
    final sleep = widget.healthData['sleep'];
    if (sleep >= 7 && sleep <= 9) {
      score += 20;
    } else if (sleep >= 6 && sleep <= 10) {
      score += 15;
    } else {
      score += 5;
    }
    
    // Activity score (20%)
    final steps = widget.healthData['steps'];
    final stepsTarget = widget.goals['steps']['target'];
    final stepsProgress = (steps / stepsTarget).clamp(0.0, 1.0);
    score += 20 * stepsProgress;
    
    // Body fat score (15%)
    final bodyFat = widget.healthData['bodyFat'];
    if (bodyFat >= 10 && bodyFat <= 20) {
      score += 15;
    } else if (bodyFat >= 8 && bodyFat <= 25) {
      score += 10;
    } else {
      score += 5;
    }
    
    return score.clamp(0, 100);
  }

  String _getHealthScoreDescription(double score) {
    if (score >= 90) return 'Отличное здоровье! 🏆';
    if (score >= 75) return 'Хорошие показатели 💪';
    if (score >= 60) return 'Неплохо, есть что улучшить 👍';
    if (score >= 40) return 'Требует внимания ⚠️';
    return 'Нужно больше заботиться о здоровье 🚨';
  }

  // ТРЕНДЫ
  Widget _buildTrendsHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Анализ трендов',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PRIMETheme.primary,
                PRIMETheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 4),
              Text(
                '30 дней',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightTrendChart() {
    // Генерируем данные веса за 30 дней
    final weightData = _generateWeightTrendData();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.primary.withOpacity(0.1),
            PRIMETheme.primary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PRIMETheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.monitor_weight,
                  color: PRIMETheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Динамика веса',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Последние 30 дней',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PRIMETheme.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '-1.2 кг',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // График веса
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: const Size(double.infinity, 120),
              painter: _WeightTrendPainter(
                data: weightData,
                animation: _chartAnimation.value,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Мин: ${weightData.reduce(math.min).toStringAsFixed(1)} кг',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                'Макс: ${weightData.reduce(math.max).toStringAsFixed(1)} кг',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBMITrendChart() {
    final bmiData = _generateBMITrendData();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.success.withOpacity(0.1),
            PRIMETheme.success.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PRIMETheme.success.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PRIMETheme.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.insights,
                  color: PRIMETheme.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Индекс массы тела',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Тренд BMI за месяц',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                bmiData.last.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PRIMETheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 100,
            child: CustomPaint(
              size: const Size(double.infinity, 100),
              painter: _BMITrendPainter(
                data: bmiData,
                animation: _chartAnimation.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTrendChart() {
    final stepsData = _generateStepsTrendData();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4FC3F7).withOpacity(0.1),
            const Color(0xFF4FC3F7).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4FC3F7).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4FC3F7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.directions_walk,
                  color: Color(0xFF4FC3F7),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Активность',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Шаги за неделю',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(stepsData.reduce((a, b) => a + b) / 7).toInt()}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF4FC3F7),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // График колонок
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stepsData.asMap().entries.map((entry) {
                final index = entry.key;
                final value = entry.value;
                final height = (value / 15000) * 100 * _chartAnimation.value;
                final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
                
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${(value / 1000).toStringAsFixed(0)}к',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: Duration(milliseconds: 1000 + index * 100),
                      width: 24,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4FC3F7),
                            const Color(0xFF4FC3F7).withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dayNames[index],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepTrendChart() {
    final sleepData = _generateSleepTrendData();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF9C27B0).withOpacity(0.1),
            const Color(0xFF9C27B0).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bedtime,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Качество сна',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Среднее: ${(sleepData.reduce((a, b) => a + b) / sleepData.length).toStringAsFixed(1)}ч',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: PRIMETheme.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Отлично',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            height: 80,
            child: CustomPaint(
              size: const Size(double.infinity, 80),
              painter: _SleepTrendPainter(
                data: sleepData,
                animation: _chartAnimation.value,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonAnalysis() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.primary.withOpacity(0.1),
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
            'Сравнительный анализ',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildComparisonItem(
            'Этот месяц vs прошлый',
            'Вес',
            '-1.2 кг',
            PRIMETheme.success,
            Icons.trending_down,
          ),
          const SizedBox(height: 12),
          _buildComparisonItem(
            'Средняя активность',
            'Шаги',
            '+847 шагов',
            PRIMETheme.success,
            Icons.trending_up,
          ),
          const SizedBox(height: 12),
          _buildComparisonItem(
            'Качество сна',
            'Сон',
            '+0.3 часа',
            PRIMETheme.success,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String period, String metric, String change, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak,
                ),
              ),
              Text(
                metric,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Text(
          change,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ДОСТИЖЕНИЯ
  Widget _buildOverallProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.success.withOpacity(0.15),
            PRIMETheme.success.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PRIMETheme.success.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      PRIMETheme.success,
                      PRIMETheme.success.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.emoji_events,
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
                      'Общий прогресс',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Уровень: Продвинутый',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PRIMETheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '73%',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PRIMETheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: 0.73 * _chartAnimation.value,
              backgroundColor: PRIMETheme.success.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(PRIMETheme.success),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressItem('Достижения', '12', PRIMETheme.success),
              _buildProgressItem('Стрики', '5', const Color(0xFFFF7043)),
              _buildProgressItem('Очки', '2840', PRIMETheme.primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: PRIMETheme.sandWeak,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentAchievements() {
    final achievements = [
      {
        'title': 'Цель по весу',
        'description': 'Достигли целевого веса!',
        'icon': Icons.emoji_events,
        'color': PRIMETheme.success,
        'date': '2 дня назад',
      },
      {
        'title': 'Мастер сна',
        'description': '7 дней подряд качественного сна',
        'icon': Icons.bedtime,
        'color': const Color(0xFF9C27B0),
        'date': '5 дней назад',
      },
      {
        'title': 'Шагомер',
        'description': '10 000 шагов в день',
        'icon': Icons.directions_walk,
        'color': const Color(0xFF4FC3F7),
        'date': '1 неделя назад',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Недавние достижения',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...achievements.map((achievement) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (achievement['color'] as Color).withOpacity(0.1),
                (achievement['color'] as Color).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (achievement['color'] as Color).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      achievement['description'] as String,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PRIMETheme.sandWeak,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                achievement['date'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActiveChallenges() {
    final challenges = [
      {
        'title': 'Гидратация Pro',
        'description': 'Пейте 3л воды 14 дней подряд',
        'progress': 0.71,
        'daysLeft': 4,
        'color': const Color(0xFF42A5F5),
      },
      {
        'title': 'Железная дисциплина',
        'description': 'Выполните все цели 30 дней',
        'progress': 0.43,
        'daysLeft': 17,
        'color': PRIMETheme.primary,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Активные челленджи',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...challenges.map((challenge) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (challenge['color'] as Color).withOpacity(0.1),
                (challenge['color'] as Color).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: (challenge['color'] as Color).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge['title'] as String,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          challenge['description'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: PRIMETheme.sandWeak,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: challenge['color'] as Color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${challenge['daysLeft']} дней',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: (challenge['progress'] as double) * _chartAnimation.value,
                  backgroundColor: (challenge['color'] as Color).withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(challenge['color'] as Color),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                '${((challenge['progress'] as double) * 100).toInt()}% выполнено',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: challenge['color'] as Color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStreaks() {
    final streaks = [
      {'title': 'Ежедневные шаги', 'count': 12, 'icon': Icons.directions_walk, 'color': const Color(0xFF4FC3F7)},
      {'title': 'Питьевой режим', 'count': 8, 'icon': Icons.water_drop, 'color': const Color(0xFF42A5F5)},
      {'title': 'Качественный сон', 'count': 5, 'icon': Icons.bedtime, 'color': const Color(0xFF9C27B0)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Стрики активности',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        Row(
          children: streaks.map((streak) => Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    (streak['color'] as Color).withOpacity(0.15),
                    (streak['color'] as Color).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (streak['color'] as Color).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (streak['color'] as Color).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      streak['icon'] as IconData,
                      color: streak['color'] as Color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${streak['count']}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: streak['color'] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'дней',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PRIMETheme.sandWeak,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    streak['title'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: streak['color'] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementStats() {
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
            'Статистика достижений',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Всего достижений', '12', Icons.emoji_events, PRIMETheme.success),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Активных дней', '89', Icons.calendar_today, PRIMETheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Очки опыта', '2840', Icons.stars, const Color(0xFFFF7043)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Рейтинг', '#127', Icons.leaderboard, const Color(0xFF9C27B0)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
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
            size: 28,
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

  // ГЕНЕРАЦИЯ ДАННЫХ
  List<double> _generateWeightTrendData() {
    // Генерируем данные веса с постепенным снижением
    final random = math.Random(42);
    const baseWeight = 79.7;
    final data = <double>[];
    
    for (int i = 0; i < 30; i++) {
      final trend = -1.2 * (i / 29); // Снижение на 1.2кг за месяц
      final noise = (random.nextDouble() - 0.5) * 0.4; // Случайные колебания
      data.add(baseWeight + trend + noise);
    }
    
    return data;
  }

  List<double> _generateBMITrendData() {
    final weightData = _generateWeightTrendData();
    return weightData.map((weight) => weight / math.pow(180 / 100, 2)).toList();
  }

  List<int> _generateStepsTrendData() {
    return [8500, 9200, 7800, 10100, 8900, 6500, 9800]; // Данные за неделю
  }

  List<double> _generateSleepTrendData() {
    return [7.2, 7.8, 7.1, 8.0, 7.5, 6.9, 7.8, 8.2, 7.4, 7.6]; // Данные за 10 дней
  }
}

// КАСТОМНЫЕ ПЕЙНТЕРЫ ДЛЯ ГРАФИКОВ
class _WeightTrendPainter extends CustomPainter {
  final List<double> data;
  final double animation;

  _WeightTrendPainter({required this.data, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = PRIMETheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          PRIMETheme.primary.withOpacity(0.3),
          PRIMETheme.primary.withOpacity(0.1),
          Colors.transparent,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();
    
    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = maxValue - minValue;
    
    final animatedLength = (data.length * animation).round();
    
    for (int i = 0; i < animatedLength; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.8 + size.height * 0.1);
      
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }
    
    // Заполнение под графиком
    if (animatedLength > 0) {
      final lastX = ((animatedLength - 1) / (data.length - 1)) * size.width;
      fillPath.lineTo(lastX, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, gradientPaint);
    }
    
    // Линия графика
    canvas.drawPath(path, paint);
    
    // Точки на графике
    final pointPaint = Paint()
      ..color = PRIMETheme.primary
      ..style = PaintingStyle.fill;
      
    for (int i = 0; i < animatedLength; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.8 + size.height * 0.1);
      
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _BMITrendPainter extends CustomPainter {
  final List<double> data;
  final double animation;

  _BMITrendPainter({required this.data, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = PRIMETheme.success
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final minValue = data.reduce(math.min);
    final maxValue = data.reduce(math.max);
    final range = maxValue - minValue;
    
    final animatedLength = (data.length * animation).round();
    
    for (int i = 0; i < animatedLength; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final normalizedValue = range > 0 ? (data[i] - minValue) / range : 0.5;
      final y = size.height - (normalizedValue * size.height * 0.8 + size.height * 0.1);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _SleepTrendPainter extends CustomPainter {
  final List<double> data;
  final double animation;

  _SleepTrendPainter({required this.data, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final barWidth = size.width / data.length * 0.8;
    final spacing = size.width / data.length * 0.2;
    
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF9C27B0),
          const Color(0xFF9C27B0).withOpacity(0.7),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final maxValue = data.reduce(math.max);
    final animatedLength = (data.length * animation).round();
    
    for (int i = 0; i < animatedLength; i++) {
      final x = i * (barWidth + spacing) + spacing / 2;
      final normalizedHeight = (data[i] / maxValue) * size.height * 0.9;
      final y = size.height - normalizedHeight;
      
      final rect = Rect.fromLTWH(x, y, barWidth, normalizedHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
