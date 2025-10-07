// PoseService: сервис верхнего уровня, управляющий backend (MediaPipe/MLKit),
// throttle обработкой кадров и публикацией состояний через Riverpod.
//
// ЭТАП 1 (MVP): Использует MediaPipePoseBackendStub (пустые точки) чтобы
// подготовить архитектуру. Далее будет заменено на нативный backend.
//
// Интеграция в UI (позже):
//  1. Инициализация камеры (как сейчас в AIMotionPage)
//  2. Передача каждого CameraImage в poseService.processCameraImage(image)
//  3. Подписка на состояние (lastFrame) для отрисовки skeleton painter.
//
// Следующий шаг после этого файла:
//  - Заменить RealAIDetector вызовы на PoseService + ExerciseDetectors (ещё не созданы)
//  - Вынести логику позиционирования в отдельный detector (PositioningDetector)
//
// NB: Сейчас НЕ подключено к AIMotionPage, чтобы не сломать существующий поток.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import 'pose_models.dart';
import 'pose_backend.dart';
import 'mlkit_pose_backend.dart';

/// Состояние PoseService
class PoseServiceState {
  final bool initializing;
  final bool initialized;
  final bool streaming;
  final PoseFrame? lastFrame;
  final double rawFps;          // оценка входного fps
  final double processedFps;    // фактическая обработка (после throttle)
  final int droppedFrames;      // сколько кадров пропущено throttle
  final int processedFrames;    // сколько обработано
  final int backendLatencyMs;   // последняя задержка backend
  final String? error;

  const PoseServiceState({
    this.initializing = false,
    this.initialized = false,
    this.streaming = false,
    this.lastFrame,
    this.rawFps = 0,
    this.processedFps = 0,
    this.droppedFrames = 0,
    this.processedFrames = 0,
    this.backendLatencyMs = 0,
    this.error,
  });

  PoseServiceState copyWith({
    bool? initializing,
    bool? initialized,
    bool? streaming,
    PoseFrame? lastFrame,
    double? rawFps,
    double? processedFps,
    int? droppedFrames,
    int? processedFrames,
    int? backendLatencyMs,
    String? error,
  }) {
    return PoseServiceState(
      initializing: initializing ?? this.initializing,
      initialized: initialized ?? this.initialized,
      streaming: streaming ?? this.streaming,
      lastFrame: lastFrame ?? this.lastFrame,
      rawFps: rawFps ?? this.rawFps,
      processedFps: processedFps ?? this.processedFps,
      droppedFrames: droppedFrames ?? this.droppedFrames,
      processedFrames: processedFrames ?? this.processedFrames,
      backendLatencyMs: backendLatencyMs ?? this.backendLatencyMs,
      error: error,
    );
  }
}

/// Riverpod StateNotifier для управления сервисом
class PoseService extends StateNotifier<PoseServiceState> {
  final PoseBackend _backend;
  final PoseBackendInitOptions _options;

  // FPS расчёт
  DateTime? _lastRawFrameTime;
  DateTime? _lastProcessedFrameTime;
  int _rawFrameCountWindow = 0;
  int _processedFrameCountWindow = 0;
  DateTime _fpsWindowStart = DateTime.now();

  // Throttle guard
  bool _processing = false;
  DateTime _lastProcessAttempt = DateTime.fromMillisecondsSinceEpoch(0);

  PoseService({
    PoseBackend? backend,
    PoseBackendInitOptions? options,
  })  : _backend = backend ?? MediaPipePoseBackendStub(),
        _options = options ?? const PoseBackendInitOptions(),
        super(const PoseServiceState());

  Future<void> initialize() async {
    if (state.initializing || state.initialized) return;
    state = state.copyWith(initializing: true, error: null);
    try {
      await _backend.initialize(_options);
      state = state.copyWith(
        initializing: false,
        initialized: true,
      );
    } catch (e) {
      state = state.copyWith(
        initializing: false,
        initialized: false,
        error: 'Pose backend init error: $e',
      );
    }
  }

  /// Обработка входного кадра из CameraController.startImageStream
  Future<void> processCameraImage(CameraImage image) async {
    if (!state.initialized) return;

    final now = DateTime.now();
    _rawFrameCountWindow++;
    // Оценка raw fps (каждые ~1 сек обновляем)
    _updateFps(now, isProcessed: false);

    // Throttle по времени
    final sinceLast = now.difference(_lastProcessAttempt).inMilliseconds;
    if (sinceLast < _options.targetProcessingIntervalMs) {
      // Пропускаем кадр
      state = state.copyWith(droppedFrames: state.droppedFrames + 1);
      return;
    }
    _lastProcessAttempt = now;

    if (_processing) {
      // если предыдущий кадр ещё обрабатывается — дроп
      state = state.copyWith(droppedFrames: state.droppedFrames + 1);
      return;
    }

    _processing = true;
    try {
      debugPrint('PoseService: Processing image ${image.width}x${image.height}');
      final result = await _backend.processCameraImage(image);
      
      if (result.frame != null) {
        debugPrint('PoseService: Got frame with ${result.frame!.points.length} points');
        _processedFrameCountWindow++;
        _updateFps(DateTime.now(), isProcessed: true);

        state = state.copyWith(
          lastFrame: result.frame,
          processedFrames: state.processedFrames + 1,
          backendLatencyMs: result.latency.inMilliseconds,
          streaming: true,
          error: result.hasError && result.error != 'throttled'
              ? result.error
              : null,
        );
      } else if (result.hasError && result.error != 'throttled') {
        debugPrint('PoseService: Backend error: ${result.error}');
        state = state.copyWith(error: result.error);
      }
    } catch (e) {
      debugPrint('PoseService: Processing error: $e');
      state = state.copyWith(error: 'process error: $e');
    } finally {
      _processing = false;
    }
  }

  void _updateFps(DateTime now, {required bool isProcessed}) {
    // Каждые 1000 ms пересчёт
    if (now.difference(_fpsWindowStart).inMilliseconds >= 1000) {
      final rawFps = _rawFrameCountWindow.toDouble();
      final procFps = _processedFrameCountWindow.toDouble();
      state = state.copyWith(
        rawFps: rawFps,
        processedFps: procFps,
      );
      _rawFrameCountWindow = 0;
      _processedFrameCountWindow = 0;
      _fpsWindowStart = now;
    }
    if (isProcessed) {
      _lastProcessedFrameTime = now;
    } else {
      _lastRawFrameTime = now;
    }
  }

  Future<void> disposeService() async {
    await _backend.dispose();
  }

  @override
  void dispose() {
    disposeService();
    super.dispose();
  }
}

/// Провайдер для сервиса (ленивая инициализация)
final poseServiceProvider =
    StateNotifierProvider<PoseService, PoseServiceState>((ref) {
  // Используем MLKit backend для реального определения поз
  final service = PoseService(
    backend: MLKitPoseBackend(),
    options: const PoseBackendInitOptions(
      useFrontCamera: true,
      mirrorFrontCamera: true,
      targetProcessingIntervalMs: 100, // 10 FPS
    ),
  );
  
  // Инициализация с обработкой ошибок
  unawaited(service.initialize().catchError((error) {
    debugPrint('MLKit init failed: $error, fallback to stub');
    // При ошибке создаем новый сервис со stub backend
    final stubService = PoseService(
      backend: MediaPipePoseBackendStub(),
    );
    return stubService.initialize();
  }));
  
  return service;
});
