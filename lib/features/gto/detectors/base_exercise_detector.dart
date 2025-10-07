// Base abstractions for exercise-specific detection logic driven by PoseFrame.
// Each ExerciseDetector implements a finite-state machine (FSM) that inspects
// pose landmarks and emits phase transitions + rep increments with hysteresis.
//
// This layer is independent from camera / backend specifics. It only consumes
// normalized PoseFrame (see pose_models.dart).
//
// NEXT: implement concrete detectors (see pushup_detector.dart).
import 'dart:math' as math;
import '../pose/pose_models.dart';
import '../models/exercise_model.dart';

/// Унифицированные фазы (общий супермножество).
/// Конкретный детектор может использовать подмножество.
enum ExercisePhase {
  unknown,
  positioning,
  ready,
  top,            // pushups/squats top
  bottom,         // pushups/squats bottom
  descending,
  ascending,
  open,           // jumping jacks open
  closed,         // jumping jacks closed
  hold,           // plank hold
  transition,
}

/// Результат одного вызова update().
class ExerciseDetectionOutput {
  final ExercisePhase phase;
  final bool repCompleted;
  final int totalReps;
  final double formScore;                // 0..100
  final Map<String, double> keyAngles;   // debug углы
  final String feedback;                 // короткая подсказка
  final bool lostTracking;               // потеря позы
  final bool stableTracking;             // хорошая видимость
  final int droppedFrames;               // пропущено для логики (если throttle внутри детектора)
  final Duration elapsed;                // с начала детектора

  const ExerciseDetectionOutput({
    required this.phase,
    required this.repCompleted,
    required this.totalReps,
    required this.formScore,
    required this.keyAngles,
    required this.feedback,
    required this.lostTracking,
    required this.stableTracking,
    required this.droppedFrames,
    required this.elapsed,
  });

  ExerciseDetectionOutput copyWith({
    ExercisePhase? phase,
    bool? repCompleted,
    int? totalReps,
    double? formScore,
    Map<String, double>? keyAngles,
    String? feedback,
    bool? lostTracking,
    bool? stableTracking,
    int? droppedFrames,
    Duration? elapsed,
  }) {
    return ExerciseDetectionOutput(
      phase: phase ?? this.phase,
      repCompleted: repCompleted ?? this.repCompleted,
      totalReps: totalReps ?? this.totalReps,
      formScore: formScore ?? this.formScore,
      keyAngles: keyAngles ?? this.keyAngles,
      feedback: feedback ?? this.feedback,
      lostTracking: lostTracking ?? this.lostTracking,
      stableTracking: stableTracking ?? this.stableTracking,
      droppedFrames: droppedFrames ?? this.droppedFrames,
      elapsed: elapsed ?? this.elapsed,
    );
  }

  static ExerciseDetectionOutput initial() => const ExerciseDetectionOutput(
        phase: ExercisePhase.positioning,
        repCompleted: false,
        totalReps: 0,
        formScore: 0,
        keyAngles: {},
        feedback: 'Позиционирование...',
        lostTracking: true,
        stableTracking: false,
        droppedFrames: 0,
        elapsed: Duration.zero,
      );
}

/// Базовый интерфейс детектора.
abstract class ExerciseDetector {
  final ExerciseTypeId typeId;
  final DateTime _startTime = DateTime.now();
  int totalReps = 0;

  ExercisePhase phase = ExercisePhase.positioning;
  bool _lostTracking = true;
  bool _stableTracking = false;

  // Отладка
  final Map<String, double> keyAngles = {};
  double formScore = 0;
  String feedback = '';

  int droppedFrames = 0;

  ExerciseDetector(this.typeId);

  /// Сброс к начальному состоянию.
  void reset() {
    totalReps = 0;
    phase = ExercisePhase.positioning;
    _lostTracking = true;
    _stableTracking = false;
    keyAngles.clear();
    formScore = 0;
    feedback = 'Позиционирование...';
    droppedFrames = 0;
    onReset();
  }

  /// Позволяет подклассу очистить свои внутренние FSM поля.
  void onReset();

  /// Обновляет FSM.
  ///
  /// Возвращает ExerciseDetectionOutput. Реализация должна:
  ///  * Проверить достаточность ключевых точек (иначе lostTracking)
  ///  * Обновить фазу / выполнить переходы
  ///  * Рассчитать formScore / feedback
  ///  * Отметить repCompleted при полном цикле
  ExerciseDetectionOutput update(PoseFrame frame) {
    final now = DateTime.now();
    final elapsed = now.difference(_startTime);

    final visibility = frame.visibilityScore;
    _lostTracking = visibility < trackingLostVisibilityThreshold;
    _stableTracking = visibility >= stableVisibilityThreshold;

    if (_lostTracking) {
      feedback = 'Выйдите в полный кадр';
      formScore = 0;
      return _buildOutput(repCompleted: false, elapsed: elapsed);
    }

    // Делегируем конкретной реализации.
    final repCompleted = processFrame(frame);

    return _buildOutput(repCompleted: repCompleted, elapsed: elapsed);
  }

  /// Реализация конкретной логики (должна:
  /// - обновить phase
  /// - обновить formScore, feedback
  /// - при завершении повтора увеличить totalReps и вернуть true)
  bool processFrame(PoseFrame frame);

  ExerciseDetectionOutput _buildOutput({
    required bool repCompleted,
    required Duration elapsed,
  }) {
    return ExerciseDetectionOutput(
      phase: phase,
      repCompleted: repCompleted,
      totalReps: totalReps,
      formScore: formScore.clamp(0, 100),
      keyAngles: Map.unmodifiable(keyAngles),
      feedback: feedback,
      lostTracking: _lostTracking,
      stableTracking: _stableTracking,
      droppedFrames: droppedFrames,
      elapsed: elapsed,
    );
  }

  // Пороговые значения (можно вынести позже в конфиги)
  double get trackingLostVisibilityThreshold => 0.15;
  double get stableVisibilityThreshold => 0.35;
}

/// Упрощённый тип для идентификации детектора (используем строки из ExerciseType).
typedef ExerciseTypeId = String;

/// Утилиты для детекторов
class DetectorMath {
  static double? angle(
    PoseFrame frame,
    PosePointType a,
    PosePointType b,
    PosePointType c,
  ) {
    return PoseMath.jointAngle(
      frame.byType(a),
      frame.byType(b),
      frame.byType(c),
    );
  }

  static double? distance(
    PoseFrame frame,
    PosePointType a,
    PosePointType b,
  ) {
    return PoseMath.distance(
      frame.byType(a),
      frame.byType(b),
    );
  }

  /// Оценка прямой линии между плечем-бедром-лодыжкой (чем ближе к 180 тем лучше)
  static double? bodyStraightnessScore(PoseFrame frame, bool left) {
    final shoulder = frame.byType(
        left ? PosePointType.leftShoulder : PosePointType.rightShoulder);
    final hip =
        frame.byType(left ? PosePointType.leftHip : PosePointType.rightHip);
    final ankle = frame.byType(
        left ? PosePointType.leftAnkle : PosePointType.rightAnkle);
    final angle = PoseMath.jointAngle(shoulder, hip, ankle);
    if (angle == null) return null;
    // 180 -> 1.0, 150 -> ~0.5
    return (1 - (180 - angle).abs() / 60).clamp(0, 1);
  }
}
