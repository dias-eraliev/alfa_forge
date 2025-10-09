/// Централизованные русские лейблы и простейший helper для получения подписей.
/// Если ключ не найден — возвращаем сам ключ (фолбэк), чтобы избежать пустых надписей.

class RuLabels {
  RuLabels._();

  /// Сферы развития пользователя
  static const Map<String, String> spheres = {
    'body': 'Тело',
    'mind': 'Разум',
    'finance': 'Финансы',
    'brotherhood': 'Братство',
  };

  /// Общие заголовки и подписи
  static const Map<String, String> general = {
    'spheres': 'Сферы',
    'todayHabits': 'Привычки сегодня',
    'all': 'Все',
  };

  /// Получить подпись из словаря по ключу (без учета регистра),
  /// при отсутствии вернется исходный ключ.
  static String resolve(Map<String, String> dict, String key) {
    final normalized = key.toLowerCase();
    return dict[normalized] ?? dict[key] ?? key;
  }
}
