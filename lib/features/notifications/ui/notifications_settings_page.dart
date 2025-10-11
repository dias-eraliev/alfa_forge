import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../app/theme.dart';
import '../controllers/notifications_controller.dart';
import '../models/quote_model.dart';

class NotificationsSettingsPage extends ConsumerWidget {
  const NotificationsSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final controller = ref.read(notificationSettingsProvider.notifier);
    final nextNotificationInfo = ref.watch(nextNotificationInfoProvider);
    final quotesStats = ref.watch(quotesStatisticsProvider);

    return Scaffold(
      backgroundColor: PRIMETheme.bg,
      appBar: AppBar(
        backgroundColor: PRIMETheme.bg,
        elevation: 0,
        title: Text(
          'Мотивационные уведомления',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: PRIMETheme.sand),
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: PRIMETheme.sandWeak),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.testTube, color: PRIMETheme.primary),
            onPressed: () => controller.showTestNotification(),
            tooltip: 'Тестовое уведомление',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основные настройки
            _buildMainSettings(settings, controller),
            
            const SizedBox(height: 24),
            
            // Расписание
            if (settings.isEnabled) ...[
              _buildScheduleSettings(settings, controller),
              const SizedBox(height: 24),
            ],
            
            // Категории цитат
            _buildCategoriesSettings(settings, controller, quotesStats),
            
            const SizedBox(height: 24),
            
            // Дополнительные настройки
            if (settings.isEnabled) ...[
              _buildAdvancedSettings(settings, controller),
              const SizedBox(height: 24),
            ],
            
            // Статистика
            _buildStatistics(nextNotificationInfo, quotesStats),
            
            const SizedBox(height: 24),
            
