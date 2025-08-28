import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/exercise_model.dart';
import '../models/workout_session_model.dart';
import '../models/mock_ai_detector.dart';
import 'tts_controller.dart';

// Provider для контроллера тренировки
final workoutControllerProvider = StateNotifierProvider<WorkoutController, WorkoutState>(
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
  
  MockAIDetector? _aiDetector;
  Timer? _sessionTimer;
  Timer? _motivationTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  DateTime? _sessionStartTime;
  int _lastRepCount = 0;
  double _totalQualitySum = 0.0;
  int _qualityMeasurements = 0;

  WorkoutController(this._ref) : super(const WorkoutState());

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

  // Создание новой тренировочной сессии
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

      // Устанавливаем первое упражнение
      if (exercises.isNotEmpty) {
        state = state.copyWith(currentExercise: exercises.first);
      }
    } catch (e) {
      state = state.copyWith(error: 'Ошибка создания тренировки: $e');
    }
  }

  // Начать AI детекцию для текущего упражнения
  Future<void> startAIDetection() async {
    if (state.currentExercise == null) {
      state = state.copyWith(error: 'Упражнение не выбрано');
      return;
    }

    try {
      // Инициализируем детектор для текущего упражнения
      _aiDetector?.dispose();
      _aiDetector = MockAIDetector(
        exerciseType: state.currentExercise!.exerciseId,
      );

      // Сбрасываем счетчики
      _lastRepCount = 0;
      _totalQualitySum = 0.0;
      _qualityMeasurements = 0;
      _sessionStartTime = DateTime.now();

      // Обновляем статус сессии
      final updatedSession = state.currentSession?.copyWith(
        status: WorkoutStatus.inProgress,
      );

      state = state.copyWith(
        isDetecting: true,
        isPaused: false,
        currentSession: updatedSession,
        error: null,
      );

      // Запускаем детекцию
      _aiDetector!.startDetection(
        onUpdate: _handleDetectionUpdate,
      );

      // Запускаем таймер сессии
      _startSessionTimer();

      // Запускаем периодическую мотивацию
      _startMotivationTimer();

      // Голосовое приветствие
      _ref.read(ttsControllerProvider.notifier).speak(
        'Начинаем ${state.currentExercise!.exercise?.name}! Готовы?'
      );

      // Звук старта
      _playSound('start');
      _hapticFeedback();

    } catch (e) {
      state = state.copyWith(error: 'Ошибка запуска детекции: $e');
    }
  }

  // Остановить детекцию
  void stopDetection() {
    _aiDetector?.stopDetection();
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

  // Завершить текущее упражнение
  Future<void> completeCurrentExercise() async {
    if (state.currentExercise == null || state.currentSession == null) return;

    try {
      // Обновляем статистику текущего упражнения
      final averageQuality = _qualityMeasurements > 0 
        ? _totalQualitySum / _qualityMeasurements 
        : 0.0;

      final completedExercise = state.currentExercise!.copyWith(
        completedReps: state.lastDetection?.repetitionCount ?? 0,
        averageQuality: averageQuality,
        completed: true,
      );

      // Обновляем список упражнений в сессии
      final updatedExercises = state.currentSession!.exercises.map((ex) {
        if (ex.exerciseId == completedExercise.exerciseId) {
          return completedExercise;
        }
        return ex;
      }).toList();

      // Находим следующее упражнение
      final currentIndex = updatedExercises.indexOf(completedExercise);
      final nextExercise = currentIndex + 1 < updatedExercises.length 
        ? updatedExercises[currentIndex + 1] 
        : null;

      final totalCompleted = updatedExercises.fold<int>(
        0, (sum, ex) => sum + ex.completedReps
      );

      final updatedSession = state.currentSession!.copyWith(
        exercises: updatedExercises,
        totalRepsCompleted: totalCompleted,
        averageQuality: updatedExercises.fold<double>(
          0.0, (sum, ex) => sum + ex.averageQuality
        ) / updatedExercises.length,
        status: nextExercise == null ? WorkoutStatus.completed : WorkoutStatus.inProgress,
        endTime: nextExercise == null ? DateTime.now() : null,
      );

      state = state.copyWith(
        currentSession: updatedSession,
        currentExercise: nextExercise,
        isDetecting: false,
      );

      // Останавливаем текущую детекцию
      _aiDetector?.stopDetection();

      // Голосовая обратная связь
      final repsCompleted = completedExercise.completedReps;
      final targetReps = completedExercise.targetReps;
      
      if (repsCompleted >= targetReps) {
        _ref.read(ttsControllerProvider.notifier).speak(
          'Отлично! ${completedExercise.exercise?.name} выполнено! $repsCompleted повторений!'
        );
        _playSound('success');
      } else {
        _ref.read(ttsControllerProvider.notifier).speak(
          'Упражнение завершено. Выполнено $repsCompleted из $targetReps повторений.'
        );
        _playSound('complete');
      }

      _hapticFeedback();

      // Если есть следующее упражнение, даем небольшую паузу
      if (nextExercise != null) {
        await Future.delayed(const Duration(seconds: 2));
        _ref.read(ttsControllerProvider.notifier).speak(
          'Следующее упражнение: ${nextExercise.exercise?.name}'
        );
      } else {
        // Тренировка завершена
        await Future.delayed(const Duration(seconds: 1));
        _ref.read(ttsControllerProvider.notifier).speak(
          'Тренировка завершена! Отличная работа!'
        );
        _playSound('workout_complete');
      }

    } catch (e) {
      state = state.copyWith(error: 'Ошибка завершения упражнения: $e');
    }
  }

  // Завершить всю тренировку
  void completeWorkout() {
    _aiDetector?.stopDetection();
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
    _ref.read(ttsControllerProvider.notifier).speak(
      'Поздравляем с завершением тренировки!'
    );
  }

  // Обработка обновлений от AI детектора
  void _handleDetectionUpdate(AIDetectionResult result) {
    // Проверяем новые повторения
    if (result.repetitionCount > _lastRepCount) {
      _lastRepCount = result.repetitionCount;
      
      // Звук засчитанного повторения
      _playSound('rep_counted');
      _hapticFeedback();

      // Голосовая обратная связь каждые 5 повторений
      if (result.repetitionCount % 5 == 0 && result.repetitionCount > 0) {
        _ref.read(ttsControllerProvider.notifier).speak(
          '${result.repetitionCount} повторений! ${result.feedback}'
        );
      }
    }

    // Накапливаем статистику качества
    _totalQualitySum += result.qualityPercentage;
    _qualityMeasurements++;

    state = state.copyWith(lastDetection: result);

    // Автоматическое завершение при достижении цели
    if (state.currentExercise != null && 
        result.repetitionCount >= state.currentExercise!.targetReps) {
      Future.delayed(const Duration(seconds: 1), () {
        completeCurrentExercise();
      });
    }
  }

  // Запуск таймера сессии
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_sessionStartTime != null) {
        final duration = DateTime.now().difference(_sessionStartTime!);
        state = state.copyWith(sessionDuration: duration);
      }
    });
  }

  // Мотивационные сообщения
  void _startMotivationTimer() {
    _motivationTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (state.isDetecting && !state.isPaused) {
        final motivationalPhrases = [
          'Продолжайте! Вы отлично справляетесь!',
          'Держите темп! Еще немного!',
          'Отличная работа! Не сдавайтесь!',
          'Вы сильнее чем вчера!',
        ];
        
        final phrase = motivationalPhrases[
          DateTime.now().millisecond % motivationalPhrases.length
        ];
        
        _ref.read(ttsControllerProvider.notifier).speak(phrase);
      }
    });
  }

  // Звуковые эффекты (пока отключены, чтобы избежать ошибок с отсутствующими файлами)
  void _playSound(String soundType) async {
    try {
      // Пока что используем только вибрацию вместо звуков
      // В будущих версиях здесь можно добавить звуковые файлы
      debugPrint('Sound event: $soundType');
      
      // Дополнительная вибрация для важных событий
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
          // Для других событий просто логируем
          break;
      }
    } catch (e) {
      debugPrint('Sound/Haptic error: $e');
    }
  }

  // Тактильная обратная связь
  void _hapticFeedback() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }
  }

  // Переключение на следующее упражнение
  void switchToNextExercise() {
    if (state.currentSession == null) return;

    final currentExercises = state.currentSession!.exercises;
    final currentIndex = state.currentExercise != null 
      ? currentExercises.indexOf(state.currentExercise!) 
      : -1;

    if (currentIndex + 1 < currentExercises.length) {
      state = state.copyWith(
        currentExercise: currentExercises[currentIndex + 1],
      );
    }
  }

  // Сброс тренировки
  void resetWorkout() {
    _aiDetector?.dispose();
    _sessionTimer?.cancel();
    _motivationTimer?.cancel();
    _aiDetector = null;
    _sessionStartTime = null;

    state = const WorkoutState();
  }

  @override
  void dispose() {
    _aiDetector?.dispose();
    _sessionTimer?.cancel();
    _motivationTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
