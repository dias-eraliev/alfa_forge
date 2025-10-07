import 'exercise_model.dart';

class WorkoutSession {
  final String id;
  final DateTime startTime;
  final DateTime? endTime;
  final List<ExercisePlan> exercises;
  final WorkoutStatus status;
  final int totalRepsCompleted;
  final double averageQuality;
  final Duration duration;

  const WorkoutSession({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.exercises,
    required this.status,
    this.totalRepsCompleted = 0,
    this.averageQuality = 0.0,
    this.duration = Duration.zero,
  });

  WorkoutSession copyWith({
    String? id,
    DateTime? startTime,
    DateTime? endTime,
    List<ExercisePlan>? exercises,
    WorkoutStatus? status,
    int? totalRepsCompleted,
    double? averageQuality,
    Duration? duration,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      exercises: exercises ?? this.exercises,
      status: status ?? this.status,
      totalRepsCompleted: totalRepsCompleted ?? this.totalRepsCompleted,
      averageQuality: averageQuality ?? this.averageQuality,
      duration: duration ?? this.duration,
    );
  }

  // Геттеры для аналитики
  int get totalTargetReps => exercises.fold(0, (sum, ex) => sum + ex.targetReps);
  
  double get completionPercentage => 
    totalTargetReps > 0 ? (totalRepsCompleted / totalTargetReps) * 100 : 0;
  
  bool get isCompleted => exercises.every((ex) => ex.isCompleted);
  
  String get durationFormatted {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    
    if (hours > 0) {
      return '$hoursч $minutesм $secondsс';
    } else if (minutes > 0) {
      return '$minutesм $secondsс';
    } else {
      return '$secondsс';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'exercises': exercises.map((e) => {
        'exerciseId': e.exerciseId,
        'targetReps': e.targetReps,
        'completedReps': e.completedReps,
        'averageQuality': e.averageQuality,
        'completed': e.completed,
      }).toList(),
      'status': status.name,
      'totalRepsCompleted': totalRepsCompleted,
      'averageQuality': averageQuality,
      'durationInSeconds': duration.inSeconds,
    };
  }

  factory WorkoutSession.fromJson(Map<String, dynamic> json) {
    return WorkoutSession(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      exercises: (json['exercises'] as List).map((e) => ExercisePlan(
        exerciseId: e['exerciseId'],
        targetReps: e['targetReps'],
        completedReps: e['completedReps'] ?? 0,
        averageQuality: e['averageQuality'] ?? 0.0,
        completed: e['completed'] ?? false,
      )).toList(),
      status: WorkoutStatus.values.firstWhere((s) => s.name == json['status']),
      totalRepsCompleted: json['totalRepsCompleted'] ?? 0,
      averageQuality: json['averageQuality'] ?? 0.0,
      duration: Duration(seconds: json['durationInSeconds'] ?? 0),
    );
  }
}

enum WorkoutStatus {
  planning,    // Планирование тренировки
  inProgress,  // Выполняется
  paused,      // На паузе
  completed,   // Завершена
  cancelled,   // Отменена
}

extension WorkoutStatusExtension on WorkoutStatus {
  String get displayName {
    switch (this) {
      case WorkoutStatus.planning:
        return 'Планирование';
      case WorkoutStatus.inProgress:
        return 'В процессе';
      case WorkoutStatus.paused:
        return 'Пауза';
      case WorkoutStatus.completed:
        return 'Завершена';
      case WorkoutStatus.cancelled:
        return 'Отменена';
    }
  }

  String get emoji {
    switch (this) {
      case WorkoutStatus.planning:
        return '📋';
      case WorkoutStatus.inProgress:
        return '🏃‍♂️';
      case WorkoutStatus.paused:
        return '⏸️';
      case WorkoutStatus.completed:
        return '✅';
      case WorkoutStatus.cancelled:
        return '❌';
    }
  }
}
