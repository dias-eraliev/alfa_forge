import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../widgets/progress_dots.dart';
import '../../../core/providers/auth_provider.dart';
import 'name_page.dart'; // Для доступа к provider

class ReadyPage extends ConsumerWidget {
  const ReadyPage({super.key});

  void _completeOnboarding(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(onboardingControllerProvider);
    
    try {
      print('🚀 Starting onboarding completion...');
      await controller.completeOnboarding();
      
      if (context.mounted) {
        print('🏠 Forcing router refresh through auth-check...');
        // Принудительно перенаправляем через auth-check, чтобы router.redirect сработал
        context.go('/auth-check');
      }
    } catch (e) {
      print('❌ Onboarding completion error: $e');
      // Обработка ошибки завершения онбординга
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка завершения онбординга: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onPressed: () => context.go('/onboarding/habits'),
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
                  // Прогресс
                  const ProgressDots(
                    totalSteps: 5,
                    currentStep: 5,
                  ),
                  
                  SizedBox(height: isSmallScreen ? 32 : 48),
                  
                  // Заголовок в стиле login_page
                  Column(
                    children: [
                      Text(
                        'prime',
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
                          'АКТИВАЦИЯ СИСТЕМЫ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: PRIMETheme.primary,
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: isSmallScreen ? 16 : 24),
                      
                      Text(
                        'Система готова к запуску.\nПуть к совершенству начинается сейчас.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: PRIMETheme.sandWeak,
                          fontSize: isSmallScreen ? 14 : 16,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  SizedBox(height: isSmallScreen ? 32 : 48),
                  
                  // Показываем выбранные данные
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 20 : 24),
                    decoration: BoxDecoration(
                      color: PRIMETheme.bg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: PRIMETheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: PRIMETheme.primary.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок секции
                        Text(
                          'КОНФИГУРАЦИЯ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: PRIMETheme.primary,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Профильные данные
                        _buildInfoRow(
                          icon: Icons.person_outline,
                          label: 'ПОЛНОЕ ИМЯ',
                          value: controller.fullName ?? "",
                          isSmallScreen: isSmallScreen,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        _buildInfoRow(
                          icon: Icons.email_outlined,
                          label: 'EMAIL',
                          value: controller.email ?? "",
                          isSmallScreen: isSmallScreen,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        _buildInfoRow(
                          icon: Icons.phone_outlined,
                          label: 'ТЕЛЕФОН',
                          value: controller.phone ?? "",
                          isSmallScreen: isSmallScreen,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        _buildInfoRow(
                          icon: Icons.location_city_outlined,
                          label: 'ГОРОД',
                          value: controller.city ?? "",
                          isSmallScreen: isSmallScreen,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        _buildInfoRow(
                          icon: Icons.account_circle_outlined,
                          label: 'ПОЛЬЗОВАТЕЛЬ',
                          value: controller.username ?? "",
                          isSmallScreen: isSmallScreen,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Выбранные привычки
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.track_changes_outlined,
                              color: PRIMETheme.primary,
                              size: isSmallScreen ? 18 : 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'АКТИВНЫЕ МОДУЛИ',
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: PRIMETheme.sand,
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...controller.selectedHabits.map((habit) => 
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: PRIMETheme.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            habit.icon,
                                            style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              habit.name,
                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: PRIMETheme.sandWeak,
                                                fontSize: isSmallScreen ? 13 : 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 40 : 60),
                  
                  // Кнопка "Начать путь" в стиле login_page
                  SizedBox(
                    width: double.infinity,
                    height: isSmallScreen ? 56 : 64,
                    child: ElevatedButton(
                      onPressed: controller.canComplete 
                          ? () => _completeOnboarding(context, ref)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.canComplete 
                            ? PRIMETheme.primary 
                            : PRIMETheme.line,
                        foregroundColor: controller.canComplete 
                            ? PRIMETheme.sand 
                            : PRIMETheme.sandWeak,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: controller.canComplete ? 8 : 0,
                        shadowColor: controller.canComplete 
                            ? PRIMETheme.primary.withOpacity(0.4) 
                            : null,
                      ),
                      child: controller.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(PRIMETheme.sand),
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rocket_launch_outlined,
                                  size: isSmallScreen ? 18 : 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ЗАПУСТИТЬ СИСТЕМУ',
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isSmallScreen,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: PRIMETheme.primary,
          size: isSmallScreen ? 18 : 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  color: PRIMETheme.sand,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: PRIMETheme.sandWeak,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
