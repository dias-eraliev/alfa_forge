import '../api/api_client.dart';
import '../models/api_models.dart';
import 'auth_service.dart';
import 'habits_service.dart';
import 'tasks_service.dart';

// Главный сервис для API интеграции
class ApiService {
  static ApiService? _instance;
  late final ApiClient _apiClient;
  late final AuthService auth;
  late final HabitsService habits;
  late final TasksService tasks;

  ApiService._internal() {
    _apiClient = ApiClient.instance;
    auth = AuthService();
    habits = HabitsService();
    tasks = TasksService();
  }

  static ApiService get instance {
    _instance ??= ApiService._internal();
    return _instance!;
  }

  // Инициализация API клиента
  Future<void> initialize() async {
    await _apiClient.initialize();
  }

  // Проверка авторизации
  bool get isAuthenticated => _apiClient.isAuthenticated;

  // === DASHBOARD ===
  Future<ApiResponse<ApiDashboard>> getDashboard() async {
    return await _apiClient.get<ApiDashboard>(
      '/dashboard',
      fromJson: (json) => ApiDashboard.fromJson(json),
    );
  }

  Future<ApiResponse<List<Map<String, dynamic>>>> getWeeklyProgress() async {
    return await _apiClient.get<List<Map<String, dynamic>>>(
      '/dashboard/weekly-progress',
      fromJson: (json) {
        final List<dynamic> progress = json['data'] ?? json;
        return progress.cast<Map<String, dynamic>>();
      },
    );
  }

  Future<ApiResponse<Map<String, double>>> getSphereProgress() async {
    return await _apiClient.get<Map<String, double>>(
      '/dashboard/sphere-progress',
      fromJson: (json) {
        final Map<String, dynamic> progress = json;
        return progress.map((key, value) => MapEntry(key, (value as num).toDouble()));
      },
    );
  }

  Future<ApiResponse<String>> getDailyQuote() async {
    return await _apiClient.get<String>(
      '/dashboard/quote',
      fromJson: (json) => json['quote'] as String,
    );
  }

  // === TASKS ===
  Future<ApiResponse<List<ApiTask>>> getTasks({
    String? status,
    String? priority,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (priority != null) queryParams['priority'] = priority;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    return await _apiClient.get<List<ApiTask>>(
      '/tasks',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final List<dynamic> tasksList = json['data'] ?? json;
        return tasksList.map((task) => ApiTask.fromJson(task)).toList();
      },
    );
  }

  Future<ApiResponse<ApiTask>> createTask(CreateTaskDto taskDto) async {
    return await _apiClient.post<ApiTask>(
      '/tasks',
      body: taskDto.toJson(),
      fromJson: (json) => ApiTask.fromJson(json),
    );
  }

