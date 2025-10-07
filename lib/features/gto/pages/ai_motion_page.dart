import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../app/theme.dart';
import '../controllers/workout_controller.dart';
import '../controllers/tts_controller.dart';
import '../pose/pose_service.dart';
import '../pose/skeleton_painter.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/workout_results.dart';
import '../models/exercise_model.dart';

/// Упрощенная страница тренировки:
/// - Нет инструкций / позиционирования / обратного отсчета
/// - Камера сразу запускает поток кадров -> PoseService
/// - При наличии выбранного упражнения автоматический старт детектора
/// - Отображение скелета и минимального фидбека (через workoutState.lastDetection)
class AIMotionPage extends ConsumerStatefulWidget {
  const AIMotionPage({super.key});

  @override
  ConsumerState<AIMotionPage> createState() => _AIMotionPageState();
}

class _AIMotionPageState extends ConsumerState<AIMotionPage>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _cameraPermissionGranted = false;
  bool _autoStarted = false;
  bool _streamStarted = false;
  bool _showDebug = true;

  @override
  void initState() {
    super.initState();
    // Только портрет
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WakelockPlus.enable();
    _initializeCamera();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attemptAutoStart());
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    WakelockPlus.disable();
    super.dispose();
  }

  void _attemptAutoStart() {
    if (_autoStarted) return;
    final workoutState = ref.read(workoutControllerProvider);
    if (workoutState.currentExercise != null && !workoutState.isDetecting) {
      if (_isCameraInitialized) {
        _autoStarted = true;
        ref.read(workoutControllerProvider.notifier).startAIDetection();
      } else {
        Future.delayed(const Duration(milliseconds: 300), _attemptAutoStart);
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraStatus = await Permission.camera.request();
      if (cameraStatus != PermissionStatus.granted) {
        setState(() => _cameraPermissionGranted = false);
        return;
      }
      setState(() => _cameraPermissionGranted = true);

      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      CameraDescription selectedCamera = cameras.first;
      for (final c in cameras) {
        if (c.lensDirection == CameraLensDirection.front) {
          selectedCamera = c;
          break;
        }
      }

      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await _cameraController!.initialize();

      if (!mounted) return;
      setState(() => _isCameraInitialized = true);

      _startImageStream(); // сразу стартуем поток
    } catch (e) {
      setState(() {
        _isCameraInitialized = false;
        _cameraPermissionGranted = false;
      });
    }
  }

  void _startImageStream() {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _streamStarted) {
      return;
    }
    _streamStarted = true;
    _cameraController!.startImageStream((image) {
      // Используем PoseService для обработки кадров
      final poseNotifier = ref.read(poseServiceProvider.notifier);
      poseNotifier.processCameraImage(image);
    });
  }

  @override
  Widget build(BuildContext context) {
    final workoutState = ref.watch(workoutControllerProvider);
    final poseState = ref.watch(poseServiceProvider);

    // Завершена тренировка
    if (workoutState.isWorkoutComplete) {
      return WorkoutResultsPage(session: workoutState.currentSession!);
    }

    final lastDetection = workoutState.lastDetection;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            _buildCameraPreview(),

            // Скелет
            if (poseState.lastFrame != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: PoseSkeletonView(
                    frame: poseState.lastFrame,
                    showDebug: _showDebug,
                    debugLines: [
                      'raw:${poseState.rawFps.toStringAsFixed(1)}',
                      'proc:${poseState.processedFps.toStringAsFixed(1)}',
                      'lat:${poseState.backendLatencyMs}ms',
                      'pts:${poseState.lastFrame?.points.length ?? 0}',
                      'drop:${poseState.droppedFrames}',
                    ],
                  ),
                ),
              ),

            // Основной overlay управления
            CameraOverlay(
              workoutState: workoutState,
              onPause: _pauseOrResume,
              onStop: _stopWorkoutConfirmation,
              onNext: () => ref
                  .read(workoutControllerProvider.notifier)
                  .completeCurrentExercise(),
            ),

            // Фидбек карточка
            if (lastDetection != null && workoutState.isDetecting)
              Positioned(
                bottom: 140,
                left: 16,
                right: 16,
                child: _FeedbackCard(detection: lastDetection),
              ),

            // Статус камеры
            if (_isCameraInitialized)
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'КАМЕРА',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Toggle debug
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => setState(() => _showDebug = !_showDebug),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(
                    _showDebug ? Icons.bug_report : Icons.bug_report_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pauseOrResume() {
    final ctrl = ref.read(workoutControllerProvider.notifier);
    final st = ref.read(workoutControllerProvider);
    if (st.isDetecting) {
      ctrl.stopDetection();
    } else if (st.currentExercise != null) {
      ctrl.startAIDetection();
    }
  }

  void _stopWorkoutConfirmation() {
    final ctrl = ref.read(workoutControllerProvider.notifier);
    final tts = ref.read(ttsControllerProvider.notifier);
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
              ctrl.completeWorkout();
              tts.speak('Тренировка завершена');
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

  Widget _buildCameraPreview() {
    if (!_cameraPermissionGranted) {
      return _permissionDeniedView();
    }
    if (!_isCameraInitialized || _cameraController == null) {
      return _loadingView();
    }
    if (!_cameraController!.value.isInitialized) {
      return _loadingView();
    }

    final screenSize = MediaQuery.of(context).size;
    final aspect = _cameraController!.value.aspectRatio;

    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
            child: SizedBox(
              width: screenSize.width,
              height: screenSize.width * aspect,
              child: CameraPreview(_cameraController!),
            ),
        ),
      ),
    );
  }

  Widget _loadingView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.black87],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Инициализация камеры...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissionDeniedView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black87, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_outlined,
                  size: 80, color: Colors.white38),
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
                'Для отслеживания упражнений необходим доступ к камере',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMETheme.primary,
                  foregroundColor: PRIMETheme.sand,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
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

class _FeedbackCard extends StatelessWidget {
  final AIDetectionResult detection;

  const _FeedbackCard({required this.detection});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = detection.isGoodForm
        ? PRIMETheme.success
        : detection.isAverageForm
            ? Colors.orange
            : PRIMETheme.warn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.25),
            blurRadius: 16,
            spreadRadius: 1,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            detection.feedback,
            style: TextStyle(
              color: borderColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _metricTile(
                  'Качество',
                  '${detection.qualityPercentage}%',
                  Icons.grade,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricTile(
                  'Повторы',
                  '${detection.repetitionCount}',
                  Icons.fitness_center,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricTile(
                  'Фаза',
                  detection.phase,
                  Icons.timeline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 6),
            Expanded(
            child: Text(
              '$label: $value',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
