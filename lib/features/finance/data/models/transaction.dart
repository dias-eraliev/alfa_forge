import 'package:drift/drift.dart';

// Модель транзакции для хранения всех финансовых операций
@DataClassName('TransactionData')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // ID счета, к которому относится транзакция
  IntColumn get accountId => integer()();
  
  // Дата и время операции
  DateTimeColumn get date => dateTime()();
  
  // Тип операции: expense, income, transfer
  TextColumn get type => text().withLength(min: 1, max: 20)();
  
  // Сумма в тиынах (минимальная единица тенге)
  IntColumn get amount => integer()();
  
  // Валюта операции
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant('KZT'))();
  
  // ID категории (может быть null для переводов)
  IntColumn get categoryId => integer().nullable()();
  
  // Название мерчанта/магазина
  TextColumn get merchant => text().withLength(min: 0, max: 200).nullable()();
  
  // Заметка к операции
  TextColumn get note => text().withLength(min: 0, max: 500).nullable()();
  
  // Теги для дополнительной категоризации (JSON array)
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  
  // Флаг регулярной операции
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  
  // ID связанной транзакции (для переводов)
  IntColumn get linkedTransactionId => integer().nullable()();
  
  // Дата создания записи
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Дата последнего обновления
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Index> get indexes => {
    // Индексы для быстрого поиска
    Index('idx_transaction_date', [date]),
    Index('idx_transaction_category', [categoryId]),
    Index('idx_transaction_merchant', [merchant]),
    Index('idx_transaction_account', [accountId]),
    Index('idx_transaction_type', [type]),
  };
}
