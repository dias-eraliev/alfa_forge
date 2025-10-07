// Skeleton painter & widget for drawing pose landmarks (MediaPipe/MLKit unified)
//
// CURRENT STATUS (MVP):
// - Draws points & bones if provided PoseFrame (can be empty for now since stub backend returns empty list)
// - Color coding: joints (primary), unreliable (faded), active highlight (optional set)
// - Provides overlay with optional debug info (fps, counts)
//
// NEXT STEPS (when detectors ready):
// - Pass activePhase / keyAngles / formScore for richer styling
// - Highlight limbs under evaluation (e.g., arms for pushups)
//
// Usage example (after integrating poseService):
// final poseState = ref.watch(poseServiceProvider);
// Positioned.fill(
//   child: PoseSkeletonView(
//     frame: poseState.lastFrame,
//     showDebug: true,
//     debugLines: [
//       'rawFPS: ${poseState.rawFps.toStringAsFixed(1)}',
//       'procFPS: ${poseState.processedFps.toStringAsFixed(1)}',
//       'latency: ${poseState.backendLatencyMs} ms',
//       'points: ${poseState.lastFrame?.points.length ?? 0}',
//     ],
//   ),
// );
import 'package:flutter/material.dart';
import 'pose_models.dart';

class PoseSkeletonView extends StatelessWidget {
  final PoseFrame? frame;
  final bool showDebug;
  final List<String>? debugLines;
  final Set<PosePointType>? highlightPoints;
  final double pointRadius;
  final double strokeWidth;

  const PoseSkeletonView({
    super.key,
    required this.frame,
    this.showDebug = false,
    this.debugLines,
    this.highlightPoints,
    this.pointRadius = 5,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final f = frame;
    return Stack(
      children: [
        CustomPaint(
          painter: _SkeletonPainter(
            frame: f,
            pointRadius: pointRadius,
            strokeWidth: strokeWidth,
            highlightPoints: highlightPoints ?? const {},
          ),
          size: Size.infinite,
        ),
        if (showDebug) _buildDebugBox(context),
      ],
    );
  }

  Widget _buildDebugBox(BuildContext context) {
    final lines = debugLines ?? [];
    return Positioned(
      left: 12,
      top: 12,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white70,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'POSE DEBUG',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              for (final l in lines.take(12))
                Text(
                  l,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonPainter extends CustomPainter {
  final PoseFrame? frame;
  final double pointRadius;
  final double strokeWidth;
  final Set<PosePointType> highlightPoints;

  _SkeletonPainter({
    required this.frame,
    required this.pointRadius,
    required this.strokeWidth,
    required this.highlightPoints,
  });

  static const List<List<PosePointType>> _edges = [
    // Arms
    [PosePointType.leftShoulder, PosePointType.leftElbow],
    [PosePointType.leftElbow, PosePointType.leftWrist],
    [PosePointType.rightShoulder, PosePointType.rightElbow],
    [PosePointType.rightElbow, PosePointType.rightWrist],
    // Shoulders & torso
    [PosePointType.leftShoulder, PosePointType.rightShoulder],
    [PosePointType.leftShoulder, PosePointType.leftHip],
    [PosePointType.rightShoulder, PosePointType.rightHip],
    [PosePointType.leftHip, PosePointType.rightHip],
    // Legs
    [PosePointType.leftHip, PosePointType.leftKnee],
    [PosePointType.leftKnee, PosePointType.leftAnkle],
    [PosePointType.rightHip, PosePointType.rightKnee],
    [PosePointType.rightKnee, PosePointType.rightAnkle],
    // Feet
    [PosePointType.leftAnkle, PosePointType.leftHeel],
    [PosePointType.leftHeel, PosePointType.leftFootIndex],
    [PosePointType.rightAnkle, PosePointType.rightHeel],
    [PosePointType.rightHeel, PosePointType.rightFootIndex],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final f = frame;
    if (f == null || f.points.isEmpty) return;

    // Base paints
    final bonePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..color = Colors.cyanAccent.withOpacity(0.75);

    final highlightBonePaint = bonePaint.clone()
      ..color = Colors.amberAccent.withOpacity(0.9);

    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.cyanAccent.withOpacity(0.9);

    final highlightPointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.amberAccent;

    final unreliablePointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.grey.withOpacity(0.35);

    // Draw bones
    for (final edge in _edges) {
      final a = f.byType(edge[0]);
      final b = f.byType(edge[1]);
      if (a == null || b == null) continue;
      final pA = _toCanvas(a, size);
      final pB = _toCanvas(b, size);

      final involvedHighlighted = highlightPoints.contains(a.type) ||
          highlightPoints.contains(b.type);

      canvas.drawLine(
        pA,
        pB,
        involvedHighlighted ? highlightBonePaint : bonePaint,
      );
    }

    // Draw points
    for (final p in f.points) {
      final offset = _toCanvas(p, size);
      final paint = !p.isReliable
          ? unreliablePointPaint
          : highlightPoints.contains(p.type)
              ? highlightPointPaint
              : pointPaint;
      canvas.drawCircle(offset, pointRadius, paint);
    }
  }

  Offset _toCanvas(PosePoint p, Size size) {
    // If frame is mirrored we assume already mirrored x
    return Offset(p.x * size.width, p.y * size.height);
  }

  @override
  bool shouldRepaint(covariant _SkeletonPainter oldDelegate) {
    if (oldDelegate.frame?.timestamp != frame?.timestamp) return true;
    if (oldDelegate.highlightPoints.length != highlightPoints.length) return true;
    return false;
  }
}

extension on Paint {
  Paint clone() {
    return Paint()
      ..blendMode = blendMode
      ..color = color
      ..filterQuality = filterQuality
      ..imageFilter = imageFilter
      ..invertColors = invertColors
      ..isAntiAlias = isAntiAlias
      ..maskFilter = maskFilter
      ..shader = shader
      ..strokeCap = strokeCap
      ..strokeJoin = strokeJoin
      ..strokeMiterLimit = strokeMiterLimit
      ..strokeWidth = strokeWidth
      ..style = style;
  }
}
