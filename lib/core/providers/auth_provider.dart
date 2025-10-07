import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/api_models.dart';
import '../api/api_client.dart';

enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  AuthState _state = AuthState.initial;
  ApiUser? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  ApiUser? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // Инициализация - проверяем сохраненные токены
  Future<void> initialize() async {
    print('👤👤👤 AuthProvider INITIALIZE START 👤👤👤');
    _setState(AuthState.loading);
    
    try {
      // Проверяем, есть ли сохраненные токены
      final isAuth = _authService.isAuthenticated;
      print('👤 AuthService isAuthenticated: $isAuth');
      
      if (isAuth) {
        print('👤 Loading current user...');
        await _loadCurrentUser();
      } else {
        print('👤 No auth tokens, setting unauthenticated');
        _setState(AuthState.unauthenticated);
      }
    } catch (e) {
      print('👤 Error during initialization: $e');
      _setError('Ошибка инициализации: $e');
    }
    
    print('👤 AuthProvider final state: $_state');
    print('👤👤👤 AuthProvider INITIALIZE END 👤👤👤');
  }

  // Загрузить данные текущего пользователя
  Future<void> _loadCurrentUser() async {
    try {
      final response = await _authService.getCurrentUser();
      
      if (response.isSuccess && response.data != null) {
        _user = response.data;
        _setState(AuthState.authenticated);
      } else {
        // Токен невалидный, выходим
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  // Регистрация
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    
    try {
      final registerDto = RegisterDto(
        email: email,
        password: password,
        name: name,
      );
      
      final response = await _authService.register(registerDto);
      
      if (response.isSuccess && response.data != null) {
        await _authService.saveAuthTokens(response.data!);
        _user = response.data!.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.error ?? 'Ошибка регистрации');
        return false;
      }
    } catch (e) {
      _setError('Ошибка регистрации: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Вход
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    
    try {
      final loginDto = LoginDto(
        email: email,
        password: password,
      );
      
      final response = await _authService.login(loginDto);
      
      if (response.isSuccess && response.data != null) {
        await _authService.saveAuthTokens(response.data!);
        _user = response.data!.user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setError(response.error ?? 'Неверные данные для входа');
        return false;
      }
    } catch (e) {
      _setError('Ошибка входа: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Выход
  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _authService.signOut();
    } catch (e) {
      print('Ошибка при выходе: $e');
    } finally {
      _user = null;
      _setState(AuthState.unauthenticated);
      _setLoading(false);
    }
  }

  // Обновить профиль пользователя
  Future<bool> updateProfile({
    String? name,
    String? avatar,
  }) async {
    if (_user == null) return false;
    
    _setLoading(true);
    
    try {
      // Здесь будет вызов API для обновления профиля
      // Пока просто уведомляем об изменениях
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка обновления профиля: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Завершить онбординг
  Future<bool> completeOnboarding() async {
    if (_user == null) return false;
    
    try {
      // Здесь будет вызов API для обновления статуса онбординга
      // Пока просто уведомляем об изменениях
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Ошибка завершения онбординга: $e');
      return false;
    }
  }

  // Очистить ошибку
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Приватные методы
  void _setState(AuthState newState) {
    _state = newState;
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _state = AuthState.error;
    _isLoading = false;
    notifyListeners();
  }

  // Проверить, нужен ли онбординг
  bool get needsOnboarding => 
    _user != null && !_user!.isOnboardingCompleted;

  // Получить инициалы пользователя
  String get userInitials {
    if (_user?.name == null || _user!.name.isEmpty) return 'U';
    
    final names = _user!.name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return _user!.name[0].toUpperCase();
  }

  // Получить приветствие
  String get greeting {
    if (_user?.name == null) return 'Привет!';
    
    final hour = DateTime.now().hour;
    String timeGreeting;
    
    if (hour < 12) {
      timeGreeting = 'Доброе утро';
    } else if (hour < 17) {
      timeGreeting = 'Добрый день';
    } else {
      timeGreeting = 'Добрый вечер';
    }
    
    return '$timeGreeting, ${_user!.name}!';
  }

  // Обновить состояние пользователя (для синхронизации после изменений)
  Future<void> refreshUserState() async {
    if (_authService.isAuthenticated) {
      await _loadCurrentUser();
    }
  }
}

// Riverpod провайдер для AuthProvider
final authProviderNotifier = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});