            // Действия
            _buildActions(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildMainSettings(settings, controller) {
    return _buildSection(
      title: 'Основные настройки',
      icon: LucideIcons.settings,
      children: [
        _buildSwitchTile(
          title: 'Включить уведомления',
          subtitle: settings.isEnabled 
            ? 'Уведомления активны' 
            : 'Уведомления отключены',
          value: settings.isEnabled,
          onChanged: () => controller.toggleNotifications(),
          icon: settings.isEnabled ? LucideIcons.bell : LucideIcons.bellOff,
        ),
        if (settings.isEnabled) ...[
          const SizedBox(height: 16),
          _buildSwitchTile(
            title: 'Звук',
            subtitle: 'Звуковые уведомления',
            value: settings.soundEnabled,
            onChanged: () => controller.toggleSound(),
            icon: LucideIcons.volume2,
          ),
          const SizedBox(height: 12),
          _buildSwitchTile(
            title: 'Вибрация',
            subtitle: 'Вибрация при уведомлении',
            value: settings.vibrationEnabled,
            onChanged: () => controller.toggleVibration(),
            icon: LucideIcons.smartphone,
          ),
        ],
      ],
    );
  }

  Widget _buildScheduleSettings(settings, controller) {
    return _buildSection(
      title: 'Расписание',
      icon: LucideIcons.clock,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTimePicker(
                title: 'Начало',
                hour: settings.startHour,
                onChanged: (hour) => controller.setStartHour(hour),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimePicker(
                title: 'Конец',
                hour: settings.endHour,
                onChanged: (hour) => controller.setEndHour(hour),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSliderTile(
          title: 'Интервал между уведомлениями',
          subtitle: '${settings.intervalMinutes} минут',
          value: settings.intervalMinutes.toDouble(),
          min: 15,
          max: 240,
          divisions: 15,
          onChanged: (value) => controller.setInterval(value.round()),
          icon: LucideIcons.timer,
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          title: 'Уведомлений в день',
          subtitle: '${settings.notificationsPerDay} уведомлений',
          icon: LucideIcons.calendar,
        ),
        const SizedBox(height: 12),
        _buildSwitchTile(
          title: 'Работать в выходные',
          subtitle: 'Суббота и воскресенье',
          value: settings.weekendsEnabled,
          onChanged: () => controller.toggleWeekends(),
          icon: LucideIcons.calendarDays,
        ),
      ],
    );
  }

  Widget _buildCategoriesSettings(settings, controller, Map<String, int> quotesStats) {
    return _buildSection(
      title: 'Категории цитат',
      icon: LucideIcons.tags,
      children: [
        ...QuoteCategory.values.map((category) {
          final isEnabled = settings.enabledCategories.contains(category.name);
          final count = quotesStats[category.name] ?? 0;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCategoryTile(
              category: category,
              isEnabled: isEnabled,
              count: count,
              onToggle: () => controller.toggleCategory(category.name),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAdvancedSettings(settings, controller) {
    return _buildSection(
      title: 'Дополнительно',
      icon: LucideIcons.sliders,
      children: [
        _buildSwitchTile(
          title: 'Умное планирование',
          subtitle: 'Адаптация под активность',
          value: settings.smartScheduling,
          onChanged: () => controller.toggleSmartScheduling(),
          icon: LucideIcons.brain,
        ),
        const SizedBox(height: 12),
        _buildSliderTile(
          title: 'Макс. уведомлений в день',
          subtitle: '${settings.maxDailyQuotes} уведомлений',
          value: settings.maxDailyQuotes.toDouble(),
          min: 1,
          max: 30,
          divisions: 29,
          onChanged: (value) => controller.setMaxDailyQuotes(value.round()),
          icon: LucideIcons.target,
        ),
      ],
    );
  }

  Widget _buildStatistics(AsyncValue<String> nextNotificationInfo, Map<String, int> quotesStats) {
    return _buildSection(
      title: 'Статистика',
      icon: LucideIcons.barChart,
      children: [
        nextNotificationInfo.when(
          data: (info) => _buildInfoTile(
            title: 'Следующее уведомление',
            subtitle: info,
            icon: LucideIcons.clock,
          ),
          loading: () => _buildInfoTile(
            title: 'Следующее уведомление',
            subtitle: 'Загрузка...',
            icon: LucideIcons.clock,
          ),
          error: (_, __) => _buildInfoTile(
            title: 'Следующее уведомление',
            subtitle: 'Ошибка загрузки',
            icon: LucideIcons.clock,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoTile(
          title: 'Всего цитат',
          subtitle: '${quotesStats.values.fold(0, (sum, count) => sum + count)} цитат',
          icon: LucideIcons.quote,
        ),
      ],
    );
  }

  Widget _buildActions(controller) {
    return _buildSection(
      title: 'Действия',
      icon: LucideIcons.zap,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                title: 'Перезапустить',
                subtitle: 'Применить настройки',
                icon: LucideIcons.refreshCw,
                onTap: () => controller.restartNotifications(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                title: 'Очистить историю',
                subtitle: 'Сбросить показанные',
                icon: LucideIcons.trash2,
                onTap: () => controller.clearHistory(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionButton(
          title: 'Сбросить настройки',
          subtitle: 'Вернуть к значениям по умолчанию',
          icon: LucideIcons.rotateCcw,
          onTap: () => controller.resetToDefaults(),
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PRIMETheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: PRIMETheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: PRIMETheme.sand,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required VoidCallback onChanged,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: value ? PRIMETheme.primary : PRIMETheme.sandWeak, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: PRIMETheme.sand,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: PRIMETheme.sandWeak,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: (_) => onChanged(),
          activeColor: PRIMETheme.primary,
        ),
      ],
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: PRIMETheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: PRIMETheme.sand,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: PRIMETheme.sandWeak,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: PRIMETheme.primary,
            thumbColor: PRIMETheme.primary,
            overlayColor: PRIMETheme.primary.withOpacity(0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: PRIMETheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: PRIMETheme.sand,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: PRIMETheme.sandWeak,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String title,
    required int hour,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PRIMETheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: PRIMETheme.sandWeak,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () async {
              // Здесь можно добавить время picker
              // Пока что простой инкремент/декремент
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: PRIMETheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${hour.toString().padLeft(2, '0')}:00',
                style: const TextStyle(
                  color: PRIMETheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required QuoteCategory category,
    required bool isEnabled,
    required int count,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isEnabled ? PRIMETheme.primary.withOpacity(0.1) : PRIMETheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled ? PRIMETheme.primary : PRIMETheme.line,
        ),
      ),
      child: Row(
        children: [
          Text(
            category.name == 'money' ? '💰' :
            category.name == 'discipline' ? '⚡' :
            category.name == 'will' ? '💪' :
            category.name == 'focus' ? '🎯' :
            category.name == 'strength' ? '🔥' :
            category.name == 'success' ? '🏆' :
            category.name == 'mindset' ? '🧠' :
            category.name == 'leadership' ? '👑' :
            category.name == 'work' ? '💼' : '🏃',
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name == 'money' ? 'Деньги' :
                  category.name == 'discipline' ? 'Дисциплина' :
                  category.name == 'will' ? 'Воля' :
                  category.name == 'focus' ? 'Фокус' :
                  category.name == 'strength' ? 'Сила' :
                  category.name == 'success' ? 'Успех' :
                  category.name == 'mindset' ? 'Мышление' :
                  category.name == 'leadership' ? 'Лидерство' :
                  category.name == 'work' ? 'Работа' : 'Здоровье',
                  style: const TextStyle(
                    color: PRIMETheme.sand,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$count цитат',
                  style: const TextStyle(
                    color: PRIMETheme.sandWeak,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: (_) => onToggle(),
            activeColor: PRIMETheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? PRIMETheme.warn : PRIMETheme.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: const TextStyle(
                color: PRIMETheme.sandWeak,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
