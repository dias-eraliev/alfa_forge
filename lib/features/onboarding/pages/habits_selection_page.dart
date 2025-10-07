import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../controllers/onboarding_controller.dart';
import '../models/development_sphere_model.dart';
import '../widgets/progress_dots.dart';
import '../widgets/sphere_card.dart';
import '../widgets/habit_card.dart';
import 'name_page.dart'; // Для доступа к provider

class HabitsSelectionPage extends ConsumerStatefulWidget {
  const HabitsSelectionPage({super.key});

  @override
  ConsumerState<HabitsSelectionPage> createState() => _HabitsSelectionPageState();
}

class _HabitsSelectionPageState extends ConsumerState<HabitsSelectionPage> 
    with TickerProviderStateMixin {
  late AnimationController _transitionController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _transitionController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  void _switchToHabitSelection() {
    ref.read(onboardingControllerProvider).enterHabitSelectionMode();
    _transitionController.forward();
  }

  void _switchBackToSphereSelection() {
    _transitionController.reverse().then((_) {
      ref.read(onboardingControllerProvider).exitHabitSelectionMode();
    });
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
          onPressed: () {
            if (controller.isInHabitSelectionMode) {
              _switchBackToSphereSelection();
            } else {
              context.go('/onboarding/name');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Экран выбора сфер
            if (!controller.isInHabitSelectionMode) 
              _buildSphereSelectionScreen(context, controller, isSmallScreen),
            
            // Экран выбора привычек
            if (controller.isInHabitSelectionMode)
              AnimatedBuilder(
                animation: _transitionController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: _buildHabitSelectionScreen(context, controller, isSmallScreen),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSphereSelectionScreen(BuildContext context, OnboardingController controller, bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 32 : 64,
          vertical: 20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              // Прогресс
              const ProgressDots(
                totalSteps: 7,
                currentStep: 4,
              ),
              
              SizedBox(height: isSmallScreen ? 32 : 48),
              
              // Заголовок
              Column(
                children: [
                  Text(
                    'ВЫБОР СФЕР',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: isSmallScreen ? 36 : 42,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: PRIMETheme.sand,
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  
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
                      'РАЗВИТИЯ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PRIMETheme.primary,
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 20 : 28),
                  
                  Text(
                    'Выбери 2-3 сферы развития.\nОни определят твой путь роста.',
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
              
              // Сетка сфер развития
              SpheresGrid(
                spheres: DevelopmentSpheresData.spheres,
                selectedSpheres: controller.selectedSpheres,
                onSphereToggle: (sphere) {
                  ref.read(onboardingControllerProvider).toggleSphere(sphere);
                },
              ),
              
              SizedBox(height: isSmallScreen ? 24 : 32),
              
              // Счетчик выбранных сфер
              if (controller.selectedSpheres.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: PRIMETheme.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PRIMETheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PRIMETheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Выбрано: ${controller.selectedSpheres.length} из 3 сфер',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: PRIMETheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              if (controller.selectedSpheres.isNotEmpty) 
                SizedBox(height: isSmallScreen ? 20 : 28),
              
              // Кнопка перехода к выбору привычек
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 56 : 64,
                child: ElevatedButton(
                  onPressed: controller.canProceedFromSpheres 
                      ? _switchToHabitSelection
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.canProceedFromSpheres 
                        ? PRIMETheme.primary 
                        : PRIMETheme.line,
                    foregroundColor: controller.canProceedFromSpheres 
                        ? PRIMETheme.sand 
                        : PRIMETheme.sandWeak,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: controller.canProceedFromSpheres ? 8 : 0,
                    shadowColor: controller.canProceedFromSpheres 
                        ? PRIMETheme.primary.withOpacity(0.4) 
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: isSmallScreen ? 18 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ВЫБРАТЬ ПРИВЫЧКИ',
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
    );
  }

  Widget _buildHabitSelectionScreen(BuildContext context, OnboardingController controller, bool isSmallScreen) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 32 : 64,
          vertical: 20,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            children: [
              // Прогресс
              const ProgressDots(
                totalSteps: 7,
                currentStep: 4,
              ),
              
              SizedBox(height: isSmallScreen ? 32 : 48),
              
              // Заголовок для выбора привычек
              Column(
                children: [
                  Text(
                    'ВЫБОР ПРИВЫЧЕК',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: isSmallScreen ? 32 : 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: PRIMETheme.sand,
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  
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
                      'ИЗ ВЫБРАННЫХ СФЕР',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PRIMETheme.primary,
                        fontSize: isSmallScreen ? 11 : 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: isSmallScreen ? 20 : 28),
                  
                  Text(
                    'Выбери 5 привычек из своих сфер развития.\nОни сформируют твою систему роста.',
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
              
              // Сетка привычек из выбранных сфер
              HabitsGrid(
                habits: controller.availableHabits,
                selectedHabits: controller.selectedHabits,
                onHabitToggle: (habit) {
                  ref.read(onboardingControllerProvider).toggleHabit(habit);
                },
              ),
              
              SizedBox(height: isSmallScreen ? 24 : 32),
              
              // Счетчик выбранных привычек
              if (controller.selectedHabits.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16 : 20,
                    vertical: isSmallScreen ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: PRIMETheme.bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: PRIMETheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: PRIMETheme.primary.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Выбрано: ${controller.selectedHabits.length} из 5 привычек',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: isSmallScreen ? 12 : 13,
                      color: PRIMETheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              
              if (controller.selectedHabits.isNotEmpty) 
                SizedBox(height: isSmallScreen ? 20 : 28),
              
              // Кнопка завершения выбора
              SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 56 : 64,
                child: ElevatedButton(
                  onPressed: controller.areHabitsValid 
                      ? () => context.go('/onboarding/password')
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.areHabitsValid 
                        ? PRIMETheme.primary 
                        : PRIMETheme.line,
                    foregroundColor: controller.areHabitsValid 
                        ? PRIMETheme.sand 
                        : PRIMETheme.sandWeak,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: controller.areHabitsValid ? 8 : 0,
                    shadowColor: controller.areHabitsValid 
                        ? PRIMETheme.primary.withOpacity(0.4) 
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: isSmallScreen ? 18 : 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'АКТИВИРОВАТЬ СИСТЕМУ',
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
    );
  }
}
