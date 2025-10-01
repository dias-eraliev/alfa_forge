import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'exercise_model.dart';

class RealAIDetector {
  static final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );

  static bool _isDisposed = false;

  /// Анализирует кадр камеры и возвращает результат детекции
  static Future<AIDetectionResult> analyzeFrame(
    CameraImage image,
    String exerciseType,
    int currentCount,
  ) async {
    if (_isDisposed) {
      return AIDetectionResult(
        isGoodForm: false,
        isAverageForm: false,
        qualityPercentage: 0,
        feedback: 'Детектор не активен',
        phase: 'inactive',
        repetitionCount: currentCount,
      );
    }

    try {
      // Конвертируем CameraImage в InputImage
      final inputImage = _convertCameraImageToInputImage(image);
      
      // Получаем позы
      final poses = await _poseDetector.processImage(inputImage);
      
      if (poses.isEmpty) {
        return AIDetectionResult(
          isGoodForm: false,
          isAverageForm: false,
          qualityPercentage: 0,
          feedback: 'Человек не обнаружен в кадре',
          phase: 'no_person',
          repetitionCount: currentCount,
        );
      }

      final pose = poses.first;
      
      // Проверяем видимость всех ключевых точек для определения готовности
      if (exerciseType == 'positioning') {
        return _analyzeBodyPositioning(pose);
      }

      // Анализируем упражнение
      return _analyzeExercise(pose, exerciseType, currentCount);
      
    } catch (e) {
      print('Ошибка анализа позы: $e');
      return AIDetectionResult(
        isGoodForm: false,
        isAverageForm: false,
        qualityPercentage: 0,
        feedback: 'Ошибка анализа: $e',
        phase: 'error',
        repetitionCount: currentCount,
      );
    }
  }

  /// Проверяет, виден ли пользователь в полный рост для начала тренировки
  static AIDetectionResult _analyzeBodyPositioning(Pose pose) {
    final landmarks = pose.landmarks;
    
    // Ключевые точки для проверки полного тела
    final requiredLandmarks = [
      PoseLandmarkType.nose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.leftHip,
      PoseLandmarkType.rightHip,
      PoseLandmarkType.leftAnkle,
      PoseLandmarkType.rightAnkle,
    ];

    int visiblePoints = 0;
    double totalConfidence = 0;

    for (final landmarkType in requiredLandmarks) {
      final landmark = landmarks[landmarkType];
      // Проверяем, что landmark существует и находится в разумных пределах экрана
      if (landmark != null && 
          landmark.x >= 0 && landmark.x <= 1 && 
          landmark.y >= 0 && landmark.y <= 1) {
        visiblePoints++;
        totalConfidence += 1.0; // Считаем все видимые точки как полностью видимые
      }
    }

    final visibility = visiblePoints / requiredLandmarks.length;
    final avgConfidence = visiblePoints > 0 ? totalConfidence / visiblePoints : 0.0;
    
    // Проверяем, что человек стоит (не сидит/лежит)
    final nose = landmarks[PoseLandmarkType.nose];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

    bool isStanding = false;
    if (nose != null && leftHip != null && rightHip != null && 
        leftAnkle != null && rightAnkle != null) {
      
      final hipY = (leftHip.y + rightHip.y) / 2;
      final ankleY = (leftAnkle.y + rightAnkle.y) / 2;
      final headToHipDistance = (hipY - nose.y).abs();
      final hipToAnkleDistance = (ankleY - hipY).abs();
      
      // Проверяем пропорции стоящего человека
      isStanding = hipToAnkleDistance > headToHipDistance * 0.8;
    }

    if (visibility >= 0.8 && avgConfidence > 0.7 && isStanding) {
      return AIDetectionResult(
        isGoodForm: true,
        isAverageForm: false,
        qualityPercentage: (visibility * avgConfidence * 100).round(),
        feedback: 'Отлично! Вы в кадре полностью',
        phase: 'ready',
        repetitionCount: 0,
      );
    } else if (visibility >= 0.6) {
      return AIDetectionResult(
        isGoodForm: false,
        isAverageForm: true,
        qualityPercentage: (visibility * 70).round(),
        feedback: isStanding 
            ? 'Пожалуйста, отойдите чтобы было видно все тело'
            : 'Встаньте в полный рост перед камерой',
        phase: 'positioning',
        repetitionCount: 0,
      );
    } else {
      return AIDetectionResult(
        isGoodForm: false,
        isAverageForm: false,
        qualityPercentage: (visibility * 50).round(),
        feedback: 'Встаньте полностью в кадр камеры',
        phase: 'not_visible',
        repetitionCount: 0,
      );
    }
  }

  /// Анализирует конкретное упражнение
  static AIDetectionResult _analyzeExercise(
    Pose pose, 
    String exerciseType, 
    int currentCount
  ) {
    switch (exerciseType) {
      case 'pushups':
        return _analyzePushUps(pose, currentCount);
      case 'squats':
        return _analyzeSquats(pose, currentCount);
      case 'plank':
        return _analyzePlank(pose, currentCount);
      case 'jumping_jacks':
        return _analyzeJumpingJacks(pose, currentCount);
      default:
        return AIDetectionResult(
          isGoodForm: false,
          isAverageForm: false,
          qualityPercentage: 0,
          feedback: 'Неизвестный тип упражнения',
          phase: 'unknown',
          repetitionCount: currentCount,
        );
    }
  }

  /// Анализ отжиманий
  static AIDetectionResult _analyzePushUps(Pose pose, int currentCount) {
    final landmarks = pose.landmarks;
    
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftElbow = landmarks[PoseLandmarkType.leftElbow];
    final rightElbow = landmarks[PoseLandmarkType.rightElbow];
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];

    if (leftShoulder == null || rightShoulder == null || 
        leftElbow == null || rightElbow == null ||
        leftWrist == null || rightWrist == null) {
      return AIDetectionResult(
        isGoodForm: false,
        isAverageForm: false,
        qualityPercentage: 0,
        feedback: 'Руки не видны в кадре',
        phase: 'not_visible',
        repetitionCount: currentCount,
      );
    }

    // Вычисляем углы в локтях
    final leftElbowAngle = _calculateAngle(leftShoulder, leftElbow, leftWrist);
    final rightElbowAngle = _calculateAngle(rightShoulder, rightElbow, rightWrist);
    final avgElbowAngle = (leftElbowAngle + rightElbowAngle) / 2;

    String phase;
    bool isGoodForm = false;
    bool isAverageForm = false;
    String feedback;
    int quality;

    if (avgElbowAngle > 160) {
      phase = 'up';
      isGoodForm = true;
      feedback = 'Хорошая позиция вверх';
      quality = 85;
    } else if (avgElbowAngle < 90) {
      phase = 'down';
      isGoodForm = true;
      feedback = 'Отличное опускание';
      quality = 90;
    } else {
      phase = 'transition';
      isAverageForm = true;
      feedback = 'Продолжайте движение';
      quality = 70;
    }

    return AIDetectionResult(
      isGoodForm: isGoodForm,
      isAverageForm: isAverageForm,
      qualityPercentage: quality,
      feedback: feedback,
      phase: phase,
      repetitionCount: currentCount,
    );
  }

  /// Анализ приседаний
  static AIDetectionResult _analyzeSquats(Pose pose, int currentCount) {
    final landmarks = pose.landmarks;
    
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];
    final leftKnee = landmarks[PoseLandmarkType.leftKnee];
    final rightKnee = landmarks[PoseLandmarkType.rightKnee];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];

    if (leftHip == null || rightHip == null || 
        leftKnee == null || rightKnee == null ||
        leftAnkle == null || rightAnkle == null) {
      return AIDetectionResult(
        isGoodForm: false,
        isAverageForm: false,
        qualityPercentage: 0,
        feedback: 'Ноги не видны в кадре',
        phase: 'not_visible',
        repetitionCount: currentCount,
      );
    }

    // Вычисляем углы в коленях
    final leftKneeAngle = _calculateAngle(leftHip, leftKnee, leftAnkle);
    final rightKneeAngle = _calculateAngle(rightHip, rightKnee, rightAnkle);
    final avgKneeAngle = (leftKneeAngle + rightKneeAngle) / 2;

    String phase;
    bool isGoodForm = false;
    bool isAverageForm = false;
    String feedback;
    int quality;

    if (avgKneeAngle > 160) {
      phase = 'up';
      isGoodForm = true;
      feedback = 'Отлично! Полное выпрямление';
      quality = 85;
    } else if (avgKneeAngle < 100) {
      phase = 'down';
      isGoodForm = true;
      feedback = 'Хорошая глубина приседа';
      quality = 90;
    } else {
      phase = 'transition';
      isAverageForm = true;
      feedback = 'Продолжайте движение';
      quality = 70;
    }

    return AIDetectionResult(
      isGoodForm: isGoodForm,
      isAverageForm: isAverageForm,
      qualityPercentage: quality,
      feedback: feedback,
      phase: phase,
      repetitionCount: currentCount,
    );
  }

  /// Анализ планки
  static AIDetectionResult _analyzePlank(Pose pose, int currentCount) {
    // Для планки currentCount = секунды удержания
    final landmarks = pose.landmarks;
    
    final leftShoulder = landmarks[PoseLandmarkType.leftShoulder];
    final rightShoulder = landmarks[PoseLandmarkType.rightShoulder];
    final leftHip = landmarks[PoseLandmarkType.leftHip];
    final rightHip = landmarks[PoseLandmarkType.rightHip];

    if (leftShoulder == null || rightShoulder == null || 
        leftHip == null || rightHip == null) {
      return AIDetectionResult(
        isGoodForm: false,
        isAverageForm: false,
        qualityPercentage: 0,
        feedback: 'Корпус не виден в кадре',
        phase: 'not_visible',
        repetitionCount: currentCount,
      );
    }

    // Проверяем прямую линию тела
    final shoulderY = (leftShoulder.y + rightShoulder.y) / 2;
    final hipY = (leftHip.y + rightHip.y) / 2;
    final bodyAlignment = (shoulderY - hipY).abs();

    bool isGoodForm = false;
    bool isAverageForm = false;
    String feedback;
    int quality;

    if (bodyAlignment < 0.05) {
      isGoodForm = true;
      feedback = 'Отличная планка! Держите позицию';
      quality = 90;
    } else if (bodyAlignment < 0.1) {
      isAverageForm = true;
      feedback = 'Выровняйте тело в прямую линию';
      quality = 75;
    } else {
      feedback = 'Корректируйте позицию планки';
      quality = 50;
    }

    return AIDetectionResult(
      isGoodForm: isGoodForm,
      isAverageForm: isAverageForm,
      qualityPercentage: quality,
      feedback: feedback,
      phase: 'hold',
      repetitionCount: currentCount,
    );
  }

  /// Анализ прыжков "звездочкой"
  static AIDetectionResult _analyzeJumpingJacks(Pose pose, int currentCount) {
    final landmarks = pose.landmarks;
    
    final leftWrist = landmarks[PoseLandmarkType.leftWrist];
    final rightWrist = landmarks[PoseLandmarkType.rightWrist];
    final leftAnkle = landmarks[PoseLandmarkType.leftAnkle];
    final rightAnkle = landmarks[PoseLandmarkType.rightAnkle];
    final nose = landmarks[PoseLandmarkType.nose];

    if (leftWrist == null || rightWrist == null || 
        leftAnkle == null || rightAnkle == null || nose == null) {
      return AIDetectionResult(
        isGoodForm: false,
        isAverageForm: false,
        qualityPercentage: 0,
        feedback: 'Руки и ноги не видны в кадре',
        phase: 'not_visible',
        repetitionCount: currentCount,
      );
    }

    // Проверяем позицию рук и ног
    final armsRaised = leftWrist.y < nose.y && rightWrist.y < nose.y;
    final legsApart = (leftAnkle.x - rightAnkle.x).abs() > 0.3;

    String phase;
    bool isGoodForm = false;
    bool isAverageForm = false;
    String feedback;
    int quality;

    if (armsRaised && legsApart) {
      phase = 'open';
      isGoodForm = true;
      feedback = 'Отличный разворот!';
      quality = 85;
    } else if (!armsRaised && !legsApart) {
      phase = 'closed';
      isGoodForm = true;
      feedback = 'Хорошее сведение';
      quality = 85;
    } else {
      phase = 'transition';
      isAverageForm = true;
      feedback = 'Продолжайте движение';
      quality = 70;
    }

    return AIDetectionResult(
      isGoodForm: isGoodForm,
      isAverageForm: isAverageForm,
      qualityPercentage: quality,
      feedback: feedback,
      phase: phase,
      repetitionCount: currentCount,
    );
  }

  /// Вычисляет угол между тремя точками
  static double _calculateAngle(
    PoseLandmark point1,
    PoseLandmark point2,
    PoseLandmark point3,
  ) {
    final vector1 = [point1.x - point2.x, point1.y - point2.y];
    final vector2 = [point3.x - point2.x, point3.y - point2.y];
    
    final dot = vector1[0] * vector2[0] + vector1[1] * vector2[1];
    final mag1 = math.sqrt(vector1[0] * vector1[0] + vector1[1] * vector1[1]);
    final mag2 = math.sqrt(vector2[0] * vector2[0] + vector2[1] * vector2[1]);
    
    final cos = dot / (mag1 * mag2);
    final angle = math.acos(cos.clamp(-1.0, 1.0)) * 180 / math.pi;
    
    return angle;
  }

  /// Конвертирует CameraImage в InputImage для ML Kit
  static InputImage _convertCameraImageToInputImage(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final imageSize = Size(image.width.toDouble(), image.height.toDouble());

    const imageRotation = InputImageRotation.rotation0deg;
    const imageFormat = InputImageFormat.nv21;

    final metadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: imageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );
  }

  /// Освобождает ресурсы детектора
  static Future<void> dispose() async {
    _isDisposed = true;
    await _poseDetector.close();
  }
}
