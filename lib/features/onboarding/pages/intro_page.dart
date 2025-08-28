import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/logo_with_glow.dart';
import '../../../app/theme.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600;

    return Scaffold(
      backgroundColor: PRIMETheme.bg,
      body: Container(
        color: PRIMETheme.bg,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 32 : 64,
                vertical: 32,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight * 0.8,
                  maxWidth: 500,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Верхний отступ
                    SizedBox(height: screenHeight * 0.1),
                    
                    // Статичный логотип без анимаций
                    LogoWithGlow(
                      size: isSmallScreen ? 56 : 72,
                      animate: false,
                    ),
                    
                    SizedBox(height: isSmallScreen ? 24 : 32),
                    
                    // Простой подзаголовок
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20 : 32,
                        vertical: isSmallScreen ? 12 : 16,
                      ),
                      child: Text(
                        'Стань лучшей версией себя',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: PRIMETheme.sandWeak,
                          fontSize: isSmallScreen ? 15 : 17,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 40 : 60),
                    
                    // Статичные кнопки
                    Column(
                      children: [
                        // Primary кнопка - "Начать путь"
                        _buildActionButton(
                          text: 'НАЧАТЬ ПУТЬ',
                          isPrimary: true,
                          icon: Icons.rocket_launch_outlined,
                          onPressed: () {
                            context.go('/onboarding/profile');
                          },
                          isSmallScreen: isSmallScreen,
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Secondary кнопка - "Уже в пути"
                        _buildActionButton(
                          text: 'УЖЕ В ПУТИ',
                          isPrimary: false,
                          icon: Icons.login_outlined,
                          onPressed: () {
                            context.go('/login');
                          },
                          isSmallScreen: isSmallScreen,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isSmallScreen ? 32 : 48),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String text,
    required bool isPrimary,
    required IconData icon,
    required VoidCallback onPressed,
    required bool isSmallScreen,
  }) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 56 : 64,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isPrimary ? PRIMETheme.primary : Colors.transparent,
          foregroundColor: isPrimary ? PRIMETheme.sand : PRIMETheme.primary,
          side: isPrimary 
              ? null 
              : BorderSide(
                  color: PRIMETheme.primary, 
                  width: 2,
                ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 20 : 24,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                color: isPrimary ? PRIMETheme.sand : PRIMETheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
