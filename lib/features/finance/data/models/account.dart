import 'package:drift/drift.dart';

// Модель счета для хранения информации о финансовых счетах пользователя
@DataClassName('AccountData')
class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Название счета (например, "Наличные", "Kaspi Card")
  TextColumn get name => text().withLength(min: 1, max: 100)();
  
  // Тип счета: cash, card, bank
  TextColumn get type => text().withLength(min: 1, max: 20)();
  
  // Валюта счета (по умолчанию KZT)
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant('KZT'))();
  
  // Текущий баланс счета в тиынах (минимальная единица тенге)
  IntColumn get balance => integer().withDefault(const Constant(0))();
  
  // Флаг активности счета
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Дата создания
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Дата последнего обновления
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
