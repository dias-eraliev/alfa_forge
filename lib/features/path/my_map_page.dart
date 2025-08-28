import 'package:flutter/material.dart';
import '../shared/bottom_nav_scaffold.dart';
import '../../app/theme.dart';
import '../onboarding/models/development_sphere_model.dart';

class MyMapPage extends StatefulWidget {
  const MyMapPage({super.key});

  @override
  State<MyMapPage> createState() => _MyMapPageState();
}

class _MyMapPageState extends State<MyMapPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  
  // Пример данных прогресса пользователя
  final Map<String, double> _sphereProgress = {
    'body': 0.8,
    'will': 0.6,
    'focus': 0.4,
    'mind': 0.3,
    'peace': 0.2,
    'money': 0.1,
  };

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _progressController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavScaffold(
      currentRoute: '/my-map',
      child: SafeArea(
        child: Column(
          children: [
            // Заголовок
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: PRIMETheme.sand),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'МОЙ ПУТЬ',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 28,
                      color: PRIMETheme.sand,
                    ),
                  ),
                  const Spacer(),
                  _buildRankBadge(),
                ],
              ),
            ),
            
            // Прогресс-бар общий
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PRIMETheme.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Общий прогресс',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _getOverallProgress(),
                    backgroundColor: PRIMETheme.line,
                    valueColor: const AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(_getOverallProgress() * 100).toInt()}% Пройдено',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            
            // Карта путешествия
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final mapHeight = screenWidth * 2.5; // Адаптивная высота
                    
                    return SizedBox(
                      width: screenWidth,
                      height: mapHeight,
                      child: CustomPaint(
                        painter: MapPathPainter(_sphereProgress, _progressController, screenWidth),
                        child: Stack(
                          children: _buildMapNodes(screenWidth),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    final progress = _getOverallProgress();
    String rank;
    Color rankColor;
    
    if (progress < 0.3) {
      rank = 'НОВИЧОК';
      rankColor = PRIMETheme.sandWeak;
    } else if (progress < 0.6) {
      rank = 'ВОИН';
      rankColor = PRIMETheme.primary;
    } else if (progress < 0.8) {
      rank = 'ГЕРОЙ';
      rankColor = PRIMETheme.success;
    } else {
      rank = 'МАСТЕР';
      rankColor = PRIMETheme.warn;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: rankColor, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: rankColor.withOpacity(0.1),
      ),
      child: Text(
        rank,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: rankColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  double _getOverallProgress() {
    final values = _sphereProgress.values;
    return values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
  }

  List<Widget> _buildMapNodes(double screenWidth) {
    final nodes = <Widget>[];
    const spheres = DevelopmentSpheresData.spheres;
    
    // Адаптивные позиции узлов для мобильных устройств
    final positions = [
      Offset(screenWidth * 0.15, 80),   // ТЕЛО
      Offset(screenWidth * 0.75, 160),  // ВОЛЯ  
      Offset(screenWidth * 0.2, 280),   // ФОКУС
      Offset(screenWidth * 0.7, 400),   // РАЗУМ
      Offset(screenWidth * 0.25, 520),  // СПОКОЙСТВИЕ
      Offset(screenWidth * 0.65, 640),  // ДЕНЬГИ
    ];
    
    for (int i = 0; i < spheres.length && i < positions.length; i++) {
      final sphere = spheres[i];
      final progress = _sphereProgress[sphere.id] ?? 0.0;
      final position = positions[i];
      
      nodes.add(
        Positioned(
          left: position.dx,
          top: position.dy,
          child: _MapNode(
            sphere: sphere,
            progress: progress,
            pulseAnimation: _pulseController,
            onTap: () => _showSphereDetails(sphere, progress),
            screenWidth: screenWidth,
          ),
        ),
      );
    }
    
    return nodes;
  }

  void _showSphereDetails(DevelopmentSphere sphere, double progress) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SphereDetailsModal(
        sphere: sphere,
        progress: progress,
      ),
    );
  }
}

class MapPathPainter extends CustomPainter {
  final Map<String, double> sphereProgress;
  final AnimationController animationController;
  final double screenWidth;

  MapPathPainter(this.sphereProgress, this.animationController, this.screenWidth)
      : super(repaint: animationController);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = PRIMETheme.line
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final progressPaint = Paint()
      ..color = PRIMETheme.primary
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Создаем адаптивную извилистую дорожку
    path.moveTo(screenWidth * 0.15, 100);
    path.quadraticBezierTo(screenWidth * 0.6, 50, screenWidth * 0.75, 180);
    path.quadraticBezierTo(screenWidth * 0.4, 250, screenWidth * 0.2, 300);
    path.quadraticBezierTo(screenWidth * 0.55, 350, screenWidth * 0.7, 420);
    path.quadraticBezierTo(screenWidth * 0.4, 470, screenWidth * 0.25, 540);
    path.quadraticBezierTo(screenWidth * 0.55, 590, screenWidth * 0.65, 660);

    // Рисуем основной путь
    canvas.drawPath(path, paint);

    // Рисуем прогресс
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      final progressDistance = metric.length * (_getOverallProgress() * animationController.value);
      final progressPath = metric.extractPath(0, progressDistance);
      canvas.drawPath(progressPath, progressPaint);
    }
  }

  double _getOverallProgress() {
    final values = sphereProgress.values;
    return values.isEmpty ? 0.0 : values.reduce((a, b) => a + b) / values.length;
  }

  @override
  bool shouldRepaint(MapPathPainter oldDelegate) {
    return oldDelegate.sphereProgress != sphereProgress;
  }
}

