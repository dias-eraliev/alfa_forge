import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  // Hardcoded goals data
  final List<Map<String, dynamic>> _goals = [
    {
      'id': 1,
      'name': 'Подушка безопасности',
      'description': 'Накопления на 6 месяцев расходов',
      'targetAmount': 60000000, // 600,000 ₸ in tiyin
      'savedAmount': 18000000,  // 180,000 ₸ in tiyin
      'deadline': DateTime(2025, 12, 31),
      'priority': 1,
      'type': 'emergency',
      'autoContribution': 5000000, // 50,000 ₸ per month
      'icon': Icons.security,
      'color': Colors.blue,
    },
    {
      'id': 2,
      'name': 'Путешествие в Турцию',
      'description': 'Отпуск на 10 дней с семьей',
      'targetAmount': 30000000, // 300,000 ₸ in tiyin
      'savedAmount': 8500000,   // 85,000 ₸ in tiyin
      'deadline': DateTime(2025, 7, 15),
      'priority': 2,
      'type': 'travel',
      'autoContribution': 2500000, // 25,000 ₸ per month
      'icon': Icons.flight,
      'color': Colors.orange,
    },
    {
      'id': 3,
      'name': 'Новый iPhone',
      'description': 'iPhone 15 Pro Max 256GB',
      'targetAmount': 65000000, // 650,000 ₸ in tiyin
      'savedAmount': 12000000, // 120,000 ₸ in tiyin
      'deadline': DateTime(2025, 11, 30),
      'priority': 3,
      'type': 'purchase',
      'autoContribution': 1500000, // 15,000 ₸ per month
      'icon': Icons.phone_iphone,
      'color': Colors.grey,
    },
    {
      'id': 4,
      'name': 'Первоначальный взнос на авто',
      'description': 'Для покупки нового автомобиля',
      'targetAmount': 150000000, // 1,500,000 ₸ in tiyin
      'savedAmount': 22500000,  // 225,000 ₸ in tiyin
      'deadline': DateTime(2026, 6, 1),
      'priority': 4,
      'type': 'purchase',
      'autoContribution': 7500000, // 75,000 ₸ per month
      'icon': Icons.directions_car,
      'color': Colors.green,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Цели'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateGoalDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly contributions summary
            _buildMonthlySummary(),
            const SizedBox(height: 16),
            
            // Goals list
            _buildGoalsList(),
            const SizedBox(height: 16),
            
            // Weekly advice
            _buildWeeklyAdvice(),
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

  Widget _buildMonthlySummary() {
    final theme = Theme.of(context);
    
    final totalMonthlyContribution = _goals.fold<int>(
      0, 
      (sum, goal) => sum + (goal['autoContribution'] as int),
    );
    
    final totalSaved = _goals.fold<int>(
      0, 
      (sum, goal) => sum + (goal['savedAmount'] as int),
    );
    
    final totalTarget = _goals.fold<int>(
      0, 
      (sum, goal) => sum + (goal['targetAmount'] as int),
    );
    
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
                  Icons.flag,
                  color: theme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Сводка по целям',
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
                  child: _buildSummaryItem(
                    'Накоплено',
                    totalSaved,
                    Colors.green,
                    theme,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Цель',
                    totalTarget,
                    theme.primaryColor,
                    theme,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'В месяц',
                    totalMonthlyContribution,
                    Colors.orange,
                    theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Overall progress
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (totalSaved / totalTarget).clamp(0.0, 1.0),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            
            Text(
              'Общий прогресс: ${((totalSaved / totalTarget) * 100).toStringAsFixed(1)}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, int amount, Color color, ThemeData theme) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCurrency(amount),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoalsList() {
    final theme = Theme.of(context);
    
    // Sort goals by priority
    final sortedGoals = List<Map<String, dynamic>>.from(_goals);
    sortedGoals.sort((a, b) => a['priority'].compareTo(b['priority']));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ваши цели',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        
        ...sortedGoals.map((goal) => _buildGoalItem(goal)),
      ],
    );
  }

  Widget _buildGoalItem(Map<String, dynamic> goal) {
    final theme = Theme.of(context);
    final targetAmount = goal['targetAmount'] as int;
    final savedAmount = goal['savedAmount'] as int;
    final remaining = targetAmount - savedAmount;
    final progress = savedAmount / targetAmount;
    final deadline = goal['deadline'] as DateTime;
    final monthsLeft = _calculateMonthsLeft(deadline);
    final monthlyNeeded = monthsLeft > 0 ? (remaining / monthsLeft).ceil() : remaining;
    
    // Determine if goal is on track
    final autoContribution = goal['autoContribution'] as int;
    final isOnTrack = autoContribution >= monthlyNeeded;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: goal['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    goal['icon'],
                    color: goal['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal['name'],
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        goal['description'],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Изменить'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Удалить', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditGoalDialog(context, goal);
                    } else if (value == 'delete') {
                      _showDeleteGoalDialog(context, goal);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_formatCurrency(savedAmount)} / ${_formatCurrency(targetAmount)}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: goal['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(goal['color']),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 16),
            
            // Timeline and recommendations
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'До ${DateFormat('d MMMM yyyy', 'ru_RU').format(deadline)} ($monthsLeft мес.)',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      Icon(
                        isOnTrack ? Icons.check_circle : Icons.warning,
                        color: isOnTrack ? Colors.green : Colors.orange,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isOnTrack 
                            ? 'На правильном пути! Автоперевод: ${_formatCurrency(autoContribution)}/мес.'
                            : 'Нужно ${_formatCurrency(monthlyNeeded)}/мес. (сейчас ${_formatCurrency(autoContribution)})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isOnTrack ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showContributeDialog(context, goal);
                    },
                    icon: const Icon(Icons.savings),
                    label: const Text('Отложить сейчас'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showAutoContributionDialog(context, goal);
                    },
                    icon: const Icon(Icons.autorenew),
                    label: const Text('Автоперевод'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyAdvice() {
    final theme = Theme.of(context);
    
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
              Colors.blue.withOpacity(0.1),
              Colors.blue.withOpacity(0.05),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: Colors.blue,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Совет недели по целям',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Правило "Сначала себе": Автоматически переводите деньги на цели в день зарплаты, до всех остальных трат. Это гарантирует, что вы достигнете своих финансовых целей.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                _showEducationQuiz(context);
              },
              child: const Text('Пройти квиз о целях'),
            ),
          ],
        ),
      ),
    );
  }

  int _calculateMonthsLeft(DateTime deadline) {
    final now = DateTime.now();
    final monthsLeft = (deadline.year - now.year) * 12 + deadline.month - now.month;
    return monthsLeft.clamp(0, double.infinity.toInt());
  }

  void _showCreateGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новая цель'),
        content: const Text('Создание новых целей будет доступно в следующей версии'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(BuildContext context, Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Изменить цель'),
        content: const Text('Редактирование целей будет доступно в следующей версии'),
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

  void _showDeleteGoalDialog(BuildContext context, Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить цель'),
        content: Text('Вы уверены, что хотите удалить цель "${goal['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Цель "${goal['name']}" удалена'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _showContributeDialog(BuildContext context, Map<String, dynamic> goal) {
    final TextEditingController amountController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
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
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Отложить на "${goal['name']}"',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: '₸',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 20),
              
              Text(
                'Осталось до цели: ${_formatCurrency(goal['targetAmount'] - goal['savedAmount'])}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (amountController.text.isNotEmpty) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${amountController.text} ₸ отложено на "${goal['name']}"'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Отложить',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showAutoContributionDialog(BuildContext context, Map<String, dynamic> goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Настройка автоперевода'),
        content: const Text('Настройка автоматических переводов будет доступна в следующей версии'),
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

  void _showEducationQuiz(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Квиз о целях'),
        content: const Text('Образовательные квизы будут доступны в следующей версии'),
        actions: [
          TextButton(
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
