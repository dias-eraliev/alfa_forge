import 'package:flutter/material.dart';

enum OnboardingButtonType { primary, secondary, text }

class OnboardingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final OnboardingButtonType type;
  final bool isLoading;
  final bool isEnabled;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double height;

  const OnboardingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = OnboardingButtonType.primary,
    this.isLoading = false,
    this.isEnabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.width,
    this.height = 48.0,
  });

  @override
  State<OnboardingButton> createState() => _OnboardingButtonState();
}

class _OnboardingButtonState extends State<OnboardingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 50),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Запускаем slide-in анимацию при создании
    if (widget.type == OnboardingButtonType.primary) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _animationController.forward();
      });
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.isEnabled && !widget.isLoading) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case OnboardingButtonType.primary:
        if (!widget.isEnabled || widget.isLoading) {
          return const Color(0xFF660000).withOpacity(0.5);
        }
        return const Color(0xFF660000);
      case OnboardingButtonType.secondary:
        return Colors.transparent;
      case OnboardingButtonType.text:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    switch (widget.type) {
      case OnboardingButtonType.primary:
        return const Color(0xFFE9E1D1);
      case OnboardingButtonType.secondary:
        if (!widget.isEnabled || widget.isLoading) {
          return const Color(0xFF660000).withOpacity(0.5);
        }
        return const Color(0xFF660000);
      case OnboardingButtonType.text:
        return const Color(0xFFE9E1D1);
    }
  }

  Border? _getBorder() {
    switch (widget.type) {
      case OnboardingButtonType.primary:
        return null;
      case OnboardingButtonType.secondary:
        return Border.all(
          color: widget.isEnabled && !widget.isLoading
              ? const Color(0xFF660000)
              : const Color(0xFF660000).withOpacity(0.5),
          width: 1,
        );
      case OnboardingButtonType.text:
        return null;
    }
  }

  Gradient? _getGradient() {
    if (widget.type == OnboardingButtonType.primary && 
        widget.isEnabled && 
        !widget.isLoading) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF660000), Color(0xFF990000)],
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient();
    
    Widget buttonChild = AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: widget.type == OnboardingButtonType.primary 
              ? _slideAnimation.value 
              : Offset.zero,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              color: gradient == null ? _getBackgroundColor() : null,
              gradient: gradient,
              border: _getBorder(),
              borderRadius: BorderRadius.circular(8),
              boxShadow: widget.type == OnboardingButtonType.primary &&
                      widget.isEnabled &&
                      !widget.isLoading
                  ? [
                      BoxShadow(
                        color: const Color(0xFF660000).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(),
                        ),
                      ),
                    )
                  : Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _getTextColor(),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );

    // Добавляем bounce эффект для primary кнопки
    if (widget.type == OnboardingButtonType.primary) {
      return AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: buttonChild,
      );
    }

    return buttonChild;
  }
}
