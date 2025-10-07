import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../models/habit_model.dart';

class HabitMiniCard extends StatelessWidget {
  final HabitModel habit;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;
  final double width;
  final int animationDelay;

  const HabitMiniCard({
    super.key,
    required this.habit,
    required this.selected,
    required this.disabled,
    required this.onTap,
    required this.width,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    const baseBorder = PRIMETheme.line;
    const primary = PRIMETheme.primary;
    const sand = PRIMETheme.sand;
    const sandWeak = PRIMETheme.sandWeak;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + animationDelay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + value * 0.1,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: disabled && !selected ? 0.35 : 1,
          child: Container(
            width: width,
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: PRIMETheme.bg,
              border: Border.all(
                color: selected ? primary : baseBorder,
                width: selected ? 1.2 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Small icon
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: selected
                      ? BoxDecoration(
color: primary.withValues(alpha: 0.08),
                          border: Border.all(
color: primary.withValues(alpha: 0.35),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        )
                      : null,
                  child: Text(
                    habit.icon,
                    style: const TextStyle(fontSize: 16, height: 1),
                  ),
                ),
                const SizedBox(width: 8),
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                          letterSpacing: 0.2,
                          color: selected ? primary : sand,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        habit.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
color: sandWeak.withValues(alpha: 0.75),
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (selected)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
color: primary.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
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
}

// Маленький бейдж выбранной привычки (для секции "Вы выбрали")
class SelectedHabitBadge extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onRemove;
  final int animationDelay;

  const SelectedHabitBadge({
    super.key,
    required this.habit,
    required this.onRemove,
    this.animationDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 220 + animationDelay),
      curve: Curves.easeOut,
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: Transform.scale(scale: 0.9 + v * 0.1, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
color: PRIMETheme.primary.withValues(alpha: 0.08),
border: Border.all(color: PRIMETheme.primary.withValues(alpha: 0.4), width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              habit.icon,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 6),
            Text(
              habit.name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: PRIMETheme.primary,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onRemove,
              child: const Icon(
                Icons.close,
                size: 14,
                color: PRIMETheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
