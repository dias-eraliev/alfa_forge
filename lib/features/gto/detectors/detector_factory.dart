import 'base_exercise_detector.dart';
import '../models/exercise_model.dart';
import 'pushup_detector.dart';
import 'squat_detector.dart';
import 'jumping_jacks_detector.dart';

/// Фабрика для создания нужного ExerciseDetector по идентификатору упражнения.
class ExerciseDetectorFactory {
  static ExerciseDetector? create(String exerciseId) {
    switch (exerciseId) {
      case ExerciseType.pushups:
        return PushUpDetector();
      case ExerciseType.squats:
        return SquatDetector();
      case ExerciseType.jumpingJacks:
        return JumpingJacksDetector();
      default:
        return null;
    }
  }
}
