import 'package:drift/drift.dart';
import '../database/finance_database.dart';

// Экспорт всех сгенерированных классов
export '../database/finance_database.dart';

/// Специализированный репозиторий для работы с транзакциями
/// Содержит сложную логику операций, аналитики и массовых операций
class TransactionRepository {
  final FinanceDatabase _database;

  TransactionRepository(this._database);

  // ==================== CRUD ОПЕРАЦИИ ====================

  /// Создать транзакцию с автоматическим обновлением баланса счёта
  Future<int> createTransactionWithBalanceUpdate(TransactionsCompanion transaction) async {
    return await _database.transaction(() async {
      // Создаём транзакцию
      final transactionId = await _database.into(_database.transactions).insert(transaction);
      
      // Обновляем баланс счёта если указан accountId
      if (transaction.accountId.present) {
        final accountId = transaction.accountId.value;
        final amount = transaction.amount.value;
        final type = transaction.type.value;
        
        final account = await (_database.select(_database.accounts)
          ..where((tbl) => tbl.id.equals(accountId)))
            .getSingleOrNull();
            
        if (account != null) {
          int balanceChange;
          switch (type) {
            case 'income':
              balanceChange = amount;
              break;
            case 'expense':
              balanceChange = -amount;
              break;
            case 'transfer':
              // Для переводов баланс не меняется на исходном счёте
              balanceChange = 0;
              break;
            default:
              balanceChange = 0;
          }
          
          final newBalance = account.balance + balanceChange;
          await (_database.update(_database.accounts)
            ..where((tbl) => tbl.id.equals(accountId)))
              .write(AccountsCompanion(
                balance: Value(newBalance),
                updatedAt: Value(DateTime.now()),
              ));
        }
      }
      
      // Обновляем потраченную сумму в бюджете если это расход
      if (transaction.type.value == 'expense' && transaction.categoryId.present && transaction.categoryId.value != null) {
        await _updateBudgetSpentAmount(transaction.categoryId.value!, transaction.amount.value);
      }
      
      return transactionId;
    });
  }

  /// Обновить транзакцию с пересчётом балансов
  Future<bool> updateTransactionWithBalanceUpdate(
    TransactionData oldTransaction, 
    TransactionData newTransaction
  ) async {
    return await _database.transaction(() async {
      // Откатываем старую транзакцию
      await _revertTransactionBalance(oldTransaction);
      
      // Применяем новую транзакцию
      await _applyTransactionBalance(newTransaction);
      
      // Обновляем запись в БД
      final result = await _database.update(_database.transactions).replace(newTransaction);
      
      // Обновляем бюджеты
      if (oldTransaction.type == 'expense' && oldTransaction.categoryId != null) {
        await _updateBudgetSpentAmount(oldTransaction.categoryId!, -oldTransaction.amount);
      }
      if (newTransaction.type == 'expense' && newTransaction.categoryId != null) {
        await _updateBudgetSpentAmount(newTransaction.categoryId!, newTransaction.amount);
      }
      
      return result;
    });
  }

  /// Удалить транзакцию с обновлением баланса
  Future<void> deleteTransactionWithBalanceUpdate(TransactionData transaction) async {
    await _database.transaction(() async {
      // Откатываем влияние на баланс
      await _revertTransactionBalance(transaction);
      
      // Удаляем транзакцию
      await (_database.delete(_database.transactions)
        ..where((tbl) => tbl.id.equals(transaction.id)))
          .go();
      
      // Обновляем бюджет
      if (transaction.type == 'expense' && transaction.categoryId != null) {
        await _updateBudgetSpentAmount(transaction.categoryId!, -transaction.amount);
      }
    });
  }

  // ==================== МАССОВЫЕ ОПЕРАЦИИ ====================

  /// Массовое создание транзакций (импорт из CSV)
  Future<List<int>> createTransactionsBatch(List<TransactionsCompanion> transactions) async {
    final ids = <int>[];
    
    await _database.transaction(() async {
      for (final transaction in transactions) {
        final id = await createTransactionWithBalanceUpdate(transaction);
        ids.add(id);
      }
    });
    
    return ids;
  }

