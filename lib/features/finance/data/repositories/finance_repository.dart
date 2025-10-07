import 'package:drift/drift.dart';
import '../database/finance_database.dart';

// Экспорт всех сгенерированных классов для использования в репозитории
export '../database/finance_database.dart';

/// Основной репозиторий для работы с финансовыми данными
class FinanceRepository {
  final FinanceDatabase _database;

  FinanceRepository(this._database);

  // ==================== ACCOUNTS ====================

  /// Получить все активные счета
  Future<List<AccountData>> getAllAccounts() async {
    return await (_database.select(_database.accounts)
      ..where((tbl) => tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.name)]))
        .get();
  }

  /// Получить счет по ID
  Future<AccountData?> getAccountById(int id) async {
    return await (_database.select(_database.accounts)
      ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Создать новый счет
  Future<int> createAccount(AccountsCompanion account) async {
    return await _database.into(_database.accounts).insert(account);
  }

  /// Обновить счет
  Future<bool> updateAccount(AccountData account) async {
    return await _database.update(_database.accounts).replace(account);
  }

  /// Обновить баланс счета
  Future<void> updateAccountBalance(int accountId, int newBalance) async {
    await (_database.update(_database.accounts)
      ..where((tbl) => tbl.id.equals(accountId)))
        .write(AccountsCompanion(
          balance: Value(newBalance),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Удалить счет (пометить как неактивный)
  Future<void> deactivateAccount(int accountId) async {
    await (_database.update(_database.accounts)
      ..where((tbl) => tbl.id.equals(accountId)))
        .write(AccountsCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ));
  }

  // ==================== CATEGORIES ====================

  /// Получить все активные категории по типу
  Future<List<CategoryData>> getCategoriesByType(String type) async {
    return await (_database.select(_database.categories)
      ..where((tbl) => tbl.type.equals(type) & tbl.isActive.equals(true))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.sortOrder)]))
        .get();
  }

  /// Получить категории расходов
  Future<List<CategoryData>> getExpenseCategories() async {
    return await getCategoriesByType('expense');
  }

  /// Получить категории доходов
  Future<List<CategoryData>> getIncomeCategories() async {
    return await getCategoriesByType('income');
  }

  /// Получить категорию по ID
  Future<CategoryData?> getCategoryById(int id) async {
    return await (_database.select(_database.categories)
      ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Создать новую категорию
  Future<int> createCategory(CategoriesCompanion category) async {
    return await _database.into(_database.categories).insert(category);
  }

  /// Обновить категорию
  Future<bool> updateCategory(CategoryData category) async {
    return await _database.update(_database.categories).replace(category);
  }

  // ==================== BUDGETS ====================

  /// Получить активные бюджеты для текущего периода
  Future<List<BudgetData>> getCurrentBudgets() async {
    final now = DateTime.now();
    return await (_database.select(_database.budgets)
      ..where((tbl) => 
        tbl.isActive.equals(true) & 
        tbl.periodStart.isSmallerOrEqualValue(now) &
        tbl.periodEnd.isBiggerOrEqualValue(now))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.categoryId)]))
        .get();
  }

  /// Получить бюджет по категории для текущего периода
  Future<BudgetData?> getBudgetByCategory(int categoryId) async {
    final now = DateTime.now();
    return await (_database.select(_database.budgets)
      ..where((tbl) => 
        tbl.categoryId.equals(categoryId) & 
        tbl.isActive.equals(true) &
        tbl.periodStart.isSmallerOrEqualValue(now) &
        tbl.periodEnd.isBiggerOrEqualValue(now)))
        .getSingleOrNull();
  }

  /// Создать новый бюджет
  Future<int> createBudget(BudgetsCompanion budget) async {
    return await _database.into(_database.budgets).insert(budget);
  }

  /// Обновить потраченную сумму в бюджете
  Future<void> updateBudgetSpent(int budgetId, int newSpent) async {
    await (_database.update(_database.budgets)
      ..where((tbl) => tbl.id.equals(budgetId)))
        .write(BudgetsCompanion(
          spent: Value(newSpent),
          updatedAt: Value(DateTime.now()),
        ));
  }

  // ==================== GOALS ====================

  /// Получить все активные цели
  Future<List<GoalData>> getActiveGoals() async {
    return await (_database.select(_database.goals)
      ..where((tbl) => tbl.isActive.equals(true) & tbl.isCompleted.equals(false))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.priority)]))
        .get();
  }

  /// Получить цель по ID
  Future<GoalData?> getGoalById(int id) async {
    return await (_database.select(_database.goals)
      ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Создать новую цель
  Future<int> createGoal(GoalsCompanion goal) async {
    return await _database.into(_database.goals).insert(goal);
  }

  /// Обновить сохраненную сумму в цели
  Future<void> updateGoalSavedAmount(int goalId, int newSavedAmount) async {
    final goal = await getGoalById(goalId);
    if (goal != null) {
      final isCompleted = newSavedAmount >= goal.targetAmount;
      await (_database.update(_database.goals)
        ..where((tbl) => tbl.id.equals(goalId)))
          .write(GoalsCompanion(
            savedAmount: Value(newSavedAmount),
            isCompleted: Value(isCompleted),
            completedAt: isCompleted ? Value(DateTime.now()) : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ));
    }
  }

  /// Обновить цель
  Future<bool> updateGoal(GoalData goal) async {
    return await _database.update(_database.goals).replace(goal);
  }

  // ==================== SETTINGS ====================

  /// Получить настройку по ключу
  Future<SettingData?> getSettingByKey(String key) async {
    return await (_database.select(_database.settings)
      ..where((tbl) => tbl.key.equals(key)))
        .getSingleOrNull();
  }

  /// Получить все настройки группы
  Future<List<SettingData>> getSettingsByGroup(String group) async {
    return await (_database.select(_database.settings)
      ..where((tbl) => tbl.group.equals(group))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.key)]))
        .get();
  }

  /// Обновить настройку
  Future<void> updateSetting(String key, String value) async {
    final existing = await getSettingByKey(key);
    if (existing != null) {
      await (_database.update(_database.settings)
        ..where((tbl) => tbl.key.equals(key)))
          .write(SettingsCompanion(
            value: Value(value),
            updatedAt: Value(DateTime.now()),
          ));
    } else {
      await _database.into(_database.settings).insert(SettingsCompanion.insert(
        key: key,
        value: value,
      ));
    }
  }

  // ==================== CALCULATIONS ====================

  /// Получить общий баланс всех счетов
  Future<int> getTotalBalance() async {
    final accounts = await getAllAccounts();
    return accounts.fold<int>(0, (sum, account) => sum + account.balance);
  }

  /// Получить общую потраченную сумму по всем бюджетам
  Future<int> getTotalBudgetSpent() async {
    final budgets = await getCurrentBudgets();
    return budgets.fold<int>(0, (sum, budget) => sum + budget.spent);
  }

  /// Получить общий лимит по всем бюджетам
  Future<int> getTotalBudgetLimit() async {
    final budgets = await getCurrentBudgets();
    return budgets.fold<int>(0, (sum, budget) => sum + budget.limit);
  }

  /// Получить прогресс всех целей
  Future<double> getTotalGoalsProgress() async {
    final goals = await getActiveGoals();
    if (goals.isEmpty) return 0.0;
    
    double totalProgress = 0.0;
    for (final goal in goals) {
      final progress = goal.targetAmount > 0 
        ? (goal.savedAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
      totalProgress += progress;
    }
    
    return totalProgress / goals.length;
  }

  // ==================== TRANSACTIONS ====================

  /// Получить все транзакции
  Future<List<TransactionData>> getAllTransactions() async {
    return await (_database.select(_database.transactions)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  /// Получить транзакции по счету
  Future<List<TransactionData>> getTransactionsByAccount(int accountId) async {
    return await (_database.select(_database.transactions)
      ..where((tbl) => tbl.accountId.equals(accountId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  /// Получить транзакции за период
  Future<List<TransactionData>> getTransactionsByDateRange(
    DateTime startDate, 
    DateTime endDate
  ) async {
    return await (_database.select(_database.transactions)
      ..where((tbl) => 
        tbl.date.isBiggerOrEqualValue(startDate) & 
        tbl.date.isSmallerOrEqualValue(endDate))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  /// Получить транзакции по категории
  Future<List<TransactionData>> getTransactionsByCategory(int categoryId) async {
    return await (_database.select(_database.transactions)
      ..where((tbl) => tbl.categoryId.equals(categoryId))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  /// Получить транзакции по типу
  Future<List<TransactionData>> getTransactionsByType(String type) async {
    return await (_database.select(_database.transactions)
      ..where((tbl) => tbl.type.equals(type))
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
        .get();
  }

  /// Получить транзакцию по ID
  Future<TransactionData?> getTransactionById(int id) async {
    return await (_database.select(_database.transactions)
      ..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  /// Создать новую транзакцию
  Future<int> createTransaction(TransactionsCompanion transaction) async {
    return await _database.into(_database.transactions).insert(transaction);
  }

  /// Обновить транзакцию
  Future<bool> updateTransaction(TransactionData transaction) async {
    return await _database.update(_database.transactions).replace(transaction);
  }

  /// Удалить транзакцию
  Future<void> deleteTransaction(int id) async {
    await (_database.delete(_database.transactions)
      ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  /// Получить сумму транзакций по типу за период
  Future<int> getTransactionSumByTypeAndPeriod(
    String type, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final transactions = await (_database.select(_database.transactions)
      ..where((tbl) =>
        tbl.type.equals(type) &
        tbl.date.isBiggerOrEqualValue(startDate) &
        tbl.date.isSmallerOrEqualValue(endDate)
      ))
        .get();
    
    return transactions.fold<int>(0, (sum, transaction) => sum + transaction.amount);
  }

  /// Получить сумму транзакций по категории за период
  Future<int> getTransactionSumByCategoryAndPeriod(
    int categoryId, 
    DateTime startDate, 
    DateTime endDate
  ) async {
    final transactions = await (_database.select(_database.transactions)
      ..where((tbl) =>
        tbl.categoryId.equals(categoryId) &
        tbl.date.isBiggerOrEqualValue(startDate) &
        tbl.date.isSmallerOrEqualValue(endDate)
      ))
        .get();
    
    return transactions.fold<int>(0, (sum, transaction) => sum + transaction.amount);
  }

  // ==================== FINANCIAL CALCULATIONS ====================

  /// Получить чистый денежный поток за период
  Future<int> getNetCashFlow(DateTime startDate, DateTime endDate) async {
    final income = await getTransactionSumByTypeAndPeriod('income', startDate, endDate);
    final expenses = await getTransactionSumByTypeAndPeriod('expense', startDate, endDate);
    return income - expenses;
  }

  /// Получить Safe-to-Spend на сегодня
  Future<int> getSafeToSpendToday() async {
    final now = DateTime.now();
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysLeftInMonth = endOfMonth.difference(now).inDays + 1;

    if (daysLeftInMonth <= 0) return 0;

    // Получить бюджеты переменных категорий
    final budgets = await getCurrentBudgets();
    int totalVariableBudget = 0;
    int totalVariableSpent = 0;

    for (final budget in budgets) {
      final category = await getCategoryById(budget.categoryId);
      if (category != null && category.type == 'expense') {
        totalVariableBudget += budget.limit;
        totalVariableSpent += budget.spent;
      }
    }

    final remainingBudget = totalVariableBudget - totalVariableSpent;
    return (remainingBudget / daysLeftInMonth).floor();
  }

  /// Получить коэффициент сбережений (Savings Rate)
  Future<double> getSavingsRate(DateTime startDate, DateTime endDate) async {
    final income = await getTransactionSumByTypeAndPeriod('income', startDate, endDate);
    final expenses = await getTransactionSumByTypeAndPeriod('expense', startDate, endDate);
    
    if (income <= 0) return 0.0;
    
    final savings = income - expenses;
    return (savings / income) * 100;
  }

  /// Получить топ категории по тратам за период
  Future<List<Map<String, dynamic>>> getTopCategoriesByExpenses(
    DateTime startDate, 
    DateTime endDate, 
    {int limit = 5}
  ) async {
    // Упрощенная версия без агрегации - получаем все транзакции расходов
    final transactions = await (_database.select(_database.transactions)
      ..where((tbl) =>
        tbl.type.equals('expense') &
        tbl.categoryId.isNotNull() &
        tbl.date.isBiggerOrEqualValue(startDate) &
        tbl.date.isSmallerOrEqualValue(endDate)
      ))
        .get();

    // Группируем по категориям и суммируем
    final categoryTotals = <int, int>{};
    for (final transaction in transactions) {
      if (transaction.categoryId != null) {
        categoryTotals[transaction.categoryId!] = 
          (categoryTotals[transaction.categoryId!] ?? 0) + transaction.amount;
      }
    }

    // Сортируем по убыванию сумм и берем топ
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topEntries = sortedEntries.take(limit);
    
    final topCategories = <Map<String, dynamic>>[];
    for (final entry in topEntries) {
      final category = await getCategoryById(entry.key);
      topCategories.add({
        'category': category,
        'amount': entry.value,
      });
    }

    return topCategories;
  }
}
