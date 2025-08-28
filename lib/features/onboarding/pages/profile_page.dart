import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../widgets/progress_dots.dart';
import '../models/city_model.dart';
import 'name_page.dart'; // Для доступа к provider

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController;
  String? _selectedCity;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _cityController = TextEditingController();
    
    // Загружаем сохраненные данные
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingControllerProvider).loadData();
      final controller = ref.read(onboardingControllerProvider);
      
      _fullNameController.text = controller.fullName ?? '';
      _emailController.text = controller.email ?? '';
      _phoneController.text = controller.phone ?? '';
      _selectedCity = controller.city;
      _cityController.text = _selectedCity ?? '';
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _validateAndContinue() {
    if (!_formKey.currentState!.validate()) return;

    // Сохраняем профильные данные
    ref.read(onboardingControllerProvider).setProfileData(
      fullName: _fullNameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      city: _cityController.text,
    );
    
    context.go('/onboarding/name');
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(onboardingControllerProvider);
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
          onPressed: () => context.go('/login'),
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
                children: [
                  // Прогресс (5 шагов теперь)
                  const ProgressDots(
                    totalSteps: 5,
                    currentStep: 1,
                  ),
                  
                  SizedBox(height: isSmallScreen ? 32 : 48),
                  
                  // Заголовок в стиле login_page
                  Column(
                    children: [
                      Text(
                        'РЕГИСТРАЦИЯ',
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
                          'ЛИЧНЫЕ ДАННЫЕ',
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
                        'Заполните основную информацию для создания аккаунта',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: PRIMETheme.sandWeak,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isSmallScreen ? 32 : 48),
                  
                  // Форма
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Полное имя
                        _buildTextField(
                          controller: _fullNameController,
                          label: 'Полное имя',
                          hint: 'Введите имя и фамилию',
                          icon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите полное имя';
                            }
                            if (value.trim().length < 2) {
                              return 'Слишком короткое имя';
                            }
                            return null;
                          },
                          isSmallScreen: isSmallScreen,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Email
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Введите ваш email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Введите корректный email';
                            }
                            return null;
                          },
                          isSmallScreen: isSmallScreen,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Телефон
                        _buildTextField(
                          controller: _phoneController,
                          label: 'Номер телефона',
                          hint: '+7 (XXX) XXX-XX-XX',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Введите номер телефона';
                            }
                            if (value.length < 10) {
                              return 'Номер телефона слишком короткий';
                            }
                            return null;
                          },
                          isSmallScreen: isSmallScreen,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Город - Выпадающий список
                        _buildCityDropdown(isSmallScreen),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 40 : 60),
                  
                  // Кнопка "Далее" в стиле login_page
                  SizedBox(
                    width: double.infinity,
                    height: isSmallScreen ? 56 : 64,
                    child: ElevatedButton(
                      onPressed: controller.isProfileValid ? _validateAndContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isProfileValid 
                            ? PRIMETheme.primary 
                            : PRIMETheme.line,
                        foregroundColor: controller.isProfileValid 
                            ? PRIMETheme.sand 
                            : PRIMETheme.sandWeak,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: controller.isProfileValid ? 4 : 0,
                        shadowColor: controller.isProfileValid 
                            ? PRIMETheme.primary.withOpacity(0.3) 
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
                  
                  SizedBox(height: isSmallScreen ? 24 : 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    required bool isSmallScreen,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: (value) {
        // Обновляем валидацию в реальном времени
        if (mounted) {
          ref.read(onboardingControllerProvider).setProfileData(
            fullName: _fullNameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            city: _cityController.text,
          );
        }
      },
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

  Widget _buildCityDropdown(bool isSmallScreen) {
    return DropdownButtonFormField<String>(
      value: _selectedCity,
      decoration: InputDecoration(
        labelText: 'Город',
        hintText: 'Выберите ваш город',
        prefixIcon: Icon(
          Icons.location_city_outlined,
          color: PRIMETheme.sandWeak,
          size: isSmallScreen ? 20 : 24,
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
      dropdownColor: PRIMETheme.bg,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: isSmallScreen ? 14 : 16,
        color: PRIMETheme.sand,
      ),
      icon: Icon(
        Icons.arrow_drop_down,
        color: PRIMETheme.sandWeak,
        size: isSmallScreen ? 20 : 24,
      ),
      items: CitiesData.cityNames.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(
            city,
            style: TextStyle(
              color: PRIMETheme.sand,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCity = newValue;
          _cityController.text = newValue ?? '';
        });
        
        // Обновляем валидацию в реальном времени
        if (mounted) {
          ref.read(onboardingControllerProvider).setProfileData(
            fullName: _fullNameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            city: _cityController.text,
          );
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Выберите город';
        }
        return null;
      },
    );
  }
}
