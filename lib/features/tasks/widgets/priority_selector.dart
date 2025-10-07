import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../models/task_model.dart';

class PrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onPriorityChanged;
  final String label;
  final bool isRequired;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
    this.label = 'Приоритет',
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
            children: TaskPriority.values.map((priority) {
              final isFirst = priority == TaskPriority.values.first;
              final isLast = priority == TaskPriority.values.last;
              
              return Column(
                children: [
                  _PriorityOption(
                    priority: priority,
                    isSelected: priority == selectedPriority,
                    onTap: () => onPriorityChanged(priority),
                  ),
                  if (!isLast) const Divider(height: 1, color: PRIMETheme.line),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final TaskPriority priority;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.priority,
    required this.isSelected,
    required this.onTap,
  });

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PRIMETheme.success;
      case TaskPriority.medium:
        return PRIMETheme.primary;
      case TaskPriority.high:
        return PRIMETheme.warn;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
    }
  }

  String _getPriorityDescription(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Может подождать';
      case TaskPriority.medium:
        return 'Обычная важность';
      case TaskPriority.high:
        return 'Требует внимания';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(priority);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Иконка приоритета
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getPriorityIcon(priority),
                color: isSelected ? PRIMETheme.sand : color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            // Название и описание
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priority.displayName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? color : null,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getPriorityDescription(priority),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PRIMETheme.sandWeak,
                    ),
                  ),
                ],
              ),
            ),
            // Индикатор выбора
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                color: color,
                size: 24,
              ),
            ] else ...[
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: PRIMETheme.sandWeak),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CompactPrioritySelector extends StatelessWidget {
  final TaskPriority selectedPriority;
  final ValueChanged<TaskPriority> onPriorityChanged;

  const CompactPrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = priority == selectedPriority;
        final color = _getPriorityColor(priority);
        
        return Expanded(
          child: GestureDetector(
            onTap: () => onPriorityChanged(priority),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? color : color.withOpacity(0.3),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _getPriorityIcon(priority),
                    color: isSelected ? PRIMETheme.sand : color,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    priority.displayName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected ? PRIMETheme.sand : color,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PRIMETheme.success;
      case TaskPriority.medium:
        return PRIMETheme.primary;
      case TaskPriority.high:
        return PRIMETheme.warn;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.high:
        return Icons.keyboard_arrow_up;
    }
  }
}

class PriorityIndicator extends StatelessWidget {
  final TaskPriority priority;
  final double size;
  final bool showLabel;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.size = 8,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getPriorityColor(priority);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            priority.displayName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return PRIMETheme.success;
      case TaskPriority.medium:
        return PRIMETheme.primary;
      case TaskPriority.high:
        return PRIMETheme.warn;
    }
  }
}
