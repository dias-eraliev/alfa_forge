import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../widgets/progress_dots.dart';
import '../models/city_model.dart';
import 'name_page.dart'; // provider (onboardingControllerProvider)

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingControllerProvider).loadData();
      final c = ref.read(onboardingControllerProvider);
      _fullNameController.text = c.fullName ?? '';
      _emailController.text = c.email ?? '';
      _phoneController.text = c.phone ?? '';
      _selectedCity = c.city;
      _cityController.text = _selectedCity ?? '';
      setState(() {});
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

  void _persistProfile() {
    ref.read(onboardingControllerProvider).setProfileData(
          fullName: _fullNameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          city: _cityController.text,
        );
  }

  void _validateAndContinue() {
    if (!_formKey.currentState!.validate()) return;
    _persistProfile();
    context.go('/onboarding/name');
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(onboardingControllerProvider);
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
          onPressed: () => context.go('/login'),
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
                        currentStep: 1,
                      ),
                      SizedBox(height: isSmallScreen ? 36 : 52),
                      _RegistrationHeader(
                        title: 'РЕГИСТРАЦИЯ',
                        tag: 'ЛИЧНЫЕ ДАННЫЕ',
                        subtitle:
                            'Заполните основную информацию для создания аккаунта',
                        isSmall: isSmallScreen,
                      ),
                      SizedBox(height: isSmallScreen ? 36 : 52),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(
                              controller: _fullNameController,
                              label: 'Полное имя',
                              hint: 'Введите имя и фамилию',
                              icon: Icons.person_outline,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Введите полное имя';
                                }
                                if (v.trim().length < 2) {
                                  return 'Слишком короткое имя';
                                }
                                return null;
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              hint: 'Введите ваш email',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Введите email';
                                }
                                if (!RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(v)) {
                                  return 'Введите корректный email';
                                }
                                return null;
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
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
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Введите номер телефона';
                                }
                                if (v.length < 10) {
                                  return 'Номер телефона слишком короткий';
                                }
                                return null;
                              },
                              isSmallScreen: isSmallScreen,
                            ),
                            SizedBox(height: isSmallScreen ? 16 : 20),
                            _buildCityDropdown(isSmallScreen),
                          ],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 44 : 64),
                      SizedBox(
                        width: double.infinity,
                        height: isSmallScreen ? 56 : 64,
                        child: ElevatedButton(
                          onPressed: controller.isProfileValid
                              ? _validateAndContinue
                              : null,
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
      onChanged: (_) => _persistProfile(),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: isSmallScreen ? 14 : 16,
            color: PRIMETheme.sand,
          ),
      decoration: _inputDecoration(
        label: label,
        hint: hint,
        icon: icon,
        isSmall: isSmallScreen,
      ),
    );
  }

  Widget _buildCityDropdown(bool isSmallScreen) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCity,
      decoration: _inputDecoration(
        label: 'Город',
        hint: 'Выберите ваш город',
        icon: Icons.location_city_outlined,
        isSmall: isSmallScreen,
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
      items: CitiesData.cityNames
          .map((city) => DropdownMenuItem<String>(
                value: city,
                child: Text(
                  city,
                  style: TextStyle(
                    color: PRIMETheme.sand,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ))
          .toList(),
      onChanged: (val) {
        setState(() {
          _selectedCity = val;
          _cityController.text = val ?? '';
        });
        _persistProfile();
      },
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Выберите город';
        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    required bool isSmall,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: PRIMETheme.sandWeak,
        size: isSmall ? 20 : 24,
      ),
      labelStyle: TextStyle(
        color: PRIMETheme.sandWeak,
        fontSize: isSmall ? 14 : 16,
      ),
      hintStyle: TextStyle(
        color: PRIMETheme.sandWeak.withValues(alpha: 0.6),
        fontSize: isSmall ? 14 : 16,
      ),
      filled: true,
      fillColor: PRIMETheme.bg,
      contentPadding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 20,
        vertical: isSmall ? 16 : 20,
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
        fontSize: isSmall ? 12 : 14,
      ),
    );
  }
}

class _RegistrationHeader extends StatelessWidget {
  final String title;
  final String tag;
  final String subtitle;
  final bool isSmall;

  const _RegistrationHeader({
    required this.title,
    required this.tag,
    required this.subtitle,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
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
