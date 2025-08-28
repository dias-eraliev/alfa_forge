import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class ProgressDots extends StatefulWidget {
  final int totalSteps;
  final int currentStep;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double spacing;
  final bool animate;

  const ProgressDots({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 10.0,
    this.spacing = 16.0,
    this.animate = true,
  });

  @override
  State<ProgressDots> createState() => _ProgressDotsState();
}

class _ProgressDotsState extends State<ProgressDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(
      widget.totalSteps,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _controllers
        .map((controller) => Tween<double>(begin: 0.8, end: 1.2).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            ))
        .toList();

    // Анимируем активную точку
    if (widget.animate && widget.currentStep < widget.totalSteps) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _animateCurrentDot();
      });
    }
  }

  @override
  void didUpdateWidget(ProgressDots oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.currentStep != widget.currentStep && widget.animate) {
      _animateCurrentDot();
    }
  }

  void _animateCurrentDot() {
    if (widget.currentStep < widget.totalSteps) {
      final controller = _controllers[widget.currentStep];
      controller.forward().then((_) {
        if (mounted) {
          controller.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? PRIMETheme.primary;
    final inactiveColor = widget.inactiveColor ?? PRIMETheme.line;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.totalSteps, (index) {
        final isActive = index <= widget.currentStep;
        final isCurrent = index == widget.currentStep;
        final isCompleted = index < widget.currentStep;

        return AnimatedBuilder(
          animation: _scaleAnimations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Transform.scale(
                scale: isCurrent ? _scaleAnimations[index].value : 1.0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isCompleted ? widget.dotSize * 1.2 : widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: isActive ? activeColor : inactiveColor,
                    borderRadius: BorderRadius.circular(widget.dotSize / 2),
                    boxShadow: isActive && isCurrent
                        ? [
                            BoxShadow(
                              color: activeColor.withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : isCompleted
                            ? [
                                BoxShadow(
                                  color: activeColor.withOpacity(0.3),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                  ),
                  child: isCompleted
                      ? Center(
                          child: Icon(
                            Icons.check,
                            size: widget.dotSize * 0.6,
                            color: PRIMETheme.sand,
                          ),
                        )
                      : null,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
