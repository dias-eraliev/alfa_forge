import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../shared/bottom_nav_scaffold.dart';
import '../../app/theme.dart';
import 'widgets/advanced_add_measurement_dialog.dart';
import 'widgets/measurement_history_dialog.dart';
import 'widgets/advanced_health_goals_dialog.dart';
import 'models/measurement_model.dart';
import 'models/health_goal_model.dart';
import '../../core/services/api_service.dart';
import '../../core/models/api_models.dart';

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

  // Данные о здоровье — без моков, инициализируем пустыми значениями и заполняем из API
  final Map<String, dynamic> healthData = {
    'weight': null,
    'height': null,
    'bodyFat': null,
    'muscle': null,
    'heartRate': null,
    'bloodPressure': null, // ожидаем Map<String,int> после API
    'sleep': null,
    'steps': null,
    'calories': null,
    'water': null,
  };

  // Измерения тела — пусто до загрузки из API
  final Map<String, double> bodyMeasurements = {};

  // Цели — отображаются по списку _healthGoals; эта карта больше не используется как источник данных
  final Map<String, dynamic> goals = {};

  // Цели здоровья
  List<HealthGoal> _healthGoals = [];
  bool _loading = false;
  // Маппинг локальных slug (например, 'weight') -> реальный backend id из таблицы measurement_types
  final Map<String, String> _measurementTypeIdMap = {};

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

    // Загрузка данных из API
    _loadFromApi();
  }

  Future<void> _loadFromApi() async {
    setState(() => _loading = true);
    try {
      final api = ApiService.instance;
      // 1) Подтягиваем типы измерений и строим маппинг локальныйId -> backendId
      final typesRes = await api.getMeasurementTypes();
      if (typesRes.isSuccess && typesRes.data != null) {
        _buildMeasurementTypeIdMap(typesRes.data!);
      }
      final latestRes = await api.getLatestHealthMeasurements();
      if (latestRes.isSuccess && latestRes.data != null) {
        for (final m in latestRes.data!) {
          _applyMeasurementToState(m);
        }
      }
      final goalsRes = await api.getHealthGoals(isActive: true);
      if (goalsRes.isSuccess && goalsRes.data != null) {
        _healthGoals = goalsRes.data!.map(_mapApiGoalToLocal).toList();
      }
    } catch (e) {
      debugPrint('Failed to load health data: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Строим соответствие между нашими статическими типами (MeasurementTypes) и типами из БЭКа
  void _buildMeasurementTypeIdMap(List<ApiMeasurementType> backendTypes) {
    // Быстрый индекс по имени (RU)
    final byName = <String, ApiMeasurementType>{
      for (final t in backendTypes) t.name.toLowerCase(): t,
    };
    _measurementTypeIdMap.clear();
    for (final local in MeasurementTypes.all) {
      // Сначала по полному имени (RU)
      var matched = byName[local.name.toLowerCase()];
      // Если не нашли, попробуем по shortName (RU)
      if (matched == null) {
        final shortKey = local.shortName.toLowerCase();
        final alt = backendTypes.where((t) => t.name.toLowerCase() == shortKey).toList();
        if (alt.isNotEmpty) {
          matched = alt.first;
        }
      }
      if (matched != null) {
        _measurementTypeIdMap[local.id] = matched.id;
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  double get bmi {
    final w = healthData['weight'] as double?;
    final h = healthData['height'] as double?;
    if (w == null || h == null || h == 0) return 0.0;
    return w / math.pow(h / 100, 2);
  }

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

  void _applyMeasurementToState(ApiHealthMeasurement m) {
    // Маппинг id типа -> поля локальной модели/карт
    final typeId = m.typeId;
    if (typeId == 'weight' || typeId == 'body_weight' || typeId == 'weight_kg' || typeId == 'WEIGHT') {
      // Вес ожидается в кг
      healthData['weight'] = m.value;
    } else if (typeId == 'height' || typeId == 'height_cm' || typeId == 'HEIGHT' || typeId == 'body_height' || typeId == 'stature') {
      // Рост: если значение похоже на метры (< 3.0), конвертируем в сантиметры
      final raw = m.value;
      final cm = raw < 3.0 ? raw * 100.0 : raw;
      healthData['height'] = cm;
    } else if (typeId == 'body_fat' || typeId == 'bodyFat') {
      healthData['bodyFat'] = m.value;
    } else if (typeId == 'muscle_mass' || typeId == 'muscle') {
      healthData['muscle'] = m.value;
    } else if (typeId == 'heart_rate' || typeId == 'heartRate') {
      healthData['heartRate'] = m.value;
    } else if (typeId == 'blood_pressure_systolic' || typeId == 'bp_systolic') {
      final existing = (healthData['bloodPressure'] as Map<String, int>?) ?? {'systolic': 0, 'diastolic': 0};
      existing['systolic'] = m.value.round();
      healthData['bloodPressure'] = existing;
    } else if (typeId == 'blood_pressure_diastolic' || typeId == 'bp_diastolic') {
      final existing = (healthData['bloodPressure'] as Map<String, int>?) ?? {'systolic': 0, 'diastolic': 0};
      existing['diastolic'] = m.value.round();
      healthData['bloodPressure'] = existing;
    } else if (typeId == 'sleep' || typeId == 'sleep_hours') {
      healthData['sleep'] = m.value;
    } else if (typeId == 'steps' || typeId == 'daily_steps') {
      healthData['steps'] = m.value.round();
    } else if (typeId == 'calories' || typeId == 'calories_burned') {
      healthData['calories'] = m.value.round();
    } else if (typeId == 'water' || typeId == 'water_intake_l') {
      healthData['water'] = m.value;
    } else if ({
      'chest',
      'waist',
      'hips',
      'biceps',
      'thighs',
      'neck',
      'bicep_left',
      'bicep_right',
      'thigh_left',
      'thigh_right',
      'forearm_left',
      'forearm_right',
      'calf_left',
      'calf_right',
    }.contains(typeId)) {
      // Нормализуем ключи для карты bodyMeasurements
      final mapKey = _normalizeBodyKey(typeId);
      if (mapKey != null) {
        bodyMeasurements[mapKey] = m.value;
      }
    }
  }

  String? _normalizeBodyKey(String typeId) {
    switch (typeId) {
      case 'bicep_left':
      case 'bicep_right':
        return 'biceps';
      case 'thigh_left':
      case 'thigh_right':
        return 'thighs';
      case 'forearm_left':
      case 'forearm_right':
        return null; // нет отдельного поля, можно не агрегировать
      case 'calf_left':
      case 'calf_right':
        return null;
      default:
        return typeId;
    }
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
                    if (_loading) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(minHeight: 3),
                      const SizedBox(height: 8),
                    ],
                  const SizedBox(height: 24),

                  // Основные метрики
                  _MainMetrics(
                    weight: (healthData['weight'] as double?) ?? 0,
                    bmi: bmi,
                    bmiCategory: bmiCategory,
                    bmiColor: bmiColor,
                    bodyFat: (healthData['bodyFat'] as double?) ?? 0,
                    muscle: (healthData['muscle'] as double?) ?? 0,
                  ),
                  const SizedBox(height: 24),

                  // Витальные показатели
                  _VitalSigns(
                    heartRate: (healthData['heartRate'] as num?)?.toInt() ?? 0,
                    bloodPressure: (healthData['bloodPressure'] as Map<String,int>?) ?? {'systolic': 0, 'diastolic': 0},
                    sleep: (healthData['sleep'] as double?) ?? 0,
                  ),
                  const SizedBox(height: 24),

                  // Ежедневная активность
                  _DailyActivity(
                    steps: (healthData['steps'] as num?)?.toInt() ?? 0,
                    calories: (healthData['calories'] as num?)?.toInt() ?? 0,
                    water: (healthData['water'] as double?) ?? 0,
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
      builder: (context) => AdvancedAddMeasurementDialog(
        onMeasurementsAdded: (measurements) {
          setState(() {
            bodyMeasurements.addAll(measurements);
            // Обновляем основные показатели если есть вес
            if (measurements.containsKey('weight')) {
              healthData['weight'] = measurements['weight'];
            }
          });
          // Отправляем в API
          _submitMeasurementsToApi(measurements);
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

  Future<void> _submitMeasurementsToApi(Map<String, double> values) async {
    final api = ApiService.instance;
    int skipped = 0;
    for (final entry in values.entries) {
      try {
        // Преобразуем наш локальный ключ (например, 'waist') в реальный backend id
        final backendTypeId = _measurementTypeIdMap[entry.key] ?? entry.key;
        if (!_measurementTypeIdMap.containsKey(entry.key)) {
          debugPrint('Skip sending unsupported measurement type: ${entry.key} (no backend mapping)');
          // Пропускаем неподдерживаемые типы, чтобы не ловить P2003
          skipped++;
          continue;
        }
        final res = await api.createHealthMeasurement(
          ApiHealthMeasurement(
            id: 'local',
            typeId: backendTypeId,
            value: entry.value,
            unit: null,
            timestamp: DateTime.now(),
            notes: null,
          ),
        );
        if (!res.isSuccess) {
          debugPrint('Failed to create measurement ${entry.key}: ${res.error}');
        }
      } catch (e) {
        debugPrint('Error creating measurement ${entry.key}: $e');
      }
    }
    if (skipped > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Некоторые типы не поддерживаются на сервере и были пропущены: $skipped'),
          backgroundColor: PRIMETheme.warn,
        ),
      );
    }
  }

  void _showHistoryDialog() {
    () async {
      // Загружаем историю за 90 дней
      final now = DateTime.now();
      final start = now.subtract(const Duration(days: 90));
      List<BodyMeasurement> initial = [];
      try {
        final res = await ApiService.instance.getHealthMeasurements(
          startDate: start,
          endDate: now,
        );
        if (res.isSuccess && res.data != null) {
          initial = res.data!
              .map((m) => BodyMeasurement(
                    id: m.id,
                    typeId: m.typeId,
                    value: m.value,
                    timestamp: m.timestamp,
                    notes: m.notes,
                  ))
              .toList();
        }
      } catch (e) {
        debugPrint('Failed to load measurement history: $e');
      }

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => MeasurementHistoryDialog(
          initialMeasurements: initial,
        ),
      );
    }();
  }

  void _showGoalsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AdvancedHealthGoalsDialog(
        existingGoals: _healthGoals,
        onGoalsUpdated: (updatedGoals) {
          setState(() {
            _healthGoals = updatedGoals;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Цели здоровья обновлены! 🎯'),
              backgroundColor: PRIMETheme.success,
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
        
        // Карточка с BMI и весом
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PRIMETheme.line),
          ),
          child: Row(
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
        ),
        const SizedBox(height: 16),
        
        // Прогресс бар BMI
        _BMIProgressBar(bmi: bmi, bmiColor: bmiColor),
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
                progress: (bodyFat / 25).clamp(0.0, 1.0),
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
                progress: (muscle / 80).clamp(0.0, 1.0),
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
    final target = ((widget.bmi - 15) / (35 - 15)).clamp(0.0, 1.0);
    _animation = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _BMIProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmi != widget.bmi) {
      final target = ((widget.bmi - 15) / (35 - 15)).clamp(0.0, 1.0);
      _animation = Tween<double>(begin: _animation.value, end: target).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
      );
      _controller
        ..stop()
        ..forward(from: 0);
      setState(() {});
    }
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

    // Цветные зоны BMI в диапазоне 15–35 (нормализовано к 0..1)
    // Границы: <18.5 (дефицит), 18.5–25 (норма), 25–30 (избыток), >30 (ожирение)
    const minBmi = 15.0;
    const maxBmi = 35.0;
    double nz(double v) => ((v - minBmi) / (maxBmi - minBmi)).clamp(0.0, 1.0);
    final zones = [
      {'start': nz(15.0), 'end': nz(18.5), 'color': PRIMETheme.warn},
      {'start': nz(18.5), 'end': nz(25.0), 'color': PRIMETheme.success},
      {'start': nz(25.0), 'end': nz(30.0), 'color': PRIMETheme.warn},
      {'start': nz(30.0), 'end': nz(35.0), 'color': const Color(0xFFE53E3E)},
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

    // Безопасное извлечение целей из карты goals
    int stepsTarget = 10000; // дефолт
    if (goals['steps'] is Map && (goals['steps'] as Map)['target'] != null) {
      final v = (goals['steps'] as Map)['target'];
      if (v is num) stepsTarget = v.toInt();
    }

    int waterTargetMl = 2000; // 2л по умолчанию
    if (goals['water'] is Map && (goals['water'] as Map)['target'] != null) {
      final v = (goals['water'] as Map)['target'];
      if (v is num) waterTargetMl = (v * 1000).toInt();
    }

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
                target: stepsTarget,
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
          target: waterTargetMl,
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
    final isCompleted = (widget.value / widget.target) >= 1.0;

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
                      value: measurements['chest'] ?? 0.0,
                      icon: Icons.fitness_center,
                      isCompact: isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Талия',
                      value: measurements['waist'] ?? 0.0,
                      icon: Icons.straighten,
                      isCompact: isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Бедра',
                      value: measurements['hips'] ?? 0.0,
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
                      value: measurements['biceps'] ?? 0.0,
                      icon: Icons.sports_martial_arts,
                      isCompact: isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Бедро',
                      value: measurements['thighs'] ?? 0.0,
                      icon: Icons.directions_run,
                      isCompact: isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MeasurementItem(
                      title: 'Шея',
                      value: measurements['neck'] ?? 0.0,
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


// Удалены Placeholder-виджеты _HistorySheet и _GoalsSheet, так как заменены реальными диалогами

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
  // API аналитика
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  List<Map<String, dynamic>> _achievements = [];
  List<ApiHealthGoal> _apiGoals = [];
  int _periodDays = 30; // период для трендов/статистики
  final Map<String, List<double>> _trendFallback = {}; // фолбэк ряды

  // Нормализация ключей трендов: поддерживаем EN и RU синонимы
  String? _matchTrendKey(String keyword, Map<String, dynamic> trends) {
    final syn = <String, List<String>>{
      'weight': ['weight', 'вес'],
      'height': ['height', 'рост'],
      'heart_rate': ['heart_rate', 'пульс'],
      'body_fat': ['body_fat', 'жир'],
      'water': ['water', 'вода'], // из health: 'Вода в организме' (процент)
      'sleep': ['sleep', 'сон'],
      'bmi': ['bmi', 'имт', 'индекс'],
      'steps': ['steps', 'шаги'],
    };
    final candidates = syn[keyword.toLowerCase()] ?? [keyword.toLowerCase()];
    String? found;
    for (final k in trends.keys) {
      final lk = k.toString().toLowerCase();
      if (candidates.any((c) => lk.contains(c))) { found = k; break; }
    }
    return found;
  }

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
  _loadAnalytics();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: PRIMETheme.warn),
          const SizedBox(height: 8),
          Text(_error ?? 'Ошибка загрузки', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadAnalytics, child: const Text('Повторить')),
        ],
      ),
    );
  }

  Future<void> _loadAnalytics() async {
    setState(() { _loading = true; _error = null; });
    try {
      final api = ApiService.instance;
      final now = DateTime.now();
      final start = now.subtract(Duration(days: _periodDays));
      final statsRes = await api.getHealthStats(startDate: start, endDate: now);
  final achRes = await api.getHealthAchievements();
      final goalsRes = await api.getHealthGoals(isActive: true);
      if (!statsRes.isSuccess) { throw Exception(statsRes.error ?? 'Ошибка stats'); }
      // Подготовим фолбэк для ключевых трендов, если их нет в stats
      final statsData = statsRes.data ?? {};
      final trends = statsData['trends'] as Map<String, dynamic>?;
      final needKeys = <String, String>{
        'weight': 'weight',
        'heart_rate': 'heart_rate',
        'body_fat': 'body_fat',
        'water': 'water_percent',
      };
      final futures = <Future>[];
      final localFallback = <String, List<double>>{};
      for (final entry in needKeys.entries) {
        final k = entry.key;
        final slug = entry.value;
        bool hasTrend = false;
        if (trends != null) {
          final key = _matchTrendKey(k, trends);
          hasTrend = key != null && key.isNotEmpty && trends[key] is List && (trends[key] as List).isNotEmpty;
        }
        if (!hasTrend) {
          futures.add(api.getMeasurementHistory(typeId: slug, days: _periodDays).then((res) {
            if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
              localFallback[k] = res.data!.map((m) => m.value).toList();
            }
          }));
        }
      }
      if (futures.isNotEmpty) {
        await Future.wait(futures);
      }
      setState(() {
        _stats = statsData;
        _trendFallback
          ..clear()
          ..addAll(localFallback);
        // Преобразуем достижения к UI-модели с цветами/иконками/датой
        final src = achRes.isSuccess && achRes.data != null ? achRes.data! : <Map<String, dynamic>>[];
        _achievements = src.map<Map<String, dynamic>>((a) {
          final type = (a['type'] ?? '').toString();
          Color color;
          IconData icon;
          switch (type) {
            case 'first_measurement':
              color = PRIMETheme.primary; icon = Icons.monitor_weight; break;
            case 'consistent_tracking':
              color = PRIMETheme.success; icon = Icons.trending_up; break;
            case 'goal_completed':
              color = const Color(0xFFFFC107); icon = Icons.emoji_events; break;
            default:
              color = PRIMETheme.sand; icon = Icons.star;
          }
          String dateStr = '—';
          final earnedAt = a['earnedAt']?.toString();
          if (earnedAt != null) {
            final dt = DateTime.tryParse(earnedAt);
            if (dt != null) {
              final d = dt.toLocal();
              dateStr = '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
            }
          }
          return {
            'type': type,
            'title': a['title'] ?? 'Достижение',
            'description': a['description'] ?? '',
            'date': dateStr,
            'color': color,
            'icon': icon,
          };
        }).toList();
        _apiGoals = goalsRes.isSuccess && goalsRes.data != null ? goalsRes.data! : [];
      });
    } catch (e) {
      setState(() { _error = 'Не удалось загрузить аналитику: $e'; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<double> _trendValuesFor(String keyword) {
    final trends = _stats != null ? _stats!['trends'] as Map<String, dynamic>? : null;
    if (trends != null) {
      final key = _matchTrendKey(keyword, trends);
      if (key != null && key.isNotEmpty) {
        final list = trends[key];
        if (list is List) {
          return list.map<double>((e) {
            final v = (e is Map && e['value'] != null) ? e['value'] : e;
            return (v as num).toDouble();
          }).toList();
        }
      }
    }
    // Если есть фолбэк — используем его
    final fb = _trendFallback[keyword];
    if (fb != null && fb.isNotEmpty) return fb;
    // Фолбэк: если трендов нет — строим из истории измерений
    // Поддерживаем ключевые метрики: weight, heart_rate, sleep, steps, water, body_fat
    final typeSlugByKey = <String, String>{
      'weight': 'weight',
      'heart_rate': 'heart_rate',
      'sleep': 'sleep',
      'steps': 'steps',
      'water': 'water_percent', // тренд по воде может быть в %, но используем как есть
      'body_fat': 'body_fat',
    };
    final resolvedKey = typeSlugByKey[keyword] ?? keyword;
    // Ищем последние значения в healthData как крайний случай
    final local = widget.healthData[resolvedKey];
    if (local is List<double>) return local;
    if (local is num) return [local.toDouble()];
    return [];
  }

  double? _latestValueFor(String keyword) {
    final arr = _trendValuesFor(keyword);
    return arr.isNotEmpty ? arr.last : null;
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
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null ? _buildError() : _buildTabContent()),
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
        // Безопасно рассчитываем значения метрик
        // Используем последние значения там, где возможно, и дефолты при отсутствии
        Builder(builder: (context) {
          final weight = (_latestValueFor('weight') ?? (widget.healthData['weight'] as num?))?.toDouble() ?? 0.0;
          final height = (_latestValueFor('height') ?? (widget.healthData['height'] as num?))?.toDouble() ?? 0.0; // см
          final bmi = (weight > 0 && height > 0)
              ? weight / math.pow(height / 100.0, 2)
              : 0.0;
          final heartRate = (widget.healthData['heartRate'] as num?)?.toDouble() ?? 0.0;
          final bodyFat = (widget.healthData['bodyFat'] as num?)?.toDouble() ?? 0.0;
          final sleep = (widget.healthData['sleep'] as num?)?.toDouble() ?? (_latestValueFor('sleep') ?? 0.0);
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricChart(
                      title: 'BMI',
                      value: bmi,
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
                      value: heartRate,
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
                      value: bodyFat,
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
                      value: sleep,
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
        }),
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
                current: (() {
                  final latest = _latestValueFor('steps');
                  final hd = widget.healthData['steps'] as int?;
                  return (latest?.round() ?? hd ?? 0);
                })(),
                target: (() {
                  ApiHealthGoal? goal;
                  try {
                    goal = _apiGoals.firstWhere((g) => g.goalType == 'STEPS');
                  } catch (_) {
                    goal = null;
                  }
                  return goal != null ? goal.targetValue.round() : 0;
                })(),
                color: const Color(0xFF4FC3F7),
                icon: Icons.directions_walk,
                unit: '',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCircularChart(
                title: 'Вода',
                current: (() {
                  final latest = _latestValueFor('water');
                  final hd = widget.healthData['water'] as double?; // литры
                  final liters = latest ?? hd ?? 0.0;
                  return (liters * 1000).round();
                })(),
                target: (() {
                  ApiHealthGoal? goal;
                  try {
                    goal = _apiGoals.firstWhere((g) => g.goalType == 'WATER');
                  } catch (_) {
                    goal = null;
                  }
                  final liters = goal?.targetValue ?? 0.0;
                  return (liters * 1000).round();
                })(),
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
    final safeTarget = target <= 0 ? 1 : target;
    final progress = (current / safeTarget).clamp(0.0, 1.0);
    
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
    final weight = (_latestValueFor('weight') ?? (widget.healthData['weight'] as num?))?.toDouble() ?? 0.0;
    final height = (widget.healthData['height'] as num?)?.toDouble() ?? 0.0; // см
    final bmi = (height > 0)
        ? (weight / math.pow(height / 100, 2))
        : 0.0;
    if (bmi >= 18.5 && bmi <= 25) {
      score += 25;
    } else if (bmi >= 17 && bmi <= 30) {
      score += 15;
    } else {
      score += 5;
    }
    
    // Heart rate score (20%)
  final heartRate = (widget.healthData['heartRate'] as num?)?.toDouble() ?? 0.0;
    if (heartRate >= 60 && heartRate <= 100) {
      score += 20;
    } else if (heartRate >= 50 && heartRate <= 110) {
      score += 15;
    } else {
      score += 5;
    }
    
    // Sleep score (20%)
  final sleep = (widget.healthData['sleep'] as num?)?.toDouble() ?? (_latestValueFor('sleep') ?? 0.0);
    if (sleep >= 7 && sleep <= 9) {
      score += 20;
    } else if (sleep >= 6 && sleep <= 10) {
      score += 15;
    } else {
      score += 5;
    }
    
    // Activity score (20%)
    final steps = (_latestValueFor('steps') ?? (widget.healthData['steps'] as num? ?? 0)).toDouble();
    double stepsTarget = 10000; // дефолт
    try {
      final g = _apiGoals.firstWhere((g) => g.goalType == 'STEPS');
      stepsTarget = g.targetValue;
    } catch (_) {
      // если цели нет — используем дефолт
    }
    final stepsProgress = stepsTarget > 0 ? (steps / stepsTarget).clamp(0.0, 1.0) : 0.0;
    score += 20 * stepsProgress;
    
    // Body fat score (15%)
  final bodyFat = (widget.healthData['bodyFat'] as num?)?.toDouble() ?? 0.0;
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PRIMETheme.primary,
                PRIMETheme.primary.withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_month, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _periodDays,
                  dropdownColor: PRIMETheme.primary,
                  iconEnabledColor: Colors.white,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  items: const [7,14,30,90]
                      .map((d) => DropdownMenuItem<int>(value: d, child: Text('$d дней')))
                      .toList(),
                  onChanged: (val) {
                    if (val == null) return;
                    setState(() { _periodDays = val; });
                    _loadAnalytics();
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightTrendChart() {
    // Данные веса из API трендов за 30 дней
    final weightData = _trendValuesFor('weight');
    final hasData = weightData.isNotEmpty;
    final String deltaStr = (() {
      if (!hasData) return '—';
      if (weightData.length < 2) return '0.0 кг';
      final delta = weightData.last - weightData.first;
      final sign = delta >= 0 ? '+' : '';
      return '$sign${delta.toStringAsFixed(1)} кг';
    })();
    
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
                child: Text(
                  deltaStr,
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
          
          // График веса
          if (hasData)
            SizedBox(
              height: 120,
              child: CustomPaint(
                size: const Size(double.infinity, 120),
                painter: _WeightTrendPainter(
                  data: weightData,
                  animation: _chartAnimation.value,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text('Нет данных для выбранного периода', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PRIMETheme.sandWeak)),
            ),
          
          const SizedBox(height: 12),
          if (hasData)
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
    // Данные BMI из API трендов; если нет — рассчитываем из веса и текущего роста
    List<double> bmiData = _trendValuesFor('bmi');
    if (bmiData.isEmpty) {
      final weightData = _trendValuesFor('weight');
      final height = widget.healthData['height'] as double?; // см
      if (weightData.isNotEmpty && (height != null && height > 0)) {
        final h = height / 100;
        bmiData = weightData.map((w) => w / math.pow(h, 2)).toList();
      }
    }
    final hasData = bmiData.isNotEmpty;
    
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
                hasData ? bmiData.last.toStringAsFixed(1) : '—',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PRIMETheme.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (hasData)
            SizedBox(
              height: 100,
              child: CustomPaint(
                size: const Size(double.infinity, 100),
                painter: _BMITrendPainter(
                  data: bmiData,
                  animation: _chartAnimation.value,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Нет данных для BMI', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PRIMETheme.sandWeak)),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityTrendChart() {
    // Шаги за последние 7 дней из трендов API
    var stepsData = _trendValuesFor('steps').map((e) => e.round()).toList();
    if (stepsData.length > 7) {
      stepsData = stepsData.sublist(stepsData.length - 7);
    }
    final avg = stepsData.isNotEmpty
        ? (stepsData.reduce((a, b) => a + b) / stepsData.length).toInt()
        : 0;
    
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
                '$avg',
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
                      dayNames[index % dayNames.length],
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
    final sleepData = _trendValuesFor('sleep');
    final hasData = sleepData.isNotEmpty;
    final avgText = hasData
        ? 'Среднее: ${(sleepData.reduce((a, b) => a + b) / sleepData.length).toStringAsFixed(1)}ч'
        : 'Нет данных';
    
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
                      avgText,
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
          
          if (hasData)
            SizedBox(
              height: 80,
              child: CustomPaint(
                size: const Size(double.infinity, 80),
                painter: _SleepTrendPainter(
                  data: sleepData,
                  animation: _chartAnimation.value,
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('Нет данных по сну', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PRIMETheme.sandWeak)),
            ),
        ],
      ),
    );
  }

  Widget _buildComparisonAnalysis() {
    // Берем текущий диапазон трендов и сравниваем с таким же предыдущим периодом
    final trends = _stats != null ? _stats!['trends'] as Map<String, dynamic>? : null;
    String formatDelta(num delta, {String unit = ''}) {
      final sign = delta >= 0 ? '+' : '';
      return '$sign${delta.toStringAsFixed(unit.isEmpty ? 0 : 1)}${unit.isNotEmpty ? ' $unit' : ''}';
    }
    String weightDelta = '—';
    String stepsDelta = '—';
    String sleepDelta = '—';
    final days = _periodDays;
    if (trends != null) {
      final w = _trendValuesFor('weight');
      if (w.length >= days * 2) {
        final prev = w.sublist(w.length - days * 2, w.length - days);
        final curr = w.sublist(w.length - days);
        final delta = (curr.last - curr.first) - (prev.last - prev.first);
        weightDelta = formatDelta(delta, unit: 'кг');
      } else if (w.length >= 2) {
        final delta = w.last - w.first;
        weightDelta = formatDelta(delta, unit: 'кг');
      }

      final s = _trendValuesFor('steps');
      if (s.length >= days * 2) {
        final prev = s.sublist(s.length - days * 2, s.length - days);
        final curr = s.sublist(s.length - days);
        final delta = (curr.reduce((a,b)=>a+b)/curr.length) - (prev.reduce((a,b)=>a+b)/prev.length);
        stepsDelta = formatDelta(delta.round());
      } else if (s.isNotEmpty) {
        stepsDelta = formatDelta(((s.reduce((a,b)=>a+b))/s.length).round());
      }

      final sl = _trendValuesFor('sleep');
      if (sl.length >= days * 2) {
        final prev = sl.sublist(sl.length - days * 2, sl.length - days);
        final curr = sl.sublist(sl.length - days);
        final delta = (curr.reduce((a,b)=>a+b)/curr.length) - (prev.reduce((a,b)=>a+b)/prev.length);
        sleepDelta = formatDelta(delta, unit: 'ч');
      } else if (sl.isNotEmpty) {
        sleepDelta = formatDelta((sl.reduce((a,b)=>a+b)/sl.length), unit: 'ч');
      }
    }

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
          
          _buildComparisonItem('Текущий период vs предыдущий', 'Вес', weightDelta, PRIMETheme.success, Icons.monitor_weight),
          const SizedBox(height: 12),
          _buildComparisonItem('Средняя активность', 'Шаги', stepsDelta, PRIMETheme.success, Icons.directions_walk),
          const SizedBox(height: 12),
          _buildComparisonItem('Качество сна', 'Сон', sleepDelta, PRIMETheme.success, Icons.bedtime),
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
    final achievements = _achievements;
    if (achievements.isEmpty) {
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
          Text('Пока нет достижений', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: PRIMETheme.sandWeak)),
        ],
      );
    }

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
    // Примерная логика: делаем 2 челленджа на базе текущих целей — вода и шаги.
    // Прогресс = доля дней за период, где достигнут таргет.
    double progressDays(List<double> trend, double target) {
      if (trend.isEmpty || target <= 0) return 0.0;
      final achieved = trend.where((v)=>v >= target).length;
      return (achieved / trend.length).clamp(0.0, 1.0);
    }
    double waterTarget = 2.0;
    double stepsTarget = 10000;
    try { waterTarget = _apiGoals.firstWhere((g)=>g.goalType=='WATER').targetValue; } catch(_){ }
    try { stepsTarget = _apiGoals.firstWhere((g)=>g.goalType=='STEPS').targetValue; } catch(_){ }
    final waterProg = progressDays(_trendValuesFor('water'), waterTarget);
    final stepsProg = progressDays(_trendValuesFor('steps'), stepsTarget);
    final challenges = [
      {
        'title': 'Гидратация Pro',
        'description': 'Пейте ${waterTarget.toStringAsFixed(1)}л ежедневно',
        'progress': waterProg,
        'daysLeft': (_periodDays - (_periodDays * waterProg)).ceil(),
        'color': const Color(0xFF42A5F5),
      },
      {
        'title': 'Железная дисциплина',
        'description': 'Шаги ≥ ${stepsTarget.toInt()} в день',
        'progress': stepsProg,
        'daysLeft': (_periodDays - (_periodDays * stepsProg)).ceil(),
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
    int calcStreak(List<double> values, double threshold, {bool greaterOrEqual = true}) {
      if (values.isEmpty) return 0;
      int current = 0, best = 0;
      for (final v in values) {
        final ok = greaterOrEqual ? v >= threshold : v <= threshold;
        if (ok) {
          current++;
          best = math.max(best, current);
        } else {
          current = 0;
        }
      }
      return best;
    }

    // Steps streak: используем цель из _apiGoals или 10000 по умолчанию
    double stepsTarget = 10000;
    try { stepsTarget = _apiGoals.firstWhere((g)=>g.goalType=='STEPS').targetValue; } catch(_){ }
    final stepsTrend = _trendValuesFor('steps');
    final stepsStreak = calcStreak(stepsTrend, stepsTarget, greaterOrEqual: true);

    // Water streak (литры) — цель из _apiGoals или 2.0 по умолчанию
    double waterTarget = 2.0;
    try { waterTarget = _apiGoals.firstWhere((g)=>g.goalType=='WATER').targetValue; } catch(_){ }
    final waterTrend = _trendValuesFor('water');
    final waterStreak = calcStreak(waterTrend, waterTarget, greaterOrEqual: true);

    // Sleep streak — >=7 часов
    final sleepTrend = _trendValuesFor('sleep');
    final sleepStreak = calcStreak(sleepTrend, 7.0, greaterOrEqual: true);

    final streaks = [
      {'title': 'Ежедневные шаги', 'count': stepsStreak, 'icon': Icons.directions_walk, 'color': const Color(0xFF4FC3F7)},
      {'title': 'Питьевой режим', 'count': waterStreak, 'icon': Icons.water_drop, 'color': const Color(0xFF42A5F5)},
      {'title': 'Качественный сон', 'count': sleepStreak, 'icon': Icons.bedtime, 'color': const Color(0xFF9C27B0)},
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
    final totalAchievements = _achievements.length;
    // Активные дни: считаем дни, где есть хотя бы одна активность (шаги > 0 или сон > 0)
    final steps = _trendValuesFor('steps');
    final sleep = _trendValuesFor('sleep');
    final activeDays = () {
      final len = math.max(steps.length, sleep.length);
      int count = 0;
      for (int i = 0; i < len; i++) {
        final s = i < steps.length ? steps[i] : 0;
        final sl = i < sleep.length ? sleep[i] : 0;
        if (s > 0 || sl > 0) count++;
      }
      return count;
    }();

    // Очки/рейтинг — оставим placeholders, либо можно суммировать очки за достижения
    final xp = totalAchievements * 200; // примитивная метрика
    final rating = '#${100 + totalAchievements}';

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
                child: _buildStatItem('Всего достижений', '$totalAchievements', Icons.emoji_events, PRIMETheme.success),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Активных дней', '$activeDays', Icons.calendar_today, PRIMETheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Очки опыта', '$xp', Icons.stars, const Color(0xFFFF7043)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Рейтинг', rating, Icons.leaderboard, const Color(0xFF9C27B0)),
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

  // Генераторы трендов удалены — теперь данные приходят из API (_stats.trends)
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
