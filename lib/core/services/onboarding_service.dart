import '../api/api_client.dart';
import '../models/api_models.dart';

class OnboardingService {
  final ApiClient _apiClient = ApiClient.instance;

  // Обновить профиль пользователя
  // Backend returns UserProfile object here, not full User
  Future<ApiResponse<ApiUserProfile>> updateProfile({
    String? fullName,
    String? phone,
    String? city,
    DateTime? birthDate,
    String? gender,
    String? avatarUrl,
  }) async {
    final body = <String, dynamic>{};
    
    if (fullName != null) body['fullName'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (city != null) body['city'] = city;
    if (birthDate != null) body['birthDate'] = birthDate.toIso8601String();
    if (gender != null) body['gender'] = gender;
    if (avatarUrl != null) body['avatarUrl'] = avatarUrl;

    return await _apiClient.put<ApiUserProfile>(
      '/users/profile',
      body: body,
      fromJson: (json) => ApiUserProfile.fromJson(json),
    );
  }

  // Завершить онбординг
  Future<ApiResponse<Map<String, dynamic>>> completeOnboarding() async {
    return await _apiClient.post<Map<String, dynamic>>(
      '/users/complete-onboarding',
      body: {},
    );
  }

  // Обновить выбранные привычки (если есть такой endpoint)
  Future<ApiResponse<Map<String, dynamic>>> updateSelectedHabits({
    required List<String> habitIds,
  }) async {
    return await _apiClient.post<Map<String, dynamic>>(
      '/users/habits/selected',
      body: {'habitIds': habitIds},
    );
  }

  // Получить текущий профиль
  Future<ApiResponse<ApiUser>> getCurrentProfile() async {
    return await _apiClient.get<ApiUser>(
      '/users/profile',
      fromJson: (json) => ApiUser.fromJson(json),
    );
  }
}
