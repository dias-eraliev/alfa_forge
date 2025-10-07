import 'dart:math' as math;
import 'base_exercise_detector.dart';
import '../pose/pose_models.dart';
import '../models/exercise_model.dart';

/// Детектор приседаний.
/// Основной сигнал: угол колена (бедро - колено - голеностоп).
/// Фазы:
///  - top (стоя) : kneeAngle >= topAngleThreshold
///  - descending : движение вниз
///  - bottom : kneeAngle <= bottomAngleThreshold
///  - ascending : движение вверх
/// Повтор засчитывается при возвращении в фазу top после фиксации bottom.
class SquatDetector extends ExerciseDetector {
  SquatDetector() : super(ExerciseType.squats);

  final double topAngleThreshold = 165;     // почти выпрямленная нога
  final double bottomAngleThreshold = 90;   // глубина приседа
  final double minRangeForValidRep = 50;    // минимальная амплитуда угла
  final double minBottomHoldMs = 120;       // минимальное пребывание внизу

  double _repMinAngle = 999;
  double _repMaxAngle = 0;
  bool _wasAtBottom = false;
  DateTime? _bottomReachedAt;

  @override
  void onReset() {
    _repMinAngle = 999;
    _repMaxAngle = 0;
    _wasAtBottom = false;
    _bottomReachedAt = null;
  }

  @override
  bool processFrame(PoseFrame frame) {
    // Нужны точки: бедро, колено, голеностоп (обе ноги — возьмем среднее)
    final lk = frame.byType(PosePointType.leftKnee);
    final rk = frame.byType(PosePointType.rightKnee);
    if ([lk, rk].any((p) => (p?.isReliable ?? false) == false)) {
      feedback = 'Ноги в кадр';
      formScore = 0;
      return false;
    }

    final leftKneeAngle = DetectorMath.angle(
      frame,
      PosePointType.leftHip,
      PosePointType.leftKnee,
      PosePointType.leftAnkle,
    );
    final rightKneeAngle = DetectorMath.angle(
      frame,
      PosePointType.rightHip,
      PosePointType.rightKnee,
      PosePointType.rightAnkle,
    );
    double? kneeAngle;
    if (leftKneeAngle != null && rightKneeAngle != null) {
      kneeAngle = (leftKneeAngle + rightKneeAngle) / 2;
    } else {
      kneeAngle = leftKneeAngle ?? rightKneeAngle;
    }

    if (kneeAngle == null) {
      feedback = 'Не вижу колени';
      formScore = 0;
      return false;
    }

    keyAngles['knee'] = kneeAngle;

    // Амплитуда
    _repMinAngle = math.min(_repMinAngle, kneeAngle);
    _repMaxAngle = math.max(_repMaxAngle, kneeAngle);

    // Определяем фазу
    switch (phase) {
      case ExercisePhase.positioning:
      case ExercisePhase.ready:
      case ExercisePhase.top:
        if (kneeAngle < topAngleThreshold - 5) {
          phase = ExercisePhase.descending;
        } else {
          phase = ExercisePhase.top;
        }
        break;
      case ExercisePhase.descending:
        if (kneeAngle <= bottomAngleThreshold) {
          phase = ExercisePhase.bottom;
          _wasAtBottom = true;
          _bottomReachedAt = DateTime.now();
        }
        break;
      case ExercisePhase.bottom:
        // Ждем минимальное время внизу для стабильности
        final heldLongEnough = _bottomReachedAt != null &&
            DateTime.now().difference(_bottomReachedAt!).inMilliseconds >=
                minBottomHoldMs;
        if (kneeAngle > bottomAngleThreshold + 8 && heldLongEnough) {
          phase = ExercisePhase.ascending;
        }
        break;
      case ExercisePhase.ascending:
        if (kneeAngle >= topAngleThreshold) {
          phase = ExercisePhase.top;
        }
        break;
      default:
        break;
    }

    bool repCompleted = false;
    if (_wasAtBottom && phase == ExercisePhase.top) {
      final amplitude = _repMaxAngle - _repMinAngle;
      if (amplitude >= minRangeForValidRep &&
          _repMinAngle <= bottomAngleThreshold + 8) {
        totalReps += 1;
        repCompleted = true;
      }
      _repMinAngle = 999;
      _repMaxAngle = 0;
      _wasAtBottom = false;
      _bottomReachedAt = null;
    }

    // Оценка формы (простая):
    //  - depthScore: глубина (чем ниже — тем лучше, до предела)
    //  - symmetryScore: разница между левым и правым коленом (если доступны)
    final depthScore = kneeAngle <= bottomAngleThreshold
        ? 100
        : (1 -
                (kneeAngle - bottomAngleThreshold) /
                    (topAngleThreshold - bottomAngleThreshold))
            .clamp(0, 1) *
            100;

    double symmetryScore = 100;
    if (leftKneeAngle != null &&
        rightKneeAngle != null &&
        leftKneeAngle > 0 &&
        rightKneeAngle > 0) {
      final diff = (leftKneeAngle - rightKneeAngle).abs();
      // diff 0..20 -> 100..50
      symmetryScore = (1 - (diff / 40).clamp(0, 1)) * 100;
    }

    formScore = (depthScore * 0.65 + symmetryScore * 0.35).clamp(0, 100);

    // Feedback
    if (formScore < 50) {
      feedback = 'Глубже и ровнее';
    } else if (phase == ExercisePhase.descending) {
      feedback = 'Контролируй вниз';
    } else if (phase == ExercisePhase.ascending) {
      feedback = 'Вверх толкайся!';
    } else if (phase == ExercisePhase.bottom) {
      feedback = 'Глубина есть';
    } else {
      feedback = 'Отлично!';
    }

    return repCompleted;
  }
}
