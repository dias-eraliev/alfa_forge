import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import 'models/exercise_model.dart';
import 'controllers/workout_controller.dart';

/// Минималистичная GTO страница:
/// - Только список упражнений (без описаний, пола, возраста, настроек)
/// - Выбор одного упражнения
/// - Кнопка СТАРТ сразу создает сессию с дефолтной целью и уходит на workout
class GTOPage extends ConsumerStatefulWidget {
  const GTOPage({super.key});

  @override
  ConsumerState<GTOPage> createState() => _GTOPageState();
}

class _GTOPageState extends ConsumerState<GTOPage> {
  String? selectedExerciseId;

  static const Map<String, int> defaultTargetReps = {
    ExerciseType.pushups: 20,
    ExerciseType.squats: 30,
    ExerciseType.jumpingJacks: 30,
  };

  final List<String> exerciseOrder = const [
    ExerciseType.pushups,
    ExerciseType.squats,
    ExerciseType.jumpingJacks,
  ];

  Future<void> _start() async {
    if (selectedExerciseId == null) return;

    final plan = ExercisePlan(
      exerciseId: selectedExerciseId!,
      targetReps: defaultTargetReps[selectedExerciseId!] ?? 10,
    );

    try {
      await ref
          .read(workoutControllerProvider.notifier)
          .createWorkoutSession([plan]);

      if (mounted) {
        context.push('/gto/workout');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка запуска: $e'),
            backgroundColor: PRIMETheme.warn,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final exercises = exerciseOrder
        .map((id) => Exercise.getById(id))
        .where((e) => e != null)
        .cast<Exercise>()
        .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'GTO',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Выберите упражнение:',
                style: TextStyle(
                  color: PRIMETheme.sand,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: ListView.separated(
                  itemCount: exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final ex = exercises[index];
                    final selected = ex.id == selectedExerciseId;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedExerciseId = ex.id;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: selected
                              ? PRIMETheme.primary.withOpacity(0.15)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? PRIMETheme.primary
                                : PRIMETheme.line,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: selected
                                    ? PRIMETheme.primary.withOpacity(0.25)
                                    : PRIMETheme.sandWeak.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                ex.icon,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                ex.name,
                                style: TextStyle(
                                  color: selected
                                      ? PRIMETheme.primary
                                      : PRIMETheme.sand,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                              color: selected
                                  ? PRIMETheme.primary
                                  : PRIMETheme.sandWeak,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Кнопка СТАРТ
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedExerciseId == null ? null : _start,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMETheme.primary,
                    foregroundColor: PRIMETheme.sand,
                    disabledBackgroundColor: PRIMETheme.line,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text(
                    'СТАРТ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }
}
