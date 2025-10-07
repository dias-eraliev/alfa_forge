import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'finance_main_screen.dart';

class FinanceDemoScreen extends StatelessWidget {
  const FinanceDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Title
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 60,
                  color: theme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'PRIME Финансы',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                'Модуль финансового планирования\nи управления бюджетом',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Demo features
              _buildFeatureItem(
                context,
                'Safe-to-Spend',
                'Умный расчет доступных средств на сегодня',
                Icons.account_balance_wallet,
                Colors.green,
              ),
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                context,
                'Бюджетирование',
                'Zero-based и конверты с автораспределением',
                Icons.pie_chart,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                context,
                'Финансовые цели',
                'Pay-yourself-first и автоперевод',
                Icons.flag,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              
              _buildFeatureItem(
                context,
                'Аналитика',
                'Net Cash Flow и Savings Rate',
                Icons.trending_up,
                Colors.purple,
              ),
              const SizedBox(height: 48),
              
              // Demo button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/finance');
                  },
                  icon: const Icon(Icons.rocket_launch),
                  label: const Text(
                    'Запустить демо',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Back button
              TextButton.icon(
                onPressed: () {
                  context.go('/');
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Вернуться в PRIME'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
