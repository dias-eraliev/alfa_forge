import 'package:drift/drift.dart';

// Модель бюджета для установки лимитов по категориям
@DataClassName('BudgetData')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Период бюджета: month, quarter, year
  TextColumn get period => text().withLength(min: 1, max: 20).withDefault(const Constant('month'))();
  
  // ID категории, к которой применяется лимит
  IntColumn get categoryId => integer()();
  
  // Лимит в тиынах
  IntColumn get limit => integer()();
  
  // Потрачено в текущем периоде (в тиынах)
  IntColumn get spent => integer().withDefault(const Constant(0))();
  
  // Флаг переноса остатка на следующий период
  BoolColumn get rollover => boolean().withDefault(const Constant(false))();
  
  // Дата начала периода
  DateTimeColumn get periodStart => dateTime()();
  
  // Дата окончания периода
  DateTimeColumn get periodEnd => dateTime()();
  
  // Флаг активности бюджета
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Дата создания
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Дата последнего обновления
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Index> get indexes => {
    // Индексы для быстрого поиска
    Index('idx_budget_category', [categoryId]),
    Index('idx_budget_period', [periodStart, periodEnd]),
    Index('idx_budget_active', [isActive]),
  };
}
