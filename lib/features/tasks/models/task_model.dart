class TaskModel {
  final String id;
  final String title;
  final String description;
  final DateTime deadline;
  final TaskPriority priority;
  final TaskStatus status;
  final String? habitId;
  final String? habitName;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isRecurring;
  final RecurringType? recurringType;
  final List<String> subtasks;
  final List<String> attachments;
  final DateTime? reminderAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.deadline,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.assigned,
    this.habitId,
    this.habitName,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isRecurring = false,
    this.recurringType,
    this.subtasks = const [],
    this.attachments = const [],
    this.reminderAt,
  });

  // Конвертация в Map для совместимости с текущей системой
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': title,
      'description': description,
      'deadline': deadline,
      'priority': priority.name,
      'status': status.name,
      'habit': habitName,
      'done': status == TaskStatus.done,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringType': recurringType?.name,
      'subtasks': subtasks,
      'attachments': attachments,
      'reminderAt': reminderAt?.toIso8601String(),
    };
  }

  // Создание из Map (для совместимости с текущими данными)
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] ?? '',
      title: map['text'] ?? map['title'] ?? '',
      description: map['description'] ?? '',
      deadline: map['deadline'] is DateTime 
          ? map['deadline'] 
          : DateTime.tryParse(map['deadline'] ?? '') ?? DateTime.now(),
      priority: TaskPriority.fromString(map['priority'] ?? 'medium'),
      status: TaskStatus.fromString(map['status'] ?? 'assigned'),
      habitId: map['habitId'],
      habitName: map['habit'],
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: map['createdAt'] != null 
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.tryParse(map['updatedAt'])
          : null,
      isRecurring: map['isRecurring'] ?? false,
      recurringType: map['recurringType'] != null 
          ? RecurringType.fromString(map['recurringType'])
          : null,
      subtasks: List<String>.from(map['subtasks'] ?? []),
      attachments: List<String>.from(map['attachments'] ?? []),
      reminderAt: map['reminderAt'] != null 
          ? DateTime.tryParse(map['reminderAt'])
          : null,
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? deadline,
    TaskPriority? priority,
    TaskStatus? status,
    String? habitId,
    String? habitName,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isRecurring,
    RecurringType? recurringType,
    List<String>? subtasks,
    List<String>? attachments,
    DateTime? reminderAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      habitId: habitId ?? this.habitId,
      habitName: habitName ?? this.habitName,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      subtasks: subtasks ?? this.subtasks,
      attachments: attachments ?? this.attachments,
      reminderAt: reminderAt ?? this.reminderAt,
    );
  }
}

enum TaskPriority {
  low,
  medium,
  high;

  static TaskPriority fromString(String value) {
    switch (value.toLowerCase()) {
      case 'low':
        return TaskPriority.low;
      case 'high':
        return TaskPriority.high;
      default:
        return TaskPriority.medium;
    }
  }

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Низкий';
      case TaskPriority.medium:
        return 'Средний';
      case TaskPriority.high:
        return 'Высокий';
    }
  }
}

enum TaskStatus {
  assigned,
  inProgress,
  done;

  static TaskStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.assigned;
    }
  }

  String get name {
    switch (this) {
      case TaskStatus.assigned:
        return 'assigned';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
    }
  }

  String get displayName {
    switch (this) {
      case TaskStatus.assigned:
        return 'Назначено';
      case TaskStatus.inProgress:
        return 'В работе';
      case TaskStatus.done:
        return 'Готово';
    }
  }
}

enum RecurringType {
  daily,
  weekly,
  monthly;

  static RecurringType? fromString(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'daily':
        return RecurringType.daily;
      case 'weekly':
        return RecurringType.weekly;
      case 'monthly':
        return RecurringType.monthly;
      default:
        return null;
    }
  }

  String get displayName {
    switch (this) {
      case RecurringType.daily:
        return 'Ежедневно';
      case RecurringType.weekly:
        return 'Еженедельно';
      case RecurringType.monthly:
        return 'Ежемесячно';
    }
  }
}

class TaskTemplate {
  final String id;
  final String title;
  final String description;
  final TaskPriority defaultPriority;
  final List<String> defaultTags;
  final Duration defaultDeadlineOffset;
  final String? habitName;

  TaskTemplate({
    required this.id,
    required this.title,
    this.description = '',
    this.defaultPriority = TaskPriority.medium,
    this.defaultTags = const [],
    this.defaultDeadlineOffset = const Duration(days: 1),
    this.habitName,
  });

  TaskModel toTask() {
    return TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      deadline: DateTime.now().add(defaultDeadlineOffset),
      priority: defaultPriority,
      tags: List.from(defaultTags),
      createdAt: DateTime.now(),
      habitName: habitName,
    );
  }
}
