import 'package:go_router/go_router.dart';
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
import '../features/onboarding/pages/habits_selection_page.dart';
import '../features/onboarding/pages/ready_page.dart';
import '../features/onboarding/controllers/onboarding_controller.dart';

final router = GoRouter(
  initialLocation: '/intro',
  redirect: (context, state) async {
    // Проверяем, завершен ли онбординг
    final isOnboardingCompleted = await OnboardingController.isOnboardingCompleted();
    final currentPath = state.uri.toString();
    
    // Если онбординг не завершен и пользователь пытается зайти в основное приложение
    if (!isOnboardingCompleted && 
        currentPath != '/login' && 
        currentPath != '/intro' &&
        !currentPath.startsWith('/onboarding')) {
      return '/intro'; // Перенаправляем на intro страницу
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
