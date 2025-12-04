import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../shared/bottom_nav_scaffold.dart';
import '../../app/theme.dart';
import '../../core/models/api_models.dart';
import '../../core/i18n/labels.dart';
import 'providers/path_providers.dart';

class PathPage extends ConsumerStatefulWidget {
  const PathPage({super.key});

  @override
  ConsumerState<PathPage> createState() => _PathPageState();
}

class _PathPageState extends ConsumerState<PathPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();

    // Загружаем данные при инициализации
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pathPageControllerProvider.notifier).loadAllData();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    // Слушаем состояние загрузки и ошибок
    final isLoading = ref.watch(isPathPageLoadingProvider);
    final error = ref.watch(pathPageErrorProvider);
    final userMetrics = ref.watch(userMetricsProvider);
    final dailyStats = ref.watch(dailyStatsProvider);

    return BottomNavScaffold(
      currentRoute: '/',
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(pathPageControllerProvider.notifier).refresh();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок и уровень
                  _buildHeader(context, isSmallScreen, userMetrics),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Показываем ошибку если есть
                  if (error != null) _buildErrorWidget(context, error),

                  // Метрики дня
                  _buildDailyMetrics(context, isSmallScreen, userMetrics, dailyStats),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Цитата дня
                  _buildDailyQuoteSection(context, isSmallScreen),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Быстрые победы секция
                  _buildQuickWinsSection(context, isSmallScreen, dailyStats),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Прогресс по сферам
                  _buildSphereProgressSection(context, isSmallScreen),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Ежедневные привычки
                  _buildTodayHabits(context, isSmallScreen, isLoading),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Быстрые задачи
                  _buildQuickTasks(context, isSmallScreen, isLoading),
                  SizedBox(height: isSmallScreen ? 20 : 24),

                  // Кнопки действий
                  _buildActionButtons(context, isSmallScreen),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Виджет ошибки
  Widget _buildErrorWidget(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: PRIMETheme.warn.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: PRIMETheme.warn.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: PRIMETheme.warn),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PRIMETheme.warn,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(pathPageControllerProvider.notifier).clearError();
            },
            icon: const Icon(Icons.close, color: PRIMETheme.warn),
          ),
        ],
      ),
    );
  }

  // Заголовок и статус
  Widget _buildHeader(BuildContext context, bool isSmallScreen, Map<String, dynamic> userMetrics) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PRIME',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: isSmallScreen ? 32 : 40,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12, 
                vertical: isSmallScreen ? 4 : 6
              ),
              decoration: BoxDecoration(
                border: Border.all(color: PRIMETheme.primary, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: PRIMETheme.primary.withOpacity(0.1),
              ),
              child: Text(
                userMetrics['currentRank'] ?? 'НОВИЧОК',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  color: PRIMETheme.primary,
                  fontSize: isSmallScreen ? 18 : 24,
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 12, 
            vertical: isSmallScreen ? 6 : 8
          ),
          decoration: BoxDecoration(
            color: PRIMETheme.success.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PRIMETheme.success.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.trending_up,
                color: PRIMETheme.success,
                size: isSmallScreen ? 14 : 16,
              ),
              const SizedBox(width: 4),
              Text(
                'АКТИВЕН',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: PRIMETheme.success,
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Метрики дня
  Widget _buildDailyMetrics(BuildContext context, bool isSmallScreen, 
      Map<String, dynamic> userMetrics, Map<String, dynamic> dailyStats) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              context: context,
              title: 'СТРИК',
              value: '${userMetrics['streak'] ?? dailyStats['streak'] ?? 0}',
              subtitle: 'дней',
              icon: Icons.local_fire_department,
              color: Colors.orange,
              isSmallScreen: isSmallScreen,
              onTap: () => _showStreakDetails(context, userMetrics),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildMetricCard(
              context: context,
              title: 'ОЧКИ',
              value: '${userMetrics['totalPoints'] ?? dailyStats['totalPoints'] ?? 0}',
              subtitle: '/${userMetrics['nextLevelPoints'] ?? 100}',
              icon: Icons.star,
              color: PRIMETheme.primary,
              isSmallScreen: isSmallScreen,
              onTap: () => _showPointsDetails(context, userMetrics),
            ),
          ),
        ],
      ),
    );
  }

  // Секция быстрых побед
  Widget _buildQuickWinsSection(BuildContext context, bool isSmallScreen, Map<String, dynamic> dailyStats) {
    final totalProgress = dailyStats['totalProgress'] ?? 0.0;
    final completedHabits = dailyStats['completedHabits'] ?? 0;
    final totalHabits = dailyStats['totalHabits'] ?? 0;
    final completedTasks = dailyStats['completedTasks'] ?? 0;
    final totalTasks = dailyStats['totalTasks'] ?? 0;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PRIMETheme.primary.withOpacity(0.1),
            PRIMETheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: PRIMETheme.primary,
                size: isSmallScreen ? 20 : 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Быстрые победы',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: isSmallScreen ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${(totalProgress * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PRIMETheme.primary,
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: totalProgress,
            backgroundColor: PRIMETheme.line,
            valueColor: const AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          Text(
            'Выполнено: $completedHabits/$totalHabits привычек, $completedTasks/$totalTasks задач',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: isSmallScreen ? 12 : 14,
              color: PRIMETheme.sandWeak,
            ),
          ),
        ],
      ),
    );
  }

  // Цитата дня
  Widget _buildDailyQuoteSection(BuildContext context, bool isSmallScreen) {
    return Consumer(
      builder: (context, ref, child) {
        final quote = ref.watch(pathPageControllerProvider).dailyQuote;

        if (quote == null || quote.trim().isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PRIMETheme.primary.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.format_quote, color: PRIMETheme.primary, size: isSmallScreen ? 18 : 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  quote,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontStyle: FontStyle.italic,
                        color: PRIMETheme.sand,
                      ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Прогресс по сферам
  Widget _buildSphereProgressSection(BuildContext context, bool isSmallScreen) {
    return Consumer(
      builder: (context, ref, child) {
        final sphereProgress = ref.watch(pathPageControllerProvider).sphereProgress;

        if (sphereProgress.isEmpty) {
          return const SizedBox.shrink();
        }

        final entries = sphereProgress.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: PRIMETheme.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.donut_large, color: PRIMETheme.primary, size: isSmallScreen ? 18 : 20),
                  const SizedBox(width: 8),
                  Text(
                    RuLabels.resolve(RuLabels.general, 'spheres'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: isSmallScreen ? 18 : 20,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...entries.map((e) {
                final label = RuLabels.resolve(RuLabels.spheres, e.key);
                final color = _mapSphereColor(e.key);
                final value = (e.value).clamp(0.0, 1.0);
                final percent = (value * 100).toInt();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              label,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: PRIMETheme.sand),
                            ),
                          ),
                          Text('$percent%', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: PRIMETheme.sandWeak)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: PRIMETheme.line,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // Лейблы сфер теперь берём из RuLabels; локальный маппер удалён.

  Color _mapSphereColor(String key) {
    switch (key.toLowerCase()) {
      case 'body':
        return Colors.teal;
      case 'mind':
        return Colors.purple;
      case 'finance':
        return Colors.amber.shade700;
      case 'brotherhood':
        return Colors.indigo;
      default:
        return PRIMETheme.primary;
    }
  }

  // Сегодняшние привычки
  Widget _buildTodayHabits(BuildContext context, bool isSmallScreen, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              RuLabels.resolve(RuLabels.general, 'todayHabits'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isSmallScreen ? 18 : 22,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => context.go('/habits'),
              icon: Icon(
                Icons.arrow_forward,
                size: isSmallScreen ? 16 : 18,
                color: PRIMETheme.primary,
              ),
              label: Text(
                RuLabels.resolve(RuLabels.general, 'all'),
                style: TextStyle(
                  color: PRIMETheme.primary,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final todayHabitsAsync = ref.watch(todayHabitsProvider);
            
            return todayHabitsAsync.when(
              loading: () => _buildLoadingIndicator('Загружаем привычки...'),
              error: (error, stack) => _buildErrorCard(
                'Не удалось загрузить привычки. Потяните вниз, чтобы обновить.',
              ),
              data: (habits) {
                if (habits.isEmpty) {
                  return _buildEmptyStateCard(
                    'Нет активных привычек',
                    'Добавьте привычки для отслеживания прогресса',
                    Icons.add_task,
                    () => context.go('/habits'),
                  );
                }
                
                return Column(
                  children: habits.map((habit) => _buildHabitCard(
                    context: context,
                    habit: habit,
                    isSmallScreen: isSmallScreen,
                    onTap: () => _toggleHabit(habit.id),
                  )).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Быстрые задачи
  Widget _buildQuickTasks(BuildContext context, bool isSmallScreen, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Быстрые задачи',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: isSmallScreen ? 18 : 22,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => context.go('/tasks'),
              icon: Icon(
                Icons.arrow_forward,
                size: isSmallScreen ? 16 : 18,
                color: PRIMETheme.primary,
              ),
              label: Text(
                'Все',
                style: TextStyle(
                  color: PRIMETheme.primary,
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Consumer(
          builder: (context, ref, child) {
            final quickTasksAsync = ref.watch(quickTasksProvider);
            
            return quickTasksAsync.when(
              loading: () => _buildLoadingIndicator('Загружаем задачи...'),
              error: (error, stack) => _buildErrorCard(
                'Не удалось загрузить задачи. Потяните вниз, чтобы обновить.',
              ),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return _buildEmptyStateCard(
                    'Нет быстрых задач',
                    'Добавьте задачи для повышения продуктивности',
                    Icons.add_circle,
                    () => context.go('/tasks'),
                  );
                }
                
                return Column(
                  children: tasks.map((task) => _buildTaskCard(
                    context: context,
                    task: task,
                    isSmallScreen: isSmallScreen,
                    onTap: () => _toggleTask(task.id),
                  )).toList(),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // Загрузочный индикатор
  Widget _buildLoadingIndicator(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
          ),
        ],
      ),
    );
  }

  // Карточка ошибки
  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PRIMETheme.warn.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.warn.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: PRIMETheme.warn),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PRIMETheme.warn,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Состояние пустого списка
  Widget _buildEmptyStateCard(String title, String subtitle, IconData icon, VoidCallback onAction) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: PRIMETheme.sandWeak),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PRIMETheme.sand,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PRIMETheme.sandWeak,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMETheme.primary,
              foregroundColor: PRIMETheme.sand,
            ),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  // Кнопки действий
  Widget _buildActionButtons(BuildContext context, bool isSmallScreen) {
    return Column(
      children: [
        // ГТО кнопка временно отключена из-за несовместимости ML Kit с 16KB страницами памяти
        /*
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/gto'),
            icon: Icon(
              Icons.fitness_center,
              size: isSmallScreen ? 18 : 20,
            ),
            label: Text(
              'ГТО Тренировка',
              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMETheme.primary,
              foregroundColor: PRIMETheme.sand,
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 12 : 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        */
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showFocusTimer(context),
                icon: Icon(
                  Icons.timer,
                  size: isSmallScreen ? 16 : 18,
                ),
                label: Text(
                  'Фокус',
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: PRIMETheme.sand,
                  side: const BorderSide(color: PRIMETheme.line),
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showStatsOverview(context),
                icon: Icon(
                  Icons.analytics,
                  size: isSmallScreen ? 16 : 18,
                ),
                label: Text(
                  'Статистика',
                  style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: PRIMETheme.sand,
                  side: const BorderSide(color: PRIMETheme.line),
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/notifications'),
            icon: Icon(
              Icons.notifications_active,
              size: isSmallScreen ? 16 : 18,
            ),
            label: Text(
              'Мотивационные уведомления',
              style: TextStyle(fontSize: isSmallScreen ? 12 : 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: PRIMETheme.sand,
              side: BorderSide(color: PRIMETheme.primary.withOpacity(0.5)),
              padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 10 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Карточка метрики
  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSmallScreen,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: isSmallScreen ? 16 : 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: PRIMETheme.sandWeak,
                  ),
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.info_outline,
                    color: PRIMETheme.sandWeak,
                    size: isSmallScreen ? 12 : 14,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: isSmallScreen ? 24 : 32,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: isSmallScreen ? 10 : 12,
                    color: PRIMETheme.sandWeak,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Карточка привычки с API данными
  Widget _buildHabitCard({
    required BuildContext context,
    required ApiHabit habit,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    // Проверяем выполнение сегодня
    final today = DateTime.now();
    final todayCompletion = habit.completions.any((c) => 
      c.date.day == today.day &&
      c.date.month == today.month &&
      c.date.year == today.year
    );

    final habitColor = _getHabitColor(habit.category);
    final progressValue = todayCompletion ? 1.0 : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: todayCompletion ? habitColor : PRIMETheme.line,
                width: todayCompletion ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    todayCompletion ? Icons.check_circle : Icons.circle_outlined,
                    color: todayCompletion ? habitColor : PRIMETheme.sandWeak,
                    size: isSmallScreen ? 20 : 24,
                    key: ValueKey(todayCompletion),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _getHabitIcon(habit.category),
                  color: habitColor,
                  size: isSmallScreen ? 18 : 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: isSmallScreen ? 14 : 16,
                          decoration: todayCompletion ? TextDecoration.lineThrough : null,
                          color: todayCompletion ? PRIMETheme.sandWeak : PRIMETheme.sand,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            habit.frequency,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: PRIMETheme.sandWeak,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '🔥 ${_getHabitStreak(habit)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Прогресс-бар
                if (!todayCompletion)
                  Container(
                    width: isSmallScreen ? 40 : 50,
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: PRIMETheme.line,
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressValue,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: habitColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Карточка задачи с API данными
  Widget _buildTaskCard({
    required BuildContext context,
    required ApiTask task,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    final priorityColor = _getPriorityColor(task.priority);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: task.isCompleted ? PRIMETheme.success : PRIMETheme.line,
                width: task.isCompleted ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                    color: task.isCompleted ? PRIMETheme.success : PRIMETheme.sandWeak,
                    size: isSmallScreen ? 20 : 24,
                    key: ValueKey(task.isCompleted),
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  _getTaskIcon(task.category),
                  color: priorityColor,
                  size: isSmallScreen ? 18 : 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: isSmallScreen ? 14 : 16,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          color: task.isCompleted ? PRIMETheme.sandWeak : PRIMETheme.sand,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              task.priority.toUpperCase(),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 8 : 9,
                                color: priorityColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (task.dueDate != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              _formatDueDate(task.dueDate!),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: isSmallScreen ? 11 : 12,
                                color: PRIMETheme.sandWeak,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Вспомогательные методы
  Color _getHabitColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
      case 'здоровье':
        return Colors.green;
      case 'fitness':
      case 'фитнес':
        return Colors.orange;
      case 'mindfulness':
      case 'разум':
        return Colors.purple;
      case 'learning':
      case 'обучение':
        return Colors.blue;
      default:
        return PRIMETheme.primary;
    }
  }

  IconData _getHabitIcon(String category) {
    switch (category.toLowerCase()) {
      case 'health':
      case 'здоровье':
        return Icons.favorite;
      case 'fitness':
      case 'фитнес':
        return Icons.fitness_center;
      case 'mindfulness':
      case 'разум':
        return Icons.self_improvement;
      case 'learning':
      case 'обучение':
        return Icons.book;
      default:
        return Icons.task_alt;
    }
  }

  IconData _getTaskIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'work':
      case 'работа':
        return Icons.work;
      case 'personal':
      case 'личное':
        return Icons.person;
      case 'shopping':
      case 'покупки':
        return Icons.shopping_cart;
      case 'health':
      case 'здоровье':
        return Icons.health_and_safety;
      default:
        return Icons.task;
    }
  }

  int _getHabitStreak(ApiHabit habit) {
    // Простой расчет стрика - количество выполнений за последние дни
    final now = DateTime.now();
    int streak = 0;
    
    for (int i = 0; i < 30; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final hasCompletion = habit.completions.any((c) => 
        c.date.day == checkDate.day &&
        c.date.month == checkDate.month &&
        c.date.year == checkDate.year
      );
      
      if (hasCompletion) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
      case 'высокий':
        return PRIMETheme.warn;
      case 'medium':
      case 'средний':
        return PRIMETheme.primary;
      case 'low':
      case 'низкий':
        return PRIMETheme.success;
      default:
        return PRIMETheme.sandWeak;
    }
  }

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    final difference = taskDate.difference(today).inDays;
    
    if (difference == 0) {
      return 'сегодня';
    } else if (difference == 1) {
      return 'завтра';
    } else if (difference == -1) {
      return 'вчера';
    } else if (difference > 1) {
      return 'через $difference дн.';
    } else {
      return '${-difference} дн. назад';
    }
  }

  void _toggleHabit(String habitId) async {
    try {
      await ref.read(pathPageControllerProvider.notifier).toggleHabit(habitId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Привычка обновлена! 🎉'),
          backgroundColor: PRIMETheme.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка обновления привычки: $e'),
          backgroundColor: PRIMETheme.warn,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _toggleTask(String taskId) async {
    try {
      await ref.read(pathPageControllerProvider.notifier).toggleTask(taskId);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Задача обновлена! ⚡'),
          backgroundColor: PRIMETheme.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка обновления задачи: $e'),
          backgroundColor: PRIMETheme.warn,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showStreakDetails(BuildContext context, Map<String, dynamic> userMetrics) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('🔥 Стрик детали', style: TextStyle(color: PRIMETheme.sand)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Текущий стрик: ${userMetrics['streak'] ?? 0} дней', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            const SizedBox(height: 8),
            Text('Всего очков: ${userMetrics['totalPoints'] ?? 0}', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            const SizedBox(height: 8),
            Text('Ранг: ${userMetrics['currentRank'] ?? 'НОВИЧОК'}', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: (userMetrics['streak'] ?? 0) / 30.0,
              backgroundColor: PRIMETheme.line,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК', style: TextStyle(color: PRIMETheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showPointsDetails(BuildContext context, Map<String, dynamic> userMetrics) {
    final currentPoints = userMetrics['totalPoints'] ?? 0;
    final nextLevelPoints = userMetrics['nextLevelPoints'] ?? 100;
    final progress = currentPoints / nextLevelPoints;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('⭐ Очки и уровень', style: TextStyle(color: PRIMETheme.sand)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Текущие очки: $currentPoints', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            const SizedBox(height: 8),
            Text('Ранг: ${userMetrics['currentRank'] ?? 'НОВИЧОК'}', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            const SizedBox(height: 8),
            Text('До следующего уровня: ${nextLevelPoints - currentPoints} очков', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: PRIMETheme.line,
              valueColor: const AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК', style: TextStyle(color: PRIMETheme.primary)),
          ),
        ],
      ),
    );
  }

  void _showFocusTimer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PRIMETheme.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Выберите время фокуса',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ...[15, 25, 45, 60].map((minutes) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Фокус-сессия $minutes минут запущена!'),
                      backgroundColor: PRIMETheme.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).cardColor,
                  foregroundColor: PRIMETheme.sand,
                  side: const BorderSide(color: PRIMETheme.line),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  '$minutes минут',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            )),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Отмена',
                style: TextStyle(color: PRIMETheme.sandWeak),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatsOverview(BuildContext context) {
    final dailyStats = ref.read(dailyStatsProvider);
    final totalProgress = (dailyStats['completedHabits'] + dailyStats['completedTasks']) / 
                         (dailyStats['totalHabits'] + dailyStats['totalTasks']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text('📊 Общая статистика', style: TextStyle(color: PRIMETheme.sand)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Сегодня выполнено:', 
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
                   color: PRIMETheme.sand,
                 )),
            const SizedBox(height: 12),
            Text('• Привычек: ${dailyStats['completedHabits']}/${dailyStats['totalHabits']}', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            Text('• Задач: ${dailyStats['completedTasks']}/${dailyStats['totalTasks']}', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            Text('• Стрик: ${dailyStats['streak'] ?? 0} дней', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            Text('• Очки: ${dailyStats['totalPoints'] ?? 0}', 
                 style: const TextStyle(color: PRIMETheme.sandWeak)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: totalProgress.isNaN ? 0.0 : totalProgress.clamp(0.0, 1.0),
              backgroundColor: PRIMETheme.line,
              valueColor: const AlwaysStoppedAnimation<Color>(PRIMETheme.primary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ОК', style: TextStyle(color: PRIMETheme.primary)),
          ),
        ],
      ),
    );
  }
}
