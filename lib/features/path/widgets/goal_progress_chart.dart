import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/goal_model.dart';
import '../../../app/theme.dart';

/// Виджет линейного графика прогресса цели
class GoalProgressChart extends StatelessWidget {
  final Goal goal;
  final double height;
  final int days;

  const GoalProgressChart({
    super.key,
    required this.goal,
    this.height = 80,
    this.days = 7,
  });

  @override
  Widget build(BuildContext context) {
    final graphData = goal.getGraphData(days: days);
    
    if (graphData.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: LineChart(
        _buildLineChartData(graphData),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: PRIMETheme.sand.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          'НЕТ ДАННЫХ',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 8,
            color: PRIMETheme.sand.withOpacity(0.5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  LineChartData _buildLineChartData(List<DailyGoalValue> data) {
    // Преобразуем данные в точки для графика
    final spots = <FlSpot>[];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].value));
    }

    // Определяем цвет линии на основе цвета цели
    final Color lineColor = _parseHexColor(goal.colorHex);
    final Color gridColor = PRIMETheme.sand.withOpacity(0.1);

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        drawHorizontalLine: true,
        horizontalInterval: _calculateInterval(data),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: gridColor,
            strokeWidth: 0.5,
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
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: lineColor,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 2,
                color: lineColor,
                strokeWidth: 0,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: lineColor.withOpacity(0.1),
          ),
          shadow: Shadow(
            color: lineColor.withOpacity(0.3),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: false,
      ),
    );
  }

  /// Парсинг hex цвета в Color
  Color _parseHexColor(String hex) {
    try {
      final hexCode = hex.replaceAll('#', '');
      return Color(int.parse('FF$hexCode', radix: 16));
    } catch (e) {
      return PRIMETheme.primary; // Fallback цвет
    }
  }

  /// Вычисление интервала для сетки
  double _calculateInterval(List<DailyGoalValue> data) {
    if (data.length < 2) return 1.0;
    
    final values = data.map((d) => d.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    
    if (range <= 0) return 1.0;
    
    // Простая логика для интервала
    if (range <= 10) return 2.0;
    if (range <= 100) return 20.0;
    if (range <= 1000) return 200.0;
    return range / 5;
  }

  /// Получить минимальное Y значение с отступом
  double _getMinY(List<DailyGoalValue> data) {
    if (data.isEmpty) return 0;
    
    final values = data.map((d) => d.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    
    if (range <= 0) return min - 1;
    
    // Добавляем 10% отступа снизу
    return min - (range * 0.1);
  }

  /// Получить максимальное Y значение с отступом
  double _getMaxY(List<DailyGoalValue> data) {
    if (data.isEmpty) return 1;
    
    final values = data.map((d) => d.value).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    
    if (range <= 0) return max + 1;
    
    // Добавляем 10% отступа сверху
    return max + (range * 0.1);
  }
}

/// Компактный виджет графика для карточек целей
class CompactGoalChart extends StatelessWidget {
  final Goal goal;
  final double height;

  const CompactGoalChart({
    super.key,
    required this.goal,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: PRIMETheme.sand.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: GoalProgressChart(
          goal: goal,
          height: height - 2,
          days: 7,
        ),
      ),
    );
  }
}
