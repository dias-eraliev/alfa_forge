import '../api/api_client.dart';
import '../models/api_models.dart';

class TasksService {
  final ApiClient _apiClient = ApiClient.instance;

  // Получить все задачи пользователя
  Future<ApiResponse<List<ApiTask>>> getTasks() async {
    return await _apiClient.get<List<ApiTask>>(
      '/tasks',
      fromJson: (json) {
        final List<dynamic> data = json['data'] ?? json as List<dynamic>;
        return data.map((taskJson) => ApiTask.fromJson(taskJson)).toList();
      },
    );
  }

  // Получить задачи на сегодня
  Future<ApiResponse<List<ApiTask>>> getTodayTasks() async {
    return await _apiClient.get<List<ApiTask>>(
      '/tasks/today/list',
      fromJson: (json) {
        final List<dynamic> data = json['data'] ?? json as List<dynamic>;
        return data.map((taskJson) => ApiTask.fromJson(taskJson)).toList();
      },
    );
  }

  // Создать задачу
  Future<ApiResponse<ApiTask>> createTask(CreateTaskDto taskDto) async {
    return await _apiClient.post<ApiTask>(
      '/tasks',
      body: taskDto.toJson(),
      fromJson: (json) {
        final data = json['data'] ?? json;
        return ApiTask.fromJson(data);
      },
    );
  }

  // Обновить статус задачи
  Future<ApiResponse<ApiTask>> updateTaskStatus(String taskId, String status) async {
    // Backend doesn't have PATCH /tasks/:id/status; use PUT /tasks/:id with status in body
    return await _apiClient.put<ApiTask>(
      '/tasks/$taskId',
      body: {'status': status},
      fromJson: (json) {
        final data = json['data'] ?? json;
        return ApiTask.fromJson(data);
      },
    );
  }

  // Обновить задачу полностью
  Future<ApiResponse<ApiTask>> updateTask(String taskId, UpdateTaskDto taskDto) async {
    return await _apiClient.put<ApiTask>(
      '/tasks/$taskId',
      body: taskDto.toJson(),
      fromJson: (json) {
        final data = json['data'] ?? json;
        return ApiTask.fromJson(data);
      },
    );
  }

  // Отметить задачу выполненной
  Future<ApiResponse<ApiTask>> completeTask(String taskId) async {
    return await _apiClient.post<ApiTask>(
      '/tasks/$taskId/complete',
      fromJson: (json) {
        final data = json['data'] ?? json;
        return ApiTask.fromJson(data);
      },
    );
  }

  // Удалить задачу
  Future<ApiResponse<void>> deleteTask(String taskId) async {
    return await _apiClient.delete<void>('/tasks/$taskId');
  }

  // Получить задачи по статусу
  Future<ApiResponse<List<ApiTask>>> getTasksByStatus(String status) async {
    return await _apiClient.get<List<ApiTask>>(
      '/tasks/status/$status',
      fromJson: (json) {
        final List<dynamic> data = json['data'] ?? json as List<dynamic>;
        return data.map((taskJson) => ApiTask.fromJson(taskJson)).toList();
      },
    );
  }

  // Получить задачи на неделю
  Future<ApiResponse<List<ApiTask>>> getWeekTasks() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    // Backend expects startDate/endDate ISO strings on /tasks
    final startDate = startOfWeek.toIso8601String();
    final endDate = endOfWeek.toIso8601String();

    return await _apiClient.get<List<ApiTask>>(
      '/tasks',
      queryParams: {'startDate': startDate, 'endDate': endDate},
      fromJson: (json) {
        final List<dynamic> data = json['data'] ?? json as List<dynamic>;
        return data.map((taskJson) => ApiTask.fromJson(taskJson)).toList();
      },
    );
  }

  // Получить статистику задач
  Future<ApiResponse<Map<String, dynamic>>> getTasksStats() async {
    return await _apiClient.get<Map<String, dynamic>>(
      '/tasks/stats/overview',
      fromJson: (json) => json['data'] ?? json,
    );
  }

  // ========== МЕТОДЫ ДЛЯ PATH PAGE ==========

  /// Получить быстрые задачи (задачи с высоким приоритетом или на сегодня)
  Future<ApiResponse<List<ApiTask>>> getQuickTasks() async {
    try {
      print('⚡ Getting quick tasks...');
      
      // Получаем задачи на сегодня
      final response = await getTodayTasks();
      
      if (response.isSuccess && response.data != null) {
        // Фильтруем только быстрые задачи (высокий приоритет или до 15 минут)
        final quickTasks = response.data!.where((task) => 
          task.priority == 'high' || 
          task.category == 'quick' ||
          !task.isCompleted
        ).take(5).toList();
        
        print('⚡ Quick tasks received successfully: ${quickTasks.length} tasks');
        return ApiResponse.success(quickTasks);
      } else {
        print('❌ Failed to get quick tasks: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка загрузки быстрых задач');
      }
    } catch (e) {
      print('❌ Quick tasks service error: $e');
      return ApiResponse.error('Ошибка загрузки быстрых задач: $e');
    }
  }

  /// Переключить статус выполнения задачи
  Future<ApiResponse<ApiTask>> toggleTaskCompletion(String taskId) async {
    try {
      print('🔄 Toggling task completion for $taskId...');
      
      if (taskId.isEmpty) {
        return ApiResponse.error('ID задачи не может быть пустым');
      }
      
      // Отмечаем задачу выполненной
      final response = await completeTask(taskId);
      
      if (response.isSuccess) {
        print('✅ Task completion toggled successfully');
        return response;
      } else {
        print('❌ Failed to toggle task completion: ${response.error}');
        return ApiResponse.error(response.error ?? 'Ошибка изменения статуса задачи');
      }
    } catch (e) {
      print('❌ Toggle task completion error: $e');
      return ApiResponse.error('Ошибка изменения статуса задачи: $e');
    }
  }
}

// DTO классы для работы с задачами
class UpdateTaskDto {
  final String? title;
  final String? description;
  // Backend expects: HIGH | MEDIUM | LOW
  final String? priority;
  // Backend expects field name 'deadline' (ISO 8601 string)
  final DateTime? deadline;
  // Backend expects: ASSIGNED | IN_PROGRESS | DONE
  final String? status;

  UpdateTaskDto({
    this.title,
    this.description,
    this.priority,
    this.deadline,
    this.status,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (title != null) map['title'] = title;
    if (description != null) map['description'] = description;
    if (priority != null) map['priority'] = priority;
    if (deadline != null) map['deadline'] = deadline!.toIso8601String();
    if (status != null) map['status'] = status;
    return map;
  }
}
