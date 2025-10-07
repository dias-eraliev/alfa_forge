import '../api/api_client.dart';
import '../models/api_models.dart';

class HabitsService {
  final ApiClient _apiClient = ApiClient.instance;

  // Получить все привычки пользователя
  Future<ApiResponse<List<ApiHabit>>> getHabits({
    String? category,
    String? frequency,
    bool? isActive,
  }) async {
    final queryParams = <String, String>{};
    if (category != null) queryParams['category'] = category;
    if (frequency != null) queryParams['frequency'] = frequency;
    if (isActive != null) queryParams['isActive'] = isActive.toString();

    return await _apiClient.get<List<ApiHabit>>(
      '/habits',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final List<dynamic> habitsList = json['data'] ?? json;
        return habitsList.map((habit) => ApiHabit.fromJson(habit)).toList();
      },
    );
  }

  // Получить привычку по ID
  Future<ApiResponse<ApiHabit>> getHabitById(String id) async {
    return await _apiClient.get<ApiHabit>(
      '/habits/$id',
      fromJson: (json) => ApiHabit.fromJson(json),
    );
  }

  // Создать новую привычку
  Future<ApiResponse<ApiHabit>> createHabit(CreateHabitDto habitDto) async {
    return await _apiClient.post<ApiHabit>(
      '/habits',
      body: habitDto.toJson(),
      fromJson: (json) => ApiHabit.fromJson(json),
    );
  }

  // Обновить привычку
  Future<ApiResponse<ApiHabit>> updateHabit(String id, CreateHabitDto habitDto) async {
    return await _apiClient.put<ApiHabit>(
      '/habits/$id',
      body: habitDto.toJson(),
      fromJson: (json) => ApiHabit.fromJson(json),
    );
  }

  // Удалить привычку
  Future<ApiResponse<Map<String, dynamic>>> deleteHabit(String id) async {
    return await _apiClient.delete<Map<String, dynamic>>('/habits/$id');
  }

  // Отметить выполнение привычки
  Future<ApiResponse<ApiHabitCompletion>> completeHabit(
    String habitId, {
    DateTime? date,
    int count = 1,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'date': (date ?? DateTime.now()).toIso8601String(),
      'count': count,
      if (notes != null) 'notes': notes,
    };

    return await _apiClient.post<ApiHabitCompletion>(
      '/habits/$habitId/complete',
      body: body,
      fromJson: (json) => ApiHabitCompletion.fromJson(json),
    );
  }

  // Отменить выполнение привычки
  Future<ApiResponse<Map<String, dynamic>>> uncompleteHabit(
    String habitId,
    DateTime date,
  ) async {
    final dateStr = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    return await _apiClient.delete<Map<String, dynamic>>(
      '/habits/$habitId/complete/$dateStr',
    );
  }

  // Получить статистику привычки
  Future<ApiResponse<Map<String, dynamic>>> getHabitStats(
    String habitId, {
    int days = 30,
  }) async {
    return await _apiClient.get<Map<String, dynamic>>(
      '/habits/$habitId/stats',
      queryParams: {'days': days.toString()},
    );
  }

  // Получить категории привычек
  Future<ApiResponse<List<String>>> getHabitCategories() async {
    return await _apiClient.get<List<String>>(
      '/habits/categories/list',
      fromJson: (json) {
        final List<dynamic> categories = json['data'] ?? json;
        return categories.cast<String>();
      },
    );
  }

  // Получить шаблоны привычек
  Future<ApiResponse<List<Map<String, dynamic>>>> getHabitTemplates() async {
    return await _apiClient.get<List<Map<String, dynamic>>>(
      '/habits/templates/list',
      fromJson: (json) {
        final List<dynamic> templates = json['data'] ?? json;
        return templates.cast<Map<String, dynamic>>();
      },
    );
  }

  // ========== МЕТОДЫ ДЛЯ PATH PAGE ==========

  /// Получить сегодняшние привычки (активные привычки с информацией о выполнении)
  Future<ApiResponse<List<ApiHabit>>> getTodayHabits() async {
    try {
      print('🏃‍♂️ Getting today habits...');
      
      // Получаем активные привычки
      final response = await getHabits(isActive: true);
      
      if (response.isSuccess && response.data != null) {
        print('🏃‍♂️ Today habits received successfully: ${response.data!.length} habits');
        return response;
      } else {
        print('❌ Failed to get today habits: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки привычек');
      }
    } catch (e) {
      print('❌ Today habits service error: $e');
      return ApiResponse.error('Ошибка загрузки привычек: $e');
    }
  }

  /// Переключить статус выполнения привычки
  Future<ApiResponse<ApiHabitCompletion>> toggleHabitCompletion(String habitId) async {
    try {
      print('🔄 Toggling habit completion for $habitId...');
      
      // Проверяем, выполнена ли привычка сегодня
      final today = DateTime.now();
      final habit = await getHabitById(habitId);
      
      if (!habit.isSuccess || habit.data == null) {
        return ApiResponse.error('Привычка не найдена');
      }
      
      // Проверяем есть ли выполнение сегодня
      final todayCompletion = habit.data!.completions.any((c) => 
        c.date.day == today.day &&
        c.date.month == today.month &&
        c.date.year == today.year
      );
      
      if (todayCompletion) {
        // Если выполнена - отменяем
        final response = await uncompleteHabit(habitId, today);
        if (response.isSuccess) {
          print('✅ Habit completion removed successfully');
          // Возвращаем пустой completion для индикации отмены
          return ApiResponse.success(ApiHabitCompletion(
            id: '', 
            habitId: habitId, 
            date: today, 
            count: 0
          ));
        } else {
          return ApiResponse.error(response.error ?? 'Ошибка отмены выполнения');
        }
      } else {
        // Если не выполнена - отмечаем
        final response = await completeHabit(habitId);
        if (response.isSuccess) {
          print('✅ Habit completed successfully');
          return response;
        } else {
          return ApiResponse.error(response.error ?? 'Ошибка выполнения привычки');
        }
      }
    } catch (e) {
      print('❌ Toggle habit completion error: $e');
      return ApiResponse.error('Ошибка изменения статуса привычки: $e');
    }
  }
}
