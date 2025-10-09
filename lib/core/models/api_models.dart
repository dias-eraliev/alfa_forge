// Базовые модели для API

// Профиль пользователя
class ApiUserProfile {
  final String id;
  final String userId;
  final String? fullName;
  final String? phone;
  final String? city;
  final bool onboardingCompleted;
  final String? avatarUrl;
  final String? birthDate;
  final String? gender;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApiUserProfile({
    required this.id,
    required this.userId,
    this.fullName,
    this.phone,
    this.city,
    required this.onboardingCompleted,
    this.avatarUrl,
    this.birthDate,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiUserProfile.fromJson(Map<String, dynamic> json) {
    return ApiUserProfile(
      id: json['id'] as String,
      userId: json['userId'] as String,
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      onboardingCompleted: json['onboardingCompleted'] as bool,
      avatarUrl: json['avatarUrl'] as String?,
      birthDate: json['birthDate'] as String?,
      gender: json['gender'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

// Настройки пользователя
class ApiUserSettings {
  final String id;
  final String userId;
  final bool notificationsEnabled;
  final bool pushNotifications;
  final bool emailNotifications;
  final String theme;
  final String language;
  final String timezone;
  final bool profilePublic;
  final bool shareProgress;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApiUserSettings({
    required this.id,
    required this.userId,
    required this.notificationsEnabled,
    required this.pushNotifications,
    required this.emailNotifications,
    required this.theme,
    required this.language,
    required this.timezone,
    required this.profilePublic,
    required this.shareProgress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiUserSettings.fromJson(Map<String, dynamic> json) {
    return ApiUserSettings(
      id: json['id'] as String,
      userId: json['userId'] as String,
      notificationsEnabled: json['notificationsEnabled'] as bool,
      pushNotifications: json['pushNotifications'] as bool,
      emailNotifications: json['emailNotifications'] as bool,
      theme: json['theme'] as String,
      language: json['language'] as String,
      timezone: json['timezone'] as String,
      profilePublic: json['profilePublic'] as bool,
      shareProgress: json['shareProgress'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

// Прогресс пользователя
class ApiUserProgress {
  final String id;
  final String userId;
  final int totalSteps;
  final int totalXP;
  final int currentStreak;
  final int longestStreak;
  final DateTime lastActiveDate;
  final String currentZone;
  final String currentRank;
  final Map<String, double> sphereProgress;
  final Map<String, int> totalStats;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApiUserProgress({
    required this.id,
    required this.userId,
    required this.totalSteps,
    required this.totalXP,
    required this.currentStreak,
    required this.longestStreak,
    required this.lastActiveDate,
    required this.currentZone,
    required this.currentRank,
    required this.sphereProgress,
    required this.totalStats,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiUserProgress.fromJson(Map<String, dynamic> json) {
    return ApiUserProgress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      totalSteps: json['totalSteps'] as int,
      totalXP: json['totalXP'] as int,
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastActiveDate: DateTime.parse(json['lastActiveDate'] as String),
      currentZone: json['currentZone'] as String,
      currentRank: json['currentRank'] as String,
      sphereProgress: Map<String, double>.from(
        (json['sphereProgress'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
        ),
      ),
      totalStats: Map<String, int>.from(
        (json['totalStats'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value as int),
        ),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

// Пользователь
class ApiUser {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ApiUserProfile profile;
  final ApiUserSettings settings;
  final List<ApiUserProgress> progress;

  ApiUser({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
    required this.profile,
    required this.settings,
    required this.progress,
  });

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    return ApiUser(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      profile: ApiUserProfile.fromJson(json['profile'] as Map<String, dynamic>),
      settings: ApiUserSettings.fromJson(json['settings'] as Map<String, dynamic>),
      progress: (json['progress'] as List<dynamic>)
          .map((e) => ApiUserProgress.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Convenience getters для совместимости с существующим кодом
  String get name => profile.fullName ?? username;
  String? get avatar => profile.avatarUrl;
  bool get isOnboardingCompleted => profile.onboardingCompleted;
}

// Токены аутентификации
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final ApiUser user;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    try {
      print('🔥 DEBUG AuthTokens.fromJson START 🔥');
      print('Raw JSON: $json');
      print('JSON type: ${json.runtimeType}');
      print('JSON keys: ${json.keys.toList()}');
      
      // Проверяем каждый ключ
      print('Has "tokens" key: ${json.containsKey('tokens')}');
      print('Has "user" key: ${json.containsKey('user')}');
      
      if (json.containsKey('tokens')) {
        print('Tokens value: ${json['tokens']}');
        print('Tokens type: ${json['tokens'].runtimeType}');
        if (json['tokens'] is Map) {
          final tokens = json['tokens'] as Map<String, dynamic>;
          print('Tokens keys: ${tokens.keys.toList()}');
          print('Has access: ${tokens.containsKey('access')}');
          print('Has refresh: ${tokens.containsKey('refresh')}');
          if (tokens.containsKey('access')) {
            print('Access token: ${tokens['access']}');
          }
          if (tokens.containsKey('refresh')) {
            print('Refresh token: ${tokens['refresh']}');
          }
        }
      }
      
      if (json.containsKey('user')) {
        print('User value: ${json['user']}');
        print('User type: ${json['user'].runtimeType}');
      }
      
      final result = AuthTokens(
        accessToken: json['tokens']['access'] as String,
        refreshToken: json['tokens']['refresh'] as String,
        user: ApiUser.fromJson(json['user'] as Map<String, dynamic>),
      );
      
      print('🔥 DEBUG AuthTokens.fromJson SUCCESS 🔥');
      return result;
      
    } catch (e, stackTrace) {
      print('🔥🔥🔥 DEBUG AuthTokens.fromJson ERROR 🔥🔥🔥');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('StackTrace: $stackTrace');
      print('Input JSON: $json');
      print('🔥🔥🔥 END ERROR 🔥🔥🔥');
      rethrow;
    }
  }
}

// Привычка из API
class ApiHabit {
  final String id;
  final String name;
  final String? description;
  // Имя категории (из связанной категории или строки)
  final String category;
  // Тип частоты (DAILY/WEEKLY/MONTHLY/CUSTOM)
  final String frequency;
  final int targetCount;
  final String? iconName;
  // Цвет из бэкенда (#RRGGBB)
  final String? colorHex;
  final bool isActive;
  final DateTime createdAt;
  final List<ApiHabitCompletion> completions;

  ApiHabit({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.frequency,
    required this.targetCount,
    this.iconName,
    this.colorHex,
    required this.isActive,
    required this.createdAt,
    this.completions = const [],
  });

  factory ApiHabit.fromJson(Map<String, dynamic> json) {
    // Достаем категорию: либо строка, либо объект { name, displayName }
    String categoryName = 'other';
    final dynamic cat = json['category'];
    if (cat is String) {
      categoryName = cat;
    } else if (cat is Map<String, dynamic>) {
      categoryName = (cat['name'] as String?) ?? (cat['displayName'] as String?) ?? 'other';
    } else if (json['categoryId'] is String) {
      // если пришёл только id, оставим как id
      categoryName = json['categoryId'] as String;
    }

    // Частота: используем frequencyType если есть
    String frequencyValue = (json['frequency'] as String?) ?? (json['frequencyType'] as String?) ?? 'DAILY';

    return ApiHabit(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: categoryName,
      frequency: frequencyValue,
      targetCount: (json['targetCount'] as int?) ?? 1,
      iconName: json['iconName'] as String?,
      colorHex: (json['colorHex'] as String?) ?? (json['color'] as String?),
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      completions: (json['completions'] as List<dynamic>?)
              ?.map((e) => ApiHabitCompletion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

// Выполнение привычки
class ApiHabitCompletion {
  final String id;
  final String habitId;
  final DateTime date;
  final int count;
  final String? notes;

  ApiHabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
    required this.count,
    this.notes,
  });

  factory ApiHabitCompletion.fromJson(Map<String, dynamic> json) {
    return ApiHabitCompletion(
      id: json['id'] as String,
      habitId: (json['habitId'] as String?) ?? '',
      date: DateTime.parse(json['date'] as String),
      count: (json['count'] as int?) ?? 1,
      notes: json['notes'] as String?,
    );
  }
}

// Задача из API
class ApiTask {
  final String id;
  final String title;
  final String? description;
  final String priority;
  final String status;
  final DateTime? dueDate;
  final String? category;
  final bool isCompleted;
  final DateTime createdAt;

  ApiTask({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    this.category,
    required this.isCompleted,
    required this.createdAt,
  });

  factory ApiTask.fromJson(Map<String, dynamic> json) {
    final priorityRaw = (json['priority'] ?? json['Priority'] ?? '') as String;
    final statusRaw = (json['status'] ?? json['Status'] ?? '') as String;
    final dueRaw = json['deadline'] ?? json['dueDate'];
    return ApiTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: priorityRaw,
      status: statusRaw,
      dueDate: dueRaw != null ? DateTime.parse(dueRaw as String) : null,
      category: json['category'] as String?,
      isCompleted: (json['isCompleted'] as bool?) ?? (statusRaw.toString().toLowerCase() == 'completed' || statusRaw.toString().toLowerCase() == 'done'),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority,
      'status': status,
  'dueDate': dueDate?.toIso8601String(),
      'category': category,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// Измерение здоровья
class ApiHealthMeasurement {
  final String id;
  final String typeId;
  final double value;
  final String? unit;
  final DateTime timestamp;
  final String? notes;

  ApiHealthMeasurement({
    required this.id,
    required this.typeId,
    required this.value,
    this.unit,
    required this.timestamp,
    this.notes,
  });

  factory ApiHealthMeasurement.fromJson(Map<String, dynamic> json) {
    return ApiHealthMeasurement(
      id: json['id'] as String,
      typeId: json['typeId'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    // Backend DTO (CreateMeasurementDto) whitelists fields strictly.
    // Do NOT include unsupported fields like 'unit' to avoid 400 errors.
    final map = <String, dynamic>{
      'typeId': typeId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
    };
    if (notes != null && notes!.isNotEmpty) {
      map['notes'] = notes;
    }
    return map;
  }
}

// Тип измерения
class ApiMeasurementType {
  final String id;
  final String name;
  final String unit;
  final String category;
  final String? iconName;
  final String? description;

  ApiMeasurementType({
    required this.id,
    required this.name,
    required this.unit,
    required this.category,
    this.iconName,
    this.description,
  });

  factory ApiMeasurementType.fromJson(Map<String, dynamic> json) {
    return ApiMeasurementType(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String,
      category: json['category'] as String,
      iconName: json['iconName'] as String?,
      description: json['description'] as String?,
    );
  }
}

// Цель здоровья (для Health API)
class ApiHealthGoal {
  final String id;
  final String title;
  final String goalType; // e.g., WEIGHT, BODY_FAT
  final double targetValue;
  final double currentValue;
  final String priority; // LOW|MEDIUM|HIGH
  final String frequency; // DAILY|WEEKLY|MONTHLY|YEARLY
  final DateTime? startDate;
  final DateTime? targetDate;
  final String? typeId; // optional measurement type link
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ApiHealthGoal({
    required this.id,
    required this.title,
    required this.goalType,
    required this.targetValue,
    required this.currentValue,
    required this.priority,
    required this.frequency,
    this.startDate,
    this.targetDate,
    this.typeId,
    this.notes,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiHealthGoal.fromJson(Map<String, dynamic> json) {
    return ApiHealthGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      goalType: json['goalType'] as String,
      targetValue: (json['targetValue'] as num).toDouble(),
      currentValue: (json['currentValue'] as num?)?.toDouble() ?? 0.0,
      priority: json['priority'] as String,
      frequency: json['frequency'] as String,
      startDate: (json['startDate'] != null && (json['startDate'] as String).isNotEmpty)
          ? DateTime.parse(json['startDate'] as String)
          : null,
      targetDate: (json['targetDate'] != null && (json['targetDate'] as String).isNotEmpty)
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      typeId: json['typeId'] as String?,
      notes: json['notes'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'goalType': goalType,
      'targetValue': targetValue,
      'currentValue': currentValue,
      'priority': priority,
      'frequency': frequency,
    };
    if (startDate != null) map['startDate'] = startDate!.toIso8601String();
    if (targetDate != null) map['targetDate'] = targetDate!.toIso8601String();
    if (typeId != null) map['typeId'] = typeId;
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    map['isActive'] = isActive;
    return map;
  }
}

// Упражнение
class ApiExercise {
  final String id;
  final String name;
  final String description;
  final String type;
  final String category;
  final String difficulty;
  final List<String> instructions;
  final bool requiresEquipment;
  final int? duration;
  final String? iconEmoji;

  ApiExercise({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.category,
    required this.difficulty,
    this.instructions = const [],
    this.requiresEquipment = false,
    this.duration,
    this.iconEmoji,
  });

  factory ApiExercise.fromJson(Map<String, dynamic> json) {
    return ApiExercise(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      requiresEquipment: json['requiresEquipment'] as bool? ?? false,
      duration: json['duration'] as int?,
      iconEmoji: json['iconEmoji'] as String?,
    );
  }
}

// Тренировка
class ApiWorkoutSession {
  final String id;
  final String name;
  final String status;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;
  final String? notes;

  ApiWorkoutSession({
    required this.id,
    required this.name,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.notes,
  });

  factory ApiWorkoutSession.fromJson(Map<String, dynamic> json) {
    return ApiWorkoutSession(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String)
          : null,
      duration: json['duration'] as int,
      notes: json['notes'] as String?,
    );
  }
}

// Уведомление
class ApiNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  ApiNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory ApiNotification.fromJson(Map<String, dynamic> json) {
    return ApiNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      isRead: json['isRead'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      data: json['data'] as Map<String, dynamic>?,
    );
  }
}

// Дашборд данные
class ApiDashboard {
  final Map<String, dynamic> overview;
  final List<Map<String, dynamic>> weeklyProgress;
  final Map<String, double> sphereProgress;
  final String? dailyQuote;

  ApiDashboard({
    required this.overview,
    required this.weeklyProgress,
    required this.sphereProgress,
    this.dailyQuote,
  });

  factory ApiDashboard.fromJson(Map<String, dynamic> json) {
    return ApiDashboard(
      overview: json['overview'] as Map<String, dynamic>,
      weeklyProgress: (json['weeklyProgress'] as List<dynamic>)
          .cast<Map<String, dynamic>>(),
      sphereProgress: (json['sphereProgress'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
      dailyQuote: json['dailyQuote'] as String?,
    );
  }
}

// DTO для создания/обновления
// Категория привычки (ответ бэкенда /habits/categories/list)
class ApiHabitCategory {
  final String id;
  final String name;
  final String displayName;
  final String iconName;
  final String colorHex;

  ApiHabitCategory({
    required this.id,
    required this.name,
    required this.displayName,
    required this.iconName,
    required this.colorHex,
  });

  factory ApiHabitCategory.fromJson(Map<String, dynamic> json) {
    return ApiHabitCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String,
      iconName: json['iconName'] as String,
      colorHex: json['colorHex'] as String,
    );
  }
}

// DTO создания/обновления привычки (совместим с backend CreateHabitDto)
class CreateHabitDto {
  final String name;
  final String? description;
  final String? motivation;
  final String iconName;
  final String? iconFamily;
  final String colorHex;
  final String categoryId;
  final String? templateId;
  // Enums в виде строк в формате бэкенда: DAILY|WEEKLY|MONTHLY|CUSTOM
  final String frequencyType;
  final int? timesPerWeek;
  final int? timesPerMonth;
  final List<int>? specificWeekdays; // 1-7
  final String? reminderTime; // HH:MM
  final int? duration; // minutes
  // Enums: EASY|MEDIUM|HARD
  final String difficulty;
  final bool? enableReminders;
  final String? linkedGoal;
  final List<String>? tags;
  final List<String>? motivationalMessages;
  // Enums: STANDARD|INCREMENTAL|TARGET
  final String progressionType;

  CreateHabitDto({
    required this.name,
    this.description,
    this.motivation,
    required this.iconName,
    this.iconFamily,
    required this.colorHex,
    required this.categoryId,
    this.templateId,
    required this.frequencyType,
    this.timesPerWeek,
    this.timesPerMonth,
    this.specificWeekdays,
    this.reminderTime,
    this.duration,
    required this.difficulty,
    this.enableReminders,
    this.linkedGoal,
    this.tags,
    this.motivationalMessages,
    required this.progressionType,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null) 'description': description,
      if (motivation != null) 'motivation': motivation,
      'iconName': iconName,
      if (iconFamily != null) 'iconFamily': iconFamily,
      'colorHex': colorHex,
      'categoryId': categoryId,
      if (templateId != null) 'templateId': templateId,
      'frequencyType': frequencyType,
      if (timesPerWeek != null) 'timesPerWeek': timesPerWeek,
      if (timesPerMonth != null) 'timesPerMonth': timesPerMonth,
      if (specificWeekdays != null) 'specificWeekdays': specificWeekdays,
      if (reminderTime != null) 'reminderTime': reminderTime,
      if (duration != null) 'duration': duration,
      'difficulty': difficulty,
      if (enableReminders != null) 'enableReminders': enableReminders,
      if (linkedGoal != null) 'linkedGoal': linkedGoal,
      if (tags != null) 'tags': tags,
      if (motivationalMessages != null) 'motivationalMessages': motivationalMessages,
      'progressionType': progressionType,
    };
  }
}

class CreateTaskDto {
  final String title;
  final String? description;
  final String priority; // must be one of: LOW, MEDIUM, HIGH
  final DateTime? deadline; // backend expects 'deadline'
  // Habit linking (optional)
  final String? habitId;
  final String? habitName;
  // Optional extras supported by backend DTO
  final DateTime? reminderAt;
  final bool? isRecurring;
  // DAILY | WEEKLY | MONTHLY
  final String? recurringType;
  final List<String>? subtasks;
  final List<String>? tags;

  CreateTaskDto({
    required this.title,
    this.description,
    required this.priority,
    this.deadline,
    this.habitId,
    this.habitName,
    this.reminderAt,
    this.isRecurring,
    this.recurringType,
    this.subtasks,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'priority': priority, // already uppercase
      if (deadline != null) 'deadline': deadline!.toIso8601String(),
      if (habitId != null) 'habitId': habitId,
      if (habitName != null) 'habitName': habitName,
      if (reminderAt != null) 'reminderAt': reminderAt!.toIso8601String(),
      if (isRecurring != null) 'isRecurring': isRecurring,
      if (recurringType != null) 'recurringType': recurringType,
      if (subtasks != null) 'subtasks': subtasks,
      if (tags != null) 'tags': tags,
    };
  }
}

class LoginDto {
  final String email;
  final String password;

  LoginDto({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class RegisterDto {
  final String email;
  final String password;
  final String username;
  final String fullName;
  final String? phone;
  final String? city;

  RegisterDto({
    required this.email,
    required this.password,
    required this.username,
    required this.fullName,
    this.phone,
    this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (city != null) 'city': city,
    };
  }
}

// =================== BROTHERHOOD (микроблог) ===================

enum ApiReactionType { FIRE, THUMBS_UP }

class ApiBrotherhoodReply {
  final String author;
  final String authorInitials;
  final DateTime time;
  final String text;

  ApiBrotherhoodReply({
    required this.author,
    required this.authorInitials,
    required this.time,
    required this.text,
  });

  factory ApiBrotherhoodReply.fromJson(Map<String, dynamic> json) {
    return ApiBrotherhoodReply(
      author: json['author'] as String,
      authorInitials: json['authorInitials'] as String? ?? _initialsFrom(json['author'] as String),
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      text: json['text'] as String,
    );
  }
}

class ApiBrotherhoodPost {
  final String id;
  final String author;
  final String authorInitials;
  final DateTime time;
  final String text;
  final String? topic;
  final int fireReactions;
  final int thumbsUpReactions;
  final bool userReactedFire;
  final bool userReactedThumbs;
  final List<ApiBrotherhoodReply> replies;

  ApiBrotherhoodPost({
    required this.id,
    required this.author,
    required this.authorInitials,
    required this.time,
    required this.text,
    this.topic,
    required this.fireReactions,
    required this.thumbsUpReactions,
    required this.userReactedFire,
    required this.userReactedThumbs,
    required this.replies,
  });

  factory ApiBrotherhoodPost.fromJson(Map<String, dynamic> json) {
    return ApiBrotherhoodPost(
      id: json['id'] as String,
      author: json['author'] as String,
      authorInitials: json['authorInitials'] as String? ?? _initialsFrom(json['author'] as String),
      time: DateTime.tryParse(json['time'] as String? ?? '') ?? DateTime.now(),
      text: json['text'] as String,
      topic: json['topic'] as String?,
      fireReactions: (json['fireReactions'] as int?) ?? 0,
      thumbsUpReactions: (json['thumbsUpReactions'] as int?) ?? 0,
      userReactedFire: (json['userReactions'] is Map<String, dynamic>)
          ? ((json['userReactions'] as Map<String, dynamic>)['fire'] as bool? ?? false)
          : (json['userReactedFire'] as bool? ?? false),
      userReactedThumbs: (json['userReactions'] is Map<String, dynamic>)
          ? ((json['userReactions'] as Map<String, dynamic>)['thumbs'] as bool? ?? false)
          : (json['userReactedThumbs'] as bool? ?? false),
      replies: (json['replies'] as List<dynamic>? ?? const [])
          .map((e) => ApiBrotherhoodReply.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

String _initialsFrom(String name) {
  final parts = name.trim().split(RegExp(r"\s+"));
  final initials = parts.take(2).map((p) => p.isNotEmpty ? p[0] : '').join();
  return initials.isNotEmpty ? initials.toUpperCase() : '?';
}
