import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool _isEnvelopeMode = false;
  
  // Hardcoded budget data
  final List<Map<String, dynamic>> _budgets = [
    {
      'id': 1,
      'category': 'Еда',
      'limit': 15000000, // 150,000 ₸ in tiyin
      'spent': 8750000,  // 87,500 ₸ in tiyin
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'rollover': true,
    },
    {
      'id': 2,
      'category': 'Транспорт',
      'limit': 5000000, // 50,000 ₸ in tiyin
      'spent': 3200000, // 32,000 ₸ in tiyin
      'icon': Icons.directions_bus,
      'color': Colors.blue,
      'rollover': false,
    },
    {
      'id': 3,
      'category': 'Развлечения',
      'limit': 4000000, // 40,000 ₸ in tiyin
      'spent': 4500000, // 45,000 ₸ in tiyin (overspent)
      'icon': Icons.movie,
      'color': Colors.purple,
      'rollover': false,
    },
    {
      'id': 4,
      'category': 'Покупки',
      'limit': 6000000, // 60,000 ₸ in tiyin
      'spent': 2100000, // 21,000 ₸ in tiyin
      'icon': Icons.shopping_bag,
      'color': Colors.teal,
      'rollover': true,
    },
    {
      'id': 5,
      'category': 'Здоровье',
      'limit': 3000000, // 30,000 ₸ in tiyin
      'spent': 750000,  // 7,500 ₸ in tiyin
      'icon': Icons.medical_services,
      'color': Colors.red,
      'rollover': true,
    },
  ];

  // Hardcoded upcoming payments
  final List<Map<String, dynamic>> _upcomingPayments = [
    {
      'name': 'Аренда квартиры',
      'amount': 18000000, // 180,000 ₸
      'date': DateTime(2025, 9, 1),
      'type': 'fixed',
      'icon': Icons.home,
      'color': Colors.brown,
    },
    {
      'name': 'Spotify Premium',
      'amount': 199000, // 1,990 ₸
      'date': DateTime(2025, 9, 3),
      'type': 'subscription',
      'icon': Icons.music_note,
      'color': Colors.green,
    },
    {
      'name': 'Netflix',
      'amount': 299000, // 2,990 ₸
      'date': DateTime(2025, 9, 5),
      'type': 'subscription',
      'icon': Icons.tv,
      'color': Colors.red,
    },
    {
      'name': 'Тренажерный зал',
      'amount': 1500000, // 15,000 ₸
      'date': DateTime(2025, 9, 10),
      'type': 'subscription',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
    },
    {
      'name': 'Интернет Beeline',
      'amount': 800000, // 8,000 ₸
      'date': DateTime(2025, 9, 15),
      'type': 'fixed',
      'icon': Icons.wifi,
      'color': Colors.blue,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Бюджет'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isEnvelopeMode ? Icons.account_balance_wallet : Icons.list),
            onPressed: () {
              setState(() {
                _isEnvelopeMode = !_isEnvelopeMode;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mode toggle
            _buildModeToggle(),
            const SizedBox(height: 16),
            
            // Safe-to-Spend card
            _buildSafeToSpendCard(),
            const SizedBox(height: 16),
            
            // Budget list
            _buildBudgetList(),
            const SizedBox(height: 16),
            
            // Upcoming payments
            _buildUpcomingPayments(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickExpenseDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildModeToggle() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEnvelopeMode = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_isEnvelopeMode 
                    ? theme.primaryColor 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Zero-based',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: !_isEnvelopeMode 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurface,
                    fontWeight: !_isEnvelopeMode ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isEnvelopeMode = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _isEnvelopeMode 
                    ? theme.primaryColor 
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Конверты',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: _isEnvelopeMode 
                      ? theme.colorScheme.onPrimary 
                      : theme.colorScheme.onSurface,
                    fontWeight: _isEnvelopeMode ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafeToSpendCard() {
    final theme = Theme.of(context);
    
    // Calculate safe-to-spend
    final totalLimit = _budgets.fold<int>(0, (sum, budget) => sum + (budget['limit'] as int));
    final totalSpent = _budgets.fold<int>(0, (sum, budget) => sum + (budget['spent'] as int));
    final upcomingFixed = _upcomingPayments
        .where((payment) => payment['type'] == 'fixed')
        .fold<int>(0, (sum, payment) => sum + (payment['amount'] as int));
    
    final remaining = totalLimit - totalSpent - upcomingFixed;
    final daysLeft = DateTime.now().day <= 15 ? 15 - DateTime.now().day : 
                     DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day - DateTime.now().day;
    final safeToSpendDaily = daysLeft > 0 ? remaining ~/ daysLeft : 0;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Safe-to-Spend',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'На месяц',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        _formatCurrency(remaining),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: remaining >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'На сегодня',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Text(
                        _formatCurrency(safeToSpendDaily),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Text(
              '$daysLeft дней до конца периода',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Лимиты по категориям',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                _showBudgetSettingsDialog(context);
              },
              icon: const Icon(Icons.settings, size: 16),
              label: const Text('Настроить'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        ..._budgets.map((budget) => _buildBudgetItem(budget)),
      ],
    );
  }

  Widget _buildBudgetItem(Map<String, dynamic> budget) {
    final theme = Theme.of(context);
    final limit = budget['limit'] as int;
    final spent = budget['spent'] as int;
    final remaining = limit - spent;
    final progress = spent / limit;
    final isOverspent = spent > limit;
    
    Color progressColor;
    if (isOverspent) {
      progressColor = Colors.red;
    } else if (progress > 0.8) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: budget['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    budget['icon'],
                    color: budget['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            budget['category'],
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (budget['rollover'] == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'rollover',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.blue,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatCurrency(spent)} из ${_formatCurrency(limit)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(remaining.abs()),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isOverspent ? Colors.red : Colors.green,
                      ),
                    ),
                    Text(
                      isOverspent ? 'превышение' : 'остаток',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(1)}% использовано',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                if (_isEnvelopeMode) ...[
                  TextButton(
                    onPressed: () {
                      _showTransferDialog(context, budget);
                    },
                    child: const Text('Перевести'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingPayments() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Календарь денег',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ..._upcomingPayments.take(5).map((payment) => 
                  _buildPaymentItem(payment)),
                if (_upcomingPayments.length > 5) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      // TODO: Show all payments
                    },
                    child: Text('Показать все (${_upcomingPayments.length})'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(Map<String, dynamic> payment) {
    final theme = Theme.of(context);
    final daysUntil = payment['date'].difference(DateTime.now()).inDays;
    
    String dateText;
    Color dateColor = theme.colorScheme.onSurface;
    
    if (daysUntil == 0) {
      dateText = 'Сегодня';
      dateColor = Colors.red;
    } else if (daysUntil == 1) {
      dateText = 'Завтра';
      dateColor = Colors.orange;
    } else if (daysUntil <= 7) {
      dateText = 'Через $daysUntil дн.';
      dateColor = Colors.orange;
    } else {
      dateText = DateFormat('d MMM', 'ru_RU').format(payment['date']);
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: payment['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              payment['icon'],
              color: payment['color'],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment['name'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  dateText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: dateColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatCurrency(payment['amount']),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: payment['type'] == 'fixed' 
                    ? Colors.blue.withOpacity(0.1)
                    : Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  payment['type'] == 'fixed' ? 'фикс' : 'подп',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: payment['type'] == 'fixed' ? Colors.blue : Colors.purple,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBudgetSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройка бюджета'),
        content: const Text('Настройка лимитов будет доступна в следующей версии'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(BuildContext context, Map<String, dynamic> budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Перевод между конвертами'),
        content: const Text('Перевод денег между категориями будет доступен в следующей версии'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
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

  String _formatCurrency(int amount) {
    // Convert tiyin to tenge and format with dots as thousand separators
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
