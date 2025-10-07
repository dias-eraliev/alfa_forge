import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/finance_database.dart';
import '../data/repositories/finance_repository.dart';
import '../data/repositories/transaction_repository.dart';

// Database provider
final financeDatabaseProvider = Provider<FinanceDatabase>((ref) {
  return FinanceDatabase();
});

// Repository providers
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final database = ref.watch(financeDatabaseProvider);
  return FinanceRepository(database);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final database = ref.watch(financeDatabaseProvider);
  return TransactionRepository(database);
});

// Balance providers
final totalBalanceProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getTotalBalance();
});

final accountBalancesProvider = FutureProvider<Map<int, int>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getAccountBalances();
});

// Safe-to-Spend providers
final safeToSpendTodayProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getSafeToSpendToday();
});

final safeToSpendMonthProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getSafeToSpendMonth();
});

// Net Cash Flow provider
final netCashFlowProvider = FutureProvider.family<int, DateRange>((ref, dateRange) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getNetCashFlow(dateRange.start, dateRange.end);
});

// Current month Net Cash Flow
final currentMonthNetCashFlowProvider = FutureProvider<int>((ref) async {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getNetCashFlow(startOfMonth, endOfMonth);
});

// Savings Rate provider
final savingsRateProvider = FutureProvider.family<double, DateRange>((ref, dateRange) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getSavingsRate(dateRange.start, dateRange.end);
});

// Current month Savings Rate
final currentMonthSavingsRateProvider = FutureProvider<double>((ref) async {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);
  
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getSavingsRate(startOfMonth, endOfMonth);
});

// Budget providers
final budgetStatusProvider = FutureProvider<List<BudgetStatusData>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getBudgetStatus();
});

final budgetProgressProvider = FutureProvider.family<BudgetProgressData, int>((ref, budgetId) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getBudgetProgress(budgetId);
});

// Goals providers
final goalsProgressProvider = FutureProvider<List<GoalProgressData>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getGoalsProgress();
});

final goalProgressProvider = FutureProvider.family<GoalProgressData, int>((ref, goalId) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getGoalProgress(goalId);
});

// Transaction providers
final recentTransactionsProvider = FutureProvider.family<List<TransactionData>, int>((ref, limit) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return await repository.getRecentTransactions(limit);
});

final transactionsByPeriodProvider = FutureProvider.family<List<TransactionData>, DateRange>((ref, dateRange) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return await repository.getTransactionsByPeriod(dateRange.start, dateRange.end);
});

final topCategoriesByExpensesProvider = FutureProvider.family<List<CategoryExpenseData>, DateRange>((ref, dateRange) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return await repository.getTopCategoriesByExpenses(dateRange.start, dateRange.end, 5);
});

// Category providers
final allCategoriesProvider = FutureProvider<List<CategoryData>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getAllCategories();
});

final expenseCategoriesProvider = FutureProvider<List<CategoryData>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getCategoriesByType('expense');
});

// Account providers
final allAccountsProvider = FutureProvider<List<AccountData>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getAllAccounts();
});

final activeAccountsProvider = FutureProvider<List<AccountData>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getActiveAccounts();
});

// Settings providers
final financeSettingsProvider = FutureProvider<Map<String, String>>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getAllSettings();
});

final currencySettingProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getSetting('currency') ?? 'KZT';
});

final thousandsSeparatorProvider = FutureProvider<String>((ref) async {
  final repository = ref.watch(financeRepositoryProvider);
  return await repository.getSetting('thousands_separator') ?? 'dot';
});

// State notifiers for mutable data
class TransactionNotifier extends StateNotifier<AsyncValue<List<TransactionData>>> {
  TransactionNotifier(this._repository) : super(const AsyncValue.loading()) {
    _loadTransactions();
  }

  final TransactionRepository _repository;

  Future<void> _loadTransactions() async {
    try {
      final transactions = await _repository.getRecentTransactions(50);
      state = AsyncValue.data(transactions);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addTransaction(TransactionCompanion transaction) async {
    try {
      await _repository.createTransaction(transaction);
      await _loadTransactions(); // Reload transactions
    } catch (error) {
      // Handle error - could emit error state or show snackbar
    }
  }

  Future<void> updateTransaction(int id, TransactionCompanion transaction) async {
    try {
      await _repository.updateTransaction(id, transaction);
      await _loadTransactions(); // Reload transactions
    } catch (error) {
      // Handle error
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await _repository.deleteTransaction(id);
      await _loadTransactions(); // Reload transactions
    } catch (error) {
      // Handle error
    }
  }
}

// Transaction state notifier provider
final transactionNotifierProvider = StateNotifierProvider<TransactionNotifier, AsyncValue<List<TransactionData>>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});

// Helper classes
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange && 
      runtimeType == other.runtimeType &&
      start == other.start &&
      end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}

// Data classes for complex return types
class BudgetStatusData {
  final int budgetId;
  final String categoryName;
  final int limit;
  final int spent;
  final bool isOverspent;
  final double progressPercentage;

  BudgetStatusData({
    required this.budgetId,
    required this.categoryName,
    required this.limit,
    required this.spent,
    required this.isOverspent,
    required this.progressPercentage,
  });
}

class BudgetProgressData {
  final int budgetId;
  final String categoryName;
  final int limit;
  final int spent;
  final int remaining;
  final double progressPercentage;
  final bool isOverspent;

  BudgetProgressData({
    required this.budgetId,
    required this.categoryName,
    required this.limit,
    required this.spent,
    required this.remaining,
    required this.progressPercentage,
    required this.isOverspent,
  });
}

class GoalProgressData {
  final int goalId;
  final String name;
  final String description;
  final int targetAmount;
  final int savedAmount;
  final int remaining;
  final double progressPercentage;
  final DateTime deadline;
  final int monthsLeft;
  final int monthlyNeeded;

  GoalProgressData({
    required this.goalId,
    required this.name,
    required this.description,
    required this.targetAmount,
    required this.savedAmount,
    required this.remaining,
    required this.progressPercentage,
    required this.deadline,
    required this.monthsLeft,
    required this.monthlyNeeded,
  });
}

class CategoryExpenseData {
  final int categoryId;
  final String categoryName;
  final int totalAmount;
  final int transactionCount;

  CategoryExpenseData({
    required this.categoryId,
    required this.categoryName,
    required this.totalAmount,
    required this.transactionCount,
  });
}
