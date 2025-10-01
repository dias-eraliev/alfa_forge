import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../app/theme.dart';
import '../models/exercise_model.dart';
import '../models/workout_session_model.dart';
import '../models/real_ai_detector.dart';
import '../controllers/workout_controller.dart';
import '../controllers/tts_controller.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/workout_results.dart';
import 'dart:async';

class AIMotionPage extends ConsumerStatefulWidget {
  const AIMotionPage({super.key});

  @override
  ConsumerState<AIMotionPage> createState() => _AIMotionPageState();
}

class _AIMotionPageState extends ConsumerState<AIMotionPage>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _countController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _countAnimation;
  
  bool _showInstructions = true;
  bool _showPositioning = false;
  bool _isPositioningReady = false;
  int _countdownSeconds = 3;
  
  // Камера
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _cameraPermissionGranted = false;
  
  // AI позиционирование
  Timer? _positioningTimer;
  bool _isAnalyzingPositioning = false;
  AIDetectionResult? _currentPositioningResult;

  @override
  void initState() {
    super.initState();
    
    // Настраиваем анимации
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _countController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _countAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _countController,
      curve: Curves.elasticOut,
    ));

    // Запрещаем поворот экрана и отключение экрана
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    
    WakelockPlus.enable();
    
    // Запускаем пульсацию
    _pulseController.repeat(reverse: true);
    
    // Инициализируем камеру
    _initializeCamera();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countController.dispose();
    
    // Освобождаем камеру
    _cameraController?.dispose();
    
    // Возвращаем настройки экрана
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    WakelockPlus.disable();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutControllerProvider);
    final ttsState = ref.watch(ttsControllerProvider);
    
    // Если тренировка завершена, показываем результаты
    if (workoutState.isWorkoutComplete) {
      return WorkoutResultsPage(session: workoutState.currentSession!);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Камера (основной слой)
            _buildCameraPreview(),

            // Инструкции (показываются в начале)
            if (_showInstructions && !workoutState.isDetecting)
              _InstructionsOverlay(
                currentExercise: workoutState.currentExercise,
                onStart: _startCountdown,
                onClose: _closeInstructions,
              ),

            // Positioning overlay (показывается во время позиционирования)
            if (_showPositioning)
              _PositioningOverlay(
                currentResult: _currentPositioningResult,
                isReady: _isPositioningReady,
              ),

            // Только если НЕ показываются инструкции И НЕ идет позиционирование, показываем overlay
            if (!_showInstructions && !_showPositioning)
              CameraOverlay(
                workoutState: workoutState,
                onPause: _pauseWorkout,
                onStop: _stopWorkout,
                onNext: _nextExercise,
              ),

            // Счетчик обратного отсчета
            if (_countdownSeconds > 0 && !_showInstructions && !workoutState.isDetecting)
              _CountdownOverlay(
                seconds: _countdownSeconds,
                animation: _countAnimation,
              ),

            // Простая отладочная информация
            if (_isCameraInitialized && !_showInstructions)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'КАМЕРА АКТИВНА',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _closeInstructions() {
    setState(() {
      _showInstructions = false;
    });
  }

  void _startCountdown() {
    _closeInstructions();
    _startPositioning();
  }
  
  // Начинаем этап позиционирования с AI анализом
  void _startPositioning() {
    setState(() {
      _showPositioning = true;
      _isPositioningReady = false;
    });
    
    // Говорим инструкцию
    ref.read(ttsControllerProvider.notifier).speak(
      'Пожалуйста, встаньте в полный рост перед камерой'
    );
    
    // Запускаем анализ позиционирования
    _startPositioningAnalysis();
  }
  
  // Анализ позиционирования через MediaPipe
  void _startPositioningAnalysis() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    
    setState(() {
      _isAnalyzingPositioning = true;
    });
    
    // Запускаем поток анализа кадров
    _cameraController!.startImageStream((image) async {
      if (!_isAnalyzingPositioning || _isPositioningReady) return; // Уже готовы, не анализируем
      
      try {
        final result = await RealAIDetector.analyzeFrame(
          image,
          'positioning', // Специальный тип для анализа позиционирования
          0,
        );
        
        if (mounted && _isAnalyzingPositioning) {
          setState(() {
            _currentPositioningResult = result;
          });
          
          // Если AI определил, что пользователь готов
          if (result.phase == 'ready' && result.isGoodForm) {
            _onPositioningReady();
          }
        }
      } catch (e) {
        print('Ошибка анализа позиционирования: $e');
      }
    });
  }
  
  // Когда AI определил готовность позиционирования
  void _onPositioningReady() {
    setState(() {
      _isPositioningReady = true;
      _showPositioning = false;
      _isAnalyzingPositioning = false;
    });
    
    // Останавливаем анализ позиционирования
    _cameraController?.stopImageStream();
    
    // Говорим "Готово!" и начинаем обратный отсчет
    ref.read(ttsControllerProvider.notifier).speak('Готово!');
    
    // Небольшая задержка перед обратным отсчетом
    Timer(const Duration(milliseconds: 1000), () {
      _startCountdownTimer();
    });
  }

  void _startCountdownTimer() {
    setState(() {
      _countdownSeconds = 3;
    });

    _countController.forward().then((_) {
      final timer = Stream.periodic(const Duration(seconds: 1), (i) => 3 - i - 1)
          .take(3)
          .listen((seconds) {
        setState(() {
          _countdownSeconds = seconds;
        });
        
        _countController.reset();
        _countController.forward();

        // Голосовой отсчет
        if (seconds > 0) {
          ref.read(ttsControllerProvider.notifier).speak('$seconds');
        } else {
          ref.read(ttsControllerProvider.notifier).speak('Начинаем!');
        }
      });

      timer.onDone(() {
        setState(() {
          _countdownSeconds = 0;
        });
        _startWorkout();
      });
    });
  }

  void _startWorkout() {
    ref.read(workoutControllerProvider.notifier).startAIDetection();
  }

  void _pauseWorkout() {
    if (ref.read(workoutControllerProvider).isDetecting) {
      ref.read(workoutControllerProvider.notifier).stopDetection();
    } else {
      _startWorkout();
    }
  }

  void _stopWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text(
          'Завершить тренировку?',
          style: TextStyle(color: PRIMETheme.sand),
        ),
        content: const Text(
          'Вы уверены, что хотите завершить текущую тренировку?',
          style: TextStyle(color: PRIMETheme.sandWeak),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Отмена',
              style: TextStyle(color: PRIMETheme.sandWeak),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(workoutControllerProvider.notifier).completeWorkout();
            },
            child: const Text(
              'Завершить',
              style: TextStyle(color: PRIMETheme.warn),
            ),
          ),
        ],
      ),
    );
  }

  void _nextExercise() {
    ref.read(workoutControllerProvider.notifier).completeCurrentExercise();
  }

  // Инициализация камеры
  Future<void> _initializeCamera() async {
    try {
      // Запрашиваем разрешение на камеру
      final cameraStatus = await Permission.camera.request();
      
      if (cameraStatus != PermissionStatus.granted) {
        setState(() {
          _cameraPermissionGranted = false;
        });
        return;
      }

      setState(() {
        _cameraPermissionGranted = true;
      });

      // Получаем список доступных камер
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      // Используем переднюю камеру для селфи-режима
      CameraDescription selectedCamera = cameras.first;
      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      print('Выбранная камера: ${selectedCamera.name} - ${selectedCamera.lensDirection}');

      // Инициализируем контроллер камеры с низким разрешением
      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.low, // Пробуем низкое разрешение
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();
      
      print('Камера инициализирована: ${_cameraController!.value.isInitialized}');
      print('Aspect ratio: ${_cameraController!.value.aspectRatio}');
      print('Preview size: ${_cameraController!.value.previewSize}');
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Ошибка инициализации камеры: $e');
      setState(() {
        _isCameraInitialized = false;
        _cameraPermissionGranted = false;
      });
    }
  }

  // Виджет камеры
  Widget _buildCameraPreview() {
    if (!_cameraPermissionGranted) {
      return _buildPermissionDeniedView();
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return _buildLoadingView();
    }

    if (!_cameraController!.value.isInitialized) {
      return _buildLoadingView();
    }

    // Отладочная информация
    print('Camera controller initialized: ${_cameraController?.value.isInitialized}');
    print('Camera aspect ratio: ${_cameraController?.value.aspectRatio}');

    // Попробуем несколько разных подходов к отображению
    final screenSize = MediaQuery.of(context).size;
    final cameraAspectRatio = _cameraController!.value.aspectRatio;
    
    print('Screen size: $screenSize');
    print('Camera aspect ratio: $cameraAspectRatio');

    // Простейший вариант - без всяких контейнеров
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: screenSize.width,
            height: screenSize.width * cameraAspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
      ),
    );
  }

  // Экран загрузки камеры
  Widget _buildLoadingView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[900]!,
            Colors.black,
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Инициализация камеры...',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Экран отказа в разрешениях
  Widget _buildPermissionDeniedView() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[900]!,
            Colors.black,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt_outlined,
                size: 80,
                color: Colors.white38,
              ),
              const SizedBox(height: 24),
              const Text(
                'Нужен доступ к камере',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Для отслеживания упражнений необходимо предоставить доступ к камере',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMETheme.primary,
                  foregroundColor: PRIMETheme.sand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Открыть настройки',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstructionsOverlay extends StatelessWidget {
  final ExercisePlan? currentExercise;
  final VoidCallback onStart;
  final VoidCallback onClose;

  const _InstructionsOverlay({
    this.currentExercise,
    required this.onStart,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final exercise = currentExercise?.exercise;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.9),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Иконка упражнения
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: PRIMETheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Center(
                  child: Text(
                    exercise?.icon ?? '💪',
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Название упражнения
              Text(
                exercise?.name ?? 'Упражнение',
                style: const TextStyle(
                  color: PRIMETheme.sand,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Цель
              Text(
                'Цель: ${currentExercise?.targetReps} повторений',
                style: const TextStyle(
                  color: PRIMETheme.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Инструкции
              const Text(
                'Техника выполнения:',
                style: TextStyle(
                  color: PRIMETheme.sand,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              ...?exercise?.instructions.map((instruction) => 
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '• ',
                        style: TextStyle(
                          color: PRIMETheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          instruction,
                          style: const TextStyle(
                            color: PRIMETheme.sandWeak,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Советы
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: PRIMETheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: PRIMETheme.primary,
                      size: 20,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Встаньте так, чтобы вас полностью видела камера. Следите за техникой - AI будет оценивать качество выполнения!',
                      style: TextStyle(
                        color: PRIMETheme.sandWeak,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),

              // Кнопки
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onClose,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: PRIMETheme.sandWeak),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Назад',
                        style: TextStyle(
                          color: PRIMETheme.sandWeak,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onStart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMETheme.primary,
                        foregroundColor: PRIMETheme.sand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'НАЧАТЬ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownOverlay extends StatelessWidget {
  final int seconds;
  final Animation<double> animation;

  const _CountdownOverlay({
    required this.seconds,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: animation.value,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: PRIMETheme.primary.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: PRIMETheme.primary.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    seconds == 0 ? 'GO!' : '$seconds',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final AIDetectionResult detection;

  const _FeedbackCard({required this.detection});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: detection.isGoodForm 
            ? PRIMETheme.success 
            : detection.isAverageForm 
              ? Colors.orange 
              : PRIMETheme.warn,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            detection.feedback,
            style: TextStyle(
              color: detection.isGoodForm 
                ? PRIMETheme.success 
                : detection.isAverageForm 
                  ? Colors.orange 
                  : PRIMETheme.warn,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Качество: ${detection.qualityPercentage}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                'Фаза: ${_getPhaseText(detection.phase)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPhaseText(String phase) {
    switch (phase) {
      case 'up': return 'Вверх';
      case 'down': return 'Вниз';
      case 'hold': return 'Удержание';
      case 'ready': return 'Готов';
      case 'complete': return 'Завершено';
      case 'plank': return 'Планка';
      case 'jump': return 'Прыжок';
      case 'squat_down': return 'Присед';
      case 'squat_up': return 'Подъем';
      default: return phase;
    }
  }
}

class _PositioningOverlay extends StatefulWidget {
  final AIDetectionResult? currentResult;
  final bool isReady;

  const _PositioningOverlay({
    this.currentResult,
    required this.isReady,
  });

  @override
  State<_PositioningOverlay> createState() => _PositioningOverlayState();
}

class _PositioningOverlayState extends State<_PositioningOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _checkmarkController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _checkmarkAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _checkmarkAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: Curves.bounceOut,
    ));

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_PositioningOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Анимация галочки при готовности
    if (widget.isReady && !oldWidget.isReady) {
      _checkmarkController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.currentResult;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withOpacity(0.8),
      child: Stack(
        children: [
          // Основная информация по центру
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Индикатор состояния
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _getStatusColor(result?.phase).withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _getStatusColor(result?.phase),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: widget.isReady
                              ? AnimatedBuilder(
                                  animation: _checkmarkAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _checkmarkAnimation.value,
                                      child: const Icon(
                                        Icons.check,
                                        color: PRIMETheme.success,
                                        size: 60,
                                      ),
                                    );
                                  },
                                )
                              : Icon(
                                  Icons.person,
                                  color: _getStatusColor(result?.phase),
                                  size: 60,
                                ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Основное сообщение
                Text(
                  _getMainMessage(result?.phase, widget.isReady),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 12),
                
                // Детальная обратная связь
                if (result != null && !widget.isReady) ...[
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _getStatusColor(result.phase).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor(result.phase).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          result.feedback,
                          style: TextStyle(
                            color: _getStatusColor(result.phase),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Видимость: ${result.qualityPercentage}%',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Силуэт-направляющие по краям экрана
          if (!widget.isReady) _buildBodyOutlineGuide(result),
          
          // Статус в верхнем углу
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(result?.phase).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.isReady ? 'ГОТОВО' : 'ПОЗИЦИОНИРОВАНИЕ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBodyOutlineGuide(AIDetectionResult? result) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BodyOutlinePainter(
          phase: result?.phase ?? 'not_visible',
          qualityPercentage: result?.qualityPercentage ?? 0,
        ),
      ),
    );
  }
  
  Color _getStatusColor(String? phase) {
    switch (phase) {
      case 'ready':
        return PRIMETheme.success;
      case 'positioning':
        return Colors.orange;
      case 'not_visible':
        return PRIMETheme.warn;
      default:
        return PRIMETheme.primary;
    }
  }
  
  String _getMainMessage(String? phase, bool isReady) {
    if (isReady) {
      return 'Отлично!\nВы в кадре';
    }
    
    switch (phase) {
      case 'ready':
        return 'Готово к началу!';
      case 'positioning':
        return 'Настройте позицию';
      case 'not_visible':
        return 'Войдите в кадр';
      default:
        return 'Встаньте перед камерой';
    }
  }
}

// Кастомный painter для отрисовки силуэта-направляющего
class _BodyOutlinePainter extends CustomPainter {
  final String phase;
  final int qualityPercentage;
  
  _BodyOutlinePainter({
    required this.phase,
    required this.qualityPercentage,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Цвет в зависимости от статуса
    switch (phase) {
      case 'ready':
        paint.color = PRIMETheme.success.withOpacity(0.6);
        break;
      case 'positioning':
        paint.color = Colors.orange.withOpacity(0.6);
        break;
      case 'not_visible':
        paint.color = PRIMETheme.warn.withOpacity(0.6);
        break;
      default:
        paint.color = Colors.white.withOpacity(0.4);
    }
    
    // Рисуем простой силуэт человека в центре
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scale = size.width / 400; // Масштабируем под размер экрана
    
    // Голова
    canvas.drawCircle(
      Offset(centerX, centerY - 80 * scale),
      25 * scale,
      paint,
    );
    
    // Тело
    canvas.drawLine(
      Offset(centerX, centerY - 55 * scale),
      Offset(centerX, centerY + 50 * scale),
      paint,
    );
    
    // Руки
    canvas.drawLine(
      Offset(centerX, centerY - 30 * scale),
      Offset(centerX - 40 * scale, centerY + 10 * scale),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY - 30 * scale),
      Offset(centerX + 40 * scale, centerY + 10 * scale),
      paint,
    );
    
    // Ноги
    canvas.drawLine(
      Offset(centerX, centerY + 50 * scale),
      Offset(centerX - 30 * scale, centerY + 120 * scale),
      paint,
    );
    canvas.drawLine(
      Offset(centerX, centerY + 50 * scale),
      Offset(centerX + 30 * scale, centerY + 120 * scale),
      paint,
    );
    
    // Рамка-ограничитель
    final rect = Rect.fromLTWH(
      centerX - 60 * scale,
      centerY - 110 * scale,
      120 * scale,
      240 * scale,
    );
    
    final framePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = paint.color;
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(12 * scale)),
      framePaint,
    );
    
    // Углы для лучшей видимости
    final cornerLength = 20 * scale;
    final cornerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = paint.color;
    
    // Верхние углы
    canvas.drawLine(
      Offset(rect.left, rect.top + cornerLength),
      Offset(rect.left, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerLength, rect.top),
      cornerPaint,
    );
    
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.top),
      Offset(rect.right, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerLength),
      cornerPaint,
    );
    
    // Нижние углы
    canvas.drawLine(
      Offset(rect.left, rect.bottom - cornerLength),
      Offset(rect.left, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerLength, rect.bottom),
      cornerPaint,
    );
    
    canvas.drawLine(
      Offset(rect.right - cornerLength, rect.bottom),
      Offset(rect.right, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerLength),
      cornerPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is _BodyOutlinePainter &&
        (oldDelegate.phase != phase || oldDelegate.qualityPercentage != qualityPercentage);
  }
}
