import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../models/exercise_model.dart';
import '../controllers/workout_controller.dart';
import 'ai_motion_page.dart';

class WorkoutPlanningPage extends ConsumerStatefulWidget {
  const WorkoutPlanningPage({super.key});

  @override
  ConsumerState<WorkoutPlanningPage> createState() => _WorkoutPlanningPageState();
}

class _WorkoutPlanningPageState extends ConsumerState<WorkoutPlanningPage> {
  List<ExercisePlan> selectedExercises = [];

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutControllerProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Планирование тренировки',
          style: TextStyle(
            color: PRIMETheme.sand,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: PRIMETheme.sand),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и описание
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PRIMETheme.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: PRIMETheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: PRIMETheme.primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI-MOTION Тренировка',
                                style: TextStyle(
                                  color: PRIMETheme.sand,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Выберите упражнения для сегодняшней тренировки',
                                style: TextStyle(
                                  color: PRIMETheme.sandWeak,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Список доступных упражнений
              const Text(
                'Выберите упражнения:',
                style: TextStyle(
                  color: PRIMETheme.sand,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.builder(
                  itemCount: Exercise.availableExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = Exercise.availableExercises[index];
                    final selectedPlan = selectedExercises
                        .where((plan) => plan.exerciseId == exercise.id)
                        .firstOrNull;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selectedPlan != null 
                            ? PRIMETheme.primary 
                            : PRIMETheme.line,
                          width: selectedPlan != null ? 2 : 1,
                        ),
                      ),
                      child: _ExerciseCard(
                        exercise: exercise,
                        selectedPlan: selectedPlan,
                        onSelectionChanged: (plan) => _updateExercisePlan(plan),
                        onRemoved: () => _removeExercise(exercise.id),
                      ),
                    );
                  },
                ),
              ),

              // Выбранные упражнения - краткий обзор
              if (selectedExercises.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: PRIMETheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'План тренировки:',
                        style: TextStyle(
                          color: PRIMETheme.sand,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...selectedExercises.map((plan) {
                        final exercise = plan.exercise;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(
                                exercise?.icon ?? '💪',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  exercise?.name ?? 'Упражнение',
                                  style: const TextStyle(
                                    color: PRIMETheme.sandWeak,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                '${plan.targetReps}',
                                style: const TextStyle(
                                  color: PRIMETheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Кнопка начала тренировки
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedExercises.isNotEmpty && !workoutState.isDetecting
                    ? _startWorkout
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMETheme.primary,
                    foregroundColor: PRIMETheme.sand,
                    disabledBackgroundColor: PRIMETheme.line,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        workoutState.isDetecting 
                          ? Icons.hourglass_empty 
                          : Icons.play_arrow,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        workoutState.isDetecting 
                          ? 'Тренировка активна...' 
                          : selectedExercises.isEmpty
                            ? 'Выберите упражнения'
                            : '🎯 НАЧАТЬ AI-ТРЕНИРОВКУ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateExercisePlan(ExercisePlan plan) {
    setState(() {
      // Удаляем старый план этого упражнения, если есть
      selectedExercises.removeWhere((p) => p.exerciseId == plan.exerciseId);
      
      // Добавляем новый план
      if (plan.targetReps > 0) {
        selectedExercises.add(plan);
      }
    });
  }

  void _removeExercise(String exerciseId) {
    setState(() {
      selectedExercises.removeWhere((plan) => plan.exerciseId == exerciseId);
    });
  }

  Future<void> _startWorkout() async {
    if (selectedExercises.isEmpty) return;

    try {
      // Создаем сессию тренировки
      await ref.read(workoutControllerProvider.notifier)
          .createWorkoutSession(selectedExercises);

      // Переходим на страницу AI-Motion
      if (mounted) {
        context.go('/gto/ai-motion');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания тренировки: $e'),
            backgroundColor: PRIMETheme.warn,
          ),
        );
      }
    }
  }
}

class _ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final ExercisePlan? selectedPlan;
  final Function(ExercisePlan) onSelectionChanged;
  final VoidCallback onRemoved;

  const _ExerciseCard({
    required this.exercise,
    this.selectedPlan,
    required this.onSelectionChanged,
    required this.onRemoved,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  late TextEditingController _repsController;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(
      text: widget.selectedPlan?.targetReps.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selectedPlan != null;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Основная информация об упражнении
              Row(
                children: [
                  // Иконка упражнения
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? PRIMETheme.primary.withOpacity(0.2)
                        : PRIMETheme.sandWeak.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.exercise.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Название и описание
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.exercise.name,
                          style: TextStyle(
                            color: isSelected ? PRIMETheme.primary : PRIMETheme.sand,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.exercise.description,
                          style: const TextStyle(
                            color: PRIMETheme.sandWeak,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Уровень сложности
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(widget.exercise.difficulty).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getDifficultyColor(widget.exercise.difficulty).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      widget.exercise.difficulty,
                      style: TextStyle(
                        color: _getDifficultyColor(widget.exercise.difficulty),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: PRIMETheme.sandWeak,
                  ),
                ],
              ),

              // Развернутая информация
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                
                // Инструкции
                const Text(
                  'Техника выполнения:',
                  style: TextStyle(
                    color: PRIMETheme.sand,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.exercise.instructions.map((instruction) => 
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(color: PRIMETheme.primary, fontSize: 14),
                        ),
                        Expanded(
                          child: Text(
                            instruction,
                            style: const TextStyle(
                              color: PRIMETheme.sandWeak,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Настройка количества повторений
                Row(
                  children: [
                    const Text(
                      'Количество повторений:',
                      style: TextStyle(
                        color: PRIMETheme.sand,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Быстрые кнопки
                    ...['10', '20', '30'].map((count) =>
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => _setReps(int.parse(count)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: PRIMETheme.sandWeak.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              count,
                              style: const TextStyle(
                                color: PRIMETheme.sandWeak,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Поле ввода и кнопки
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _repsController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: PRIMETheme.sand),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: const TextStyle(color: PRIMETheme.sandWeak),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(color: PRIMETheme.line),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: PRIMETheme.line),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: PRIMETheme.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                          onChanged: (_) => _updatePlan(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Кнопка добавить/удалить
                    ElevatedButton(
                      onPressed: isSelected ? widget.onRemoved : _addExercise,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? PRIMETheme.warn : PRIMETheme.primary,
                        foregroundColor: PRIMETheme.sand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        isSelected ? 'Удалить' : 'Добавить',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _setReps(int reps) {
    setState(() {
      _repsController.text = reps.toString();
    });
    _updatePlan();
  }

  void _addExercise() {
    final reps = int.tryParse(_repsController.text) ?? 0;
    if (reps > 0) {
      final plan = ExercisePlan(
        exerciseId: widget.exercise.id,
        targetReps: reps,
      );
      widget.onSelectionChanged(plan);
    }
  }

  void _updatePlan() {
    final reps = int.tryParse(_repsController.text) ?? 0;
    final plan = ExercisePlan(
      exerciseId: widget.exercise.id,
      targetReps: reps,
    );
    widget.onSelectionChanged(plan);
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'легкий':
        return Colors.green;
      case 'средний':
        return Colors.orange;
      case 'сложный':
        return Colors.red;
      default:
        return PRIMETheme.sandWeak;
    }
  }
}
