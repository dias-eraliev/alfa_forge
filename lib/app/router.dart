import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/services/auth_service.dart';
import '../core/api/api_client.dart';
import '../features/auth/pages/login_page.dart';
import '../features/path/path_page.dart';
import '../features/path/my_map_page.dart';
import '../features/habits/habits_page.dart';
import '../features/tasks/tasks_page.dart';
import '../features/brotherhood/brotherhood_page.dart';
import '../features/body/body_page.dart';
// GTO features removed due to 16KB page size compatibility
import '../features/onboarding/pages/intro_page.dart';
import '../features/onboarding/pages/profile_page.dart';
import '../features/onboarding/pages/name_page.dart';
import '../features/onboarding/pages/habits_selection_page.dart';
import '../features/onboarding/pages/ready_page.dart';
import '../features/onboarding/controllers/onboarding_controller.dart';
import '../features/notifications/ui/notifications_settings_page.dart';

final router = GoRouter(
  initialLocation: '/auth-check',
  redirect: (context, state) async {
    final authService = AuthService();
    final currentPath = state.uri.toString();
    
    print('🔄🔄🔄 ROUTER REDIRECT START 🔄🔄🔄');
    print('📍 Current path: $currentPath');
    
    // Проверяем авторизацию
    var isAuthenticated = authService.isAuthenticated;
    print('🔐 Is authenticated: $isAuthenticated');
    
    // Проверяем токены в ApiClient
    final apiClient = ApiClient.instance;
    print('🎫 ApiClient isAuthenticated: ${apiClient.isAuthenticated}');
    print('🎫 ApiClient hasRefreshToken: ${apiClient.hasRefreshToken}');

    // Если access отсутствует, но есть refresh — попробуем тихо обновить токен прямо в редиректе
    if (!isAuthenticated && apiClient.hasRefreshToken) {
      print('🔄 Trying silent refresh inside router.redirect...');
      final refreshed = await apiClient.tryRefresh();
      print('🔄 Silent refresh result: $refreshed');
      if (refreshed) {
        // После успешного refresh авторизация должна появиться
        isAuthenticated = authService.isAuthenticated || apiClient.isAuthenticated;
        print('🔐 Is authenticated after refresh: $isAuthenticated');
      }
    }
    
    // Если пользователь НЕ авторизован
    if (!isAuthenticated) {
      print('❌ User NOT authenticated');
      
      // Если на auth-check - перенаправляем на intro
      if (currentPath == '/auth-check') {
        print('🚀 Redirecting from auth-check to /intro');
        return '/intro';
      }
      
      // Разрешаем доступ к публичным и онбординг-роутам (регистрация проходит в онбординге)
      final isPublic = currentPath == '/intro' || currentPath == '/login';
      final isOnboarding = currentPath.startsWith('/onboarding');
      if (isPublic || isOnboarding) {
        print('✅ Staying on public route: $currentPath');
        return null; // Остаемся на текущем роуте
      }
      
      // Все остальные роуты перенаправляем на intro
      print('🚀 Redirecting to /intro from: $currentPath');
      return '/intro';
    }
    
    // Если пользователь авторизован
    if (isAuthenticated) {
      print('✅ User IS authenticated');
      
      // Если находимся на auth-check, проверяем онбординг
      if (currentPath == '/auth-check') {
        print('🔍 Checking onboarding status...');
        final isOnboardingCompleted = await OnboardingController.isOnboardingCompleted();
        print('📋 Onboarding completed: $isOnboardingCompleted');
        
        if (!isOnboardingCompleted) {
          print('🚀 Redirecting to onboarding: /onboarding/profile');
          return '/onboarding/profile'; // Перенаправляем на онбординг
        }
        print('🚀 Redirecting to home: /');
        return '/'; // Перенаправляем на главную
      }
      
      // Если авторизован, но пытается зайти на intro или login
      if (currentPath == '/intro' || currentPath == '/login') {
        print('🔍 User on intro/login page, checking onboarding...');
        final isOnboardingCompleted = await OnboardingController.isOnboardingCompleted();
        print('📋 Onboarding completed: $isOnboardingCompleted');
        
        if (!isOnboardingCompleted) {
          print('🚀 Redirecting to onboarding: /onboarding/profile');
          return '/onboarding/profile';
        }
        print('🚀 Redirecting to home: /');
        return '/'; // Перенаправляем на главную
      }
      
      // Проверяем онбординг для основных роутов
      if (!currentPath.startsWith('/onboarding') && 
          currentPath != '/intro' && 
          currentPath != '/login') {
        print('🔍 Checking onboarding for main route...');
        final isOnboardingCompleted = await OnboardingController.isOnboardingCompleted();
        print('📋 Onboarding completed: $isOnboardingCompleted');
        
        if (!isOnboardingCompleted) {
          print('🚀 Redirecting to onboarding: /onboarding/profile');
          return '/onboarding/profile';
        }
      }
    }
    
    print('✅ No redirect needed, staying on: $currentPath');
    print('🔄🔄🔄 ROUTER REDIRECT END 🔄🔄🔄');
    return null; // Остаемся на текущем роуте
  },
  routes: [
    // Auth check route - показывает спиннер пока определяется статус авторизации
    GoRoute(
      path: '/auth-check',
      builder: (c, s) => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    ),
    
    // Intro route
    GoRoute(path: '/intro', builder: (c, s) => const IntroPage()),
    
    // Auth route
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
    
    // Onboarding routes - полная система регистрации в стиле Силиконовой долины
    GoRoute(path: '/onboarding/profile', builder: (c, s) => const ProfilePage()),
    GoRoute(path: '/onboarding/name', builder: (c, s) => const NamePage()),
    GoRoute(path: '/onboarding/habits', builder: (c, s) => const HabitsSelectionPage()),
    GoRoute(path: '/onboarding/ready', builder: (c, s) => const ReadyPage()),
    
    // Main app routes
    GoRoute(path: '/', builder: (c, s) => const PathPage()),
    GoRoute(path: '/my-map', builder: (c, s) => const MyMapPage()),
    GoRoute(path: '/habits', builder: (c, s) => const HabitsPage()),
    GoRoute(path: '/body', builder: (c, s) => const BodyPage()),
    GoRoute(path: '/tasks', builder: (c, s) => const TasksPage()),
    GoRoute(path: '/brotherhood', builder: (c, s) => const BrotherhoodPage()),
    
    // GTO routes removed - incompatible with 16KB page size
    
    // Finance route (temporarily disabled module)
    GoRoute(
      path: '/finance',
      builder: (c, s) => const Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_wallet, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Модуль «Финансы» временно отключен',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Мы работаем над улучшениями. Возвращайтесь позже.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    
    // Notifications routes
    GoRoute(path: '/notifications', builder: (c, s) => const NotificationsSettingsPage()),
  ],
);
