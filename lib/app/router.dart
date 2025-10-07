import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../features/auth/login_page.dart';
import '../features/path/path_page.dart';
import '../features/path/my_map_page.dart';
import '../features/habits/habits_page.dart';
import '../features/tasks/tasks_page.dart';
import '../features/brotherhood/brotherhood_page.dart';
import '../features/body/body_page.dart';
import '../features/gto/gto_page.dart';
import '../features/gto/pages/ai_motion_page.dart';
import '../features/onboarding/pages/intro_page.dart';
import '../features/onboarding/pages/profile_page.dart';
import '../features/onboarding/pages/name_page.dart';
import '../features/onboarding/pages/email_verification_page.dart';
import '../features/onboarding/pages/password_page.dart';
import '../features/onboarding/pages/habits_selection_page.dart';
import '../features/onboarding/pages/ready_page.dart';
import '../features/onboarding/controllers/onboarding_controller.dart';

class _SupabaseAuthListenable extends ChangeNotifier {
  _SupabaseAuthListenable() {
    // слушаем изменения auth и уведомляем роутер
    Supabase.instance.client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }
}

final router = GoRouter(
  refreshListenable: _SupabaseAuthListenable(),
  initialLocation: '/intro',
  redirect: (context, state) async {
    // Проверяем статус аутентификации через Supabase
    final supabase = Supabase.instance.client;
    final currentUser = supabase.auth.currentUser;
    final isAuthenticated = currentUser != null;

    // Проверяем, завершен ли онбординг
    final isOnboardingCompleted = await OnboardingController.isOnboardingCompleted();
    final currentPath = state.uri.toString();

    // Логика редиректов:
    // 1. Если онбординг завершен И пользователь авторизован → разрешаем доступ к основному приложению
    if (isOnboardingCompleted && isAuthenticated) {
      // Если пользователь пытается зайти на страницы онбординга или логина, перенаправляем на главную
      if (currentPath == '/intro' ||
          currentPath == '/login' ||
          currentPath.startsWith('/onboarding')) {
        return '/';
      }
      return null; // Остаемся на текущем маршруте
    }

    // 2. Если онбординг завершен, НО пользователь НЕ авторизован → перенаправляем на логин
    if (isOnboardingCompleted && !isAuthenticated) {
      if (currentPath != '/login') {
        return '/login';
      }
      return null;
    }

    // 3. Если онбординг НЕ завершен → разрешаем только страницы онбординга и логина
    if (!isOnboardingCompleted) {
      if (currentPath != '/login' &&
          currentPath != '/intro' &&
          !currentPath.startsWith('/onboarding')) {
        return '/intro';
      }
    }

    return null; // Остаемся на текущем маршруте
  },
  routes: [
    // Intro route
    GoRoute(path: '/intro', builder: (c, s) => const IntroPage()),
    
    // Auth route
    GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
    
    // Onboarding routes - полная система регистрации в стиле Силиконовой долины
    GoRoute(path: '/onboarding/profile', builder: (c, s) => const ProfilePage()),
    GoRoute(path: '/onboarding/name', builder: (c, s) => const NamePage()),
    GoRoute(path: '/onboarding/password', builder: (c, s) => const PasswordPage()),
    GoRoute(path: '/onboarding/email-verification', builder: (c, s) => const EmailVerificationPage()),
    GoRoute(path: '/onboarding/habits', builder: (c, s) => const HabitsSelectionPage()),
    GoRoute(path: '/onboarding/ready', builder: (c, s) => const ReadyPage()),
    
    // Main app routes
    GoRoute(path: '/', builder: (c, s) => const PathPage()),
    GoRoute(path: '/my-map', builder: (c, s) => const MyMapPage()),
    GoRoute(path: '/habits', builder: (c, s) => const HabitsPage()),
    GoRoute(path: '/body', builder: (c, s) => const BodyPage()),
    GoRoute(path: '/tasks', builder: (c, s) => const TasksPage()),
    GoRoute(path: '/brotherhood', builder: (c, s) => const BrotherhoodPage()),
    
    // GTO routes
    GoRoute(path: '/gto', builder: (c, s) => const GTOPage()),
    GoRoute(path: '/gto/workout', builder: (c, s) => const AIMotionPage()),
  ],
);
