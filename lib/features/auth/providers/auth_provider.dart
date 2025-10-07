import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

// Провайдер сервиса аутентификации
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Провайдер состояния аутентификации
final authStateProvider = StreamProvider<AuthStateData>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Провайдер текущего пользователя
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.maybeWhen(
    data: (state) => state.user,
    orElse: () => null,
  );
});

// Провайдер статуса аутентификации
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user != null;
});

// Провайдер профиля пользователя
final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) return Future.value(null);

  final authService = ref.watch(authServiceProvider);
  return authService.getUserProfile(user.id);
});

// Нотифаер для управления состоянием аутентификации
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    // Инициализируем состояние
    _init();
  }

  void _init() {
    final currentUser = _authService.currentUser;
    state = AsyncValue.data(currentUser);
  }

  // Регистрация
  Future<void> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
    String? phone,
    String? city,
    List<String>? selectedHabitIds,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _authService.signUp(
        email: email,
        password: password,
        username: username,
        fullName: fullName,
        phone: phone,
        city: city,
        selectedHabitIds: selectedHabitIds,
      );

      state = AsyncValue.data(response.user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Вход
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _authService.signIn(
        email: email,
        password: password,
      );

      state = AsyncValue.data(response.user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Вход через OTP
  Future<void> signInWithOtp({
    required String email,
  }) async {
    try {
      await _authService.signInWithOtp(email: email);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Подтверждение OTP
  Future<void> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    state = const AsyncValue.loading();

    try {
      final response = await _authService.verifyOtp(
        email: email,
        token: token,
        type: type,
      );

      state = AsyncValue.data(response.user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Выход
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Сброс пароля
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _authService.resetPassword(email: email);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Обновление пароля
  Future<void> updatePassword({
    required String newPassword,
  }) async {
    try {
      final response = await _authService.updatePassword(newPassword: newPassword);
      state = AsyncValue.data(response.user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Обновление профиля
  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? phone,
    String? city,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    double? weightKg,
  }) async {
    try {
      final response = await _authService.updateProfile(
        username: username,
        fullName: fullName,
        phone: phone,
        city: city,
        bio: bio,
        dateOfBirth: dateOfBirth,
        gender: gender,
        heightCm: heightCm,
        weightKg: weightKg,
      );

      state = AsyncValue.data(response.user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  // Удаление аккаунта
  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

// Провайдер нотифаера аутентификации
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});

// Провайдер для отслеживания ошибок аутентификации
final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return authState.maybeWhen(
    error: (error, stackTrace) => error.toString(),
    orElse: () => null,
  );
});

// Провайдер для отслеживания загрузки
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isLoading;
});