  Future<ApiResponse<ApiTask>> updateTask(String id, CreateTaskDto taskDto) async {
    return await _apiClient.put<ApiTask>(
      '/tasks/$id',
      body: taskDto.toJson(),
      fromJson: (json) => ApiTask.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> deleteTask(String id) async {
    return await _apiClient.delete<Map<String, dynamic>>('/tasks/$id');
  }

  Future<ApiResponse<ApiTask>> completeTask(String id) async {
    return await _apiClient.post<ApiTask>(
      '/tasks/$id/complete',
      fromJson: (json) => ApiTask.fromJson(json),
    );
  }

  Future<ApiResponse<List<ApiTask>>> getTodayTasks() async {
    return await _apiClient.get<List<ApiTask>>(
      '/tasks/today/list',
      fromJson: (json) {
        final List<dynamic> tasksList = json['data'] ?? json;
        return tasksList.map((task) => ApiTask.fromJson(task)).toList();
      },
    );
  }

  // === HEALTH ===
  Future<ApiResponse<List<ApiHealthMeasurement>>> getHealthMeasurements({
    String? typeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (typeId != null) queryParams['typeId'] = typeId;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    return await _apiClient.get<List<ApiHealthMeasurement>>(
      '/health/measurements',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final List<dynamic> measurements = json['data'] ?? json;
        return measurements.map((m) => ApiHealthMeasurement.fromJson(m)).toList();
      },
    );
  }

  Future<ApiResponse<ApiHealthMeasurement>> createHealthMeasurement(
    ApiHealthMeasurement measurement,
  ) async {
    return await _apiClient.post<ApiHealthMeasurement>(
      '/health/measurements',
      body: measurement.toJson(),
      fromJson: (json) => ApiHealthMeasurement.fromJson(json),
    );
  }

  Future<ApiResponse<List<ApiMeasurementType>>> getMeasurementTypes({
    String? category,
  }) async {
    final endpoint = category != null 
        ? '/health/measurement-types/category/$category'
        : '/health/measurement-types';
    
    return await _apiClient.get<List<ApiMeasurementType>>(
      endpoint,
      fromJson: (json) {
        final List<dynamic> types = json['data'] ?? json;
        return types.map((type) => ApiMeasurementType.fromJson(type)).toList();
      },
    );
  }

  // === EXERCISES ===
  Future<ApiResponse<List<ApiExercise>>> getExercises({
    String? type,
    String? category,
    String? difficulty,
    String? search,
  }) async {
    final queryParams = <String, String>{};
    if (type != null) queryParams['type'] = type;
    if (category != null) queryParams['category'] = category;
    if (difficulty != null) queryParams['difficulty'] = difficulty;
    if (search != null) queryParams['search'] = search;

    return await _apiClient.get<List<ApiExercise>>(
      '/exercises',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final List<dynamic> exercises = json['data'] ?? json;
        return exercises.map((exercise) => ApiExercise.fromJson(exercise)).toList();
      },
    );
  }

  Future<ApiResponse<List<ApiExercise>>> getGTOExercises() async {
    return await _apiClient.get<List<ApiExercise>>(
      '/exercises/gto/list',
      fromJson: (json) {
        final List<dynamic> exercises = json['data'] ?? json;
        return exercises.map((exercise) => ApiExercise.fromJson(exercise)).toList();
      },
    );
  }

  Future<ApiResponse<List<ApiWorkoutSession>>> getUserWorkouts({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
    if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

    return await _apiClient.get<List<ApiWorkoutSession>>(
      '/exercises/workouts/my',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final List<dynamic> workouts = json['data'] ?? json;
        return workouts.map((workout) => ApiWorkoutSession.fromJson(workout)).toList();
      },
    );
  }

  // === NOTIFICATIONS ===
  Future<ApiResponse<List<ApiNotification>>> getNotifications({
    bool? isRead,
    String? type,
  }) async {
    final queryParams = <String, String>{};
    if (isRead != null) queryParams['isRead'] = isRead.toString();
    if (type != null) queryParams['type'] = type;

    return await _apiClient.get<List<ApiNotification>>(
      '/notifications',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      fromJson: (json) {
        final List<dynamic> notifications = json['data'] ?? json;
        return notifications.map((n) => ApiNotification.fromJson(n)).toList();
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> markNotificationAsRead(String id) async {
    return await _apiClient.post<Map<String, dynamic>>('/notifications/$id/read');
  }

  Future<ApiResponse<Map<String, dynamic>>> markAllNotificationsAsRead() async {
    return await _apiClient.post<Map<String, dynamic>>('/notifications/mark-all-read');
  }

  // === USERS ===
  Future<ApiResponse<ApiUser>> getUserProfile() async {
    return await _apiClient.get<ApiUser>(
      '/users/profile',
      fromJson: (json) => ApiUser.fromJson(json),
    );
  }

  Future<ApiResponse<ApiUser>> updateUserProfile(Map<String, dynamic> profileData) async {
    return await _apiClient.put<ApiUser>(
      '/users/profile',
      body: profileData,
      fromJson: (json) => ApiUser.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> completeOnboarding(Map<String, dynamic> data) async {
    return await _apiClient.post<Map<String, dynamic>>(
      '/users/complete-onboarding',
      body: data,
    );
  }

  // Утилиты для работы с ошибками
  String getErrorMessage(ApiResponse response) {
    return response.error ?? 'Неизвестная ошибка';
  }

  bool isNetworkError(ApiResponse response) {
    return response.error?.contains('Ошибка сети') ?? false;
  }

  bool isAuthError(ApiResponse response) {
    return response.error?.contains('401') ?? false;
  }
}
