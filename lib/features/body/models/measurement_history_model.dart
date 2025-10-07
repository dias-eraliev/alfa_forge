import 'package:flutter/material.dart';
import 'measurement_model.dart';

enum HistoryPeriod {
  week('week', 'Неделя', 7),
  month('month', 'Месяц', 30),
  quarter('quarter', 'Квартал', 90),
  year('year', 'Год', 365),
  all('all', 'Все время', 0);

  const HistoryPeriod(this.id, this.name, this.days);
  
  final String id;
  final String name;
  final int days;
}

enum TrendDirection {
  up('up', 'Рост', Icons.trending_up, Color(0xFF4CAF50)),
  down('down', 'Снижение', Icons.trending_down, Color(0xFF2196F3)),
  stable('stable', 'Стабильно', Icons.trending_flat, Color(0xFF9E9E9E));

  const TrendDirection(this.id, this.name, this.icon, this.color);
  
  final String id;
  final String name;
  final IconData icon;
  final Color color;
}

class MeasurementStatistics {
  final String typeId;
  final double? minValue;
  final double? maxValue;
  final double? avgValue;
  final double? currentValue;
  final double? previousValue;
  final double? changeAmount;
  final double? changePercent;
  final TrendDirection trend;
  final int totalMeasurements;
  final DateTime? firstMeasurement;
  final DateTime? lastMeasurement;

  MeasurementStatistics({
    required this.typeId,
    this.minValue,
    this.maxValue,
    this.avgValue,
    this.currentValue,
    this.previousValue,
    this.changeAmount,
    this.changePercent,
    required this.trend,
    required this.totalMeasurements,
    this.firstMeasurement,
    this.lastMeasurement,
  });

  factory MeasurementStatistics.fromMeasurements(
    String typeId,
    List<BodyMeasurement> measurements,
  ) {
    if (measurements.isEmpty) {
      return MeasurementStatistics(
        typeId: typeId,
        trend: TrendDirection.stable,
        totalMeasurements: 0,
      );
    }

    // Сортируем по дате
    final sortedMeasurements = List<BodyMeasurement>.from(measurements)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final values = sortedMeasurements.map((m) => m.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final avgValue = values.reduce((a, b) => a + b) / values.length;
    
    final currentValue = sortedMeasurements.last.value;
    final previousValue = sortedMeasurements.length > 1 
        ? sortedMeasurements[sortedMeasurements.length - 2].value
        : null;

    double? changeAmount;
    double? changePercent;
    TrendDirection trend = TrendDirection.stable;

    if (previousValue != null) {
      changeAmount = currentValue - previousValue;
      changePercent = (changeAmount / previousValue) * 100;
      
      if (changeAmount > 0.1) {
        trend = TrendDirection.up;
      } else if (changeAmount < -0.1) {
        trend = TrendDirection.down;
      }
    }

    return MeasurementStatistics(
      typeId: typeId,
      minValue: minValue,
      maxValue: maxValue,
      avgValue: avgValue,
      currentValue: currentValue,
      previousValue: previousValue,
      changeAmount: changeAmount,
      changePercent: changePercent,
      trend: trend,
      totalMeasurements: measurements.length,
      firstMeasurement: sortedMeasurements.first.timestamp,
      lastMeasurement: sortedMeasurements.last.timestamp,
    );
  }

  String getChangeText(MeasurementUnit unit) {
    if (changeAmount == null) return 'Нет данных';
    
    final sign = changeAmount! >= 0 ? '+' : '';
    return '$sign${changeAmount!.toStringAsFixed(1)}${unit.symbol}';
  }

  String getChangePercentText() {
    if (changePercent == null) return '';
    
    final sign = changePercent! >= 0 ? '+' : '';
    return '($sign${changePercent!.toStringAsFixed(1)}%)';
  }
}

class MeasurementHistory {
  final Map<String, List<BodyMeasurement>> measurementsByType;
  final Map<String, MeasurementStatistics> statistics;
  final DateTime startDate;
  final DateTime endDate;

  MeasurementHistory({
    required this.measurementsByType,
    required this.statistics,
    required this.startDate,
    required this.endDate,
  });

  factory MeasurementHistory.fromMeasurements(
    List<BodyMeasurement> allMeasurements,
    HistoryPeriod period,
  ) {
    final now = DateTime.now();
    final startDate = period == HistoryPeriod.all 
        ? allMeasurements.isNotEmpty 
            ? allMeasurements.map((m) => m.timestamp).reduce((a, b) => a.isBefore(b) ? a : b)
            : now
        : now.subtract(Duration(days: period.days));

    // Фильтруем по периоду
    final filteredMeasurements = allMeasurements
        .where((m) => m.timestamp.isAfter(startDate))
        .toList();

    // Группируем по типам
    final measurementsByType = <String, List<BodyMeasurement>>{};
    for (final measurement in filteredMeasurements) {
      measurementsByType.putIfAbsent(measurement.typeId, () => []).add(measurement);
    }

    // Создаем статистику для каждого типа
    final statistics = <String, MeasurementStatistics>{};
    for (final entry in measurementsByType.entries) {
      statistics[entry.key] = MeasurementStatistics.fromMeasurements(
        entry.key,
        entry.value,
      );
    }

    return MeasurementHistory(
      measurementsByType: measurementsByType,
      statistics: statistics,
      startDate: startDate,
      endDate: now,
    );
  }

