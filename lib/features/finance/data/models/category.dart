import 'package:drift/drift.dart';

// Модель категории для классификации финансовых операций
@DataClassName('CategoryData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  // Название категории
  TextColumn get name => text().withLength(min: 1, max: 100)();
  
  // ID родительской категории (для иерархии)
  IntColumn get parentId => integer().nullable()();
  
  // Иконка категории (название иконки из Material Icons или Lucide)
  TextColumn get icon => text().withLength(min: 1, max: 50).withDefault(const Constant('category'))();
  
  // Цвет категории в формате HEX
  TextColumn get color => text().withLength(min: 7, max: 9).withDefault(const Constant('#666666'))();
  
  // Тип категории: expense, income
  TextColumn get type => text().withLength(min: 1, max: 20).withDefault(const Constant('expense'))();
  
  // Порядок сортировки
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  
  // Флаг активности категории
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  
  // Флаг системной категории (нельзя удалить)
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();
  
  // Дата создания
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Дата последнего обновления
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Index> get indexes => {
    // Индексы для быстрого поиска
    Index('idx_category_type', [type]),
    Index('idx_category_parent', [parentId]),
    Index('idx_category_active', [isActive]),
  };
}
