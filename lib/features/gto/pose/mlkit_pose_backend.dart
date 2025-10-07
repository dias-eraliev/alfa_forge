// MLKit-based pose backend для реального определения поз
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'pose_models.dart';
import 'pose_backend.dart';

/// MLKit реализация для реального определения поз через Google ML Kit
class MLKitPoseBackend implements PoseBackend {
  PoseDetector? _detector;
  bool _initialized = false;
  late PoseBackendInitOptions _options;

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize(PoseBackendInitOptions options) async {
    if (_initialized) return;
    
    _options = options;
    
    try {
      // Создаем детектор поз с оптимальными настройками
      _detector = PoseDetector(
        options: PoseDetectorOptions(
          mode: PoseDetectionMode.stream, // Для видео потока
          model: PoseDetectionModel.accurate, // Точная модель
        ),
      );
      
      _initialized = true;
    } catch (e) {
      _initialized = false;
      rethrow;
    }
  }

  @override
  Future<PoseBackendResult> processCameraImage(CameraImage image) async {
    final start = DateTime.now();
    
    if (!_initialized || _detector == null) {
      return PoseBackendResult(
        frame: null,
        latency: Duration.zero,
        error: 'MLKit detector not initialized',
      );
    }

    try {
      // Конвертируем CameraImage в InputImage для ML Kit
      final inputImage = _convertCameraImage(image);
      if (inputImage == null) {
        return PoseBackendResult(
          frame: null,
          latency: DateTime.now().difference(start),
          error: 'Failed to convert camera image',
        );
      }

      // Детекция поз через ML Kit
      final poses = await _detector!.processImage(inputImage);
      
      // Конвертируем результат в наш формат
      final points = <PosePoint>[];
      
      if (poses.isNotEmpty) {
        final pose = poses.first; // Берем первую позу
        
        // Конвертируем ML Kit landmarks в наши PosePoint
        for (final landmark in pose.landmarks.values) {
          final poseType = _convertMLKitLandmarkType(landmark.type);
          if (poseType != null) {
            final point = PosePoint(
              type: poseType,
              index: poseType.index,
              x: landmark.x / image.width, // Нормализуем к 0-1
              y: landmark.y / image.height,
              z: null, // ML Kit не предоставляет Z
              visibility: landmark.likelihood, // Используем likelihood как visibility
              presence: landmark.likelihood,
            );
            points.add(point);
          }
        }
      }

      // Сортируем по индексу для быстрого доступа
      points.sort((a, b) => a.index.compareTo(b.index));

      final frame = PoseFrame(
        points: points,
        timestamp: DateTime.now(),
        originalWidth: image.width,
        originalHeight: image.height,
        mirrored: _options.useFrontCamera && _options.mirrorFrontCamera,
      );

      return PoseBackendResult(
        frame: frame,
        latency: DateTime.now().difference(start),
      );

    } catch (e) {
      return PoseBackendResult(
        frame: null,
        latency: DateTime.now().difference(start),
        error: 'MLKit processing error: $e',
      );
    }
  }

  /// Конвертирует CameraImage в InputImage для ML Kit
  InputImage? _convertCameraImage(CameraImage image) {
    try {
      // Используем упрощенный метод конвертации
      final allBytes = <int>[];
      for (final Plane plane in image.planes) {
        allBytes.addAll(plane.bytes);
      }
      final bytes = Uint8List.fromList(allBytes);

      final inputImageRotation = _options.useFrontCamera 
          ? InputImageRotation.rotation270deg 
          : InputImageRotation.rotation90deg;

      final inputImageData = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: inputImageRotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: image.planes.first.bytesPerRow,
      );

      return InputImage.fromBytes(
        bytes: bytes,
        metadata: inputImageData,
      );
    } catch (e) {
      return null;
    }
  }

  /// Конвертирует ML Kit landmark type в наш PosePointType
  PosePointType? _convertMLKitLandmarkType(PoseLandmarkType mlkitType) {
    switch (mlkitType) {
      case PoseLandmarkType.nose:
        return PosePointType.nose;
      case PoseLandmarkType.leftEyeInner:
        return PosePointType.leftEyeInner;
      case PoseLandmarkType.leftEye:
        return PosePointType.leftEye;
      case PoseLandmarkType.leftEyeOuter:
        return PosePointType.leftEyeOuter;
      case PoseLandmarkType.rightEyeInner:
        return PosePointType.rightEyeInner;
      case PoseLandmarkType.rightEye:
        return PosePointType.rightEye;
      case PoseLandmarkType.rightEyeOuter:
        return PosePointType.rightEyeOuter;
      case PoseLandmarkType.leftEar:
        return PosePointType.leftEar;
      case PoseLandmarkType.rightEar:
        return PosePointType.rightEar;
      case PoseLandmarkType.leftMouth:
        return PosePointType.leftMouth;
      case PoseLandmarkType.rightMouth:
        return PosePointType.rightMouth;
      case PoseLandmarkType.leftShoulder:
        return PosePointType.leftShoulder;
      case PoseLandmarkType.rightShoulder:
        return PosePointType.rightShoulder;
      case PoseLandmarkType.leftElbow:
        return PosePointType.leftElbow;
      case PoseLandmarkType.rightElbow:
        return PosePointType.rightElbow;
      case PoseLandmarkType.leftWrist:
        return PosePointType.leftWrist;
      case PoseLandmarkType.rightWrist:
        return PosePointType.rightWrist;
      case PoseLandmarkType.leftPinky:
        return PosePointType.leftPinky;
      case PoseLandmarkType.rightPinky:
        return PosePointType.rightPinky;
      case PoseLandmarkType.leftIndex:
        return PosePointType.leftIndex;
      case PoseLandmarkType.rightIndex:
        return PosePointType.rightIndex;
      case PoseLandmarkType.leftThumb:
        return PosePointType.leftThumb;
      case PoseLandmarkType.rightThumb:
        return PosePointType.rightThumb;
      case PoseLandmarkType.leftHip:
        return PosePointType.leftHip;
      case PoseLandmarkType.rightHip:
        return PosePointType.rightHip;
      case PoseLandmarkType.leftKnee:
        return PosePointType.leftKnee;
      case PoseLandmarkType.rightKnee:
        return PosePointType.rightKnee;
      case PoseLandmarkType.leftAnkle:
        return PosePointType.leftAnkle;
      case PoseLandmarkType.rightAnkle:
        return PosePointType.rightAnkle;
      case PoseLandmarkType.leftHeel:
        return PosePointType.leftHeel;
      case PoseLandmarkType.rightHeel:
        return PosePointType.rightHeel;
      case PoseLandmarkType.leftFootIndex:
        return PosePointType.leftFootIndex;
      case PoseLandmarkType.rightFootIndex:
        return PosePointType.rightFootIndex;
      default:
        return null;
    }
  }

  @override
  Future<void> dispose() async {
    await _detector?.close();
    _detector = null;
    _initialized = false;
  }
}
