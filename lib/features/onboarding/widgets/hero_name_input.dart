import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../app/theme.dart';

class HeroNameInput extends StatefulWidget {
  final TextEditingController controller;
  final String placeholder;
  final Function(String)? onChanged;
  final String? errorText;
  final bool autofocus;

  const HeroNameInput({
    super.key,
    required this.controller,
    this.placeholder = 'Имя героя',
    this.onChanged,
    this.errorText,
    this.autofocus = false,
  });

  @override
  State<HeroNameInput> createState() => _HeroNameInputState();
}

class _HeroNameInputState extends State<HeroNameInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _focusNode.addListener(_onFocusChange);

    // Запускаем анимацию появления
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _animationController.forward();
      }
    });

    if (widget.autofocus) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didUpdateWidget(HeroNameInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Анимация shake при ошибке
    if (widget.errorText != null && oldWidget.errorText == null) {
      _playShakeAnimation();
    }
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _playShakeAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Color _getBorderColor() {
    if (widget.errorText != null) {
      return PRIMETheme.primary;
    }
    if (_isFocused) {
      return PRIMETheme.primary;
    }
    return PRIMETheme.line;
  }

  double _getBorderWidth() {
    if (widget.errorText != null || _isFocused) {
      return 2.0;
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: widget.errorText != null
                ? Transform.translate(
                    offset: Offset(
                      10 * _shakeAnimation.value * 
                      (1 - _shakeAnimation.value) * 
                      (1 - _shakeAnimation.value),
                      0,
                    ),
                    child: child,
                  )
                : child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            autofocus: widget.autofocus,
            style: const TextStyle(
              fontSize: 16,
              color: PRIMETheme.sand,
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(20),
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Zа-яА-Я\s]'),
              ),
            ],
            decoration: InputDecoration(
              labelText: 'Имя героя',
              hintText: widget.placeholder,
              prefixIcon: const Icon(
                Icons.person_outline,
                color: PRIMETheme.sandWeak,
                size: 24,
              ),
              labelStyle: const TextStyle(
                color: PRIMETheme.sandWeak,
                fontSize: 16,
              ),
              hintStyle: TextStyle(
                color: PRIMETheme.sandWeak.withOpacity(0.6),
                fontSize: 16,
              ),
              filled: true,
              fillColor: PRIMETheme.bg,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.line, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.line, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: PRIMETheme.primary, width: 2),
              ),
              errorText: widget.errorText,
              errorStyle: const TextStyle(
                color: PRIMETheme.primary,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Счетчик символов
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Максимум 20 символов',
                style: TextStyle(
                  fontSize: 12,
                  color: PRIMETheme.sandWeak.withOpacity(0.7),
                ),
              ),
              AnimatedOpacity(
                opacity: _isFocused ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  '${widget.controller.text.length}/20',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.controller.text.length > 15
                        ? PRIMETheme.primary
                        : PRIMETheme.sandWeak.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
