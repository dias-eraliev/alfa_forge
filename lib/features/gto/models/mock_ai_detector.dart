import 'dart:async';
import 'dart:math';
import 'exercise_model.dart';
import 'workout_session_model.dart';

class MockAIDetector {
  final String exerciseType;
  final Random _random = Random();
  
  int _currentReps = 0;
  double _currentQuality = 0.0;
  String _currentPhase = 'ready';
  bool _isValidPosition = false;
  
  Timer? _detectionTimer;
  Timer? _phaseTimer;
  
  // Callback для отправки результатов
  Function(AIDetectionResult)? onDetectionUpdate;
  
  MockAIDetector({required this.exerciseType});
  
  void startDetection({Function(AIDetectionResult)? onUpdate}) {
    onDetectionUpdate = onUpdate;
    _startSimulation();
  }
  
  void stopDetection() {
    _detectionTimer?.cancel();
    _phaseTimer?.cancel();
    onDetectionUpdate = null;
  }
  
  void reset() {
    _currentReps = 0;
    _currentQuality = 0.0;
    _currentPhase = 'ready';
    _isValidPosition = false;
  }
  
  void _startSimulation() {
    // Основной цикл детекции (каждые 100мс)
    _detectionTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _updateDetection();
    });
    
    // Симуляция выполнения упражнения
    _simulateExerciseCycle();
  }
  
  void _updateDetection() {
    // Симуляция качества формы (от 60% до 95%)
    final baseQuality = 0.6 + (_random.nextDouble() * 0.35);
    final qualityVariation = (_random.nextDouble() - 0.5) * 0.2;
    _currentQuality = (baseQuality + qualityVariation).clamp(0.4, 1.0);
    
    // Определение валидной позиции
    _isValidPosition = _currentQuality > 0.55;
    
    final result = AIDetectionResult(
      isGoodForm: _currentQuality > 0.7,
      isAverageForm: _currentQuality > 0.5 && _currentQuality <= 0.7,
      qualityPercentage: (_currentQuality * 100).round(),
      feedback: _generateFeedback(),
      phase: _currentPhase,
      repetitionCount: _currentReps,
    );
    
    onDetectionUpdate?.call(result);
  }
  
  void _simulateExerciseCycle() {
    switch (exerciseType) {
      case ExerciseType.pushups:
        _simulatePushupsCycle();
        break;
      case ExerciseType.squats:
        _simulateSquatsCycle();
        break;
      case ExerciseType.burpees:
        _simulateBurpeesCycle();
        break;
    }
  }
  
  void _simulatePushupsCycle() {
    // Цикл отжимания: готов -> вниз -> вверх -> повтор
    const phaseDurations = {
      'ready': 1000,
      'down': 800,
      'up': 700,
      'complete': 300,
    };
    
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      switch (_currentPhase) {
        case 'ready':
          Future.delayed(Duration(milliseconds: phaseDurations['ready']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'down';
            }
          });
          break;
        case 'down':
          Future.delayed(Duration(milliseconds: phaseDurations['down']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'up';
            }
          });
          break;
        case 'up':
          Future.delayed(Duration(milliseconds: phaseDurations['up']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'complete';
              _currentReps++;
            }
          });
          break;
        case 'complete':
          Future.delayed(Duration(milliseconds: phaseDurations['complete']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'ready';
              // Небольшая пауза между повторениями
              Future.delayed(Duration(milliseconds: 500 + _random.nextInt(1000)), () {
                if (_phaseTimer?.isActive == true) {
                  _currentPhase = 'down';
                }
              });
            }
          });
          break;
      }
    });
  }
  
  void _simulateSquatsCycle() {
    // Цикл приседания: готов -> вниз -> вверх -> повтор
    const phaseDurations = {
      'ready': 800,
      'down': 600,
      'up': 600,
      'complete': 200,
    };
    
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      switch (_currentPhase) {
        case 'ready':
          Future.delayed(Duration(milliseconds: phaseDurations['ready']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'down';
            }
          });
          break;
        case 'down':
          Future.delayed(Duration(milliseconds: phaseDurations['down']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'up';
            }
          });
          break;
        case 'up':
          Future.delayed(Duration(milliseconds: phaseDurations['up']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'complete';
              _currentReps++;
            }
          });
          break;
        case 'complete':
          Future.delayed(Duration(milliseconds: phaseDurations['complete']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'ready';
              // Пауза между повторениями
              Future.delayed(Duration(milliseconds: 300 + _random.nextInt(700)), () {
                if (_phaseTimer?.isActive == true) {
                  _currentPhase = 'down';
                }
              });
            }
          });
          break;
      }
    });
  }
  
  void _simulateBurpeesCycle() {
    // Цикл берпи: готов -> присед -> планка -> присед -> прыжок -> повтор
    const phaseDurations = {
      'ready': 1000,
      'squat_down': 600,
      'plank': 800,
      'squat_up': 600,
      'jump': 400,
      'complete': 500,
    };
    
    _phaseTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      switch (_currentPhase) {
        case 'ready':
          Future.delayed(Duration(milliseconds: phaseDurations['ready']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'squat_down';
            }
          });
          break;
        case 'squat_down':
          Future.delayed(Duration(milliseconds: phaseDurations['squat_down']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'plank';
            }
          });
          break;
        case 'plank':
          Future.delayed(Duration(milliseconds: phaseDurations['plank']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'squat_up';
            }
          });
          break;
        case 'squat_up':
          Future.delayed(Duration(milliseconds: phaseDurations['squat_up']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'jump';
            }
          });
          break;
        case 'jump':
          Future.delayed(Duration(milliseconds: phaseDurations['jump']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'complete';
              _currentReps++;
            }
          });
          break;
        case 'complete':
          Future.delayed(Duration(milliseconds: phaseDurations['complete']!), () {
            if (_phaseTimer?.isActive == true) {
              _currentPhase = 'ready';
              // Более длительная пауза для берпи
              Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)), () {
                if (_phaseTimer?.isActive == true) {
                  _currentPhase = 'squat_down';
                }
              });
            }
          });
          break;
      }
    });
  }
  
  String _generateFeedback() {
    final exercise = Exercise.getById(exerciseType);
    if (exercise == null) return 'Продолжайте!';
    
    final tips = exercise.tips;
    
    // Выбор фидбека на основе качества и фазы
    if (_currentQuality >= 0.85) {
      return tips['correct'] ?? 'Отлично!';
    } else if (_currentQuality >= 0.7) {
      return tips['good_pace'] ?? 'Хорошо!';
    } else if (_currentQuality >= 0.6) {
      // Случайная подсказка по улучшению
      final improvementTips = [
        tips['too_fast'],
        tips['too_shallow'],
        tips['bad_form'],
      ].where((tip) => tip != null).cast<String>().toList();
      
      if (improvementTips.isNotEmpty) {
        return improvementTips[_random.nextInt(improvementTips.length)];
      }
    }
    
    // Фидбек по фазам
    switch (_currentPhase) {
      case 'down':
        return exerciseType == ExerciseType.squats 
          ? 'Глубже! Бедра параллельно!' 
          : 'Опускайтесь медленнее!';
      case 'up':
        return 'Подъем! Полная амплитуда!';
      case 'plank':
        return 'Держите планку!';
      case 'jump':
        return 'Мощный прыжок!';
      default:
        return 'Продолжайте!';
    }
  }
  
  void dispose() {
    stopDetection();
  }
}
