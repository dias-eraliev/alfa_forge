import 'package:flutter/material.dart';
import '../models/habit_model.dart';

class HabitCard extends StatefulWidget {
  final HabitModel habit;
  final bool isSelected;
  final VoidCallback onTap;
  final Duration animationDuration;
  final int animationDelay;

  const HabitCard({
    super.key,
    required this.habit,
    required this.isSelected,
    required this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationDelay = 0,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 30),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Staggered animation с задержкой
    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  Color _getBackgroundColor() {
    if (widget.isSelected) {
      return const Color(0xFF660000);
    }
    return const Color(0xFF1A1A1A);
  }

  Color _getBorderColor() {
    if (widget.isSelected) {
      return const Color(0xFF660000);
    }
    return const Color(0xFF333333);
  }

  Color _getTextColor() {
    return const Color(0xFFE9E1D1);
  }

  List<BoxShadow>? _getBoxShadow() {
    if (widget.isSelected) {
      return [
        BoxShadow(
          color: const Color(0xFF660000).withOpacity(0.3),
          blurRadius: 8,
          spreadRadius: 1,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: _slideAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: 160,
          height: 120,
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: Border.all(
              color: _getBorderColor(),
              width: widget.isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _getBoxShadow(),
          ),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Иконка
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: widget.isSelected
                        ? BoxDecoration(
                            color: const Color(0xFFE9E1D1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          )
                        : null,
                    child: Text(
                      widget.habit.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Название
                  Text(
                    widget.habit.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: _getTextColor(),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Описание
                  Text(
                    widget.habit.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: _getTextColor().withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Виджет для отображения сетки карточек привычек
class HabitsGrid extends StatelessWidget {
  final List<HabitModel> habits;
  final List<HabitModel> selectedHabits;
  final Function(HabitModel) onHabitToggle;

  const HabitsGrid({
    super.key,
    required this.habits,
    required this.selectedHabits,
    required this.onHabitToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: habits.asMap().entries.map((entry) {
        final index = entry.key;
        final habit = entry.value;
        
        return HabitCard(
          habit: habit,
          isSelected: selectedHabits.contains(habit),
          onTap: () => onHabitToggle(habit),
          animationDelay: index * 50, // Staggered animation
        );
      }).toList(),
    );
  }
}
