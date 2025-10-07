import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

/// Обертка для защиты маршрутов, требующих аутентификации
class AuthWrapper extends ConsumerWidget {
  final Widget child;
  final String? redirectTo;

  const AuthWrapper({
    super.key,
    required this.child,
    this.redirectTo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return authState.when(
      data: (state) {
        if (isAuthenticated) {
          return child;
        } else {
          // Если пользователь не авторизован, перенаправляем на страницу входа
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (redirectTo != null) {
              context.go(redirectTo!);
            } else {
              context.go('/auth/login');
            }
          });
          return const _LoadingScreen();
        }
      },
      loading: () => const _LoadingScreen(),
      error: (error, stackTrace) {
        // В случае ошибки показываем экран входа
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (redirectTo != null) {
            context.go(redirectTo!);
          } else {
            context.go('/auth/login');
          }
        });
        return const _LoadingScreen();
      },
    );
  }
}

/// Экран загрузки во время проверки аутентификации
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

/// Провайдер для условного отображения виджетов на основе статуса аутентификации
class AuthGuard extends ConsumerWidget {
  final Widget authenticated;
  final Widget unauthenticated;

  const AuthGuard({
    super.key,
    required this.authenticated,
    required this.unauthenticated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return isAuthenticated ? authenticated : unauthenticated;
  }
}

/// Хук для проверки аутентификации в виджетах
bool useIsAuthenticated(WidgetRef ref) {
  return ref.watch(isAuthenticatedProvider);
}

/// Хук для получения текущего пользователя
User? useCurrentUser(WidgetRef ref) {
  return ref.watch(currentUserProvider);
}

/// Хук для получения профиля пользователя
AsyncValue<Map<String, dynamic>?> useUserProfile(WidgetRef ref) {
  return ref.watch(userProfileProvider);
}

/// Хук для получения ошибок аутентификации
String? useAuthError(WidgetRef ref) {
  return ref.watch(authErrorProvider);
}

/// Хук для проверки загрузки
bool useAuthLoading(WidgetRef ref) {
  return ref.watch(authLoadingProvider);
}