import 'dart:math' as math;
import 'base_exercise_detector.dart';
import '../pose/pose_models.dart';
import '../models/exercise_model.dart';

/// Детектор отжиманий:
/// Логика:
///  - Фазы top (локти разогнуты >= topAngleThreshold)
///  - Фаза descending при переходе вниз
///  - Фаза bottom (локти согнуты <= bottomAngleThreshold)
///  - Фаза ascending при движении вверх
/// Подсчет повтора: переход bottom -> ascending -> top
class PushUpDetector extends ExerciseDetector {
  PushUpDetector() : super(ExerciseType.pushups);

  // Гистерезис углов (средний угол локтя)
  final double topAngleThreshold = 155;
  final double bottomAngleThreshold = 80;
  final double minRangeForValidRep = 50; // Минимальная амплитуда

  double? _lastElbowAngle;
  bool _wasAtBottom = false;
  double _repMinAngle = 999;
  double _repMaxAngle = 0;

  @override
  void onReset() {
    _lastElbowAngle = null;
    _wasAtBottom = false;
    _repMinAngle = 999;
    _repMaxAngle = 0;
  }

  @override
  bool processFrame(PoseFrame frame) {
    // Проверяем минимальные ключевые точки (плечи/локти/запястья/бедра/щиколотки)
    final ls = frame.byType(PosePointType.leftShoulder);
    final rs = frame.byType(PosePointType.rightShoulder);
    final le = frame.byType(PosePointType.leftElbow);
    final re = frame.byType(PosePointType.rightElbow);
    final lw = frame.byType(PosePointType.leftWrist);
    final rw = frame.byType(PosePointType.rightWrist);
    final lh = frame.byType(PosePointType.leftHip);
    final rh = frame.byType(PosePointType.rightHip);
    final la = frame.byType(PosePointType.leftAnkle);
    final ra = frame.byType(PosePointType.rightAnkle);

    if ([ls, rs, le, re, lw, rw, lh, rh, la, ra].any((p) => p == null || !p.isReliable)) {
      feedback = 'Попробуйте в полный кадр / освещение';
      formScore = 0;
      return false;
    }

    // Угол локтя (усредним левый/правый)
    final leftElbowAngle = DetectorMath.angle(frame, PosePointType.leftShoulder, PosePointType.leftElbow, PosePointType.leftWrist);
    final rightElbowAngle = DetectorMath.angle(frame, PosePointType.rightShoulder, PosePointType.rightElbow, PosePointType.rightWrist);
    double? elbowAngle;
    if (leftElbowAngle != null && rightElbowAngle != null) {
      elbowAngle = (leftElbowAngle + rightElbowAngle) / 2;
    } else {
      elbowAngle = leftElbowAngle ?? rightElbowAngle;
    }

    if (elbowAngle == null) {
      feedback = 'Держите руки в кадре';
      formScore = 0;
      return false;
    }

    keyAngles['elbow'] = elbowAngle;

    // Обновляем экстремумы для амплитуды
    _repMinAngle = math.min(_repMinAngle, elbowAngle);
    _repMaxAngle = math.max(_repMaxAngle, elbowAngle);

    // Определяем фазу
    switch (phase) {
      case ExercisePhase.positioning:
      case ExercisePhase.ready:
      case ExercisePhase.top:
        if (elbowAngle < topAngleThreshold - 5) {
          phase = ExercisePhase.descending;
        } else {
          phase = ExercisePhase.top;
        }
        break;
      case ExercisePhase.descending:
        if (elbowAngle <= bottomAngleThreshold) {
          phase = ExercisePhase.bottom;
          _wasAtBottom = true;
        }
        break;
      case ExercisePhase.bottom:
        if (elbowAngle > bottomAngleThreshold + 10) {
          phase = ExercisePhase.ascending;
        }
        break;
      case ExercisePhase.ascending:
        if (elbowAngle >= topAngleThreshold) {
          phase = ExercisePhase.top;
        }
        break;
      default:
        // прочие фазы не используются
        break;
    }

    // Подсчет повтора
    bool repCompleted = false;
    if (_wasAtBottom && phase == ExercisePhase.top) {
      final amplitude = _repMaxAngle - _repMinAngle;
      if (amplitude >= minRangeForValidRep && _repMinAngle <= bottomAngleThreshold + 10) {
        totalReps += 1;
        repCompleted = true;
      }
      // Сброс диапазона на следующий цикл
      _repMinAngle = 999;
      _repMaxAngle = 0;
      _wasAtBottom = false;
    }

    // Оценка формы:
    final straightL = DetectorMath.bodyStraightnessScore(frame, true) ?? 0;
    final straightR = DetectorMath.bodyStraightnessScore(frame, false) ?? 0;
    final straightScore = ((straightL + straightR) / 2) * 100;

    // Нормализуем глубину: внизу (малый угол) 100, вверху 0
    final adjustedDepthScore = elbowAngle <= bottomAngleThreshold
        ? 100
        : (1 - (elbowAngle - bottomAngleThreshold) / (topAngleThreshold - bottomAngleThreshold))
            .clamp(0, 1) * 100;

    formScore = (straightScore * 0.55 + adjustedDepthScore * 0.45).clamp(0, 100);

    // Feedback
    if (straightScore < 70) {
      feedback = 'Корпус ровнее';
    } else if (phase == ExercisePhase.descending) {
      feedback = 'Вниз контролируй';
    } else if (phase == ExercisePhase.ascending) {
      feedback = 'Толкай вверх!';
    } else if (phase == ExercisePhase.bottom) {
      feedback = 'Глубоко — толкайся';
    } else {
      feedback = 'Отлично!';
    }

    _lastElbowAngle = elbowAngle;
    return repCompleted;
  }
}
