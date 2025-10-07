import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../controllers/onboarding_controller.dart';
import '../widgets/progress_dots.dart';

final onboardingControllerProvider = ChangeNotifierProvider<OnboardingController>(
  (ref) => OnboardingController(),
);

class NamePage extends ConsumerStatefulWidget {
  const NamePage({super.key});

  @override
  ConsumerState<NamePage> createState() => _NamePageState();
}

class _NamePageState extends ConsumerState<NamePage> {
  late TextEditingController _nameController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    // Загружаем сохраненные данные после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingControllerProvider).loadData();
      final username = ref.read(onboardingControllerProvider).username;
      if (username != null) {
        _nameController.text = username;
      }
      setState(() {}); // обновить кнопку
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _validateAndContinue() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() {
        _errorText = 'Введите имя пользователя';
      });
      return;
    }

    if (name.length < 2) {
      setState(() {
        _errorText = 'Слишком короткое имя';
      });
      return;
    }

    ref.read(onboardingControllerProvider).setUsername(name);
    context.go('/onboarding/habits');
  }

  void _onNameChanged(String value) {
    if (_errorText != null) {
      setState(() {
        _errorText = null;
      });
    }
    ref.read(onboardingControllerProvider).setUsername(value);
    setState(() {}); // для обновления состояния кнопки
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
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
          onPressed: () => context.go('/onboarding/profile'),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = isSmallScreen ? 24.0 : 64.0;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 32),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ProgressDots(
                        totalSteps: 5,
                        currentStep: 2,
                      ),
                      SizedBox(height: isSmallScreen ? 36 : 52),
                      _RegistrationHeader(
                        isSmall: isSmallScreen,
                        tag: 'РЕГИСТРАЦИЯ',
                        subtitle: 'Создание учетной записи пользователя',
                      ),
                      SizedBox(height: isSmallScreen ? 36 : 52),
                      TextFormField(
                        controller: _nameController,
                        autofocus: true,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: PRIMETheme.sand,
                            ),
                        decoration: InputDecoration(
                          labelText: 'Имя пользователя',
                          hintText: 'Введите ваше имя',
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: PRIMETheme.sandWeak,
                            size: isSmallScreen ? 20 : 24,
                          ),
                          labelStyle: TextStyle(
                            color: PRIMETheme.sandWeak,
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          hintStyle: TextStyle(
                            color: PRIMETheme.sandWeak.withValues(alpha: 0.6),
                            fontSize: isSmallScreen ? 14 : 16,
                          ),
                          errorText: _errorText,
                          filled: true,
                          fillColor: PRIMETheme.bg,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16 : 20,
                            vertical: isSmallScreen ? 16 : 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: PRIMETheme.line,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: PRIMETheme.line,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: PRIMETheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: PRIMETheme.primary,
                              width: 2,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: PRIMETheme.primary,
                              width: 2,
                            ),
                          ),
                          errorStyle: TextStyle(
                            color: PRIMETheme.primary,
                            fontSize: isSmallScreen ? 12 : 14,
                          ),
                        ),
                        onChanged: _onNameChanged,
                      ),
                      SizedBox(height: isSmallScreen ? 44 : 64),
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 56 : 64,
                        child: ElevatedButton(
                          onPressed: _nameController.text.trim().isNotEmpty
                              ? _validateAndContinue
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _nameController.text.trim().isNotEmpty
                                ? PRIMETheme.primary
                                : PRIMETheme.line,
                            foregroundColor: _nameController.text.trim().isNotEmpty
                                ? PRIMETheme.sand
                                : PRIMETheme.sandWeak,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation:
                                _nameController.text.trim().isNotEmpty ? 4 : 0,
                            shadowColor: _nameController.text.trim().isNotEmpty
                                ? PRIMETheme.primary.withValues(alpha: 0.3)
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_forward,
                                size: isSmallScreen ? 18 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ПРОДОЛЖИТЬ',
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RegistrationHeader extends StatelessWidget {
  final bool isSmall;
  final String tag;
  final String subtitle;

  const _RegistrationHeader({
    required this.isSmall,
    required this.tag,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'PRIME',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: isSmall ? 40 : 56,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: PRIMETheme.sand,
              ),
        ),
        SizedBox(height: isSmall ? 10 : 14),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 16 : 20,
            vertical: isSmall ? 8 : 10,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: PRIMETheme.primary, width: 2),
            borderRadius: BorderRadius.circular(8),
            color: PRIMETheme.primary.withValues(alpha: 0.08),
          ),
          child: Text(
            tag,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PRIMETheme.primary,
                  fontSize: isSmall ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
          ),
        ),
        SizedBox(height: isSmall ? 14 : 18),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: PRIMETheme.sandWeak,
                fontSize: isSmall ? 14 : 16,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
