import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/goal_model.dart';
import '../../../app/theme.dart';

/// Анимированный компактный график прогресса цели с брутальным дизайном
class AnimatedGoalChart extends StatefulWidget {
  final Goal goal;
  final double height;

  const AnimatedGoalChart({
    super.key,
    required this.goal,
    this.height = 70,
  });

  @override
  State<AnimatedGoalChart> createState() => _AnimatedGoalChartState();
}

class _AnimatedGoalChartState extends State<AnimatedGoalChart>
    with TickerProviderStateMixin {
  late AnimationController _lineAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _lineAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Анимация появления линии
    _lineAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Анимация появления элементов
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _lineAnimation = CurvedAnimation(
      parent: _lineAnimationController,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeIn,
    );

    // Запускаем анимации с задержкой
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _lineAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _lineAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final graphData = widget.goal.getGraphData(days: 7);
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        height: widget.height,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: PRIMETheme.bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: widget.goal.color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: graphData.isEmpty
              ? _buildEmptyState()
              : _buildAnimatedChart(graphData),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            PRIMETheme.line,
            PRIMETheme.bg,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.goal.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'НЕТ ДАННЫХ',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 6,
                color: PRIMETheme.sand.withOpacity(0.4),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedChart(List<DailyGoalValue> data) {
    return AnimatedBuilder(
      animation: _lineAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                PRIMETheme.line,
                PRIMETheme.bg,
              ],
            ),
          ),
          child: LineChart(
            _buildLineChartData(data, _lineAnimation.value),
            duration: Duration.zero, // Отключаем встроенную анимацию
          ),
        );
      },
    );
  }

  LineChartData _buildLineChartData(List<DailyGoalValue> data, double animationProgress) {
    // Создаем точки с анимацией
    final spots = <FlSpot>[];
    final animatedDataCount = (data.length * animationProgress).ceil();
    
    for (int i = 0; i < animatedDataCount && i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].value));
    }

    // Если анимация еще не завершена, добавляем промежуточную точку
    if (animationProgress < 1.0 && animatedDataCount < data.length) {
      final progress = (data.length * animationProgress) % 1;
      if (animatedDataCount > 0 && animatedDataCount < data.length) {
        final currentValue = data[animatedDataCount - 1].value;
        final nextValue = data[animatedDataCount].value;
        final interpolatedValue = currentValue + (nextValue - currentValue) * progress;
        
        spots.add(FlSpot((animatedDataCount - 1 + progress).toDouble(), interpolatedValue));
      }
    }

    final lineColor = widget.goal.color;
    final glowColor = lineColor.withOpacity(0.6);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
        horizontalInterval: _calculateInterval(data),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: PRIMETheme.sand.withOpacity(0.05),
            strokeWidth: 0.5,
            dashArray: [2, 4],
          );
        },
      ),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (data.length - 1).toDouble(),
      minY: _getMinY(data),
      maxY: _getMaxY(data),
      lineBarsData: [
        // Основная линия
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.4,
          color: lineColor,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length > 1,
            getDotPainter: (spot, percent, barData, index) {
              // Анимированные точки
              final isLastPoint = index == spots.length - 1;
              final radius = isLastPoint ? 3.0 : 2.0;
              final opacity = isLastPoint ? 1.0 : 0.7;
              
              return FlDotCirclePainter(
                radius: radius,
                color: lineColor.withOpacity(opacity),
                strokeWidth: isLastPoint ? 2 : 0,
                strokeColor: PRIMETheme.bg,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                lineColor.withOpacity(0.15),
                lineColor.withOpacity(0.02),
              ],
            ),
          ),
          shadow: Shadow(
            color: lineColor.withOpacity(0.4),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ),
        // Светящийся эффект
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.4,
          color: glowColor,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(enabled: false),
    );
  }

  double _calculateInterval(List<DailyGoalValue> data) {
    if (data.length < 2) return 1.0;
    
    final values = data.map((d) => d.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    
    if (range <= 0) return 1.0;
    if (range <= 10) return 2.0;
    if (range <= 100) return 20.0;
    if (range <= 1000) return 200.0;
    return range / 3;
  }

  double _getMinY(List<DailyGoalValue> data) {
    if (data.isEmpty) return 0;
    
    final values = data.map((d) => d.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    
    if (range <= 0) return min - 1;
    return min - (range * 0.15);
  }

  double _getMaxY(List<DailyGoalValue> data) {
    if (data.isEmpty) return 1;
    
    final values = data.map((d) => d.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    
    if (range <= 0) return max + 1;
    return max + (range * 0.15);
  }
}

/// Анимированный тетрис-индикатор прогресса
class AnimatedTetrisProgressBar extends StatefulWidget {
  final Goal goal;
  final int totalBlocks;

  const AnimatedTetrisProgressBar({
    super.key,
    required this.goal,
    this.totalBlocks = 10,
  });

  @override
  State<AnimatedTetrisProgressBar> createState() => _AnimatedTetrisProgressBarState();
}

class _AnimatedTetrisProgressBarState extends State<AnimatedTetrisProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    // Запускаем анимацию после небольшой задержки
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _progressController.forward();
      }
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final animatedProgress = widget.goal.progressPercent * _progressAnimation.value;
        final completedBlocks = (animatedProgress * widget.totalBlocks).round();
        
        return SizedBox(
          height: 20,
          child: Row(
            children: List.generate(widget.totalBlocks, (index) {
              final isCompleted = index < completedBlocks;
              final delay = index * 0.1;
              
              return Expanded(
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0.0,
                    end: isCompleted ? 1.0 : 0.0,
                  ),
                  duration: Duration(milliseconds: (200 + delay * 100).round()),
                  curve: Curves.elasticOut,
                  builder: (context, animValue, child) {
                    return Container(
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? widget.goal.color.withOpacity(0.7 + animValue * 0.3)
                            : PRIMETheme.bg,
                        borderRadius: BorderRadius.circular(1),
                        border: Border.all(
                          color: widget.goal.color.withOpacity(0.4),
                          width: 1,
                        ),
                        boxShadow: isCompleted && animValue > 0.5
                            ? [
                                BoxShadow(
                                  color: widget.goal.color.withOpacity(0.3 * animValue),
                                  blurRadius: 2,
                                  spreadRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      transform: Matrix4.identity()
                        ..scale(0.8 + animValue * 0.2)
                        ..translate(0.0, (1 - animValue) * 5),
                    );
                  },
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