  List<BodyMeasurement> getAllMeasurements() {
    final allMeasurements = <BodyMeasurement>[];
    for (final measurements in measurementsByType.values) {
      allMeasurements.addAll(measurements);
    }
    allMeasurements.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return allMeasurements;
  }

  List<String> getActiveMeasurementTypes() {
    return measurementsByType.keys.toList();
  }

  MeasurementStatistics? getStatisticsForType(String typeId) {
    return statistics[typeId];
  }

  List<BodyMeasurement> getMeasurementsForType(String typeId) {
    return measurementsByType[typeId] ?? [];
  }

  int getTotalMeasurements() {
    return measurementsByType.values
        .map((measurements) => measurements.length)
        .fold(0, (sum, count) => sum + count);
  }

  List<DateTime> getUniqueMeasurementDates() {
    final dates = <DateTime>{};
    for (final measurements in measurementsByType.values) {
      for (final measurement in measurements) {
        final date = DateTime(
          measurement.timestamp.year,
          measurement.timestamp.month,
          measurement.timestamp.day,
        );
        dates.add(date);
      }
    }
    final sortedDates = dates.toList()..sort();
    return sortedDates;
  }

  Map<DateTime, List<BodyMeasurement>> getMeasurementsByDate() {
    final measurementsByDate = <DateTime, List<BodyMeasurement>>{};
    
    for (final measurements in measurementsByType.values) {
      for (final measurement in measurements) {
        final date = DateTime(
          measurement.timestamp.year,
          measurement.timestamp.month,
          measurement.timestamp.day,
        );
        measurementsByDate.putIfAbsent(date, () => []).add(measurement);
      }
    }
    
    return measurementsByDate;
  }
}

class HistoryFilter {
  final Set<String> selectedTypes;
  final HistoryPeriod period;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String? searchQuery;

  HistoryFilter({
    this.selectedTypes = const {},
    this.period = HistoryPeriod.month,
    this.customStartDate,
    this.customEndDate,
    this.searchQuery,
  });

  HistoryFilter copyWith({
    Set<String>? selectedTypes,
    HistoryPeriod? period,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? searchQuery,
  }) {
    return HistoryFilter(
      selectedTypes: selectedTypes ?? this.selectedTypes,
      period: period ?? this.period,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool isActive() {
    return selectedTypes.isNotEmpty ||
           period != HistoryPeriod.month ||
           customStartDate != null ||
           customEndDate != null ||
           (searchQuery?.isNotEmpty ?? false);
  }
}

// Генератор тестовых данных для истории
class MockMeasurementData {
  static List<BodyMeasurement> generateMockHistory() {
    final now = DateTime.now();
    final measurements = <BodyMeasurement>[];
    
    // Генерируем данные за последние 3 месяца
    for (int days = 90; days >= 0; days -= 7) {
      final date = now.subtract(Duration(days: days));
      
      // Вес - постепенное снижение
      measurements.add(BodyMeasurement.create(
        typeId: 'weight',
        value: 79.5 - (90 - days) * 0.02 + (days % 14 - 7) * 0.1,
      ).copyWith(timestamp: date));
      
      // Процент жира - снижение
      measurements.add(BodyMeasurement.create(
        typeId: 'body_fat',
        value: 16.2 - (90 - days) * 0.01,
      ).copyWith(timestamp: date));
      
      // Мышечная масса - рост
      measurements.add(BodyMeasurement.create(
        typeId: 'muscle_mass',
        value: 67.0 + (90 - days) * 0.015,
      ).copyWith(timestamp: date));
      
      // Талия - уменьшение
      if (days % 14 == 0) {
        measurements.add(BodyMeasurement.create(
          typeId: 'waist',
          value: 85.0 - (90 - days) * 0.03,
        ).copyWith(timestamp: date));
      }
      
      // Грудь - рост мышц
      if (days % 21 == 0) {
        measurements.add(BodyMeasurement.create(
          typeId: 'chest',
          value: 101.5 + (90 - days) * 0.02,
        ).copyWith(timestamp: date));
      }
      
      // Пульс в покое
      if (days % 7 == 0) {
        measurements.add(BodyMeasurement.create(
          typeId: 'heart_rate',
          value: 75.0 - (90 - days) * 0.05,
        ).copyWith(timestamp: date.add(const Duration(hours: 8))));
      }
    }
    
    return measurements;
  }

  static List<BodyMeasurement> generateRecentMeasurements() {
    final now = DateTime.now();
    return [
      BodyMeasurement.create(
        typeId: 'weight',
        value: 78.2,
        notes: 'Утреннее взвешивание',
        conditions: {'time_of_day': 'morning', 'clothing': 'underwear'},
        confidence: 0.95,
      ).copyWith(timestamp: now.subtract(const Duration(hours: 2))),
      
      BodyMeasurement.create(
        typeId: 'body_fat',
        value: 14.8,
        notes: 'Измерение на весах с биоимпедансом',
        confidence: 0.85,
      ).copyWith(timestamp: now.subtract(const Duration(hours: 2))),
      
      BodyMeasurement.create(
        typeId: 'waist',
        value: 82.5,
        notes: 'После тренировки',
        conditions: {'body_state': 'after_workout'},
        confidence: 0.9,
      ).copyWith(timestamp: now.subtract(const Duration(days: 1))),
    ];
  }
}
