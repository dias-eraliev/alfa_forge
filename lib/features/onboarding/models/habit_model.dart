class HabitModel {
  final String id;
  final String name;
  final String icon;
  final String description;

  const HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      description: json['description'] as String,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Предустановленные привычки для выбора
class DefaultHabits {
  static const List<HabitModel> habits = [
    HabitModel(
      id: 'early_rise',
      name: 'Ранний подъём',
      icon: '🌅',
      description: 'Просыпаться в 6:00',
    ),
    HabitModel(
      id: 'reading',
      name: 'Чтение',
      icon: '📚',
      description: '30 минут чтения',
    ),
    HabitModel(
      id: 'workout',
      name: 'Тренировка',
      icon: '🏋️‍♂️',
      description: 'Физические упражнения',
    ),
    HabitModel(
      id: 'meditation',
      name: 'Медитация',
      icon: '🧘',
      description: '10 минут медитации',
    ),
  ];

  static HabitModel? findById(String id) {
    try {
      return habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }
}
