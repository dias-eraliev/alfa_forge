import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../widgets/progress_dots.dart';
import 'name_page.dart'; // Для доступа к provider

class PasswordPage extends ConsumerStatefulWidget {
  const PasswordPage({super.key});

  @override
  ConsumerState<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends ConsumerState<PasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;

    final controller = ref.read(onboardingControllerProvider);
    controller.setPassword(_passwordController.text);

    // Переходим к финальному шагу регистрации
    context.go('/onboarding/ready');
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(onboardingControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final cardWidth = isSmallScreen ? screenWidth * 0.9 : 400.0;

    return Scaffold(
      backgroundColor: PRIMETheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: PRIMETheme.sand,
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: () => context.go('/onboarding/habits'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 40,
              vertical: 20,
            ),
            child: Container(
              width: cardWidth,
              constraints: BoxConstraints(
                minHeight: screenHeight * 0.6,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Прогресс (теперь 7 шагов: профиль, username, пароль, сферы, привычки, email-подтверждение, готово)
                  const ProgressDots(
                    totalSteps: 7,
                    currentStep: 5,
                  ),

                  SizedBox(height: isSmallScreen ? 40 : 60),

                  // Заголовок
                  Column(
                    children: [
                      Text(
                        'СОЗДАНИЕ ПАРОЛЯ',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: isSmallScreen ? 48 : 56,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: PRIMETheme.sand,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 8 : 12),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 16 : 20,
                          vertical: isSmallScreen ? 8 : 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: PRIMETheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: PRIMETheme.primary.withOpacity(0.1),
                        ),
                        child: Text(
                          'БЕЗОПАСНОСТЬ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: PRIMETheme.primary,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 16),

                      Text(
                        'Создайте надежный пароль для защиты вашего аккаунта',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: PRIMETheme.sandWeak,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                  SizedBox(height: isSmallScreen ? 40 : 60),

                  // Форма пароля
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Поле пароля
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: PRIMETheme.sand,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Пароль',
                            hintText: 'Введите пароль (минимум 6 символов)',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: PRIMETheme.sandWeak,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: PRIMETheme.sandWeak,
                                size: isSmallScreen ? 20 : 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            ),
                            labelStyle: TextStyle(
                              color: PRIMETheme.sandWeak,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            hintStyle: TextStyle(
                              color: PRIMETheme.sandWeak.withOpacity(0.6),
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            filled: true,
                            fillColor: PRIMETheme.bg,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 20,
                              vertical: isSmallScreen ? 16 : 20,
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
                            errorStyle: TextStyle(
                              color: PRIMETheme.primary,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Введите пароль';
                            }
                            if (value.length < 6) {
                              return 'Пароль должен содержать минимум 6 символов';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: isSmallScreen ? 16 : 20),

                        // Поле подтверждения пароля
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: isSmallScreen ? 14 : 16,
                            color: PRIMETheme.sand,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Подтверждение пароля',
                            hintText: 'Повторите пароль',
                            prefixIcon: Icon(
                              Icons.lock_reset,
                              color: PRIMETheme.sandWeak,
                              size: isSmallScreen ? 20 : 24,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                color: PRIMETheme.sandWeak,
                                size: isSmallScreen ? 20 : 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                });
                              },
                            ),
                            labelStyle: TextStyle(
                              color: PRIMETheme.sandWeak,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            hintStyle: TextStyle(
                              color: PRIMETheme.sandWeak.withOpacity(0.6),
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            filled: true,
                            fillColor: PRIMETheme.bg,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 20,
                              vertical: isSmallScreen ? 16 : 20,
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
                            errorStyle: TextStyle(
                              color: PRIMETheme.primary,
                              fontSize: isSmallScreen ? 12 : 14,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Подтвердите пароль';
                            }
                            if (value != _passwordController.text) {
                              return 'Пароли не совпадают';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 40 : 60),

                  // Кнопка продолжения
                  SizedBox(
                    width: double.infinity,
                    height: isSmallScreen ? 50 : 56,
                    child: ElevatedButton(
                      onPressed: _continue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMETheme.primary,
                        foregroundColor: PRIMETheme.sand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: PRIMETheme.primary.withOpacity(0.3),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ПРОДОЛЖИТЬ',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 24 : 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}