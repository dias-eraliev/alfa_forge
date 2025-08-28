import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme.dart';
import '../onboarding/controllers/onboarding_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Имитация запроса к серверу
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    // Простая проверка для демо
    if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty) {
      if (mounted) {
        // Отмечаем онбординг как завершённый при успешном входе
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_completed', true);
        } catch (e) {
          debugPrint('Error marking onboarding as completed: $e');
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Добро пожаловать в PRIME!'),
            backgroundColor: PRIMETheme.success,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Переход на главную страницу
        context.go('/');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Неверные данные для входа'),
            backgroundColor: PRIMETheme.primary,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;
    final cardWidth = isSmallScreen ? screenWidth * 0.9 : 400.0;

    return Scaffold(
      backgroundColor: PRIMETheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 20 : 40,
              vertical: 20,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: cardWidth,
                  constraints: BoxConstraints(
                    minHeight: screenHeight * 0.6,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Логотип и заголовок
                      _buildHeader(isSmallScreen),
                      
                      SizedBox(height: isSmallScreen ? 40 : 60),
                      
                      // Форма входа
                      _buildLoginForm(isSmallScreen),
                      
                      SizedBox(height: isSmallScreen ? 24 : 32),
                      
                      // Кнопка входа
                      _buildLoginButton(isSmallScreen),
                      
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      
                      // Дополнительные ссылки
                      _buildAdditionalLinks(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isSmallScreen) {
    return Column(
      children: [
        // Основной логотип
        Text(
          'PRIME',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: isSmallScreen ? 56 : 72,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: PRIMETheme.sand,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 8 : 12),
        
        // Статус с рамкой
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
            'СИСТЕМА ВХОДА',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PRIMETheme.primary,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Подзаголовок
        Text(
          'Авторизация в мобильном приложении',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: PRIMETheme.sandWeak,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm(bool isSmallScreen) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email поле
          _buildTextField(
            controller: _emailController,
            label: 'Email или логин',
            hint: 'Введите ваш email',
            icon: Icons.person_outline,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите email или логин';
              }
              return null;
            },
            isSmallScreen: isSmallScreen,
          ),
          
          SizedBox(height: isSmallScreen ? 16 : 20),
          
          // Password поле
          _buildTextField(
            controller: _passwordController,
            label: 'Пароль',
            hint: 'Введите ваш пароль',
            icon: Icons.lock_outline,
            isPassword: true,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите пароль';
              }
              if (value.length < 6) {
                return 'Пароль должен содержать минимум 6 символов';
              }
              return null;
            },
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    required bool isSmallScreen,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: isSmallScreen ? 14 : 16,
        color: PRIMETheme.sand,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: PRIMETheme.sandWeak,
          size: isSmallScreen ? 20 : 24,
        ),
        suffixIcon: isPassword
            ? IconButton(
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
              )
            : null,
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
    );
  }

  Widget _buildLoginButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 50 : 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: PRIMETheme.primary,
          foregroundColor: PRIMETheme.sand,
          disabledBackgroundColor: PRIMETheme.line,
          disabledForegroundColor: PRIMETheme.sandWeak,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: _isLoading ? 0 : 4,
          shadowColor: PRIMETheme.primary.withOpacity(0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(PRIMETheme.sandWeak),
                  strokeWidth: 2,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.login,
                    size: isSmallScreen ? 18 : 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ВОЙТИ В СИСТЕМУ',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildAdditionalLinks() {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Функция восстановления пароля будет добавлена'),
                backgroundColor: PRIMETheme.warn,
              ),
            );
          },
          child: const Text(
            'Забыли пароль?',
            style: TextStyle(
              color: PRIMETheme.sandWeak,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Нет аккаунта? ',
              style: TextStyle(
                color: PRIMETheme.sandWeak,
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () {
                // Переходим на профильную страницу для полной регистрации
                context.go('/onboarding/profile');
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Зарегистрироваться',
                style: TextStyle(
                  color: PRIMETheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        // Дополнительная кнопка для демо - сброс онбординга
        const SizedBox(height: 16),
        TextButton(
          onPressed: () async {
            // Сброс онбординга для демо
            final controller = OnboardingController();
            await controller.resetOnboarding();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Онбординг сброшен (демо функция)'),
                  backgroundColor: PRIMETheme.warn,
                ),
              );
            }
          },
          child: const Text(
            'Сбросить онбординг (демо)',
            style: TextStyle(
              color: PRIMETheme.sandWeak,
              fontSize: 12,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
