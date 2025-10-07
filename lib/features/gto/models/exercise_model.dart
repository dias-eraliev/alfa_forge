class ExerciseType {
  static const String pushups = 'pushups';
  static const String squats = 'squats';
  static const String burpees = 'burpees';
  static const String plank = 'plank';
  static const String jumpingJacks = 'jumping_jacks';
}

class Exercise {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String difficulty;
  final List<String> instructions;
  final Map<String, String> tips;

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.difficulty,
    required this.instructions,
    required this.tips,
  });

  static const List<Exercise> availableExercises = [
    // PUSH UPS
    Exercise(
      id: ExerciseType.pushups,
      name: 'Отжимания',
      description: 'Классические отжимания от пола',
      icon: '💪',
      difficulty: 'Средний',
      instructions: [
        'Примите упор лежа',
        'Руки на ширине плеч',
        'Опускайтесь до касания грудью пола',
        'Поднимайтесь в исходное положение',
      ],
      tips: {
        'correct': 'Отлично! Полная амплитуда!',
        'too_fast': 'Медленнее! Контролируйте движение!',
        'too_shallow': 'Ниже! Касайтесь грудью пола!',
        'bad_form': 'Держите корпус прямо!',
        'good_pace': 'Идеальный темп!',
      },
    ),
    // SQUATS
    Exercise(
      id: ExerciseType.squats,
      name: 'Приседания',
      description: 'Глубокие приседания',
      icon: '🦵',
      difficulty: 'Легкий',
      instructions: [
        'Встаньте прямо, ноги на ширине плеч',
        'Опускайтесь, отводя таз назад',
        'Бедра параллельно полу',
        'Поднимайтесь в исходное положение',
      ],
      tips: {
        'correct': 'Превосходно! Глубокий присед!',
        'too_fast': 'Быстрее! Держите темп!',
        'too_shallow': 'Глубже! Бедра параллельно полу!',
        'bad_form': 'Спина прямая, колени не заворачивайте!',
        'good_pace': 'Отличный ритм!',
      },
    ),
    // BURPEES
    Exercise(
      id: ExerciseType.burpees,
      name: 'Берпи',
      description: 'Комплексное упражнение',
      icon: '⭐',
      difficulty: 'Сложный',
      instructions: [
        'Присядьте, руки на пол',
        'Прыжком ноги назад в планку',
        'Отжимание (опционально)',
        'Прыжком ноги к рукам',
        'Выпрыгивание вверх с хлопком',
      ],
      tips: {
        'correct': 'Невероятно! Идеальное берпи!',
        'too_fast': 'Контролируйте каждую фазу!',
        'incomplete': 'Выполните все этапы!',
        'bad_form': 'Четче переходы между позициями!',
        'good_pace': 'Мощно! Продолжайте!',
      },
    ),
    // PLANK
    Exercise(
      id: ExerciseType.plank,
      name: 'Планка',
      description: 'Изометрическое удержание корпуса',
      icon: '🧱',
      difficulty: 'Средний',
      instructions: [
        'Локти под плечами',
        'Корпус прямой, без прогиба',
        'Не поднимайте таз высоко',
      ],
      tips: {
        'correct': 'Идеальное удержание!',
        'hips_low': 'Поднимите таз немного',
        'hips_high': 'Опустите таз и выровняйтесь',
        'bad_form': 'Сохраняйте прямую линию корпуса',
        'good_pace': 'Отлично держите!',
      },
    ),
    // JUMPING JACKS
    Exercise(
      id: ExerciseType.jumpingJacks,
      name: 'Прыжки ⭐',
      description: 'Прыжки "звездочка"',
      icon: '✨',
      difficulty: 'Легкий',
      instructions: [
        'Старт стоя, ноги вместе, руки вдоль тела',
        'Прыжок — ноги в стороны, руки вверх',
        'Прыжок — вернуться в старт',
      ],
      tips: {
        'correct': 'Хорошая амплитуда!',
        'too_fast': 'Держите стабильный ритм',
        'low_arms': 'Выше руки!',
        'narrow_legs': 'Шире ноги!',
        'good_pace': 'Отличный темп!',
      },
    ),
  ];

  static Exercise? getById(String id) {
    try {
      return availableExercises.firstWhere((exercise) => exercise.id == id);
    } catch (e) {
      return null;
    }
  }
}

class ExercisePlan {
  final String exerciseId;
  final int targetReps;
  final bool completed;
  final int completedReps;
  final double averageQuality;

  const ExercisePlan({
    required this.exerciseId,
    required this.targetReps,
    this.completed = false,
    this.completedReps = 0,
    this.averageQuality = 0.0,
  });

  ExercisePlan copyWith({
    String? exerciseId,
    int? targetReps,
    bool? completed,
    int? completedReps,
    double? averageQuality,
  }) {
    return ExercisePlan(
      exerciseId: exerciseId ?? this.exerciseId,
      targetReps: targetReps ?? this.targetReps,
      completed: completed ?? this.completed,
      completedReps: completedReps ?? this.completedReps,
      averageQuality: averageQuality ?? this.averageQuality,
    );
  }

  Exercise? get exercise => Exercise.getById(exerciseId);
  
  double get progress => completedReps / targetReps;
  
  bool get isCompleted => completedReps >= targetReps;
  
  String get progressText => '$completedReps / $targetReps';
}

class AIDetectionResult {
  final bool isGoodForm;
  final bool isAverageForm;
  final int qualityPercentage;
  final String feedback;
  final String phase;
  final int repetitionCount;

  const AIDetectionResult({
    required this.isGoodForm,
    required this.isAverageForm,
    required this.qualityPercentage,
    required this.feedback,
    required this.phase,
    required this.repetitionCount,
  });

  AIDetectionResult copyWith({
    bool? isGoodForm,
    bool? isAverageForm,
    int? qualityPercentage,
    String? feedback,
    String? phase,
    int? repetitionCount,
  }) {
    return AIDetectionResult(
      isGoodForm: isGoodForm ?? this.isGoodForm,
      isAverageForm: isAverageForm ?? this.isAverageForm,
      qualityPercentage: qualityPercentage ?? this.qualityPercentage,
      feedback: feedback ?? this.feedback,
      phase: phase ?? this.phase,
      repetitionCount: repetitionCount ?? this.repetitionCount,
    );
  }
}
