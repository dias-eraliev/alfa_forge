import 'dart:math' as math;
import 'base_exercise_detector.dart';
import '../pose/pose_models.dart';
import '../models/exercise_model.dart';

/// Детектор "Jumping Jacks" (прыжки звездочка).
/// Простая логика:
///  - closed: ноги вместе (малое расстояние между щиколотками), руки вниз (запястья ниже плеч)
///  - open: ноги врозь (большое расстояние), руки вверх (запястья выше головы / ушей)
/// Фазы используем: open / closed + ascending/descending для проходов, но можно
/// упростить до open/closed + переходы.
/// Повтор: closed -> open -> closed
class JumpingJacksDetector extends ExerciseDetector {
  JumpingJacksDetector() : super(ExerciseType.jumpingJacks);

  // Порог раскрытия ног (в доле ширины плеч или абсолюте по нормализованным координатам)
  final double minAnklesSpreadForOpen = 0.25; // нормализованная дистанция
  final double maxAnklesSpreadForClosed = 0.12;

  // Порог по рукам: запястья должны быть выше линии ушей / головы
  final double wristAboveHeadMargin = 0.02;

  bool _wasOpen = false;
  double _repMinSpread = 1;
  double _repMaxSpread = 0;

  @override
  void onReset() {
    _wasOpen = false;
    _repMinSpread = 1;
    _repMaxSpread = 0;
  }

  @override
  bool processFrame(PoseFrame frame) {
    final la = frame.byType(PosePointType.leftAnkle);
    final ra = frame.byType(PosePointType.rightAnkle);
    final lw = frame.byType(PosePointType.leftWrist);
    final rw = frame.byType(PosePointType.rightWrist);
    final nose = frame.byType(PosePointType.nose);
    final le = frame.byType(PosePointType.leftEar);
    final re = frame.byType(PosePointType.rightEar);

    // Требуем базовые точки
    if ([la, ra, lw, rw, nose].any((p) => (p?.isReliable ?? false) == false)) {
      feedback = 'В полный кадр / освещение';
      formScore = 0;
      return false;
    }

    // Расстояние между щиколотками (нормализованное)
    final spread = DetectorMath.distance(frame, PosePointType.leftAnkle, PosePointType.rightAnkle) ?? 0;
    _repMinSpread = math.min(_repMinSpread, spread);
    _repMaxSpread = math.max(_repMaxSpread, spread);
    keyAngles['spread'] = spread;

    // Определяем "руки вверх": wrists выше уровня ушей/головы (меньше y, т.к. (0,0) вверху)
    final headY = [
      if (nose != null) nose.y,
      if (le != null) le.y,
      if (re != null) re.y,
    ].whereType<double>().fold<double?>(null, (minY, y) => minY == null ? y : math.min(minY, y));

    bool armsUp = false;
    if (headY != null && lw != null && rw != null) {
      armsUp = lw.y < headY + wristAboveHeadMargin && rw.y < headY + wristAboveHeadMargin;
    }

    final isOpen = spread >= minAnklesSpreadForOpen && armsUp;
    final isClosed = spread <= maxAnklesSpreadForClosed && !armsUp;

    // FSM
    switch (phase) {
      case ExercisePhase.positioning:
      case ExercisePhase.ready:
      case ExercisePhase.closed:
        if (isOpen) {
          phase = ExercisePhase.open;
        } else {
          phase = ExercisePhase.closed;
        }
        break;
      case ExercisePhase.open:
        if (isClosed) {
          phase = ExercisePhase.closed;
        }
        break;
      default:
        // Используем только open/closed для простоты
        if (isOpen) {
          phase = ExercisePhase.open;
        } else if (isClosed) {
          phase = ExercisePhase.closed;
        }
        break;
    }

    bool repCompleted = false;
    // Законченный повтор: мы были открыты и снова закрылись
    if (_wasOpen && phase == ExercisePhase.closed) {
      // Валидация амплитуды
      final amplitude = _repMaxSpread - _repMinSpread;
      if (amplitude >= (minAnklesSpreadForOpen - maxAnklesSpreadForClosed) * 0.6) {
        totalReps += 1;
        repCompleted = true;
      }
      _repMinSpread = 1;
      _repMaxSpread = 0;
      _wasOpen = false;
    } else if (phase == ExercisePhase.open) {
      _wasOpen = true;
    }

    // Оценка формы:
    //  - spreadScore: насколько сильно развели ноги
    //  - armsScore: подняты ли руки полностью
    final spreadScore = (spread - maxAnklesSpreadForClosed) /
        (minAnklesSpreadForOpen - maxAnklesSpreadForClosed);
    final normSpread = spreadScore.clamp(0, 1) * 100;
    final armsScore = armsUp ? 100 : 40;
    formScore = (normSpread * 0.5 + armsScore * 0.5).clamp(0, 100);

    // Feedback
    if (!armsUp) {
      feedback = 'Руки выше!';
    } else if (spread < minAnklesSpreadForOpen * 0.9 && phase == ExercisePhase.open) {
      feedback = 'Ноги шире!';
    } else if (repCompleted) {
      feedback = 'Отлично!';
    } else {
      feedback = phase == ExercisePhase.open ? 'Держи амплитуду' : 'Прыжок!';
    }

    return repCompleted;
  }
}
