// Core pose models for unified pose pipeline (MediaPipe primary, MLKit fallback)
import 'dart:math' as math;

/// Тип ключевой точки (унифицированный enum на базе MediaPipe/BlazePose 33 точек)
enum PosePointType {
  nose,
  leftEyeInner,
  leftEye,
  leftEyeOuter,
  rightEyeInner,
  rightEye,
  rightEyeOuter,
  leftEar,
  rightEar,
  leftMouth,
  rightMouth,
  leftShoulder,
  rightShoulder,
  leftElbow,
  rightElbow,
  leftWrist,
  rightWrist,
  leftPinky,
  rightPinky,
  leftIndex,
  rightIndex,
  leftThumb,
  rightThumb,
  leftHip,
  rightHip,
  leftKnee,
  rightKnee,
  leftAnkle,
  rightAnkle,
  leftHeel,
  rightHeel,
  leftFootIndex,
  rightFootIndex,
}

/// Унифицированная точка позы (нормализованные координаты 0..1 относительно исходного кадра)
class PosePoint {
  final PosePointType type;
  final int index;
  final double x;        // normalized [0..1]
  final double y;        // normalized [0..1]
  final double? z;       // относительная глубина (опц.)
  final double? visibility; // вероятность видимости (0..1)
  final double? presence;   // вероятность присутствия (0..1) (MediaPipe WorldLandmarks)

  const PosePoint({
    required this.type,
    required this.index,
    required this.x,
    required this.y,
    this.z,
    this.visibility,
    this.presence,
  });

  bool get isReliable =>
      (visibility ?? 0) > 0.5 || (presence ?? 0) > 0.5;

  PosePoint copyWith({
    PosePointType? type,
    int? index,
    double? x,
    double? y,
    double? z,
    double? visibility,
    double? presence,
  }) {
    return PosePoint(
      type: type ?? this.type,
      index: index ?? this.index,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      visibility: visibility ?? this.visibility,
      presence: presence ?? this.presence,
    );
  }

  static PosePoint? fromBackendMap(Map<String, dynamic> map) {
    // Ожидаемый формат:
    // {
    //   "index": 11,
    //   "x": 0.42, "y": 0.63, "z": -0.12,
    //   "visibility": 0.91, "presence": 0.88
    // }
    final idx = map['index'];
    if (idx is! int || idx < 0 || idx >= PosePointType.values.length) return null;
    return PosePoint(
      type: PosePointType.values[idx],
      index: idx,
      x: (map['x'] as num?)?.toDouble() ?? 0,
      y: (map['y'] as num?)?.toDouble() ?? 0,
      z: (map['z'] as num?)?.toDouble(),
      visibility: (map['visibility'] as num?)?.toDouble(),
      presence: (map['presence'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'index': index,
        'type': type.name,
        'x': x,
        'y': y,
        if (z != null) 'z': z,
        if (visibility != null) 'visibility': visibility,
        if (presence != null) 'presence': presence,
      };
}

/// Кадр позы: коллекция точек + метаданные
class PoseFrame {
  final List<PosePoint> points;
  final DateTime timestamp;
  final int? originalWidth;
  final int? originalHeight;
  final double? rawFps;        // FPS входного видеопотока
  final double? processedFps;  // частота обработанных кадров (после throttle)
  final bool mirrored;         // true если фронтальная камера и применено отражение

  const PoseFrame({
    required this.points,
    required this.timestamp,
    this.originalWidth,
    this.originalHeight,
    this.rawFps,
    this.processedFps,
    this.mirrored = true,
  });

  PosePoint? byType(PosePointType t) {
    // Поиск по типу точки
    try {
      return points.firstWhere((p) => p.type == t);
    } catch (e) {
      return null; // Возвращаем null если точка не найдена
    }
  }

  bool get hasMinimumBody {
    return [
      PosePointType.leftShoulder,
      PosePointType.rightShoulder,
      PosePointType.leftHip,
      PosePointType.rightHip,
      PosePointType.leftKnee,
      PosePointType.rightKnee,
      PosePointType.leftAnkle,
      PosePointType.rightAnkle,
    ].every((t) => byType(t)?.isReliable ?? false);
  }

  double get visibilityScore {
    if (points.isEmpty) return 0;
    final sum = points.fold<double>(
      0,
      (acc, p) => acc + (p.visibility ?? p.presence ?? 0),
    );
    return sum / points.length;
  }

  PoseFrame copyWith({
    List<PosePoint>? points,
    DateTime? timestamp,
    int? originalWidth,
    int? originalHeight,
    double? rawFps,
    double? processedFps,
    bool? mirrored,
  }) {
    return PoseFrame(
      points: points ?? this.points,
      timestamp: timestamp ?? this.timestamp,
      originalWidth: originalWidth ?? this.originalWidth,
      originalHeight: originalHeight ?? this.originalHeight,
      rawFps: rawFps ?? this.rawFps,
      processedFps: processedFps ?? this.processedFps,
      mirrored: mirrored ?? this.mirrored,
    );
  }
}

/// Утилиты для вычислений углов и расстояний
class PoseMath {
  /// Угол (pointB - вершина)
  static double? jointAngle(PosePoint? a, PosePoint? b, PosePoint? c) {
    if (a == null || b == null || c == null) return null;
    final v1x = a.x - b.x;
    final v1y = a.y - b.y;
    final v2x = c.x - b.x;
    final v2y = c.y - b.y;
    final dot = v1x * v2x + v1y * v2y;
    final m1 = math.sqrt(v1x * v1x + v1y * v1y);
    final m2 = math.sqrt(v2x * v2x + v2y * v2y);
    if (m1 == 0 || m2 == 0) return null;
    final cos = (dot / (m1 * m2)).clamp(-1.0, 1.0);
    return math.acos(cos) * 180 / math.pi;
  }

  static double? distance(PosePoint? a, PosePoint? b) {
    if (a == null || b == null) return null;
    final dx = a.x - b.x;
    final dy = a.y - b.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}
