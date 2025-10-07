import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'Все';
  String _selectedPeriod = 'Месяц';
  
  // Hardcoded transactions data
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 1,
      'amount': -250000,
      'category': 'Еда',
      'merchant': 'Магнум',
      'date': DateTime.now().subtract(const Duration(hours: 2)),
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'id': 2,
      'amount': -120000,
      'category': 'Транспорт',
      'merchant': 'Kaspi Pay',
      'date': DateTime.now().subtract(const Duration(hours: 5)),
      'icon': Icons.directions_bus,
      'color': Colors.blue,
    },
    {
      'id': 3,
      'amount': 35000000,
      'category': 'Зарплата',
      'merchant': 'UIB Bank',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.work,
      'color': Colors.green,
    },
    {
      'id': 4,
      'amount': -45000,
      'category': 'Развлечения',
      'merchant': 'Кинотеатр Chaplin',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'icon': Icons.movie,
      'color': Colors.purple,
    },
    {
      'id': 5,
      'amount': -18000000,
      'category': 'Дом',
      'merchant': 'Аренда квартиры',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'icon': Icons.home,
      'color': Colors.brown,
    },
    {
      'id': 6,
      'amount': -89000,
      'category': 'Покупки',
      'merchant': 'Sulpak',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'icon': Icons.shopping_bag,
      'color': Colors.teal,
    },
    {
      'id': 7,
      'amount': -25000,
      'category': 'Здоровье',
      'merchant': 'Аптека Европа',
      'date': DateTime.now().subtract(const Duration(days: 4)),
      'icon': Icons.medical_services,
      'color': Colors.red,
    },
    {
      'id': 8,
      'amount': -199000,
      'category': 'Подписки',
      'merchant': 'Netflix',
      'date': DateTime.now().subtract(const Duration(days: 5)),
      'icon': Icons.subscriptions,
      'color': Colors.indigo,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTransactions = _getFilteredTransactions();
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Транзакции'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: () {
              _showExportDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),
          
          // Summary
          _buildSummary(filteredTransactions),
          
          // Transactions list
          Expanded(
            child: _buildTransactionsList(filteredTransactions),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickExpenseDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Category filters
          Row(
            children: [
              Text(
                'Категория: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Все', 'Еда', 'Транспорт', 'Развлечения', 'Покупки', 'Дом']
                        .map((filter) => _buildFilterChip(filter, _selectedFilter == filter))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Period filters
          Row(
            children: [
              Text(
                'Период: ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Неделя', 'Месяц', '3 месяца', 'Год']
                        .map((period) => _buildFilterChip(period, _selectedPeriod == period))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (['Все', 'Еда', 'Транспорт', 'Развлечения', 'Покупки', 'Дом'].contains(label)) {
              _selectedFilter = label;
            } else {
              _selectedPeriod = label;
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected 
              ? theme.primaryColor 
              : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected 
                ? theme.colorScheme.onPrimary 
                : theme.colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummary(List<Map<String, dynamic>> transactions) {
    final theme = Theme.of(context);
    
    final totalIncome = transactions
        .where((t) => t['amount'] > 0)
        .fold<int>(0, (sum, t) => sum + (t['amount'] as int));
    
    final totalExpense = transactions
        .where((t) => t['amount'] < 0)
        .fold<int>(0, (sum, t) => sum + (t['amount'] as int).abs());
    
    final netFlow = totalIncome - totalExpense;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              'Доходы',
              totalIncome,
              Colors.green,
              Icons.trending_up,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Расходы',
              totalExpense,
              Colors.red,
              Icons.trending_down,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.onSurface.withOpacity(0.2),
          ),
          Expanded(
            child: _buildSummaryItem(
              'Итого',
              netFlow,
              netFlow >= 0 ? Colors.green : Colors.red,
              netFlow >= 0 ? Icons.add : Icons.remove,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, int amount, Color color, IconData icon) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _formatCurrency(amount),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionsList(List<Map<String, dynamic>> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }
    
    // Group transactions by date
    final groupedTransactions = <String, List<Map<String, dynamic>>>{};
    for (final transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction['date']);
      groupedTransactions.putIfAbsent(dateKey, () => []);
      groupedTransactions[dateKey]!.add(transaction);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final dayTransactions = groupedTransactions[dateKey]!;
        final date = DateTime.parse(dateKey);
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateHeader(date),
            ...dayTransactions.map((transaction) => 
              _buildTransactionItem(transaction)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildDateHeader(DateTime date) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final transactionDate = DateTime(date.year, date.month, date.day);
    
    String dateText;
    if (transactionDate == today) {
      dateText = 'Сегодня';
    } else if (transactionDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Вчера';
    } else {
      dateText = DateFormat('d MMMM', 'ru_RU').format(date);
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        dateText,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    final isExpense = transaction['amount'] < 0;
    final amount = transaction['amount'] as int;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: transaction['color'].withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            transaction['icon'],
            color: transaction['color'],
            size: 24,
          ),
        ),
        title: Text(
          transaction['merchant'],
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          transaction['category'],
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatCurrency(amount.abs()),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isExpense ? Colors.red : Colors.green,
              ),
            ),
            Text(
              DateFormat('HH:mm').format(transaction['date']),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        onTap: () {
          _showTransactionDetails(context, transaction);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Нет транзакций',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте первую транзакцию нажав на +',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredTransactions() {
    var filtered = List<Map<String, dynamic>>.from(_transactions);
    
    // Filter by category
    if (_selectedFilter != 'Все') {
      filtered = filtered.where((t) => t['category'] == _selectedFilter).toList();
    }
    
    // Filter by period
    final now = DateTime.now();
    DateTime startDate;
    
    switch (_selectedPeriod) {
      case 'Неделя':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'Месяц':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case '3 месяца':
        startDate = DateTime(now.year, now.month - 3, now.day);
        break;
      case 'Год':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = DateTime(2020); // Show all
    }
    
    filtered = filtered.where((t) => t['date'].isAfter(startDate)).toList();
    
    // Sort by date (newest first)
    filtered.sort((a, b) => b['date'].compareTo(a['date']));
    
    return filtered;
  }

  void _showTransactionDetails(BuildContext context, Map<String, dynamic> transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailsSheet(transaction: transaction),
    );
  }

  void _showQuickExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickExpenseSheet(),
    );
  }

  void _showExportDialog(BuildContext context) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Экспорт данных'),
        content: const Text('Экспортировать транзакции в CSV файл?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement CSV export
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Экспорт будет доступен в следующей версии'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Экспорт'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    // Convert tiyin to tenge and format with dots as thousand separators
    final amountInTenge = amount / 100;
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return '${formatter.format(amountInTenge).replaceAll(',', '.')} ₸';
  }
}

class TransactionDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const TransactionDetailsSheet({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction['amount'] < 0;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Transaction header
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: transaction['color'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  transaction['icon'],
                  color: transaction['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['merchant'],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      transaction['category'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Сумма',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                _formatCurrency(transaction['amount'].abs()),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isExpense ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Дата и время',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                DateFormat('d MMMM yyyy, HH:mm', 'ru_RU').format(transaction['date']),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Implement edit
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Изменить'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Implement delete
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Удалить', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    final amountInTenge = amount / 100;
    final formatter = NumberFormat('#,##0', 'ru_RU');
    return '${formatter.format(amountInTenge).replaceAll(',', '.')} ₸';
  }
}

class QuickExpenseSheet extends StatefulWidget {
  const QuickExpenseSheet({super.key});

  @override
  _QuickExpenseSheetState createState() => _QuickExpenseSheetState();
}

class _QuickExpenseSheetState extends State<QuickExpenseSheet> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;
  
  final categories = ['Еда', 'Транспорт', 'Развлечения', 'Покупки', 'Здоровье'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Быстрый расход',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: '₸',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Категория',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? theme.primaryColor 
                        : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected 
                          ? theme.colorScheme.onPrimary 
                          : theme.colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSave() ? _saveExpense : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Сохранить',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  bool _canSave() {
    return _amountController.text.isNotEmpty && _selectedCategory != null;
  }

  void _saveExpense() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Расход ${_amountController.text} ₸ сохранен'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }
}