  /// Массовое обновление категории для транзакций
  Future<void> updateCategoryForTransactions(List<int> transactionIds, int newCategoryId) async {
    await _database.transaction(() async {
      for (final id in transactionIds) {
        await (_database.update(_database.transactions)
          ..where((tbl) => tbl.id.equals(id)))
            .write(TransactionsCompanion(
              categoryId: Value(newCategoryId),
              updatedAt: Value(DateTime.now()),
            ));
      }
    });
  }

  /// Массовое удаление транзакций по фильтру
  Future<void> deleteTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    // Сначала получаем все транзакции для откатывания балансов
    final transactionsToDelete = await (_database.select(_database.transactions)
      ..where((tbl) => 
        tbl.date.isBiggerOrEqualValue(startDate) & 
        tbl.date.isSmallerOrEqualValue(endDate)))
        .get();

    await _database.transaction(() async {
      // Откатываем балансы для каждой транзакции
      for (final transaction in transactionsToDelete) {
        await _revertTransactionBalance(transaction);
        if (transaction.type == 'expense' && transaction.categoryId != null) {
          await _updateBudgetSpentAmount(transaction.categoryId!, -transaction.amount);
        }
      }
      
      // Удаляем транзакции
      await (_database.delete(_database.transactions)
        ..where((tbl) => 
          tbl.date.isBiggerOrEqualValue(startDate) & 
          tbl.date.isSmallerOrEqualValue(endDate)))
          .go();
    });
  }

  // ==================== АНАЛИТИКА И ОТЧЁТЫ ====================

  /// Получить транзакции с информацией о категории и счёте
  Future<List<Map<String, dynamic>>> getTransactionsWithDetails({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
    List<int>? accountIds,
    List<String>? types,
    String? searchQuery,
    int? limit,
    int? offset,
  }) async {
    var query = _database.select(_database.transactions);
    
    // Применяем фильтры
    query = query..where((tbl) {
      Expression<bool>? condition;
      
      if (startDate != null) {
        condition = _combineConditions(condition, tbl.date.isBiggerOrEqualValue(startDate));
      }
      
      if (endDate != null) {
        condition = _combineConditions(condition, tbl.date.isSmallerOrEqualValue(endDate));
      }
      
      if (categoryIds != null && categoryIds.isNotEmpty) {
        condition = _combineConditions(condition, tbl.categoryId.isIn(categoryIds));
      }
      
      if (accountIds != null && accountIds.isNotEmpty) {
        condition = _combineConditions(condition, tbl.accountId.isIn(accountIds));
      }
      
      if (types != null && types.isNotEmpty) {
        condition = _combineConditions(condition, tbl.type.isIn(types));
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final searchCondition = tbl.merchant.like('%$searchQuery%') | 
                               tbl.note.like('%$searchQuery%');
        condition = _combineConditions(condition, searchCondition);
      }
      
      return condition ?? const Constant(true);
    });
    
    // Сортировка, лимит и смещение
    query = query..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]);
    
    if (limit != null) {
      query = query..limit(limit, offset: offset);
    }
    
    final transactions = await query.get();
    
    // Получаем дополнительную информацию для каждой транзакции
    final result = <Map<String, dynamic>>[];
    for (final transaction in transactions) {
      CategoryData? category;
      AccountData? account;
      
      final categoryId = transaction.categoryId;
      if (categoryId != null) {
        category = await (_database.select(_database.categories)
          ..where((tbl) => tbl.id.equals(categoryId)))
            .getSingleOrNull();
      }
      
      final accountId = transaction.accountId;
      account = await (_database.select(_database.accounts)
        ..where((tbl) => tbl.id.equals(accountId)))
          .getSingleOrNull();
          
      result.add({
        'transaction': transaction,
        'category': category,
        'account': account,
      });
    }
    
    return result;
  }

  /// Получить статистику по периодам (по дням/неделям/месяцам)
  Future<List<Map<String, dynamic>>> getTransactionStatsByPeriod(
    DateTime startDate,
    DateTime endDate,
    String periodType, // 'day', 'week', 'month'
  ) async {
    final transactions = await (_database.select(_database.transactions)
      ..where((tbl) => 
        tbl.date.isBiggerOrEqualValue(startDate) & 
        tbl.date.isSmallerOrEqualValue(endDate))
      ..orderBy([(tbl) => OrderingTerm.asc(tbl.date)]))
        .get();

    final stats = <String, Map<String, int>>{};
    
    for (final transaction in transactions) {
      String periodKey;
      
      switch (periodType) {
        case 'day':
          periodKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}-${transaction.date.day.toString().padLeft(2, '0')}';
          break;
        case 'week':
          final weekStart = transaction.date.subtract(Duration(days: transaction.date.weekday - 1));
          periodKey = '${weekStart.year}-W${_getWeekOfYear(weekStart)}';
          break;
        case 'month':
          periodKey = '${transaction.date.year}-${transaction.date.month.toString().padLeft(2, '0')}';
          break;
        default:
          periodKey = transaction.date.toIso8601String().split('T')[0];
      }
      
      if (!stats.containsKey(periodKey)) {
        stats[periodKey] = {'income': 0, 'expense': 0, 'transfer': 0};
      }
      
      stats[periodKey]![transaction.type] = (stats[periodKey]![transaction.type] ?? 0) + transaction.amount;
    }
    
    return stats.entries.map((entry) => {
      'period': entry.key,
      'income': entry.value['income'] ?? 0,
      'expense': entry.value['expense'] ?? 0,
      'transfer': entry.value['transfer'] ?? 0,
      'netCashFlow': (entry.value['income'] ?? 0) - (entry.value['expense'] ?? 0),
    }).toList();
  }

  /// Получить анализ трат по категориям за период
  Future<List<Map<String, dynamic>>> getCategoryAnalysis(
    DateTime startDate,
    DateTime endDate,
    {String type = 'expense'}
  ) async {
    final transactions = await (_database.select(_database.transactions)
      ..where((tbl) => 
        tbl.type.equals(type) &
        tbl.categoryId.isNotNull() &
        tbl.date.isBiggerOrEqualValue(startDate) & 
        tbl.date.isSmallerOrEqualValue(endDate)))
        .get();

    final categoryTotals = <int, Map<String, dynamic>>{};
    int totalAmount = 0;
    
    for (final transaction in transactions) {
      if (transaction.categoryId != null) {
        if (!categoryTotals.containsKey(transaction.categoryId!)) {
          categoryTotals[transaction.categoryId!] = {
            'amount': 0,
            'count': 0,
            'avgAmount': 0,
          };
        }
        
        categoryTotals[transaction.categoryId!]!['amount'] += transaction.amount;
        categoryTotals[transaction.categoryId!]!['count'] += 1;
        totalAmount += transaction.amount;
      }
    }
    
    final result = <Map<String, dynamic>>[];
    for (final entry in categoryTotals.entries) {
      final category = await (_database.select(_database.categories)
        ..where((tbl) => tbl.id.equals(entry.key)))
          .getSingleOrNull();
      
      final amount = entry.value['amount'];
      final count = entry.value['count'];
      
      result.add({
        'category': category,
        'amount': amount,
        'count': count,
        'avgAmount': count > 0 ? (amount / count).round() : 0,
        'percentage': totalAmount > 0 ? (amount / totalAmount * 100) : 0.0,
      });
    }
    
    // Сортируем по убыванию суммы
    result.sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));
    
    return result;
  }

  /// Получить топ мерчантов по тратам
  Future<List<Map<String, dynamic>>> getTopMerchants(
    DateTime startDate,
    DateTime endDate,
    {int limit = 10}
  ) async {
    final transactions = await (_database.select(_database.transactions)
      ..where((tbl) => 
        tbl.type.equals('expense') &
        tbl.merchant.isNotNull() &
        tbl.date.isBiggerOrEqualValue(startDate) & 
        tbl.date.isSmallerOrEqualValue(endDate)))
        .get();

    final merchantTotals = <String, Map<String, dynamic>>{};
    
    for (final transaction in transactions) {
      if (transaction.merchant != null && transaction.merchant!.isNotEmpty) {
        final merchant = transaction.merchant!;
        if (!merchantTotals.containsKey(merchant)) {
          merchantTotals[merchant] = {
            'amount': 0,
            'count': 0,
            'lastDate': transaction.date,
          };
        }
        
        merchantTotals[merchant]!['amount'] += transaction.amount;
        merchantTotals[merchant]!['count'] += 1;
        
        final lastDate = merchantTotals[merchant]!['lastDate'] as DateTime;
        if (transaction.date.isAfter(lastDate)) {
          merchantTotals[merchant]!['lastDate'] = transaction.date;
        }
      }
    }
    
    final result = merchantTotals.entries.map((entry) => {
      'merchant': entry.key,
      'amount': entry.value['amount'],
      'count': entry.value['count'],
      'lastDate': entry.value['lastDate'],
      'avgAmount': (entry.value['amount'] / entry.value['count']).round(),
    }).toList();
    
    // Сортируем по убыванию суммы и берём топ
    result.sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));
    
    return result.take(limit).toList();
  }

  // ==================== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ====================

  /// Применить влияние транзакции на баланс счёта
  Future<void> _applyTransactionBalance(TransactionData transaction) async {
    final accountId = transaction.accountId;
    
    final account = await (_database.select(_database.accounts)
      ..where((tbl) => tbl.id.equals(accountId)))
        .getSingleOrNull();
        
    if (account != null) {
      int balanceChange;
      switch (transaction.type) {
        case 'income':
          balanceChange = transaction.amount;
          break;
        case 'expense':
          balanceChange = -transaction.amount;
          break;
        case 'transfer':
          balanceChange = 0; // Для переводов баланс не меняется
          break;
        default:
          balanceChange = 0;
      }
      
      final newBalance = account.balance + balanceChange;
      await (_database.update(_database.accounts)
        ..where((tbl) => tbl.id.equals(accountId)))
          .write(AccountsCompanion(
            balance: Value(newBalance),
            updatedAt: Value(DateTime.now()),
          ));
    }
  }

  /// Отменить влияние транзакции на баланс счёта
  Future<void> _revertTransactionBalance(TransactionData transaction) async {
    final accountId = transaction.accountId;
    
    final account = await (_database.select(_database.accounts)
      ..where((tbl) => tbl.id.equals(accountId)))
        .getSingleOrNull();
        
    if (account != null) {
      int balanceChange;
      switch (transaction.type) {
        case 'income':
          balanceChange = -transaction.amount; // Откатываем доход
          break;
        case 'expense':
          balanceChange = transaction.amount; // Откатываем расход
          break;
        case 'transfer':
          balanceChange = 0;
          break;
        default:
          balanceChange = 0;
      }
      
      final newBalance = account.balance + balanceChange;
      await (_database.update(_database.accounts)
        ..where((tbl) => tbl.id.equals(accountId)))
          .write(AccountsCompanion(
            balance: Value(newBalance),
            updatedAt: Value(DateTime.now()),
          ));
    }
  }

  /// Обновить потраченную сумму в бюджете
  Future<void> _updateBudgetSpentAmount(int categoryId, int amountChange) async {
    final now = DateTime.now();
    final budget = await (_database.select(_database.budgets)
      ..where((tbl) => 
        tbl.categoryId.equals(categoryId) & 
        tbl.isActive.equals(true) &
        tbl.periodStart.isSmallerOrEqualValue(now) &
        tbl.periodEnd.isBiggerOrEqualValue(now)))
        .getSingleOrNull();
    
    if (budget != null) {
      final newSpent = (budget.spent + amountChange).clamp(0, double.infinity).toInt();
      await (_database.update(_database.budgets)
        ..where((tbl) => tbl.id.equals(budget.id)))
          .write(BudgetsCompanion(
            spent: Value(newSpent),
            updatedAt: Value(DateTime.now()),
          ));
    }
  }

  /// Объединить условия WHERE
  Expression<bool> _combineConditions(Expression<bool>? existing, Expression<bool> newCondition) {
    return existing == null ? newCondition : existing & newCondition;
  }

  /// Получить номер недели в году
  int _getWeekOfYear(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays;
    return ((dayOfYear - date.weekday + 10) / 7).floor();
  }
}