class _MapNode extends StatelessWidget {
  final DevelopmentSphere sphere;
  final double progress;
  final AnimationController pulseAnimation;
  final VoidCallback onTap;
  final double screenWidth;

  const _MapNode({
    required this.sphere,
    required this.progress,
    required this.pulseAnimation,
    required this.onTap,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = progress >= 1.0;
    final isActive = progress > 0.0 && progress < 1.0;
    final nodeSize = screenWidth * 0.2; // Адаптивный размер узла
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseAnimation,
        builder: (context, child) {
          return Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _getNodeColor(isCompleted, isActive),
              border: Border.all(
                color: _getBorderColor(isCompleted, isActive),
                width: isActive ? 3 + pulseAnimation.value * 2 : 2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: PRIMETheme.primary.withOpacity(0.3 + pulseAnimation.value * 0.3),
                        blurRadius: 10 + pulseAnimation.value * 10,
                        spreadRadius: 2 + pulseAnimation.value * 3,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  sphere.icon,
                  style: TextStyle(fontSize: nodeSize * 0.3),
                ),
                SizedBox(height: nodeSize * 0.05),
                Text(
                  sphere.name,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PRIMETheme.sand,
                    fontSize: nodeSize * 0.12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getNodeColor(bool isCompleted, bool isActive) {
    if (isCompleted) return PRIMETheme.success.withOpacity(0.2);
    if (isActive) return PRIMETheme.primary.withOpacity(0.1);
    return PRIMETheme.line.withOpacity(0.1);
  }

  Color _getBorderColor(bool isCompleted, bool isActive) {
    if (isCompleted) return PRIMETheme.success;
    if (isActive) return PRIMETheme.primary;
    return PRIMETheme.line;
  }
}

class _SphereDetailsModal extends StatelessWidget {
  final DevelopmentSphere sphere;
  final double progress;

  const _SphereDetailsModal({
    required this.sphere,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                sphere.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sphere.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${(progress * 100).toInt()}% завершено',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: PRIMETheme.line,
            valueColor: const AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
          ),
          const SizedBox(height: 20),
          
          Text(
            'Привычки в этой сфере:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: Column(
                children: sphere.habits.take(5).map((habit) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: PRIMETheme.line),
                  ),
                  child: Row(
                    children: [
                      Text(habit.icon, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              habit.name,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              habit.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMETheme.primary,
                foregroundColor: PRIMETheme.sand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Закрыть'),
            ),
          ),
        ],
      ),
    );
  }
}
