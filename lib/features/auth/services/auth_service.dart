import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Сервис для работы с аутентификацией через Supabase
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Поток состояния аутентификации
  Stream<AuthStateData> get authStateChanges => _supabase.auth.onAuthStateChange.map(
        (event) => AuthStateData(
          event: event.event,
          session: event.session,
          user: event.session?.user,
        ),
      );

  /// Текущий пользователь
  User? get currentUser => _supabase.auth.currentUser;

  /// Текущая сессия
  Session? get currentSession => _supabase.auth.currentSession;

  /// Проверка авторизации
  bool get isAuthenticated => currentUser != null;

  /// Регистрация нового пользователя
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? username,
    String? fullName,
    String? phone,
    String? city,
    List<String>? selectedHabitIds,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          if (username != null) 'username': username,
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (city != null) 'city': city,
        },
      );

      // Если регистрация успешна, создаем запись в таблице users и привычки
      if (response.user != null && response.session != null) {
        await _createUserProfile(response.user!, username, fullName, phone, city, selectedHabitIds);
      }

      return response;
    } catch (e) {
      debugPrint('SignUp error: $e');
      rethrow;
    }
  }

  /// Вход в систему
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Обновляем время последнего входа
      if (response.user != null) {
        await _updateLastLogin(response.user!.id);
      }

      return response;
    } catch (e) {
      debugPrint('SignIn error: $e');
      rethrow;
    }
  }

  /// Вход через email ссылку (magic link)
  Future<void> signInWithOtp({
    required String email,
  }) async {
    try {
      await _supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: kIsWeb ? null : 'alfaforge://auth/callback',
      );
    } catch (e) {
      debugPrint('SignInWithOtp error: $e');
      rethrow;
    }
  }

  /// Подтверждение OTP
  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: token,
        type: type,
      );
      return response;
    } catch (e) {
      debugPrint('VerifyOtp error: $e');
      rethrow;
    }
  }

  /// Повторная отправка email подтверждения
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      debugPrint('ResendVerificationEmail error: $e');
      rethrow;
    }
  }

  /// Обновление сессии
  Future<void> refreshSession() async {
    try {
      await _supabase.auth.refreshSession();
    } catch (e) {
      debugPrint('RefreshSession error: $e');
      rethrow;
    }
  }

  /// Выход из системы
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('SignOut error: $e');
      rethrow;
    }
  }

  /// Сброс пароля
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: kIsWeb ? null : 'alfaforge://auth/reset-password',
      );
    } catch (e) {
      debugPrint('ResetPassword error: $e');
      rethrow;
    }
  }

  /// Обновление пароля
  Future<UserResponse> updatePassword({
    required String newPassword,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      debugPrint('UpdatePassword error: $e');
      rethrow;
    }
  }

  /// Обновление профиля пользователя
  Future<UserResponse> updateProfile({
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
      // Обновляем метаданные пользователя в auth
      final userAttributes = UserAttributes(
        data: {
          if (username != null) 'username': username,
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (city != null) 'city': city,
          if (bio != null) 'bio': bio,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String(),
          if (gender != null) 'gender': gender,
          if (heightCm != null) 'height_cm': heightCm,
          if (weightKg != null) 'weight_kg': weightKg,
        },
      );

      final response = await _supabase.auth.updateUser(userAttributes);

      // Обновляем профиль в таблице users
      if (response.user != null) {
        await _updateUserProfile(response.user!.id, {
          if (username != null) 'username': username,
          if (fullName != null) 'full_name': fullName,
          if (phone != null) 'phone': phone,
          if (city != null) 'city': city,
          if (bio != null) 'bio': bio,
          if (dateOfBirth != null) 'date_of_birth': dateOfBirth.toIso8601String(),
          if (gender != null) 'gender': gender,
          if (heightCm != null) 'height_cm': heightCm,
          if (weightKg != null) 'weight_kg': weightKg,
        });
      }

      return response;
    } catch (e) {
      debugPrint('UpdateProfile error: $e');
      rethrow;
    }
  }

  /// Получение профиля пользователя
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return response;
    } catch (e) {
      debugPrint('GetUserProfile error: $e');
      return null;
    }
  }

  /// Обновление времени последнего входа
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e) {
      debugPrint('UpdateLastLogin error: $e');
      // Не критично, если не удалось обновить время входа
    }
  }

  /// Обновление профиля пользователя в таблице users
  Future<void> _updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);
    } catch (e) {
      debugPrint('UpdateUserProfile error: $e');
      rethrow;
    }
  }

  /// Создание профиля пользователя в таблице users
  Future<void> _createUserProfile(User user, String? username, String? fullName, String? phone, String? city, List<String>? selectedHabitIds) async {
    try {
      // Идемпотентно создаем/обновляем запись пользователя
      await _supabase.from('users').upsert({
        'id': user.id,
        'email': user.email,
        'username': username,
        'full_name': fullName,
        'phone': phone,
        'city': city,
        'onboarding_completed': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'last_login_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      // Создаем записи для выбранных привычек
      if (selectedHabitIds != null && selectedHabitIds.isNotEmpty) {
        final now = DateTime.now().toIso8601String();
        final habitUpserts = selectedHabitIds.map((habitId) => {
          'user_id': user.id,
          'habit_id': habitId,
          'is_active': true,
          'target_value': 1,
          'frequency': 'daily',
          'created_at': now,
          'updated_at': now,
        }).toList();

        // Идемпотентно добавляем привычки пользователя
        await _supabase.from('user_habits').upsert(
          habitUpserts,
          onConflict: 'user_id,habit_id',
        );
      }

      // Создаем начальную запись прогресса пользователя
      await _supabase.from('user_progress').upsert({
        'user_id': user.id,
        'total_steps': 0,
        'current_streak': 0,
        'total_xp': 0,
        'current_zone': 'beginner',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

    } catch (e) {
      debugPrint('CreateUserProfile error: $e');
      rethrow;
    }
  }

  /// Удаление аккаунта
  Future<void> deleteAccount() async {
    try {
      // Сначала удаляем профиль из таблицы users
      if (currentUser != null) {
        await _supabase
            .from('users')
            .delete()
            .eq('id', currentUser!.id);
      }

      // Затем удаляем пользователя из auth
      await _supabase.auth.admin.deleteUser(currentUser!.id);
    } catch (e) {
      debugPrint('DeleteAccount error: $e');
      rethrow;
    }
  }
}

/// Состояние аутентификации
class AuthStateData {
  final AuthChangeEvent event;
  final Session? session;
  final User? user;

  const AuthStateData({
    required this.event,
    this.session,
    this.user,
  });

  bool get isAuthenticated => user != null;
  bool get isSignedIn => event == AuthChangeEvent.signedIn;
  bool get isSignedOut => event == AuthChangeEvent.signedOut;
  bool get isTokenRefreshed => event == AuthChangeEvent.tokenRefreshed;
  bool get isUserUpdated => event == AuthChangeEvent.userUpdated;
}