import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../models/development_sphere_model.dart';

class SphereCard extends StatefulWidget {
  final DevelopmentSphere sphere;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDuration;
  final int animationDelay;

  const SphereCard({
    super.key,
    required this.sphere,
    required this.isSelected,
    required this.onTap,
    this.animationDuration = const Duration(milliseconds: 400),
    this.animationDelay = 0,
  });

  @override
  State<SphereCard> createState() => _SphereCardState();
}

class _SphereCardState extends State<SphereCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 50),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Staggered animation с задержкой
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  Color _getBackgroundColor() {
    if (widget.isSelected) {
      return PRIMETheme.primary.withOpacity(0.15);
    }
    return PRIMETheme.bg;
  }

  Color _getBorderColor() {
    if (widget.isSelected) {
      return PRIMETheme.primary;
    }
    return PRIMETheme.line;
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.isSelected) {
      return [
        BoxShadow(
          color: PRIMETheme.primary.withOpacity(0.3 * _glowAnimation.value),
          blurRadius: 20 * _glowAnimation.value,
          spreadRadius: 5 * _glowAnimation.value,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: PRIMETheme.primary.withOpacity(0.2 * _glowAnimation.value),
          blurRadius: 40 * _glowAnimation.value,
          spreadRadius: 10 * _glowAnimation.value,
          offset: const Offset(0, 16),
        ),
      ];
    }
    return [
      BoxShadow(
        color: PRIMETheme.bg.withOpacity(0.1),
        blurRadius: 8,
        spreadRadius: 1,
        offset: const Offset(0, 4),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final cardWidth = isSmallScreen ? 140.0 : 160.0;
    final cardHeight = isSmallScreen ? 140.0 : 160.0;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: Border.all(
              color: _getBorderColor(),
              width: widget.isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _getBoxShadow(),
          ),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Иконка сферы
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(12),
                  decoration: widget.isSelected
                      ? BoxDecoration(
                          color: PRIMETheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: PRIMETheme.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        )
                      : null,
                  child: Text(
                    widget.sphere.icon,
                    style: TextStyle(
                      fontSize: isSmallScreen ? 36 : 42,
                    ),
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 8 : 12),
                
                // Название сферы
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    widget.sphere.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w600,
                      color: widget.isSelected ? PRIMETheme.primary : PRIMETheme.sand,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 4 : 6),
                
                // Количество привычек
                Text(
                  '${widget.sphere.habits.length} привычек',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isSmallScreen ? 10 : 11,
                    color: widget.isSelected 
                        ? PRIMETheme.primary.withOpacity(0.8) 
                        : PRIMETheme.sandWeak.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Виджет для отображения сетки карточек сфер
class SpheresGrid extends StatelessWidget {
  final List<DevelopmentSphere> spheres;
  final List<DevelopmentSphere> selectedSpheres;
  final Function(DevelopmentSphere) onSphereToggle;

  const SpheresGrid({
    super.key,
    required this.spheres,
    required this.selectedSpheres,
    required this.onSphereToggle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Wrap(
      spacing: isSmallScreen ? 12 : 16,
      runSpacing: isSmallScreen ? 12 : 16,
      alignment: WrapAlignment.center,
      children: spheres.asMap().entries.map((entry) {
        final index = entry.key;
        final sphere = entry.value;
        
        return SphereCard(
          sphere: sphere,
          isSelected: selectedSpheres.contains(sphere),
          onTap: () => onSphereToggle(sphere),
          animationDelay: index * 100, // Staggered animation
        );
      }).toList(),
    );
  }
}
