import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../models/workout_session_model.dart';

class WorkoutResultsPage extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutResultsPage({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Заголовок
              const Icon(
                Icons.emoji_events,
                color: PRIMETheme.primary,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'Тренировка завершена!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _getMotivationalMessage(),
                style: const TextStyle(
                  color: PRIMETheme.sandWeak,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Статистика
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: PRIMETheme.line),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Результаты тренировки',
                        style: TextStyle(
                          color: PRIMETheme.sand,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Основная статистика
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Повторения',
                              value: '${session.totalRepsCompleted}',
                              icon: Icons.fitness_center,
                              color: PRIMETheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Качество',
                              value: '${session.averageQuality.toInt()}%',
                              icon: Icons.star,
                              color: _getQualityColor(session.averageQuality),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Время',
                              value: _formatDuration(session.duration),
                              icon: Icons.timer,
                              color: PRIMETheme.success,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              title: 'Упражнений',
                              value: '${session.exercises.length}',
                              icon: Icons.list,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Детали по упражнениям
                      Expanded(
                        child: ListView.builder(
                          itemCount: session.exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = session.exercises[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: PRIMETheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: PRIMETheme.primary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    exercise.exercise?.icon ?? '💪',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          exercise.exercise?.name ?? 'Упражнение',
                                          style: const TextStyle(
                                            color: PRIMETheme.sand,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${exercise.completedReps} из ${exercise.targetReps}',
                                          style: const TextStyle(
                                            color: PRIMETheme.sandWeak,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: exercise.isCompleted 
                                        ? PRIMETheme.success 
                                        : PRIMETheme.warn,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      exercise.isCompleted ? 'Выполнено' : 'Частично',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.pop();
                        context.pop(); // Вернуться к ГТО странице
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: PRIMETheme.sandWeak),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Назад к ГТО',
                        style: TextStyle(
                          color: PRIMETheme.sandWeak,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Начать новую тренировку
                        context.pop();
                        // Можно добавить логику для повтора тренировки
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMETheme.primary,
                        foregroundColor: PRIMETheme.sand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Еще раз',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMotivationalMessage() {
    final completionRate = session.totalRepsCompleted / 
        session.exercises.fold<int>(0, (sum, ex) => sum + ex.targetReps);
    
    if (completionRate >= 1.0) {
      return 'Невероятно! Вы выполнили все упражнения!';
    } else if (completionRate >= 0.8) {
      return 'Отличная работа! Почти все цели достигнуты!';
    } else if (completionRate >= 0.5) {
      return 'Хорошее начало! Продолжайте тренироваться!';
    } else {
      return 'Каждый шаг важен! Не сдавайтесь!';
    }
  }

  Color _getQualityColor(double quality) {
    if (quality >= 80) return PRIMETheme.success;
    if (quality >= 60) return Colors.orange;
    return PRIMETheme.warn;
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutesм $secondsс';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
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
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: PRIMETheme.sandWeak,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
