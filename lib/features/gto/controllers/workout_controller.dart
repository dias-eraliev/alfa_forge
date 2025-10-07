import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/exercise_model.dart';
import '../models/workout_session_model.dart';
import 'tts_controller.dart';

import '../pose/pose_service.dart';
import '../pose/pose_models.dart';
import '../detectors/base_exercise_detector.dart';
import '../detectors/detector_factory.dart';

/// Provider контроллера тренировки (новый pipeline: PoseService + ExerciseDetectors)
final workoutControllerProvider =
    StateNotifierProvider<WorkoutController, WorkoutState>(
  (ref) => WorkoutController(ref),
);

class WorkoutState {
  final WorkoutSession? currentSession;
  final ExercisePlan? currentExercise;
  final AIDetectionResult? lastDetection;
  final bool isDetecting;
  final bool isPaused;
  final String? error;
  final Duration sessionDuration;

  const WorkoutState({
    this.currentSession,
    this.currentExercise,
    this.lastDetection,
    this.isDetecting = false,
    this.isPaused = false,
    this.error,
    this.sessionDuration = Duration.zero,
  });

  WorkoutState copyWith({
    WorkoutSession? currentSession,
    ExercisePlan? currentExercise,
    AIDetectionResult? lastDetection,
    bool? isDetecting,
    bool? isPaused,
    String? error,
    Duration? sessionDuration,
  }) {
    return WorkoutState(
      currentSession: currentSession ?? this.currentSession,
      currentExercise: currentExercise ?? this.currentExercise,
      lastDetection: lastDetection ?? this.lastDetection,
      isDetecting: isDetecting ?? this.isDetecting,
      isPaused: isPaused ?? this.isPaused,
      error: error ?? this.error,
      sessionDuration: sessionDuration ?? this.sessionDuration,
    );
  }

  bool get hasActiveSession => currentSession != null;
  bool get canStartDetection => currentExercise != null && !isDetecting;
  bool get isWorkoutComplete => currentSession?.isCompleted ?? false;
}

class WorkoutController extends StateNotifier<WorkoutState> {
  final Ref _ref;

  ExerciseDetector? _detector;
  late final ProviderSubscription _poseSub;

  Timer? _sessionTimer;
  Timer? _motivationTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  DateTime? _sessionStartTime;
  int _lastRepCount = 0;
  double _totalQualitySum = 0.0;
  int _qualityMeasurements = 0;

  WorkoutController(this._ref) : super(const WorkoutState()) {
    // Подписка на обновления PoseService
    _poseSub = _ref.listen<PoseServiceState>(
      poseServiceProvider,
      (previous, next) {
        if (state.isDetecting &&
            !state.isPaused &&
            _detector != null &&
            next.lastFrame != null) {
          _processPoseFrame(next.lastFrame!);
        }
      },
      fireImmediately: false,
    );
  }

  // Создание быстрой ГТО тренировки (отжимания 10 раз)
  Future<void> createGTOWorkout() async {
    final gtoExercises = [
      const ExercisePlan(
        exerciseId: ExerciseType.pushups,
        targetReps: 10,
      ),
    ];
    await createWorkoutSession(gtoExercises);
  }

  Future<void> createWorkoutSession(List<ExercisePlan> exercises) async {
    try {
      final session = WorkoutSession(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        startTime: DateTime.now(),
        exercises: exercises,
        status: WorkoutStatus.planning,
      );

      state = state.copyWith(
        currentSession: session,
        error: null,
      );

      if (exercises.isNotEmpty) {
        state = state.copyWith(currentExercise: exercises.first);
      }
    } catch (e) {
      state = state.copyWith(error: 'Ошибка создания тренировки: $e');
    }
  }

