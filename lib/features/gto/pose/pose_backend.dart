// Unified pose backend abstraction (MediaPipe primary, MLKit fallback)
import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'pose_models.dart';

/// Параметры инициализации backend
class PoseBackendInitOptions {
  final bool useFrontCamera;
  final int targetProcessingIntervalMs; // throttle интервал
  final bool mirrorFrontCamera;
  final String? modelAssetPath; // путь к .task (MediaPipe) или др. модели
  final bool enableWorldLandmarks;

  const PoseBackendInitOptions({
    this.useFrontCamera = true,
    this.targetProcessingIntervalMs = 100, // Более отзывчивое определение (10 FPS)
    this.mirrorFrontCamera = true,
    this.modelAssetPath,
    this.enableWorldLandmarks = false,
  });
}

/// Результат обработки кадра (минимальный, без фаз логики упражнения)
class PoseBackendResult {
  final PoseFrame? frame;
  final String? error;
  final Duration latency;

  const PoseBackendResult({
    required this.frame,
    required this.latency,
    this.error,
  });

  bool get hasError => error != null;
}

/// Интерфейс backend (платформенно-зависимая реализация)
abstract class PoseBackend {
  bool get isInitialized;
  Future<void> initialize(PoseBackendInitOptions options);
  Future<PoseBackendResult> processCameraImage(CameraImage image);
  Future<void> dispose();
}

class MethodChannelPoseBackend implements PoseBackend {
  final MethodChannel _channel = const MethodChannel('ai/pose');
  bool _initialized = false;
  late PoseBackendInitOptions _options;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize(PoseBackendInitOptions options) async {
    if (_initialized) return;
    _options = options;
    try {
      await _channel.invokeMethod('initialize', {
        'modelAsset': options.modelAssetPath,
        'mirror': options.mirrorFrontCamera,
      });
      _initialized = true;
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  @override
  Future<PoseBackendResult> processCameraImage(CameraImage image) async {
    final start = DateTime.now();
    if (!_initialized) {
      return const PoseBackendResult(
        frame: null,
        latency: Duration.zero,
        error: 'Backend not initialized',
      );
    }

    try {
      // Кодируем плейны YUV420 в base64 (временный формат для stub native)
      final planesB64 = image.planes.map((p) => base64Encode(p.bytes)).toList();

      final Map<dynamic, dynamic> native =
          await _channel.invokeMethod('process', {
        'width': image.width,
        'height': image.height,
        'format': 'yuv420',
        'planes': planesB64,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      final latencyMs = native['latencyMs'] as int? ?? 0;
      final List<dynamic> pts = native['points'] as List<dynamic>? ?? const [];

      // MediaPipe возвращает точки в порядке 0-32, добавляем индексы
      final parsedPoints = <PosePoint>[];
      for (int i = 0; i < pts.length && i < PosePointType.values.length; i++) {
        final p = pts[i];
        if (p is Map) {
          final map = p.map((k, v) => MapEntry(k.toString(), v));
          // Добавляем индекс, если его нет
          map['index'] = i;
          final point = PosePoint.fromBackendMap(map);
          if (point != null) parsedPoints.add(point);
        }
      }

      // Сортируем по index для быстрого доступа
      parsedPoints.sort((a, b) => a.index.compareTo(b.index));

      final frame = PoseFrame(
        points: parsedPoints,
        timestamp: DateTime.now(),
        originalWidth: image.width,
        originalHeight: image.height,
        rawFps: null,
        processedFps: null,
        mirrored: _options.useFrontCamera && _options.mirrorFrontCamera,
      );

      return PoseBackendResult(
        frame: frame,
        latency: Duration(milliseconds: latencyMs),
      );
    } catch (e) {
      return PoseBackendResult(
        frame: null,
        latency: DateTime.now().difference(start),
        error: 'process error: $e',
      );
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _channel.invokeMethod('dispose');
    } catch (_) {}
    _initialized = false;
  }
}

/// Stub реализация MediaPipe (пока без нативного слоя).
/// Возвращает пустой кадр для отладки архитектуры.
class MediaPipePoseBackendStub implements PoseBackend {
  bool _initialized = false;
  late PoseBackendInitOptions _options;
  DateTime? _lastProcessed;
  int _processedCount = 0;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize(PoseBackendInitOptions options) async {
    _options = options;
    _initialized = true;
  }

  @override
  Future<PoseBackendResult> processCameraImage(CameraImage image) async {
    final start = DateTime.now();

    if (!_initialized) {
      return const PoseBackendResult(
        frame: null,
        latency: Duration.zero,
        error: 'Backend not initialized',
      );
    }

    // Throttle (пока на уровне сервиса тоже будет, но оставим двойную защиту)
    final now = DateTime.now();
    if (_lastProcessed != null) {
      final diff = now.difference(_lastProcessed!);
      if (diff.inMilliseconds < _options.targetProcessingIntervalMs) {
        // Пропустить кадр
        return PoseBackendResult(
          frame: null,
          latency: diff,
          error: 'throttled',
        );
      }
    }
    _lastProcessed = now;
    _processedCount++;

    // Пустой список точек (в реальной реализации заменится результатом из нативного кода)
    final frame = PoseFrame(
      points: const [],
      timestamp: now,
      originalWidth: image.width,
      originalHeight: image.height,
      rawFps: null,
      processedFps: null,
      mirrored: _options.useFrontCamera && _options.mirrorFrontCamera,
    );

    return PoseBackendResult(
      frame: frame,
      latency: DateTime.now().difference(start),
    );
  }

  @override
  Future<void> dispose() async {
    _initialized = false;
  }
}
