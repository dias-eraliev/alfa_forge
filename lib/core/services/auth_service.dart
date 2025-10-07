import '../api/api_client.dart';
import '../models/api_models.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient.instance;

  // Регистрация
  Future<ApiResponse<AuthTokens>> register(RegisterDto registerDto) async {
    return await _apiClient.post<AuthTokens>(
      '/auth/register',
      body: registerDto.toJson(),
      fromJson: (json) => AuthTokens.fromJson(json),
    );
  }

  // Вход
  Future<ApiResponse<AuthTokens>> login(LoginDto loginDto) async {
    return await _apiClient.post<AuthTokens>(
      '/auth/login',
      body: loginDto.toJson(),
      fromJson: (json) => AuthTokens.fromJson(json),
    );
  }

  // Обновление токена
  Future<ApiResponse<AuthTokens>> refreshToken() async {
    return await _apiClient.post<AuthTokens>(
      '/auth/refresh',
      fromJson: (json) => AuthTokens.fromJson(json),
    );
  }

  // Выход
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    return await _apiClient.post<Map<String, dynamic>>('/auth/logout');
  }

  // Получить текущего пользователя
  Future<ApiResponse<ApiUser>> getCurrentUser() async {
    return await _apiClient.get<ApiUser>(
      '/auth/me',
      fromJson: (json) => ApiUser.fromJson(json),
    );
  }

  // Сохранить токены и авторизоваться
  Future<void> saveAuthTokens(AuthTokens tokens) async {
    await _apiClient.saveTokens(tokens.accessToken, tokens.refreshToken);
  }

  // Выйти и очистить токены
  Future<void> signOut() async {
    await logout();
    await _apiClient.clearTokens();
  }

  // Проверить авторизацию
  bool get isAuthenticated {
    final result = _apiClient.isAuthenticated;
    print('🔐🔐🔐 AuthService.isAuthenticated: $result 🔐🔐🔐');
    return result;
  }
}
