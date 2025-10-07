import 'package:hive/hive.dart';

part 'notification_settings.g.dart';

@HiveType(typeId: 11)
class NotificationSettings extends HiveObject {
  @HiveField(0)
  bool isEnabled;

  @HiveField(1)
  int startHour; // Час начала уведомлений (по умолчанию 7)

  @HiveField(2)
  int endHour; // Час окончания уведомлений (по умолчанию 22)

  @HiveField(3)
  int intervalMinutes; // Интервал между уведомлениями в минутах (по умолчанию 60)

  @HiveField(4)
  List<String> enabledCategories; // Включенные категории цитат

  @HiveField(5)
  bool soundEnabled; // Включен ли звук

  @HiveField(6)
  bool vibrationEnabled; // Включена ли вибрация

  @HiveField(7)
  bool weekendsEnabled; // Работать ли в выходные

  @HiveField(8)
  List<int> disabledDays; // Отключенные дни недели (1=Monday, 7=Sunday)

  @HiveField(9)
  String preferredTimeZone; // Часовой пояс пользователя

  @HiveField(10)
  bool smartScheduling; // Умное планирование на основе активности

  @HiveField(11)
  bool premiumQuotesEnabled; // Включены ли премиум цитаты

  @HiveField(12)
  int maxDailyQuotes; // Максимальное количество цитат в день

  NotificationSettings({
    this.isEnabled = true,
    this.startHour = 7,
    this.endHour = 22,
    this.intervalMinutes = 60,
    this.enabledCategories = const [
      'money',
      'discipline', 
      'will',
      'focus',
      'success',
    ],
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.weekendsEnabled = true,
    this.disabledDays = const [],
    this.preferredTimeZone = 'Asia/Qyzylorda',
    this.smartScheduling = true,
    this.premiumQuotesEnabled = false,
    this.maxDailyQuotes = 15,
  });

  /// Создать копию с обновленными настройками
  NotificationSettings copyWith({
    bool? isEnabled,
    int? startHour,
    int? endHour,
    int? intervalMinutes,
    List<String>? enabledCategories,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? weekendsEnabled,
    List<int>? disabledDays,
    String? preferredTimeZone,
    bool? smartScheduling,
    bool? premiumQuotesEnabled,
    int? maxDailyQuotes,
  }) {
    return NotificationSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      enabledCategories: enabledCategories ?? this.enabledCategories,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      weekendsEnabled: weekendsEnabled ?? this.weekendsEnabled,
      disabledDays: disabledDays ?? this.disabledDays,
      preferredTimeZone: preferredTimeZone ?? this.preferredTimeZone,
      smartScheduling: smartScheduling ?? this.smartScheduling,
      premiumQuotesEnabled: premiumQuotesEnabled ?? this.premiumQuotesEnabled,
      maxDailyQuotes: maxDailyQuotes ?? this.maxDailyQuotes,
    );
  }

  /// Проверить, должны ли работать уведомления в указанный день
  bool shouldWorkOnDay(DateTime day) {
    if (!isEnabled) return false;
    
    // Проверяем выходные
    if (!weekendsEnabled && (day.weekday == 6 || day.weekday == 7)) {
      return false;
    }

    // Проверяем отключенные дни
    if (disabledDays.contains(day.weekday)) {
      return false;
    }

    return true;
  }

  /// Проверить, подходит ли текущее время для уведомления
  bool shouldWorkAtTime(DateTime time) {
    if (!shouldWorkOnDay(time)) return false;
    
    final hour = time.hour;
    return hour >= startHour && hour <= endHour;
  }

  /// Получить количество уведомлений в день
  int get notificationsPerDay {
    final workingHours = endHour - startHour + 1;
    final maxByInterval = (workingHours * 60 / intervalMinutes).floor();
    return maxByInterval > maxDailyQuotes ? maxDailyQuotes : maxByInterval;
  }

  /// Получить времена уведомлений для дня
  List<DateTime> getNotificationTimesForDay(DateTime day) {
    if (!shouldWorkOnDay(day)) return [];

    final times = <DateTime>[];
    final baseDay = DateTime(day.year, day.month, day.day);
    
    for (int hour = startHour; hour <= endHour; hour += (intervalMinutes ~/ 60)) {
      if (times.length >= maxDailyQuotes) break;
      
      final notificationTime = baseDay.add(Duration(hours: hour));
      times.add(notificationTime);
    }

    return times;
  }

  /// Получить настройки по умолчанию
  static NotificationSettings defaultSettings() {
    return NotificationSettings();
  }

  /// Экспорт настроек в Map для сериализации
  Map<String, dynamic> toMap() {
    return {
      'isEnabled': isEnabled,
      'startHour': startHour,
      'endHour': endHour,
      'intervalMinutes': intervalMinutes,
      'enabledCategories': enabledCategories,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'weekendsEnabled': weekendsEnabled,
      'disabledDays': disabledDays,
      'preferredTimeZone': preferredTimeZone,
      'smartScheduling': smartScheduling,
      'premiumQuotesEnabled': premiumQuotesEnabled,
      'maxDailyQuotes': maxDailyQuotes,
    };
  }

  /// Создание настроек из Map
  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      isEnabled: map['isEnabled'] ?? true,
      startHour: map['startHour'] ?? 7,
      endHour: map['endHour'] ?? 22,
      intervalMinutes: map['intervalMinutes'] ?? 60,
      enabledCategories: List<String>.from(map['enabledCategories'] ?? [
        'money',
        'discipline', 
        'will',
        'focus',
        'success',
      ]),
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      weekendsEnabled: map['weekendsEnabled'] ?? true,
      disabledDays: List<int>.from(map['disabledDays'] ?? []),
      preferredTimeZone: map['preferredTimeZone'] ?? 'Asia/Qyzylorda',
      smartScheduling: map['smartScheduling'] ?? true,
      premiumQuotesEnabled: map['premiumQuotesEnabled'] ?? false,
      maxDailyQuotes: map['maxDailyQuotes'] ?? 15,
    );
  }

  @override
  String toString() {
    return 'NotificationSettings{isEnabled: $isEnabled, startHour: $startHour, endHour: $endHour, interval: ${intervalMinutes}min}';
  }
}
