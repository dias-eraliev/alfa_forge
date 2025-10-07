import 'package:flutter/material.dart';
import '../../../app/theme.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime selectedDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;
  final String label;
  final bool isRequired;

  const DateTimePicker({
    super.key,
    required this.selectedDateTime,
    required this.onDateTimeChanged,
    this.label = 'Дедлайн',
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: PRIMETheme.warn),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PRIMETheme.line),
          ),
          child: Column(
            children: [
              // Дата
              _DatePickerTile(
                selectedDate: selectedDateTime,
                onDateChanged: (date) {
                  final newDateTime = DateTime(
                    date.year,
                    date.month,
                    date.day,
                    selectedDateTime.hour,
                    selectedDateTime.minute,
                  );
                  onDateTimeChanged(newDateTime);
                },
              ),
              const Divider(height: 1, color: PRIMETheme.line),
              // Время
              _TimePickerTile(
                selectedTime: TimeOfDay.fromDateTime(selectedDateTime),
                onTimeChanged: (time) {
                  final newDateTime = DateTime(
                    selectedDateTime.year,
                    selectedDateTime.month,
                    selectedDateTime.day,
                    time.hour,
                    time.minute,
                  );
                  onDateTimeChanged(newDateTime);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DatePickerTile({
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.calendar_today, color: PRIMETheme.primary),
      title: Text(
        'Дата',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        _formatDate(selectedDate),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: PRIMETheme.sand,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: PRIMETheme.sandWeak),
      onTap: () => _showDatePicker(context),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Сегодня';
    } else if (selectedDay == tomorrow) {
      return 'Завтра';
    } else {
      final months = [
        'янв', 'фев', 'мар', 'апр', 'май', 'июн',
        'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: PRIMETheme.primary,
              onPrimary: PRIMETheme.sand,
              surface: Theme.of(context).cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateChanged(picked);
    }
  }
}

class _TimePickerTile extends StatelessWidget {
  final TimeOfDay selectedTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const _TimePickerTile({
    required this.selectedTime,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.access_time, color: PRIMETheme.primary),
      title: Text(
        'Время',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        selectedTime.format(context),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: PRIMETheme.sand,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: PRIMETheme.sandWeak),
      onTap: () => _showTimePicker(context),
    );
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: PRIMETheme.primary,
              onPrimary: PRIMETheme.sand,
              surface: Theme.of(context).cardColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }
}

class QuickDateSelector extends StatelessWidget {
  final ValueChanged<DateTime> onDateSelected;

  const QuickDateSelector({
    super.key,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Быстрый выбор',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: PRIMETheme.sandWeak,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickDateChip(
              label: 'Сегодня',
              onTap: () => onDateSelected(now),
            ),
            _QuickDateChip(
              label: 'Завтра',
              onTap: () => onDateSelected(now.add(const Duration(days: 1))),
            ),
            _QuickDateChip(
              label: 'Через неделю',
              onTap: () => onDateSelected(now.add(const Duration(days: 7))),
            ),
            _QuickDateChip(
              label: 'Через месяц',
              onTap: () => onDateSelected(now.add(const Duration(days: 30))),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickDateChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickDateChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: PRIMETheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: PRIMETheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