  /// Запуск детекции (создаем ExerciseDetector и начинаем слушать поток поз)
  Future<void> startAIDetection() async {
    if (state.currentExercise == null) {
      state = state.copyWith(error: 'Упражнение не выбрано');
      return;
    }

    try {
      // Создаем детектор
      _detector = ExerciseDetectorFactory.create(
        state.currentExercise!.exerciseId,
      );

      if (_detector == null) {
        state = state.copyWith(error: 'Нет детектора для упражнения');
        return;
      }
      _detector!.reset();

      // Сбрасываем накопители
      _lastRepCount = 0;
      _totalQualitySum = 0.0;
      _qualityMeasurements = 0;
      _sessionStartTime = DateTime.now();

      final updatedSession = state.currentSession?.copyWith(
        status: WorkoutStatus.inProgress,
      );

      state = state.copyWith(
        isDetecting: true,
        isPaused: false,
        currentSession: updatedSession,
        error: null,
      );

      // Таймеры
      _startSessionTimer();
      _startMotivationTimer();

      // Голос/звуки
      _ref
          .read(ttsControllerProvider.notifier)
          .speak('Начинаем ${state.currentExercise!.exercise?.name}! Готовы?');
      _playSound('start');
      _hapticFeedback();
    } catch (e) {
      state = state.copyWith(error: 'Ошибка запуска детекции: $e');
    }
  }

  void stopDetection() {
    _sessionTimer?.cancel();
    _motivationTimer?.cancel();

    final updatedSession = state.currentSession?.copyWith(
      status: WorkoutStatus.paused,
      endTime: DateTime.now(),
    );

    state = state.copyWith(
      isDetecting: false,
      isPaused: true,
      currentSession: updatedSession,
    );

    _playSound('pause');
  }

  Future<void> completeCurrentExercise() async {
    if (state.currentExercise == null || state.currentSession == null) return;

    try {
      final averageQuality = _qualityMeasurements > 0
          ? _totalQualitySum / _qualityMeasurements
          : 0.0;

      final completedExercise = state.currentExercise!.copyWith(
        completedReps: state.lastDetection?.repetitionCount ?? 0,
        averageQuality: averageQuality,
        completed: true,
      );

      final updatedExercises = state.currentSession!.exercises.map((ex) {
        if (ex.exerciseId == completedExercise.exerciseId) {
          return completedExercise;
        }
        return ex;
      }).toList();

      final currentIndex = updatedExercises.indexOf(completedExercise);
      final nextExercise = currentIndex + 1 < updatedExercises.length
          ? updatedExercises[currentIndex + 1]
          : null;

      final totalCompleted = updatedExercises.fold<int>(
          0, (sum, ex) => sum + ex.completedReps);

      final updatedSession = state.currentSession!.copyWith(
        exercises: updatedExercises,
        totalRepsCompleted: totalCompleted,
        averageQuality: updatedExercises.fold<double>(
              0.0,
              (sum, ex) => sum + ex.averageQuality,
            ) /
            updatedExercises.length,
        status: nextExercise == null
            ? WorkoutStatus.completed
            : WorkoutStatus.inProgress,
        endTime: nextExercise == null ? DateTime.now() : null,
      );

      state = state.copyWith(
        currentSession: updatedSession,
        currentExercise: nextExercise,
        isDetecting: false,
      );

      // Голос/звуки
      final repsCompleted = completedExercise.completedReps;
      final targetReps = completedExercise.targetReps;

      if (repsCompleted >= targetReps) {
        _ref.read(ttsControllerProvider.notifier).speak(
              'Отлично! ${completedExercise.exercise?.name} выполнено! $repsCompleted повторений!',
            );
        _playSound('success');
      } else {
        _ref.read(ttsControllerProvider.notifier).speak(
              'Упражнение завершено. Выполнено $repsCompleted из $targetReps повторений.',
            );
        _playSound('complete');
      }

      _hapticFeedback();

      if (nextExercise != null) {
        await Future.delayed(const Duration(seconds: 2));
        _ref
            .read(ttsControllerProvider.notifier)
            .speak('Следующее упражнение: ${nextExercise.exercise?.name}');
      } else {
        await Future.delayed(const Duration(seconds: 1));
        _ref
            .read(ttsControllerProvider.notifier)
            .speak('Тренировка завершена! Отличная работа!');
        _playSound('workout_complete');
      }
    } catch (e) {
      state = state.copyWith(error: 'Ошибка завершения упражнения: $e');
    }
  }

