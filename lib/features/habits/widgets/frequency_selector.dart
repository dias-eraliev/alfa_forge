import 'package:flutter/material.dart';
import '../models/habit_model.dart';
import '../../../app/theme.dart';

class FrequencySelector extends StatefulWidget {
  final HabitFrequency frequency;
  final ValueChanged<HabitFrequency> onChanged;

  const FrequencySelector({
    super.key,
    required this.frequency,
    required this.onChanged,
  });

  @override
  State<FrequencySelector> createState() => _FrequencySelectorState();
}

class _FrequencySelectorState extends State<FrequencySelector> {
  late HabitFrequencyType selectedType;
  late int timesPerWeek;
  late int timesPerMonth;
  late List<int> selectedWeekdays;

  @override
  void initState() {
    super.initState();
    selectedType = widget.frequency.type;
    timesPerWeek = widget.frequency.timesPerWeek ?? 3;
    timesPerMonth = widget.frequency.timesPerMonth ?? 4;
    selectedWeekdays = widget.frequency.specificDays ?? [];
  }

  void _updateFrequency() {
    HabitFrequency newFrequency;
    
    switch (selectedType) {
      case HabitFrequencyType.daily:
        newFrequency = HabitFrequency(type: HabitFrequencyType.daily);
        break;
      case HabitFrequencyType.weekly:
        newFrequency = HabitFrequency(
          type: HabitFrequencyType.weekly,
          timesPerWeek: timesPerWeek,
          specificDays: selectedWeekdays.isNotEmpty ? selectedWeekdays : null,
        );
        break;
      case HabitFrequencyType.monthly:
        newFrequency = HabitFrequency(
          type: HabitFrequencyType.monthly,
          timesPerMonth: timesPerMonth,
        );
        break;
      case HabitFrequencyType.custom:
        newFrequency = HabitFrequency(
          type: HabitFrequencyType.custom,
          specificDays: selectedWeekdays,
        );
        break;
    }
    
    widget.onChanged(newFrequency);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Частота выполнения',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 16 : 18,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),

        // Основные типы частоты
        Column(
          children: [
            _FrequencyOption(
              title: 'Каждый день',
              subtitle: 'Ежедневное выполнение',
              icon: Icons.today,
              value: HabitFrequencyType.daily,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
                _updateFrequency();
              },
              isSmallScreen: isSmallScreen,
            ),
            
            _FrequencyOption(
              title: 'Несколько раз в неделю',
              subtitle: 'Гибкий недельный график',
              icon: Icons.view_week,
              value: HabitFrequencyType.weekly,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
                _updateFrequency();
              },
              isSmallScreen: isSmallScreen,
            ),
            
            _FrequencyOption(
              title: 'Несколько раз в месяц',
              subtitle: 'Месячная периодичность',
              icon: Icons.calendar_month,
              value: HabitFrequencyType.monthly,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
                _updateFrequency();
              },
              isSmallScreen: isSmallScreen,
            ),
            
