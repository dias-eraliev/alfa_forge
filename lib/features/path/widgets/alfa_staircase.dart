import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../controllers/progress_controller.dart';

/// Минималистичная Альфа-лестница в стиле приложения
class PRIMEStaircase extends ConsumerWidget {
  const PRIMEStaircase({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stairData = ref.watch(stairDataProvider);
    
    return Scaffold(
      backgroundColor: PRIMETheme.bg,
      appBar: _buildAppBar(context, stairData),
      body: _buildBody(context, stairData),
    );
  }

  /// Верхняя панель
  PreferredSizeWidget _buildAppBar(BuildContext context, Map<String, dynamic> stairData) {
    return AppBar(
      backgroundColor: PRIMETheme.bg,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: PRIMETheme.sand, size: 24),
      ),
      title: Text(
        'ЛЕСТНИЦА',
        style: GoogleFonts.jetBrainsMono(
          color: PRIMETheme.sand,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: Text(
              '${((stairData['overall_progress'] as double) * 100).toInt()}%',
              style: GoogleFonts.jetBrainsMono(
                color: PRIMETheme.sand,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Основное содержимое
  Widget _buildBody(BuildContext context, Map<String, dynamic> stairData) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Информация о текущей зоне
          _buildCurrentZoneInfo(stairData),
          
          const SizedBox(height: 32),
          
          // Лестница (основной элемент)
          Expanded(child: _buildStaircase(context, stairData)),
          
          const SizedBox(height: 24),
          
          // Кнопка статистики
          _buildStatsButton(context, stairData),
        ],
      ),
    );
  }

  /// Информация о текущей зоне
  Widget _buildCurrentZoneInfo(Map<String, dynamic> stairData) {
    final currentZone = stairData['current_zone'] as String;
    final currentStep = stairData['character_position'] as int;
    const totalSteps = 600;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: PRIMETheme.line,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.sandWeak.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            'ЗОНА: $currentZone',
            style: GoogleFonts.jetBrainsMono(
              color: PRIMETheme.sand,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$currentStep / $totalSteps',
            style: GoogleFonts.jetBrainsMono(
              color: PRIMETheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'СТУПЕНЕК ПРОЙДЕНО',
            style: GoogleFonts.jetBrainsMono(
              color: PRIMETheme.sandWeak,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Главная лестница - минималистичный дизайн
  Widget _buildStaircase(BuildContext context, Map<String, dynamic> stairData) {
    final characterPosition = stairData['character_position'] as int;
    const totalSteps = 600;
    
    // Показываем последние 20 шагов для лучшей видимости
    const visibleSteps = 20;
    final startStep = (characterPosition - visibleSteps ~/ 2).clamp(0, totalSteps - visibleSteps);
    
    return Container(
      decoration: BoxDecoration(
        color: PRIMETheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: ListView.builder(
        reverse: true, // Начинаем снизу
        padding: const EdgeInsets.all(16),
        itemCount: visibleSteps,
        itemBuilder: (context, index) {
          final stepNumber = startStep + index;
          final isCompleted = stepNumber < characterPosition;
          final isCurrent = stepNumber == characterPosition;
          final zoneInfo = _getZoneInfo(stepNumber);
          
          return _StepItem(
            stepNumber: stepNumber,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            zoneName: zoneInfo['name']!,
            zoneEmoji: zoneInfo['emoji']!,
            isZoneStart: stepNumber % 100 == 0,
          );
        },
      ),
    );
  }

  /// Кнопка для показа статистики
  Widget _buildStatsButton(BuildContext context, Map<String, dynamic> stairData) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showStats(context, stairData),
        style: ElevatedButton.styleFrom(
          backgroundColor: PRIMETheme.primary,
          foregroundColor: PRIMETheme.sand,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          'ПОКАЗАТЬ СТАТИСТИКУ',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Получить информацию о зоне по номеру шага
  Map<String, String> _getZoneInfo(int step) {
    final zones = [
      {'name': 'ТЕЛО', 'emoji': '🏃'},
      {'name': 'ВОЛЯ', 'emoji': '💪'},
      {'name': 'ФОКУС', 'emoji': '🎯'},
      {'name': 'РАЗУМ', 'emoji': '🧠'},
      {'name': 'СПОКОЙСТВИЕ', 'emoji': '🧘'},
      {'name': 'ДЕНЬГИ', 'emoji': '💰'},
    ];
    
    final zoneIndex = (step ~/ 100).clamp(0, zones.length - 1);
    return zones[zoneIndex];
  }

  /// Показать статистику
  void _showStats(BuildContext context, Map<String, dynamic> stairData) {
    showDialog(
      context: context,
      builder: (context) => _StatsDialog(stairData: stairData),
    );
  }
}

/// Элемент ступеньки - минималистичный дизайн
class _StepItem extends StatelessWidget {
  final int stepNumber;
  final bool isCompleted;
  final bool isCurrent;
  final String zoneName;
  final String zoneEmoji;
  final bool isZoneStart;

  const _StepItem({
    required this.stepNumber,
    required this.isCompleted,
    required this.isCurrent,
    required this.zoneName,
    required this.zoneEmoji,
    required this.isZoneStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          // Номер ступени
          SizedBox(
            width: 60,
            child: Text(
              '$stepNumber',
              style: GoogleFonts.jetBrainsMono(
                color: isCurrent ? PRIMETheme.primary : PRIMETheme.sandWeak,
                fontSize: 12,
                fontWeight: isCurrent ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
          
          // Визуализация ступени
          Expanded(
            child: Container(
              height: isZoneStart ? 24 : 16,
              decoration: BoxDecoration(
                color: isCompleted 
                    ? PRIMETheme.primary 
                    : PRIMETheme.line.withOpacity(0.5),
                borderRadius: BorderRadius.circular(isZoneStart ? 6 : 4),
                border: isCurrent 
                    ? Border.all(color: PRIMETheme.sand, width: 1)
                    : null,
              ),
              child: isZoneStart 
                  ? Center(
                      child: Text(
                        '$zoneEmoji $zoneName',
                        style: GoogleFonts.jetBrainsMono(
                          color: isCompleted ? PRIMETheme.sand : PRIMETheme.sandWeak,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          
          // Персонаж на текущей ступени
          if (isCurrent) ...[
            const SizedBox(width: 12),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: PRIMETheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: PRIMETheme.sand, width: 1),
              ),
              child: const Icon(
                Icons.person,
                color: PRIMETheme.sand,
                size: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Диалог статистики - минималистичный дизайн
class _StatsDialog extends ConsumerWidget {
  final Map<String, dynamic> stairData;

  const _StatsDialog({required this.stairData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTimeStats = ref.watch(allTimeStatsProvider);
    
    return Dialog(
      backgroundColor: PRIMETheme.line,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Text(
              'СТАТИСТИКА',
              style: GoogleFonts.jetBrainsMono(
                color: PRIMETheme.sand,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Основные показатели
            _StatRow('Текущая позиция:', '${stairData['character_position']}'),
            _StatRow('Общий прогресс:', '${((stairData['overall_progress'] as double) * 100).toInt()}%'),
            _StatRow('Текущая зона:', stairData['current_zone'] as String),
            _StatRow('Ранг:', stairData['character_rank'] as String),
            
            const SizedBox(height: 16),
            const Divider(color: PRIMETheme.sandWeak),
            const SizedBox(height: 16),
            
            // Достижения
            Text(
              'ДОСТИЖЕНИЯ',
              style: GoogleFonts.jetBrainsMono(
                color: PRIMETheme.sand,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            _StatRow('Общий XP:', '${allTimeStats['total_xp']}'),
            _StatRow('Стрик:', '${allTimeStats['current_streak']} дней'),
            _StatRow('Лучший стрик:', '${allTimeStats['longest_streak']} дней'),
            
            const SizedBox(height: 24),
            
            // Кнопка закрыть
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMETheme.primary,
                  foregroundColor: PRIMETheme.sand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'ЗАКРЫТЬ',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Строка статистики
class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              color: PRIMETheme.sandWeak,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.jetBrainsMono(
              color: PRIMETheme.sand,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
