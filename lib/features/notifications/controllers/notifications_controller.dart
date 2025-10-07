import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_settings.dart';
import '../models/quote_model.dart';
import '../services/background_notification_service.dart';
import '../data/quotes_data.dart';

/// Provider для сервиса уведомлений
final notificationServiceProvider = Provider<BackgroundNotificationService>((ref) {
  return BackgroundNotificationService();
});

/// Provider для настроек уведомлений
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsController, NotificationSettings>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationSettingsController(service);
});

/// Provider для статистики уведомлений
final notificationStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return await service.getNotificationStatistics();
});

/// Provider для списка доступных цитат
final availableQuotesProvider = Provider<List<Quote>>((ref) {
  return QuotesDatabase.getAllQuotes();
});

/// Provider для статистики цитат по категориям
final quotesStatisticsProvider = Provider<Map<String, int>>((ref) {
  return QuotesDatabase.getQuotesStatistics();
});

/// Provider для контекстной цитаты (для превью)
final contextualQuoteProvider = Provider.family<Quote?, DateTime>((ref, time) {
  final settings = ref.watch(notificationSettingsProvider);
  return QuotesDatabase.getContextualQuote(
    time: time,
    enabledCategories: settings.enabledCategories,
  );
});

/// Контроллер для управления настройками уведомлений
class NotificationSettingsController extends StateNotifier<NotificationSettings> {
  final BackgroundNotificationService _service;
  
  NotificationSettingsController(this._service) : super(NotificationSettings.defaultSettings()) {
    _loadSettings();
  }

  /// Загрузить настройки из хранилища
  Future<void> _loadSettings() async {
    try {
      await _service.initialize();
      state = _service.getSettings();
    } catch (e) {
      debugPrint('❌ Ошибка загрузки настроек уведомлений: $e');
    }
  }

  /// Включить/выключить уведомления
  Future<void> toggleNotifications() async {
    final newSettings = state.copyWith(isEnabled: !state.isEnabled);
    await _updateSettings(newSettings);
  }

  /// Установить время начала уведомлений
  Future<void> setStartHour(int hour) async {
    if (hour >= 0 && hour <= 23 && hour < state.endHour) {
      final newSettings = state.copyWith(startHour: hour);
      await _updateSettings(newSettings);
    }
  }

  /// Установить время окончания уведомлений
  Future<void> setEndHour(int hour) async {
    if (hour >= 0 && hour <= 23 && hour > state.startHour) {
      final newSettings = state.copyWith(endHour: hour);
      await _updateSettings(newSettings);
    }
  }

  /// Установить интервал между уведомлениями
  Future<void> setInterval(int minutes) async {
    if (minutes >= 15 && minutes <= 240) { // От 15 минут до 4 часов
      final newSettings = state.copyWith(intervalMinutes: minutes);
      await _updateSettings(newSettings);
    }
  }

  /// Включить/выключить категорию цитат
  Future<void> toggleCategory(String category) async {
    final categories = List<String>.from(state.enabledCategories);
    
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    
    // Должна быть включена хотя бы одна категория
    if (categories.isNotEmpty) {
      final newSettings = state.copyWith(enabledCategories: categories);
      await _updateSettings(newSettings);
    }
  }

  /// Включить/выключить звук
  Future<void> toggleSound() async {
    final newSettings = state.copyWith(soundEnabled: !state.soundEnabled);
    await _updateSettings(newSettings);
  }

  /// Включить/выключить вибрацию
  Future<void> toggleVibration() async {
    final newSettings = state.copyWith(vibrationEnabled: !state.vibrationEnabled);
    await _updateSettings(newSettings);
  }

  /// Включить/выключить работу в выходные
  Future<void> toggleWeekends() async {
    final newSettings = state.copyWith(weekendsEnabled: !state.weekendsEnabled);
    await _updateSettings(newSettings);
  }

  /// Включить/выключить день недели
  Future<void> toggleDay(int dayOfWeek) async {
    final disabledDays = List<int>.from(state.disabledDays);
    
    if (disabledDays.contains(dayOfWeek)) {
      disabledDays.remove(dayOfWeek);
    } else {
      disabledDays.add(dayOfWeek);
    }
    
    final newSettings = state.copyWith(disabledDays: disabledDays);
    await _updateSettings(newSettings);
  }

  /// Включить/выключить умное планирование
  Future<void> toggleSmartScheduling() async {
    final newSettings = state.copyWith(smartScheduling: !state.smartScheduling);
    await _updateSettings(newSettings);
  }

