import '../api/api_client.dart';
import '../models/api_models.dart';

class ProgressService {
  final ApiClient _apiClient = ApiClient.instance;

  // ========== DASHBOARD ==========

  /// Получить данные дашборда
  Future<ApiResponse<ApiDashboard>> getDashboard() async {
    try {
      print('📊 Getting dashboard data...');
      
      final response = await _apiClient.get('/dashboard');
      
      if (response.isSuccess && response.data != null) {
        final dashboard = ApiDashboard.fromJson(response.data!);
        print('📊 Dashboard data received successfully');
        return ApiResponse.success(dashboard);
      } else {
        print('❌ Failed to get dashboard data: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки дашборда');
      }
    } catch (e) {
      print('❌ Dashboard service error: $e');
      return ApiResponse.error('Ошибка загрузки дашборда: $e');
    }
  }

  /// Получить недельный прогресс
  Future<ApiResponse<List<Map<String, dynamic>>>> getWeeklyProgress() async {
    try {
      print('📈 Getting weekly progress...');
      
      final response = await _apiClient.get('/dashboard/weekly-progress');
      
      if (response.isSuccess && response.data != null) {
        final weeklyProgress = (response.data as List<dynamic>)
            .cast<Map<String, dynamic>>();
        print('📈 Weekly progress received successfully');
        return ApiResponse.success(weeklyProgress);
      } else {
        print('❌ Failed to get weekly progress: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки недельного прогресса');
      }
    } catch (e) {
      print('❌ Weekly progress service error: $e');
      return ApiResponse.error('Ошибка загрузки недельного прогресса: $e');
    }
  }

