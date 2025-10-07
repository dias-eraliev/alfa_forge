import 'package:drift/drift.dart';

// Модель финансовой цели для накоплений
@DataClassName('GoalData')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Название цели
  TextColumn get name => text().withLength(min: 1, max: 200)();
  
  // Описание цели
  TextColumn get description => text().withLength(min: 0, max: 500).nullable()();
  
  // Целевая сумма в тиынах
  IntColumn get targetAmount => integer()();
  
  // Уже накопленная сумма в тиынах
  IntColumn get savedAmount => integer().withDefault(const Constant(0))();
  
  // Валюта цели
  TextColumn get currency => text().withLength(min: 3, max: 3).withDefault(const Constant('KZT'))();
  
  // Дедлайн для достижения цели
  DateTimeColumn get deadline => dateTime().nullable()();
  
  // Приоритет цели (1 - высокий, 5 - низкий)
  IntColumn get priority => integer().withDefault(const Constant(3))();
  
  // Тип цели: emergency_fund, travel, purchase, investment, debt_payoff
  TextColumn get type => text().withLength(min: 1, max: 50).withDefault(const Constant('purchase'))();
  
  // Цвет для отображения в UI
  TextColumn get color => text().withLength(min: 7, max: 9).withDefault(const Constant('#4CAF50'))();
  
  // Иконка цели
  TextColumn get icon => text().withLength(min: 1, max: 50).withDefault(const Constant('savings'))();
  
  // Автоматическое пополнение (сумма в тиынах)
  IntColumn get autoContribution => integer().nullable()();
  
  // Частота автопополнения: daily, weekly, monthly
  TextColumn get autoFrequency => text().withLength(min: 1, max: 20).nullable()();
  
  // Флаг активности цели
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Флаг достижения цели
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  
  // Дата завершения цели
  DateTimeColumn get completedAt => dateTime().nullable()();
  
  // Дата создания
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Дата последнего обновления
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Index> get indexes => {
    // Индексы для быстрого поиска
    Index('idx_goal_type', [type]),
    Index('idx_goal_priority', [priority]),
    Index('idx_goal_active', [isActive]),
    Index('idx_goal_completed', [isCompleted]),
    Index('idx_goal_deadline', [deadline]),
  };
}
