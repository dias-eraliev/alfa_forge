import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../app/theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // Для новой логики: на логин-экране только вход (регистрация через онбординг)
  
  bool _isPasswordVisible = false;
  // Режим регистрации убран; всегда режим входа
  final bool _isLoginMode = true;
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: PRIMETheme.bg,
      body: SafeArea(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 24,
                vertical: isSmallScreen ? 20 : 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: isSmallScreen ? 20 : 40),
                  
                  // Логотип и заголовок
                  _buildHeader(isSmallScreen),
                  
                  SizedBox(height: isSmallScreen ? 40 : 60),
                  
                  // Форма
                  _buildForm(),
                  
                  SizedBox(height: isSmallScreen ? 20 : 30),
                  
                  // Кнопка входа/регистрации
                  _buildActionButton(),
                  
                  SizedBox(height: isSmallScreen ? 15 : 20),
                  
                  // Переключение режима
                  _buildModeToggle(),
                  
                  SizedBox(height: isSmallScreen ? 30 : 40),
                  
                  // Социальные сети (опционально)
                  _buildSocialLogin(),
                  
                  SizedBox(height: isSmallScreen ? 20 : 30),
                  
                  // Условия использования
                  _buildTerms(),
                ],
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
        // Логотип
        Container(
          width: isSmallScreen ? 80 : 100,
          height: isSmallScreen ? 80 : 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                PRIMETheme.primary,
                PRIMETheme.primary.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: PRIMETheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: isSmallScreen ? 40 : 50,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 20 : 30),
        
        // Заголовок
        Text(
          'ALFA FORGE',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 28 : 36,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        
        SizedBox(height: isSmallScreen ? 8 : 12),
        
        Text(
          _isLoginMode 
            ? 'Добро пожаловать обратно!'
            : 'Начни свой путь к совершенству',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: PRIMETheme.sandWeak,
            fontSize: isSmallScreen ? 14 : 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Поля username/fullName убраны: регистрация перенесена в онбординг
          
          // Email
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Введите ваш email',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Введите email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Введите корректный email';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // Пароль
          _buildTextField(
            controller: _passwordController,
            label: 'Пароль',
            hint: 'Введите пароль',
            icon: Icons.lock_outline,
            obscureText: !_isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: PRIMETheme.sandWeak,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
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
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: PRIMETheme.primary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: PRIMETheme.line.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: PRIMETheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildActionButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return InkWell(
          onTap: authProvider.isLoading ? null : _handleSubmit,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: authProvider.isLoading
                  ? [Colors.grey, Colors.grey.withOpacity(0.8)]
                  : [PRIMETheme.primary, PRIMETheme.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (authProvider.isLoading ? Colors.grey : PRIMETheme.primary)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (authProvider.isLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  authProvider.isLoading
                    ? 'Загрузка...'
                    : 'Войти',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModeToggle() {
    // Вместо переключения режима показываем ссылку "Пройти онбординг"
    return GestureDetector(
      onTap: () {
        // очистка ошибок
        context.read<AuthProvider>().clearError();
        // переход к онбордингу
        context.go('/onboarding/profile');
      },
      child: Center(
        child: Text(
          'Нет аккаунта? Пройдите онбординг',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PRIMETheme.primary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: PRIMETheme.line)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'или',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PRIMETheme.sandWeak,
                ),
              ),
            ),
            Expanded(child: Divider(color: PRIMETheme.line)),
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Кнопка "Продолжить как гость"
        InkWell(
          onTap: _continueAsGuest,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: PRIMETheme.line),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  color: PRIMETheme.sandWeak,
                ),
                const SizedBox(width: 8),
                Text(
                  'Продолжить как гость',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: PRIMETheme.sand,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerms() {
    return Text(
      'Продолжая, вы соглашаетесь с условиями использования и политикой конфиденциальности',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: PRIMETheme.sandWeak,
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    bool success;

    success = await authProvider.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Переходим к главному экрану с GoRouter
      context.go('/');
    } else if (mounted) {
      // Показываем ошибку
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authProvider.errorMessage ?? 'Произошла ошибка',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _continueAsGuest() {
    // Переходим к главному экрану без авторизации с GoRouter
    context.go('/');
    
    // Показываем уведомление
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Вы вошли как гость. Некоторые функции недоступны.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: PRIMETheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
