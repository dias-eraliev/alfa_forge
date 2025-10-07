import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Импорт всех моделей
import '../models/account.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/budget.dart';
import '../models/goal.dart';
import '../models/setting.dart';

// Генерируемый файл будет создан после build_runner
part 'finance_database.g.dart';

// Основная база данных для финансового модуля
@DriftDatabase(tables: [
  Accounts,
  Transactions,
  Categories,
  Budgets,
  Goals,
  Settings,
])
class FinanceDatabase extends _$FinanceDatabase {
  FinanceDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _insertDefaultData();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Здесь будут миграции при обновлении схемы
    },
  );

  // Вставка дефолтных данных при создании БД
  Future<void> _insertDefaultData() async {
    // Создание базовых категорий расходов
    final expenseCategories = [
      CategoriesCompanion.insert(
        name: 'Еда',
        icon: const Value('restaurant'),
        color: const Value('#FF5722'),
        type: const Value('expense'),
        sortOrder: const Value(1),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Транспорт',
        icon: const Value('directions_car'),
        color: const Value('#2196F3'),
        type: const Value('expense'),
        sortOrder: const Value(2),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Подписки',
        icon: const Value('subscriptions'),
        color: const Value('#9C27B0'),
        type: const Value('expense'),
        sortOrder: const Value(3),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Досуг',
        icon: const Value('movie'),
        color: const Value('#FF9800'),
        type: const Value('expense'),
        sortOrder: const Value(4),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Здоровье',
        icon: const Value('local_hospital'),
        color: const Value('#4CAF50'),
        type: const Value('expense'),
        sortOrder: const Value(5),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Дом',
        icon: const Value('home'),
        color: const Value('#795548'),
        type: const Value('expense'),
        sortOrder: const Value(6),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Образование',
        icon: const Value('school'),
        color: const Value('#607D8B'),
        type: const Value('expense'),
        sortOrder: const Value(7),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Прочее',
        icon: const Value('more_horiz'),
        color: const Value('#9E9E9E'),
        type: const Value('expense'),
        sortOrder: const Value(8),
        isSystem: const Value(true),
      ),
    ];

    for (final category in expenseCategories) {
      await into(categories).insert(category);
    }

    // Создание базовых категорий доходов
    final incomeCategories = [
      CategoriesCompanion.insert(
        name: 'Зарплата',
        icon: const Value('work'),
        color: const Value('#4CAF50'),
        type: const Value('income'),
        sortOrder: const Value(1),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Фриланс',
        icon: const Value('laptop'),
        color: const Value('#2196F3'),
        type: const Value('income'),
        sortOrder: const Value(2),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Инвестиции',
        icon: const Value('trending_up'),
        color: const Value('#FF9800'),
        type: const Value('income'),
        sortOrder: const Value(3),
        isSystem: const Value(true),
      ),
      CategoriesCompanion.insert(
        name: 'Другие доходы',
        icon: const Value('attach_money'),
        color: const Value('#9C27B0'),
        type: const Value('income'),
        sortOrder: const Value(4),
        isSystem: const Value(true),
      ),
    ];

    for (final category in incomeCategories) {
      await into(categories).insert(category);
    }

    // Создание базовых счетов
    await into(accounts).insert(AccountsCompanion.insert(
      name: 'Наличные',
      type: 'cash',
      currency: const Value('KZT'),
      balance: const Value(0),
    ));

    await into(accounts).insert(AccountsCompanion.insert(
      name: 'Kaspi Card',
      type: 'card',
      currency: const Value('KZT'),
      balance: const Value(0),
    ));

    // Создание базовых настроек
    final defaultSettings = [
      SettingsCompanion.insert(
        key: 'currency',
        value: 'KZT',
        valueType: 'string',
        description: const Value('Основная валюта'),
        group: 'currency',
      ),
      SettingsCompanion.insert(
        key: 'thousands_separator',
        value: 'dot',
        valueType: 'string',
        description: const Value('Разделитель тысяч: dot, space'),
        group: 'format',
      ),
      SettingsCompanion.insert(
        key: 'language',
        value: 'ru',
        valueType: 'string',
        description: const Value('Язык интерфейса'),
        group: 'general',
      ),
      SettingsCompanion.insert(
        key: 'notifications',
        value: 'true',
        valueType: 'bool',
        description: const Value('Включить уведомления'),
        group: 'notifications',
      ),
      SettingsCompanion.insert(
        key: 'timezone',
        value: 'Asia/Almaty',
        valueType: 'string',
        description: const Value('Часовой пояс'),
        group: 'general',
      ),
    ];

    for (final setting in defaultSettings) {
      await into(settings).insert(setting);
    }
  }
}

// Функция создания подключения к базе данных
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'finance.db'));
    return NativeDatabase(file);
  });
}
