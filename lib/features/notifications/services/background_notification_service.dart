import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import '../models/quote_model.dart';
import '../models/notification_settings.dart';
import '../data/quotes_data.dart';
import '../../path/models/user_progress_model.dart';

/// Сервис для управления локальными уведомлениями с мотивационными цитатами
class BackgroundNotificationService {
  static const String _settingsBoxName = 'notification_settings';
  static const String _historyBoxName = 'notification_history';
  
  static final BackgroundNotificationService _instance = BackgroundNotificationService._internal();
  factory BackgroundNotificationService() => _instance;
  BackgroundNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  Box<NotificationSettings>? _settingsBox;
  Box<String>? _historyBox; // История показанных цитат (ID)

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Инициализация timezone
      tz.initializeTimeZones();

      // Инициализация Hive боксов
      await _initializeHive();

      // Инициализация локальных уведомлений
      await _initializeLocalNotifications();

      _isInitialized = true;
      debugPrint('✅ BackgroundNotificationService инициализирован');
    } catch (e) {
      debugPrint('❌ Ошибка инициализации BackgroundNotificationService: $e');
    }
  }

  /// Инициализация Hive боксов
  Future<void> _initializeHive() async {
    try {
      _settingsBox = await Hive.openBox<NotificationSettings>(_settingsBoxName);
      _historyBox = await Hive.openBox<String>(_historyBoxName);
    } catch (e) {
      debugPrint('❌ Ошибка инициализации Hive: $e');
    }
  }

  /// Инициализация локальных уведомлений
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Запрос разрешений на Android 13+
    await _requestPermissions();
  }

  /// Запрос разрешений для уведомлений
  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      await iosImplementation?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  /// Обработка нажатия на уведомление
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    debugPrint('📱 Уведомление нажато: ${notificationResponse.payload}');
    // Здесь можно добавить навигацию или другую логику
  }

  /// Получить текущие настройки уведомлений
  NotificationSettings getSettings() {
    return _settingsBox?.get('current') ?? NotificationSettings.defaultSettings();
  }

  /// Сохранить настройки уведомлений
  Future<void> saveSettings(NotificationSettings settings) async {
    await _settingsBox?.put('current', settings);
    
    if (settings.isEnabled) {
      await startNotifications();
    } else {
      await stopNotifications();
    }
  }

  /// Запустить уведомления
  Future<void> startNotifications() async {
    final settings = getSettings();
    if (!settings.isEnabled) return;

    // Планируем уведомления на сегодня
    await _scheduleTodayNotifications();

    debugPrint('🔔 Уведомления запущены');
  }

  /// Остановить уведомления
  Future<void> stopNotifications() async {
    // Отменяем все запланированные уведомления
    await _flutterLocalNotificationsPlugin.cancelAll();

    debugPrint('🔕 Уведомления остановлены');
  }

  /// Запланировать уведомления на сегодня
  Future<void> _scheduleTodayNotifications() async {
    final settings = getSettings();
    final today = DateTime.now();
    
    if (!settings.shouldWorkOnDay(today)) {
      debugPrint('⏸️ Уведомления отключены на сегодня');
      return;
    }

    final notificationTimes = settings.getNotificationTimesForDay(today);
    final userProgress = await _getUserProgress();
    final shownToday = await _getShownTodayIds();

    for (int i = 0; i < notificationTimes.length; i++) {
      final scheduledTime = notificationTimes[i];
      
      // Пропускаем прошедшее время
      if (scheduledTime.isBefore(DateTime.now())) continue;

      // Получаем контекстную цитату
      final quote = QuotesDatabase.getContextualQuote(
        time: scheduledTime,
        userZone: userProgress?.currentZone,
        enabledCategories: settings.enabledCategories,
        excludeIds: shownToday,
      );

      if (quote != null) {
        await _scheduleNotification(
          id: i + 1000, // Уникальный ID для каждого уведомления
          quote: quote,
          scheduledTime: scheduledTime,
          settings: settings,
        );
      }
    }

    debugPrint('📅 Запланировано ${notificationTimes.length} уведомлений на сегодня');
  }

  /// Запланировать одно уведомление
  Future<void> _scheduleNotification({
    required int id,
    required Quote quote,
    required DateTime scheduledTime,
    required NotificationSettings settings,
  }) async {
    final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'quotes_channel',
      'Мотивационные цитаты',
      channelDescription: 'Уведомления с мотивационными цитатами от AlFA',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = '${quote.categoryEmoji} Мотивация от AlFA';
    final body = quote.text;

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tzDateTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: quote.id,
    );

    debugPrint('⏰ Уведомление запланировано: ${quote.id} на ${scheduledTime.hour}:${scheduledTime.minute}');
  }

  /// Получить прогресс пользователя
  Future<UserProgress?> _getUserProgress() async {
    try {
      final progressBox = await Hive.openBox<UserProgress>('user_progress');
      return progressBox.get('current');
    } catch (e) {
      debugPrint('❌ Ошибка получения прогресса пользователя: $e');
      return null;
    }
  }

  /// Получить ID цитат, показанных сегодня
  Future<List<String>> _getShownTodayIds() async {
    try {
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      
      final shownIds = _historyBox?.get(todayKey);
      if (shownIds != null) {
        return shownIds.split(',').where((id) => id.isNotEmpty).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Ошибка получения истории: $e');
      return [];
    }
  }

  /// Добавить ID цитаты в историю показанных сегодня
  Future<void> _addToHistory(String quoteId) async {
    try {
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      
      final existingIds = await _getShownTodayIds();
      if (!existingIds.contains(quoteId)) {
        existingIds.add(quoteId);
        await _historyBox?.put(todayKey, existingIds.join(','));
      }
    } catch (e) {
      debugPrint('❌ Ошибка добавления в историю: $e');
    }
  }

  /// Показать тестовое уведомление
  Future<void> showTestNotification() async {
    final quote = QuotesDatabase.getContextualQuote(
      time: DateTime.now(),
      enabledCategories: ['motivation', 'success'],
    );

    if (quote != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Тестовые уведомления',
        channelDescription: 'Тестовые уведомления AlFA',
        importance: Importance.high,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _flutterLocalNotificationsPlugin.show(
        Random().nextInt(1000),
        '🧪 Тест: ${quote.categoryEmoji} Мотивация от AlFA',
        quote.text,
        notificationDetails,
        payload: quote.id,
      );

      await _addToHistory(quote.id);
    }
  }

  /// Получить статистику уведомлений
  Future<Map<String, dynamic>> getNotificationStatistics() async {
    final settings = getSettings();
    final shownToday = await _getShownTodayIds();
    
    return {
      'isEnabled': settings.isEnabled,
      'notificationsPerDay': settings.notificationsPerDay,
      'shownToday': shownToday.length,
      'nextNotificationTime': await _getNextNotificationTime(),
      'totalQuotesAvailable': QuotesDatabase.getAllQuotes().length,
    };
  }

  /// Получить время следующего уведомления
  Future<DateTime?> _getNextNotificationTime() async {
    try {
      final pendingNotifications = await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
      
      if (pendingNotifications.isEmpty) return null;

      // Находим ближайшее уведомление (здесь упрощенная логика)
      final now = DateTime.now();
      final settings = getSettings();
      
      for (int hour = now.hour; hour <= settings.endHour; hour++) {
        final nextTime = DateTime(now.year, now.month, now.day, hour);
        if (nextTime.isAfter(now) && settings.shouldWorkAtTime(nextTime)) {
          return nextTime;
        }
      }
      
      // Если сегодня больше нет уведомлений, возвращаем завтрашнее утро
      final tomorrow = now.add(const Duration(days: 1));
      return DateTime(tomorrow.year, tomorrow.month, tomorrow.day, settings.startHour);
    } catch (e) {
      debugPrint('❌ Ошибка получения времени следующего уведомления: $e');
      return null;
    }
  }

  /// Очистить историю уведомлений
  Future<void> clearHistory() async {
    await _historyBox?.clear();
    debugPrint('🧹 История уведомлений очищена');
  }

  /// Освободить ресурсы
  Future<void> dispose() async {
    await _settingsBox?.close();
    await _historyBox?.close();
  }
}
