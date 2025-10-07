import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../models/goal_model.dart';
import 'animated_goal_chart.dart';
import 'modern_goal_icons.dart';

/// Виджет "6 Лестниц Целей" в стиле тетрис
class SixGoalsGrid extends ConsumerWidget {
  const SixGoalsGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = _getDemoGoals();
    
    return Scaffold(
      backgroundColor: PRIMETheme.bg,
      appBar: _buildAppBar(context),
      body: _buildBody(context, goals),
    );
  }

  /// Верхняя панель
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: PRIMETheme.bg,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: PRIMETheme.sand, size: 24),
      ),
      title: Text(
        'МОИ ЦЕЛИ',
        style: GoogleFonts.robotoSlab(
          color: PRIMETheme.sand,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () => _showOverallStats(context),
          icon: const Icon(Icons.analytics_outlined, color: PRIMETheme.sand, size: 24),
        ),
      ],
    );
  }

  /// Основное содержимое
  Widget _buildBody(BuildContext context, List<Goal> goals) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Общая статистика
          _buildOverallProgressCard(goals),
          
          const SizedBox(height: 20),
          
          // Сетка целей 2x3
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75, // Увеличенное соотношение для больших графиков
              ),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                return _GoalCard(
                  goal: goals[index],
                  onTap: () => _showGoalDetails(context, goals[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Карта общего прогресса
  Widget _buildOverallProgressCard(List<Goal> goals) {
    final overallProgress = goals.fold(0.0, (sum, goal) => sum + goal.progressPercent) / goals.length;
    final completedGoals = goals.where((goal) => goal.progressPercent >= 1.0).length;
    final totalDays = goals.fold(0, (sum, goal) => sum + goal.daysPassed) ~/ goals.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PRIMETheme.line,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.sandWeak.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Общий прогресс
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ОБЩИЙ ПРОГРЕСС',
                  style: GoogleFonts.jetBrainsMono(
                    color: PRIMETheme.sandWeak,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(overallProgress * 100).toInt()}%',
                  style: GoogleFonts.jetBrainsMono(
                    color: PRIMETheme.sand,
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Статистика
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completedGoals/6 ЗАВЕРШЕНО',
                style: GoogleFonts.jetBrainsMono(
                  color: PRIMETheme.sand,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalDays ДНЕЙ В СРЕДНЕМ',
                style: GoogleFonts.jetBrainsMono(
                  color: PRIMETheme.sandWeak,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Показать общую статистику
  void _showOverallStats(BuildContext context) {
    final goals = _getDemoGoals();
    showDialog(
      context: context,
      builder: (context) => _OverallStatsDialog(goals: goals),
    );
  }

  /// Показать детали цели
  void _showGoalDetails(BuildContext context, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => _GoalDetailsDialog(goal: goal),
    );
  }

  /// Получить демо-данные целей с графиками
  List<Goal> _getDemoGoals() {
    return GoPRIMEctory.getDefaultGoalsWithDemoData();
  }
}

/// Карточка цели в стиле тетрис
class _GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;

  const _GoalCard({
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: PRIMETheme.line,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: goal.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Заголовок с современными минималистичными иконками и названием
            Row(
              children: [
                ModernGoalIcons.getIconWidget(
                  goalId: goal.id,
                  color: goal.color,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.name,
                    style: GoogleFonts.robotoSlab(
                      color: PRIMETheme.sand,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // 2. Текущее значение и цель
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    goal.formattedCurrentValue,
                    style: GoogleFonts.jetBrainsMono(
                      color: PRIMETheme.sand,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    'из ${goal.formattedTargetValue}',
                    style: GoogleFonts.jetBrainsMono(
                      color: PRIMETheme.sandWeak,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // 3. Тетрис-индикаторы
            AnimatedTetrisProgressBar(goal: goal),
            
            const SizedBox(height: 12),
            
            // 4. Линейный график (увеличенного размера)
            SizedBox(
              height: 75,
              child: AnimatedGoalChart(goal: goal),
            ),
            
            const Spacer(),
            
            // 5. Подмодули: Дни и процент как выделенные контейнеры
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Подмодуль "Дни"
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PRIMETheme.bg.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: PRIMETheme.sandWeak.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${goal.daysPassed} дней',
                      style: GoogleFonts.jetBrainsMono(
                        color: PRIMETheme.sandWeak,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Подмодуль "Процент"
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: goal.color.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '${(goal.progressPercent * 100).toInt()}%',
                      style: GoogleFonts.jetBrainsMono(
                        color: goal.color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

/// Диалог деталей цели
class _GoalDetailsDialog extends StatelessWidget {
  final Goal goal;

  const _GoalDetailsDialog({required this.goal});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PRIMETheme.line,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                ModernGoalIcons.getIconWidget(
                  goalId: goal.id,
                  color: goal.color,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    goal.name,
                    style: GoogleFonts.robotoSlab(
                      color: PRIMETheme.sand,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Основные метрики
            _DetailRow('Текущее значение:', goal.formattedCurrentValue),
            _DetailRow('Целевое значение:', goal.formattedTargetValue),
            _DetailRow('Осталось:', goal.formattedRemainingValue),
            _DetailRow('Прогресс:', '${(goal.progressPercent * 100).toInt()}%'),
            _DetailRow('Дней прошло:', '${goal.daysPassed}'),
            
            const SizedBox(height: 20),
            
            // Большой прогресс-бар
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: PRIMETheme.bg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: goal.color.withOpacity(0.4)),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: goal.progressPercent,
                child: Container(
                  decoration: BoxDecoration(
                    color: goal.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Кнопка закрыть
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: goal.color,
                  foregroundColor: PRIMETheme.bg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'ЗАКРЫТЬ',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Диалог общей статистики
class _OverallStatsDialog extends StatelessWidget {
  final List<Goal> goals;

  const _OverallStatsDialog({required this.goals});

  @override
  Widget build(BuildContext context) {
    final overallProgress = goals.fold(0.0, (sum, goal) => sum + goal.progressPercent) / goals.length;
    final completedGoals = goals.where((goal) => goal.progressPercent >= 1.0).length;
    final totalDays = goals.fold(0, (sum, goal) => sum + goal.daysPassed);
    final avgDays = totalDays ~/ goals.length;

    return Dialog(
      backgroundColor: PRIMETheme.line,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              'ОБЩАЯ СТАТИСТИКА',
              style: GoogleFonts.robotoSlab(
                color: PRIMETheme.sand,
                fontSize: 20,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Основные показатели
            _DetailRow('Общий прогресс:', '${(overallProgress * 100).toInt()}%'),
            _DetailRow('Завершенных целей:', '$completedGoals из ${goals.length}'),
            _DetailRow('Средний период:', '$avgDays дней'),
            _DetailRow('Общий период:', '$totalDays дней'),
            
            const SizedBox(height: 16),
            const Divider(color: PRIMETheme.sandWeak),
            const SizedBox(height: 16),
            
            // Список по прогрессу
            Text(
              'ПО ПРОГРЕССУ',
              style: GoogleFonts.robotoSlab(
                color: PRIMETheme.sand,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            
            ...goals
                .map((goal) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          ModernGoalIcons.getIconWidget(
                            goalId: goal.id,
                            color: goal.color,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              goal.name,
                              style: GoogleFonts.jetBrainsMono(
                                color: PRIMETheme.sandWeak,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Text(
                            '${(goal.progressPercent * 100).toInt()}%',
                            style: GoogleFonts.jetBrainsMono(
                              color: goal.color,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ))
                ,
            
            const SizedBox(height: 24),
            
            // Кнопка закрыть
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMETheme.primary,
                  foregroundColor: PRIMETheme.sand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'ЗАКРЫТЬ',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Строка деталей
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: PRIMETheme.sandWeak,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: PRIMETheme.sand,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
