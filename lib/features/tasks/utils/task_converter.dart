import '../../../core/models/api_models.dart';

class TaskConverter {
  // Конвертация ApiTask в Map для существующего UI
  static Map<String, dynamic> apiTaskToMap(ApiTask apiTask) {
    return {
      'id': apiTask.id,
      'text': apiTask.title,
      'done': apiTask.isCompleted,
      'habit': null, // Пока не используем связь с привычками
      'description': apiTask.description ?? 'Нет описания',
      'deadline': apiTask.dueDate ?? DateTime.now().add(const Duration(days: 1)),
      'priority': _convertPriority(apiTask.priority),
      'status': _convertStatus(apiTask.status),
    };
  }

  // Конвертация списка ApiTask в список Map
  static List<Map<String, dynamic>> apiTasksToMaps(List<ApiTask> apiTasks) {
    return apiTasks.map((task) => apiTaskToMap(task)).toList();
  }

  // Конвертация приоритета API в UI
  static String _convertPriority(String apiPriority) {
    switch (apiPriority.toLowerCase()) {
      case 'urgent':
      case 'critical':
        return 'high';
      case 'normal':
      case 'medium':
        return 'medium';
      case 'low':
      case 'minor':
        return 'low';
      default:
        return 'medium';
    }
  }

  // Конвертация статуса API в UI
  static String _convertStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'pending':
      case 'todo':
        return 'assigned';
      case 'in_progress':
      case 'active':
        return 'in_progress';
      case 'completed':
      case 'done':
        return 'done';
      default:
        return 'assigned';
    }
  }

  // Конвертация приоритета UI в API
  static String convertPriorityToApi(String uiPriority) {
    switch (uiPriority.toLowerCase()) {
      case 'high':
        return 'urgent';
      case 'medium':
        return 'normal';
      case 'low':
        return 'low';
      default:
        return 'normal';
    }
  }

  // Конвертация статуса UI в API
  static String convertStatusToApi(String uiStatus) {
    switch (uiStatus.toLowerCase()) {
      case 'assigned':
        return 'pending';
      case 'in_progress':
        return 'in_progress';
      case 'done':
        return 'completed';
      default:
        return 'pending';
    }
  }

  // Получить fallback данные при ошибке API
  static List<Map<String, dynamic>> getFallbackTasks() {
    return [
      {
        'text': 'Купить продукты на неделю', 
        'done': false, 
        'habit': null, 
        'id': 'fallback_1',
        'description': 'Купить все необходимые продукты для семьи на предстоящую неделю. Не забыть про овощи, фрукты и молочные продукты.',
        'deadline': DateTime.now().add(const Duration(days: 2)),
        'priority': 'medium',
        'status': 'assigned'
      },
      {
        'text': 'Позвонить клиенту по проекту', 
        'done': true, 
        'habit': null, 
        'id': 'fallback_2',
        'description': 'Обсудить детали проекта Alpha Corp и согласовать следующие этапы работы.',
        'deadline': DateTime.now().subtract(const Duration(days: 1)),
        'priority': 'high',
        'status': 'done'
      },
      {
        'text': 'Тренировка 20 минут', 
        'done': false, 
        'habit': 'Бег', 
        'id': 'fallback_3',
        'description': 'Кардио тренировка в спортзале или пробежка в парке. Поддержание физической формы.',
        'deadline': DateTime.now(),
        'priority': 'low',
        'status': 'assigned'
      },
      {
        'text': 'Прочитать 10 страниц книги', 
        'done': false, 
        'habit': 'Чтение', 
        'id': 'fallback_4',
        'description': 'Продолжить чтение книги "Чистый код" Роберта Мартина. Развитие профессиональных навыков.',
        'deadline': DateTime.now().add(const Duration(days: 1)),
        'priority': 'medium',
        'status': 'in_progress'
      },
      {
        'text': 'Обновить резюме', 
        'done': false, 
        'habit': null, 
        'id': 'fallback_5',
        'description': 'Добавить новые навыки и последние проекты в резюме. Подготовиться к новым возможностям.',
        'deadline': DateTime.now().add(const Duration(days: 7)),
        'priority': 'low',
        'status': 'assigned'
      },
      {
        'text': 'Подготовить отчет', 
        'done': true, 
        'habit': null, 
        'id': 'fallback_6',
        'description': 'Составить детальный отчет о проделанной работе за месяц для руководства.',
        'deadline': DateTime.now().subtract(const Duration(hours: 2)),
        'priority': 'high',
        'status': 'done'
      },
      {
        'text': 'Медитация 5 минут', 
        'done': true, 
        'habit': 'Медитация', 
        'id': 'fallback_7',
        'description': 'Утренняя медитация для снятия стресса и улучшения концентрации.',
        'deadline': DateTime.now(),
        'priority': 'medium',
        'status': 'done'
      },
    ];
  }

  // Создать CreateTaskDto из UI данных
  static CreateTaskDto createTaskDtoFromUI({
    required String title,
    String? description,
    required String priority,
    DateTime? dueDate,
    String? category,
  }) {
    return CreateTaskDto(
      title: title,
      description: description,
      priority: convertPriorityToApi(priority),
      dueDate: dueDate,
      category: category,
    );
  }
}