  /// Установить максимальное количество уведомлений в день
  Future<void> setMaxDailyQuotes(int count) async {
    if (count >= 1 && count <= 50) {
      final newSettings = state.copyWith(maxDailyQuotes: count);
      await _updateSettings(newSettings);
    }
  }

  /// Включить/выключить премиум цитаты
  Future<void> togglePremiumQuotes() async {
    final newSettings = state.copyWith(premiumQuotesEnabled: !state.premiumQuotesEnabled);
    await _updateSettings(newSettings);
  }

  /// Установить часовой пояс
  Future<void> setTimeZone(String timeZone) async {
    final newSettings = state.copyWith(preferredTimeZone: timeZone);
    await _updateSettings(newSettings);
  }

  /// Показать тестовое уведомление
  Future<void> showTestNotification() async {
    try {
      await _service.showTestNotification();
      debugPrint('🧪 Тестовое уведомление отправлено');
    } catch (e) {
      debugPrint('❌ Ошибка отправки тестового уведомления: $e');
    }
  }

  /// Перезапустить уведомления с новыми настройками
  Future<void> restartNotifications() async {
    try {
      await _service.stopNotifications();
      await _service.startNotifications();
      debugPrint('🔄 Уведомления перезапущены');
    } catch (e) {
      debugPrint('❌ Ошибка перезапуска уведомлений: $e');
    }
  }

  /// Очистить историю уведомлений
  Future<void> clearHistory() async {
    try {
      await _service.clearHistory();
      debugPrint('🧹 История уведомлений очищена');
    } catch (e) {
      debugPrint('❌ Ошибка очистки истории: $e');
    }
  }

  /// Сбросить настройки к значениям по умолчанию
  Future<void> resetToDefaults() async {
    final defaultSettings = NotificationSettings.defaultSettings();
    await _updateSettings(defaultSettings);
  }

  /// Обновить настройки и сохранить их
  Future<void> _updateSettings(NotificationSettings newSettings) async {
    try {
      state = newSettings;
      await _service.saveSettings(newSettings);
      debugPrint('✅ Настройки уведомлений обновлены');
    } catch (e) {
      debugPrint('❌ Ошибка обновления настроек: $e');
    }
  }

  /// Получить предпросмотр расписания уведомлений на день
  List<DateTime> getSchedulePreview({DateTime? date}) {
    final targetDate = date ?? DateTime.now();
    return state.getNotificationTimesForDay(targetDate);
  }

  /// Проверить, работают ли уведомления в указанное время
  bool isActiveAtTime(DateTime time) {
    return state.shouldWorkAtTime(time);
  }

  /// Получить информацию о следующем уведомлении
  Future<String> getNextNotificationInfo() async {
    try {
      final stats = await _service.getNotificationStatistics();
      final nextTime = stats['nextNotificationTime'] as DateTime?;
      
      if (nextTime == null) {
        return state.isEnabled ? 'Следующее уведомление не запланировано' : 'Уведомления отключены';
      }
      
      final now = DateTime.now();
      final difference = nextTime.difference(now);
      
      if (difference.inDays > 0) {
        return 'Следующее уведомление завтра в ${nextTime.hour}:${nextTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inHours > 0) {
        return 'Следующее уведомление через ${difference.inHours} ч ${difference.inMinutes % 60} мин';
      } else if (difference.inMinutes > 0) {
        return 'Следующее уведомление через ${difference.inMinutes} мин';
      } else {
        return 'Следующее уведомление скоро';
      }
    } catch (e) {
      return 'Ошибка получения информации';
    }
  }

  /// Получить статистику за день
  Future<Map<String, int>> getDailyStatistics({DateTime? date}) async {
    final targetDate = date ?? DateTime.now();
    final stats = await _service.getNotificationStatistics();
    
    final planned = state.getNotificationTimesForDay(targetDate).length;
    final shown = (stats['shownToday'] as int?) ?? 0;
    
    return {
      'planned': planned,
      'shown': shown,
      'remaining': planned - shown,
    };
  }
}

/// Provider для информации о следующем уведомлении
final nextNotificationInfoProvider = FutureProvider<String>((ref) async {
  final controller = ref.watch(notificationSettingsProvider.notifier);
  return await controller.getNextNotificationInfo();
});

/// Provider для ежедневной статистики
final dailyStatisticsProvider = FutureProvider.family<Map<String, int>, DateTime?>((ref, date) async {
  final controller = ref.watch(notificationSettingsProvider.notifier);
  return await controller.getDailyStatistics(date: date);
});

/// Provider для предпросмотра расписания
final schedulePreviewProvider = Provider.family<List<DateTime>, DateTime?>((ref, date) {
  final controller = ref.watch(notificationSettingsProvider.notifier);
  return controller.getSchedulePreview(date: date);
});
