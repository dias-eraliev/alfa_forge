import 'package:flutter/material.dart';
import '../models/health_goal_model.dart';
import '../../../app/theme.dart';

class GoalPrioritySelector extends StatelessWidget {
  final HealthGoalPriority? selectedPriority;
  final Function(HealthGoalPriority) onPrioritySelected;
  final bool isCompact;

  const GoalPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Приоритет',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isCompact ? 12 : 14,
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        
        Row(
          children: HealthGoalPriority.values.map((priority) {
            final isSelected = selectedPriority == priority;
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _PriorityCard(
                  priority: priority,
                  isSelected: isSelected,
                  onTap: () => onPrioritySelected(priority),
                  isCompact: isCompact,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PriorityCard extends StatefulWidget {
  final HealthGoalPriority priority;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const _PriorityCard({
    required this.priority,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  State<_PriorityCard> createState() => _PriorityCardState();
}

class _PriorityCardState extends State<_PriorityCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.all(widget.isCompact ? 8 : 12),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: [
                          widget.priority.color,
                          widget.priority.color.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isSelected ? null : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.priority.color
                      : widget.priority.color.withOpacity(0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.priority.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(widget.isCompact ? 4 : 6),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? Colors.white.withOpacity(0.2)
                          : widget.priority.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getPriorityIcon(widget.priority),
                      color: widget.isSelected
                          ? Colors.white
                          : widget.priority.color,
                      size: widget.isCompact ? 16 : 20,
                    ),
                  ),
                  SizedBox(height: widget.isCompact ? 4 : 6),
                  Text(
                    widget.priority.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.isSelected
                          ? Colors.white
                          : widget.priority.color,
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: widget.isCompact ? 10 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getPriorityIcon(HealthGoalPriority priority) {
    switch (priority) {
      case HealthGoalPriority.low:
        return Icons.keyboard_arrow_down;
      case HealthGoalPriority.medium:
        return Icons.remove;
      case HealthGoalPriority.high:
        return Icons.keyboard_arrow_up;
    }
  }
}

class GoalFrequencySelector extends StatelessWidget {
  final HealthGoalFrequency? selectedFrequency;
  final Function(HealthGoalFrequency) onFrequencySelected;
  final bool isCompact;

  const GoalFrequencySelector({
    super.key,
    required this.selectedFrequency,
    required this.onFrequencySelected,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Частота отслеживания',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isCompact ? 12 : 14,
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HealthGoalFrequency.values.map((frequency) {
            final isSelected = selectedFrequency == frequency;
            
            return _FrequencyChip(
              frequency: frequency,
              isSelected: isSelected,
              onTap: () => onFrequencySelected(frequency),
              isCompact: isCompact,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _FrequencyChip extends StatefulWidget {
  final HealthGoalFrequency frequency;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const _FrequencyChip({
    required this.frequency,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  State<_FrequencyChip> createState() => _FrequencyChipState();
}

class _FrequencyChipState extends State<_FrequencyChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCompact ? 12 : 16,
                vertical: widget.isCompact ? 8 : 10,
              ),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: [
                          PRIMETheme.primary,
                          PRIMETheme.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isSelected ? null : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.isSelected
                      ? PRIMETheme.primary
                      : PRIMETheme.primary.withOpacity(0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: PRIMETheme.primary.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFrequencyIcon(widget.frequency),
                    color: widget.isSelected
                        ? Colors.white
                        : PRIMETheme.primary,
                    size: widget.isCompact ? 14 : 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.frequency.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.isSelected
                          ? Colors.white
                          : PRIMETheme.primary,
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: widget.isCompact ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getFrequencyIcon(HealthGoalFrequency frequency) {
    switch (frequency) {
      case HealthGoalFrequency.daily:
        return Icons.today;
      case HealthGoalFrequency.weekly:
        return Icons.date_range;
      case HealthGoalFrequency.monthly:
        return Icons.calendar_month;
      case HealthGoalFrequency.yearly:
        return Icons.event;
    }
  }
}

class GoalTypeSelector extends StatelessWidget {
  final HealthGoalType? selectedType;
  final Function(HealthGoalType) onTypeSelected;
  final bool isCompact;

  const GoalTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Группируем цели по категориям
    final categories = {
      'Вес и композиция тела': [
        HealthGoalType.weight,
        HealthGoalType.bodyFat,
        HealthGoalType.muscle,
      ],
      'Измерения тела': [
        HealthGoalType.waist,
        HealthGoalType.chest,
        HealthGoalType.hips,
        HealthGoalType.biceps,
      ],
      'Активность': [
        HealthGoalType.steps,
        HealthGoalType.calories,
      ],
      'Здоровье': [
        HealthGoalType.water,
        HealthGoalType.sleep,
        HealthGoalType.heartRate,
        HealthGoalType.bloodPressure,
      ],
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Тип цели',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: isCompact ? 12 : 14,
          ),
        ),
        SizedBox(height: isCompact ? 8 : 12),
        
        ...categories.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  entry.key,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: PRIMETheme.sandWeak,
                    fontSize: isCompact ? 11 : 12,
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: entry.value.map((type) {
                  final isSelected = selectedType == type;
                  
                  return _GoalTypeChip(
                    type: type,
                    isSelected: isSelected,
                    onTap: () => onTypeSelected(type),
                    isCompact: isCompact,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ],
    );
  }
}

class _GoalTypeChip extends StatefulWidget {
  final HealthGoalType type;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isCompact;

  const _GoalTypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  State<_GoalTypeChip> createState() => _GoalTypeChipState();
}

class _GoalTypeChipState extends State<_GoalTypeChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) {
              _controller.reverse();
              widget.onTap();
            },
            onTapCancel: () => _controller.reverse(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: widget.isCompact ? 10 : 12,
                vertical: widget.isCompact ? 6 : 8,
              ),
              decoration: BoxDecoration(
                gradient: widget.isSelected
                    ? LinearGradient(
                        colors: [
                          widget.type.color,
                          widget.type.color.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.isSelected ? null : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isSelected
                      ? widget.type.color
                      : widget.type.color.withOpacity(0.3),
                  width: widget.isSelected ? 2 : 1,
                ),
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.type.color.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.type.icon,
                    color: widget.isSelected
                        ? Colors.white
                        : widget.type.color,
                    size: widget.isCompact ? 14 : 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.type.title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.isSelected
                          ? Colors.white
                          : widget.type.color,
                      fontWeight: widget.isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: widget.isCompact ? 10 : 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