            _FrequencyOption(
              title: 'Определенные дни',
              subtitle: 'Конкретные дни недели',
              icon: Icons.event_note,
              value: HabitFrequencyType.custom,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
                _updateFrequency();
              },
              isSmallScreen: isSmallScreen,
            ),
          ],
        ),

        // Дополнительные настройки в зависимости от выбранного типа
        if (selectedType == HabitFrequencyType.weekly) ...[
          SizedBox(height: isSmallScreen ? 16 : 20),
          _WeeklySettings(
            timesPerWeek: timesPerWeek,
            selectedWeekdays: selectedWeekdays,
            onTimesChanged: (value) {
              setState(() {
                timesPerWeek = value;
              });
              _updateFrequency();
            },
            onWeekdaysChanged: (days) {
              setState(() {
                selectedWeekdays = days;
              });
              _updateFrequency();
            },
            isSmallScreen: isSmallScreen,
          ),
        ],

        if (selectedType == HabitFrequencyType.monthly) ...[
          SizedBox(height: isSmallScreen ? 16 : 20),
          _MonthlySettings(
            timesPerMonth: timesPerMonth,
            onChanged: (value) {
              setState(() {
                timesPerMonth = value;
              });
              _updateFrequency();
            },
            isSmallScreen: isSmallScreen,
          ),
        ],

        if (selectedType == HabitFrequencyType.custom) ...[
          SizedBox(height: isSmallScreen ? 16 : 20),
          _CustomSettings(
            selectedWeekdays: selectedWeekdays,
            onChanged: (days) {
              setState(() {
                selectedWeekdays = days;
              });
              _updateFrequency();
            },
            isSmallScreen: isSmallScreen,
          ),
        ],

        SizedBox(height: isSmallScreen ? 16 : 20),
        
        // Превью выбранной частоты
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            color: PRIMETheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PRIMETheme.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule,
                color: PRIMETheme.primary,
                size: isSmallScreen ? 20 : 24,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Выбранная частота:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PRIMETheme.primary,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                    Text(
                      _getFrequencyDescription(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: PRIMETheme.primary,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getFrequencyDescription() {
    switch (selectedType) {
      case HabitFrequencyType.daily:
        return 'Каждый день';
      case HabitFrequencyType.weekly:
        if (selectedWeekdays.isNotEmpty) {
          final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
          final selectedDayNames = selectedWeekdays
              .map((day) => dayNames[day - 1])
              .join(', ');
          return 'По $selectedDayNames';
        }
        return '$timesPerWeek раз в неделю';
      case HabitFrequencyType.monthly:
        return '$timesPerMonth раз в месяц';
      case HabitFrequencyType.custom:
        if (selectedWeekdays.isEmpty) return 'Выберите дни';
        final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
        final selectedDayNames = selectedWeekdays
            .map((day) => dayNames[day - 1])
            .join(', ');
        return 'По $selectedDayNames';
    }
  }
}

class _FrequencyOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final HabitFrequencyType value;
  final HabitFrequencyType groupValue;
  final ValueChanged<HabitFrequencyType?> onChanged;
  final bool isSmallScreen;

  const _FrequencyOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? PRIMETheme.primary.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? PRIMETheme.primary 
                : PRIMETheme.line,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isSmallScreen ? 40 : 48,
              height: isSmallScreen ? 40 : 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? PRIMETheme.primary.withOpacity(0.2)
                    : PRIMETheme.line.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? PRIMETheme.primary : PRIMETheme.sandWeak,
                size: isSmallScreen ? 20 : 24,
              ),
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? PRIMETheme.primary : null,
                      fontSize: isSmallScreen ? 14 : 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PRIMETheme.sandWeak,
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSmallScreen ? 20 : 24,
              height: isSmallScreen ? 20 : 24,
              decoration: BoxDecoration(
                color: isSelected ? PRIMETheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? PRIMETheme.primary : PRIMETheme.line,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                      size: isSmallScreen ? 12 : 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklySettings extends StatelessWidget {
  final int timesPerWeek;
  final List<int> selectedWeekdays;
  final ValueChanged<int> onTimesChanged;
  final ValueChanged<List<int>> onWeekdaysChanged;
  final bool isSmallScreen;

  const _WeeklySettings({
    required this.timesPerWeek,
    required this.selectedWeekdays,
    required this.onTimesChanged,
    required this.onWeekdaysChanged,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Количество раз в неделю
          Row(
            children: [
              Text(
                'Количество раз в неделю:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: PRIMETheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$timesPerWeek',
                  style: TextStyle(
                    color: PRIMETheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          Slider(
            value: timesPerWeek.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            activeColor: PRIMETheme.primary,
            onChanged: (value) => onTimesChanged(value.round()),
          ),
          
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          Text(
            'Или выберите конкретные дни:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          // Выбор дней недели
          _WeekdaySelector(
            selectedWeekdays: selectedWeekdays,
            onChanged: onWeekdaysChanged,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }
}

class _MonthlySettings extends StatelessWidget {
  final int timesPerMonth;
  final ValueChanged<int> onChanged;
  final bool isSmallScreen;

  const _MonthlySettings({
    required this.timesPerMonth,
    required this.onChanged,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Количество раз в месяц:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: PRIMETheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$timesPerMonth',
                  style: TextStyle(
                    color: PRIMETheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          Slider(
            value: timesPerMonth.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            activeColor: PRIMETheme.primary,
            onChanged: (value) => onChanged(value.round()),
          ),
        ],
      ),
    );
  }
}

class _CustomSettings extends StatelessWidget {
  final List<int> selectedWeekdays;
  final ValueChanged<List<int>> onChanged;
  final bool isSmallScreen;

  const _CustomSettings({
    required this.selectedWeekdays,
    required this.onChanged,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PRIMETheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Выберите дни недели:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 8 : 12),
          
          _WeekdaySelector(
            selectedWeekdays: selectedWeekdays,
            onChanged: onChanged,
            isSmallScreen: isSmallScreen,
          ),
        ],
      ),
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  final List<int> selectedWeekdays;
  final ValueChanged<List<int>> onChanged;
  final bool isSmallScreen;

  const _WeekdaySelector({
    required this.selectedWeekdays,
    required this.onChanged,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final weekdays = [
      {'id': 1, 'name': 'Пн', 'fullName': 'Понедельник'},
      {'id': 2, 'name': 'Вт', 'fullName': 'Вторник'},
      {'id': 3, 'name': 'Ср', 'fullName': 'Среда'},
      {'id': 4, 'name': 'Чт', 'fullName': 'Четверг'},
      {'id': 5, 'name': 'Пт', 'fullName': 'Пятница'},
      {'id': 6, 'name': 'Сб', 'fullName': 'Суббота'},
      {'id': 7, 'name': 'Вс', 'fullName': 'Воскресенье'},
    ];

    return Wrap(
      spacing: isSmallScreen ? 6 : 8,
      runSpacing: isSmallScreen ? 6 : 8,
      children: weekdays.map((day) {
        final dayId = day['id'] as int;
        final isSelected = selectedWeekdays.contains(dayId);
        
        return GestureDetector(
          onTap: () {
            final newSelection = List<int>.from(selectedWeekdays);
            if (isSelected) {
              newSelection.remove(dayId);
            } else {
              newSelection.add(dayId);
            }
            newSelection.sort();
            onChanged(newSelection);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: isSelected 
                  ? PRIMETheme.primary 
                  : PRIMETheme.line.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected 
                    ? PRIMETheme.primary 
                    : PRIMETheme.line,
              ),
            ),
            child: Text(
              day['name'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : PRIMETheme.sand,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