  /// Получить прогресс по сферам
  Future<ApiResponse<Map<String, double>>> getSphereProgress() async {
    try {
      print('🔮 Getting sphere progress...');
      
      final response = await _apiClient.get('/dashboard/sphere-progress');
      
      if (response.isSuccess && response.data != null) {
        final sphereProgress = (response.data as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, (value as num).toDouble()));
        print('🔮 Sphere progress received successfully');
        return ApiResponse.success(sphereProgress);
      } else {
        print('❌ Failed to get sphere progress: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки прогресса по сферам');
      }
    } catch (e) {
      print('❌ Sphere progress service error: $e');
      return ApiResponse.error('Ошибка загрузки прогресса по сферам: $e');
    }
  }

  /// Получить мотивационную цитату
  Future<ApiResponse<String>> getDailyQuote() async {
    try {
      print('💭 Getting daily quote...');
      
      final response = await _apiClient.get('/dashboard/quote');
      
      if (response.isSuccess && response.data != null) {
        final quote = response.data['quote'] as String? ?? 
                     response.data['message'] as String? ??
                     response.data.toString();
        print('💭 Daily quote received successfully');
        return ApiResponse.success(quote);
      } else {
        print('❌ Failed to get daily quote: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки цитаты');
      }
    } catch (e) {
      print('❌ Daily quote service error: $e');
      return ApiResponse.error('Ошибка загрузки цитаты: $e');
    }
  }

  // ========== PROGRESS STATS ==========

  /// Получить статистику прогресса
  Future<ApiResponse<Map<String, dynamic>>> getProgressStats({
    String? period = 'today',
    String? type,
  }) async {
    try {
      print('📊 Getting progress stats...');
      
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      if (type != null) queryParams['type'] = type;
      
      final response = await _apiClient.get('/progress/stats', queryParams: queryParams);
      
      if (response.isSuccess && response.data != null) {
        final stats = response.data as Map<String, dynamic>;
        print('📊 Progress stats received successfully');
        return ApiResponse.success(stats);
      } else {
        print('❌ Failed to get progress stats: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки статистики');
      }
    } catch (e) {
      print('❌ Progress stats service error: $e');
      return ApiResponse.error('Ошибка загрузки статистики: $e');
    }
  }

  /// Получить данные дашборда для прогресса
  Future<ApiResponse<Map<String, dynamic>>> getDashboardStats({
    String? period = 'today',
  }) async {
    try {
      print('📈 Getting dashboard stats...');
      
      final queryParams = <String, String>{};
      if (period != null) queryParams['period'] = period;
      
      final response = await _apiClient.get('/progress/dashboard', queryParams: queryParams);
      
      if (response.isSuccess && response.data != null) {
        final dashboardStats = response.data as Map<String, dynamic>;
        print('📈 Dashboard stats received successfully');
        return ApiResponse.success(dashboardStats);
      } else {
        print('❌ Failed to get dashboard stats: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки статистики дашборда');
      }
    } catch (e) {
      print('❌ Dashboard stats service error: $e');
      return ApiResponse.error('Ошибка загрузки статистики дашборда: $e');
    }
  }

  // ========== GOALS ==========

  /// Получить цели пользователя
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserGoals({
    String? status,
    String? category,
    int? limit,
  }) async {
    try {
      print('🎯 Getting user goals...');
      
      final queryParams = <String, String>{};
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final response = await _apiClient.get('/progress/goals', queryParams: queryParams);
      
      if (response.isSuccess && response.data != null) {
        final goals = (response.data as List<dynamic>)
            .cast<Map<String, dynamic>>();
        print('🎯 User goals received successfully');
        return ApiResponse.success(goals);
      } else {
        print('❌ Failed to get user goals: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки целей');
      }
    } catch (e) {
      print('❌ User goals service error: $e');
      return ApiResponse.error('Ошибка загрузки целей: $e');
    }
  }

  /// Создать цель
  Future<ApiResponse<Map<String, dynamic>>> createGoal({
    required String title,
    required String description,
    required String category,
    required DateTime targetDate,
    String? priority = 'medium',
  }) async {
    try {
      print('🎯 Creating goal...');
      
      final goalData = {
        'title': title,
        'description': description,
        'category': category,
        'targetDate': targetDate.toIso8601String(),
        'priority': priority,
      };
      
      final response = await _apiClient.post('/progress/goals', body: goalData);
      
      if (response.isSuccess && response.data != null) {
        final goal = response.data as Map<String, dynamic>;
        print('🎯 Goal created successfully');
        return ApiResponse.success(goal);
      } else {
        print('❌ Failed to create goal: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка создания цели');
      }
    } catch (e) {
      print('❌ Create goal service error: $e');
      return ApiResponse.error('Ошибка создания цели: $e');
    }
  }

  // ========== ACHIEVEMENTS ==========

  /// Получить достижения пользователя
  Future<ApiResponse<List<Map<String, dynamic>>>> getUserAchievements({
    bool? unlocked,
    String? category,
  }) async {
    try {
      print('🏆 Getting user achievements...');
      
      final queryParams = <String, String>{};
      if (unlocked != null) queryParams['unlocked'] = unlocked.toString();
      if (category != null) queryParams['category'] = category;
      
      final response = await _apiClient.get('/progress/achievements', queryParams: queryParams);
      
      if (response.isSuccess && response.data != null) {
        final achievements = (response.data as List<dynamic>)
            .cast<Map<String, dynamic>>();
        print('🏆 User achievements received successfully');
        return ApiResponse.success(achievements);
      } else {
        print('❌ Failed to get user achievements: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки достижений');
      }
    } catch (e) {
      print('❌ User achievements service error: $e');
      return ApiResponse.error('Ошибка загрузки достижений: $e');
    }
  }

  // ========== PROGRESS ENTRIES ==========

  /// Получить записи прогресса
  Future<ApiResponse<List<Map<String, dynamic>>>> getProgressEntries({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      print('📝 Getting progress entries...');
      
      final queryParams = <String, String>{};
      if (type != null) queryParams['type'] = type;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (limit != null) queryParams['limit'] = limit.toString();
      
      final response = await _apiClient.get('/progress/entries', queryParams: queryParams);
      
      if (response.isSuccess && response.data != null) {
        final entries = (response.data as List<dynamic>)
            .cast<Map<String, dynamic>>();
        print('📝 Progress entries received successfully');
        return ApiResponse.success(entries);
      } else {
        print('❌ Failed to get progress entries: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки записей прогресса');
      }
    } catch (e) {
      print('❌ Progress entries service error: $e');
      return ApiResponse.error('Ошибка загрузки записей прогресса: $e');
    }
  }

  /// Создать запись прогресса
  Future<ApiResponse<Map<String, dynamic>>> createProgressEntry({
    required String type,
    required Map<String, dynamic> data,
    String? notes,
  }) async {
    try {
      print('📝 Creating progress entry...');
      
      final entryData = {
        'type': type,
        'data': data,
        'notes': notes,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      final response = await _apiClient.post('/progress/entries', body: entryData);
      
      if (response.isSuccess && response.data != null) {
        final entry = response.data as Map<String, dynamic>;
        print('📝 Progress entry created successfully');
        return ApiResponse.success(entry);
      } else {
        print('❌ Failed to create progress entry: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка создания записи прогресса');
      }
    } catch (e) {
      print('❌ Create progress entry service error: $e');
      return ApiResponse.error('Ошибка создания записи прогресса: $e');
    }
  }
}
