import 'package:alfa_forge/app/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/progress_dots.dart';
import 'name_page.dart'; // Для доступа к onboardingControllerProvider

class EmailVerificationPage extends ConsumerStatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  ConsumerState<EmailVerificationPage> createState() =>
      _EmailVerificationPageState();
}

class _EmailVerificationPageState extends ConsumerState<EmailVerificationPage> {
  bool _isResending = false;

  @override
  void initState() {
    super.initState();

    // На этом этапе сессии может не быть, так как email еще не подтвержден
    // Поэтому убираем проверку сессии и сразу переходим к проверке статуса
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVerificationStatusSilently();
      _setupAuthListener();
    });
  }

  void _checkVerificationStatusSilently() async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.refreshSession();

      final currentUser = authService.currentUser;
      if (currentUser != null &&
          currentUser.emailConfirmedAt != null &&
          mounted) {
        // Email уже подтвержден, завершаем онбординг автоматически
        _handleEmailConfirmed();
      }
    } catch (error) {
      // Игнорируем ошибки при автоматической проверке
      debugPrint('Silent verification check failed: $error');
    }
  }

  void _setupAuthListener() {
    // Слушаем изменения состояния аутентификации
    ref.read(authServiceProvider).authStateChanges.listen((event) {
      if (event.session?.user.emailConfirmedAt != null && mounted) {
        // Email подтвержден автоматически, завершаем онбординг
        _handleEmailConfirmed();
      }
    });
  }

  void _handleEmailConfirmed() async {
    final controller = ref.read(onboardingControllerProvider);
    await controller.completeOnboarding();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email подтвержден! Добро пожаловать в PRIME!'),
          backgroundColor: PRIMETheme.success,
          duration: Duration(seconds: 3),
        ),
      );
      context.go('/');
    }
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);

    try {
      final authService = ref.read(authServiceProvider);
      final controller = ref.read(onboardingControllerProvider);

      // Берем email из OnboardingController
      final email = controller.email;
      if (email != null && email.isNotEmpty) {
        await authService.resendVerificationEmail(email);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Письмо подтверждения отправлено повторно'),
              backgroundColor: PRIMETheme.success,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email не найден. Попробуйте начать регистрацию заново.',
              ),
              backgroundColor: PRIMETheme.primary,
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка отправки письма: ${error.toString()}'),
            backgroundColor: PRIMETheme.primary,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _checkVerificationStatus() async {
    try {
      final controller = ref.read(onboardingControllerProvider);

      // Берем email и пароль из OnboardingController
      final email = controller.email;
      final password = controller.password;

      if (email == null ||
          password == null ||
          email.isEmpty ||
          password.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email или пароль не найдены. Попробуйте начать регистрацию заново.',
              ),
              backgroundColor: PRIMETheme.primary,
            ),
          );
        }
        return;
      }

  // Теперь пробуем войти в систему — если email подтвержден, login пройдет успешно
      final supabase = SupabaseService();
      await supabase.auth.signInWithPassword(email: email, password: password);

  // Завершаем онбординг (идемпотентно, контроллер защищен от повторов)
  await controller.completeOnboarding();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email подтвержден! Добро пожаловать в PRIME!'),
            backgroundColor: PRIMETheme.success,
            duration: Duration(seconds: 3),
          ),
        );
        context.go('/');
      }
    } catch (error) {
      // Если login не прошел, значит email еще не подтвержден
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Email еще не подтвержден. Проверьте почту и перейдите по ссылке.',
            ),
            backgroundColor: PRIMETheme.primary,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isSmallScreen = screenWidth < 600;

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
              onPressed: () => context.go('/onboarding/password'),
            ),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 32 : 64,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: screenHeight * 0.7,
                    maxWidth: 500,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Progress dots
                      const ProgressDots(currentStep: 6, totalSteps: 7),

                      SizedBox(height: isSmallScreen ? 40 : 60),

                      // Email icon
                      Container(
                        width: isSmallScreen ? 80 : 100,
                        height: isSmallScreen ? 80 : 100,
                        decoration: BoxDecoration(
                          color: PRIMETheme.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.email_outlined,
                          size: isSmallScreen ? 40 : 50,
                          color: PRIMETheme.primary,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 32 : 40),

                      // Title
                      Text(
                        'Подтвердите email',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: PRIMETheme.sand,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Description
                      Text(
                        'Мы отправили письмо с ссылкой для подтверждения на ваш email адрес. Пожалуйста, проверьте почту и перейдите по ссылке.',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          color: PRIMETheme.sandWeak,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: isSmallScreen ? 40 : 60),

                      // Check verification button
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 56 : 64,
                        child: ElevatedButton(
                          onPressed: _checkVerificationStatus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: PRIMETheme.primary,
                            foregroundColor: PRIMETheme.sand,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Я подтвердил email',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 20),

                      // Resend email button
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 56 : 64,
                        child: OutlinedButton(
                          onPressed: _isResending
                              ? null
                              : _resendVerificationEmail,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: PRIMETheme.line),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isResending
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      PRIMETheme.primary,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Отправить письмо повторно',
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 16 : 18,
                                    color: PRIMETheme.sand,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 32 : 40),

                      // Additional info
                      Container(
                        padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                        decoration: BoxDecoration(
                          color: PRIMETheme.cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: PRIMETheme.line),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: PRIMETheme.sandWeak,
                              size: isSmallScreen ? 24 : 28,
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Text(
                              'Не получили письмо?',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.w600,
                                color: PRIMETheme.sand,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isSmallScreen ? 8 : 12),
                            Text(
                              'Проверьте папку "Спам" или "Нежелательная почта". Если письмо не приходит в течение 5 минут, нажмите кнопку "Отправить письмо повторно".',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 14 : 16,
                                color: PRIMETheme.sandWeak,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 40 : 60),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