  void completeWorkout() {
    _sessionTimer?.cancel();
    _motivationTimer?.cancel();

    final updatedSession = state.currentSession?.copyWith(
      status: WorkoutStatus.completed,
      endTime: DateTime.now(),
    );

    state = state.copyWith(
      currentSession: updatedSession,
      isDetecting: false,
      isPaused: false,
    );

    _playSound('workout_complete');
    _ref
        .read(ttsControllerProvider.notifier)
        .speak('Поздравляем с завершением тренировки!');
  }

  void _processPoseFrame(PoseFrame frame) {
    if (_detector == null) return;

    // Добавим дебаг информацию
    print('Processing pose frame with ${frame.points.length} points');
    
    final output = _detector!.update(frame);
    
    print('Detector output: reps=${output.totalReps}, score=${output.formScore}, phase=${output.phase.name}');

    // Конвертация в старый AIDetectionResult (для совместимости UI)
    final result = AIDetectionResult(
      isGoodForm: output.formScore >= 75,
      isAverageForm: output.formScore >= 50 && output.formScore < 75,
      qualityPercentage: output.formScore.round(),
      feedback: output.feedback,
      phase: output.phase.name,
      repetitionCount: output.totalReps,
    );

    _handleDetectionUpdate(result);

    // Автозавершение если достигли цели
    final target = state.currentExercise?.targetReps;
    if (target != null && output.totalReps >= target && state.isDetecting) {
      Future.delayed(const Duration(milliseconds: 600), () {
        completeCurrentExercise();
      });
    }
  }

  void _handleDetectionUpdate(AIDetectionResult result) {
    if (result.repetitionCount > _lastRepCount) {
      _lastRepCount = result.repetitionCount;
      _playSound('rep_counted');
      _hapticFeedback();

      if (result.repetitionCount % 5 == 0 && result.repetitionCount > 0) {
        _ref
            .read(ttsControllerProvider.notifier)
            .speak('${result.repetitionCount} повторений! ${result.feedback}');
      }
    }

    _totalQualitySum += result.qualityPercentage;
    _qualityMeasurements++;

    state = state.copyWith(lastDetection: result);
  }

  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sessionStartTime != null) {
        state = state.copyWith(
          sessionDuration: DateTime.now().difference(_sessionStartTime!),
        );
      }
    });
  }

  void _startMotivationTimer() {
    _motivationTimer =
        Timer.periodic(const Duration(seconds: 30), (timer) {
      if (state.isDetecting && !state.isPaused) {
        final phrases = [
          'Продолжайте! Вы отлично справляетесь!',
            'Держите темп! Еще немного!',
            'Отличная работа! Не сдавайтесь!',
            'Вы сильнее чем вчера!',
        ];
        final phrase = phrases[DateTime.now().millisecond % phrases.length];
        _ref.read(ttsControllerProvider.notifier).speak(phrase);
      }
    });
  }

  void _playSound(String soundType) async {
    try {
      debugPrint('Sound event: $soundType');
      switch (soundType) {
        case 'start':
        case 'success':
        case 'workout_complete':
          _hapticFeedback();
          await Future.delayed(const Duration(milliseconds: 100));
          _hapticFeedback();
          break;
        case 'rep_counted':
          _hapticFeedback();
          break;
        default:
          break;
      }
    } catch (e) {
      debugPrint('Sound/Haptic error: $e');
    }
  }

  void _hapticFeedback() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  void switchToNextExercise() {
    if (state.currentSession == null) return;
    final list = state.currentSession!.exercises;
    final idx =
        state.currentExercise != null ? list.indexOf(state.currentExercise!) : -1;
    if (idx + 1 < list.length) {
      state = state.copyWith(currentExercise: list[idx + 1]);
    }
  }

  void resetWorkout() {
    _sessionTimer?.cancel();
    _motivationTimer?.cancel();
    _detector = null;
    _sessionStartTime = null;
    state = const WorkoutState();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _motivationTimer?.cancel();
    _audioPlayer.dispose();
    _poseSub.close();
    super.dispose();
  }
}
