import 'package:drift/drift.dart';

// Модель настроек финансового модуля
@DataClassName('SettingData')
class Settings extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Ключ настройки
  TextColumn get key => text().withLength(min: 1, max: 100)();
  
  // Значение настройки
  TextColumn get value => text().withLength(min: 0, max: 500)();
  
  // Тип значения: string, int, bool, double
  TextColumn get valueType => text().withLength(min: 1, max: 20).withDefault(const Constant('string'))();
  
  // Описание настройки
  TextColumn get description => text().withLength(min: 0, max: 200).nullable()();
  
  // Группа настроек: currency, format, notifications, appearance
  TextColumn get group => text().withLength(min: 1, max: 50).withDefault(const Constant('general'))();
  
  // Дата создания
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Дата последнего обновления
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Index> get indexes => {
    // Индексы для быстрого поиска
    Index('idx_setting_key', [key], unique: true),
    Index('idx_setting_group', [group]),
  };
}
