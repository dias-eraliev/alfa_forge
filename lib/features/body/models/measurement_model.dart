import 'package:flutter/material.dart';

enum MeasurementCategory {
  basic('basic', 'Основные показатели', Icons.monitor_weight, Color(0xFF4FC3F7)),
  body('body', 'Объемы тела', Icons.straighten, Color(0xFF66BB6A)), 
  composition('composition', 'Композиция тела', Icons.pie_chart, Color(0xFFFF7043)),
  vital('vital', 'Витальные показатели', Icons.favorite, Color(0xFFE53E3E));

  const MeasurementCategory(this.id, this.name, this.icon, this.color);
  
  final String id;
  final String name;
  final IconData icon;
  final Color color;
}

enum MeasurementUnit {
  kg('kg', 'кг'),
  cm('cm', 'см'),
  percent('%', '%'),
  bpm('bpm', 'уд/мин'),
  mmhg('mmhg', 'мм рт.ст.'),
  celsius('celsius', '°C'),
  kcal('kcal', 'ккал');

  const MeasurementUnit(this.id, this.symbol);
  
  final String id;
  final String symbol;
}

class MeasurementType {
  final String id;
  final String name;
  final String shortName;
  final MeasurementCategory category;
  final MeasurementUnit unit;
  final double? minValue;
  final double? maxValue;
  final double? defaultValue;
  final String? description;
  final IconData icon;
  final bool isRequired;
  final bool allowsDecimal;
  final int decimalPlaces;

  const MeasurementType({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.unit,
    this.minValue,
    this.maxValue,
    this.defaultValue,
    this.description,
    required this.icon,
    this.isRequired = false,
    this.allowsDecimal = true,
    this.decimalPlaces = 1,
  });
}

class MeasurementCondition {
  final String id;
  final String name;
  final IconData icon;

  const MeasurementCondition({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class BodyMeasurement {
  final String id;
  final String typeId;
  final double value;
  final DateTime timestamp;
  final String? notes;
  final String? photoPath;
  final Map<String, String>? conditions;
  final String? mood;
  final double? confidence; // Уверенность в точности измерения (0-1)

  BodyMeasurement({
    required this.id,
    required this.typeId,
    required this.value,
    required this.timestamp,
    this.notes,
    this.photoPath,
    this.conditions,
    this.mood,
    this.confidence,
  });

  factory BodyMeasurement.create({
    required String typeId,
    required double value,
    String? notes,
    String? photoPath,
    Map<String, String>? conditions,
    String? mood,
    double? confidence,
  }) {
    return BodyMeasurement(
      id: 'measurement_${DateTime.now().millisecondsSinceEpoch}',
      typeId: typeId,
      value: value,
      timestamp: DateTime.now(),
      notes: notes,
      photoPath: photoPath,
      conditions: conditions,
      mood: mood,
      confidence: confidence,
    );
  }

  BodyMeasurement copyWith({
    String? id,
    String? typeId,
    double? value,
    DateTime? timestamp,
    String? notes,
    String? photoPath,
    Map<String, String>? conditions,
    String? mood,
    double? confidence,
  }) {
    return BodyMeasurement(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      value: value ?? this.value,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      conditions: conditions ?? this.conditions,
      mood: mood ?? this.mood,
      confidence: confidence ?? this.confidence,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'typeId': typeId,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'photoPath': photoPath,
      'conditions': conditions,
      'mood': mood,
      'confidence': confidence,
    };
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      id: json['id'],
      typeId: json['typeId'],
      value: json['value'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
      photoPath: json['photoPath'],
      conditions: json['conditions'] != null 
          ? Map<String, String>.from(json['conditions'])
          : null,
      mood: json['mood'],
      confidence: json['confidence']?.toDouble(),
    );
  }
}

// Статические данные типов измерений
class MeasurementTypes {
  static const List<MeasurementType> all = [
    // Основные показатели
    MeasurementType(
      id: 'weight',
      name: 'Вес',
      shortName: 'Вес',
      category: MeasurementCategory.basic,
      unit: MeasurementUnit.kg,
      minValue: 30,
      maxValue: 200,
      icon: Icons.monitor_weight,
      isRequired: true,
      description: 'Общая масса тела',
    ),
    MeasurementType(
      id: 'height',
      name: 'Рост',
      shortName: 'Рост',
      category: MeasurementCategory.basic,
      unit: MeasurementUnit.cm,
      minValue: 100,
      maxValue: 250,
      icon: Icons.height,
      description: 'Рост в полный рост',
    ),

    // Объемы тела
    MeasurementType(
      id: 'chest',
      name: 'Грудь/Бюст',
      shortName: 'Грудь',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 60,
      maxValue: 150,
      icon: Icons.fitness_center,
      description: 'Обхват груди/бюста',
    ),
    MeasurementType(
      id: 'waist',
      name: 'Талия',
      shortName: 'Талия',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 50,
      maxValue: 150,
      icon: Icons.straighten,
      description: 'Обхват талии в самой узкой части',
    ),
    MeasurementType(
      id: 'hips',
      name: 'Бедра',
      shortName: 'Бедра',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 60,
      maxValue: 150,
      icon: Icons.accessibility,
      description: 'Обхват бедер в самой широкой части',
    ),
    MeasurementType(
      id: 'bicep_left',
      name: 'Бицепс (левый)',
      shortName: 'Бицепс Л',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 15,
      maxValue: 60,
      icon: Icons.sports_martial_arts,
      description: 'Обхват левого бицепса в напряженном состоянии',
    ),
    MeasurementType(
      id: 'bicep_right',
      name: 'Бицепс (правый)',
      shortName: 'Бицепс П',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 15,
      maxValue: 60,
      icon: Icons.sports_martial_arts,
      description: 'Обхват правого бицепса в напряженном состоянии',
    ),
    MeasurementType(
      id: 'thigh_left',
      name: 'Бедро (левое)',
      shortName: 'Бедро Л',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 30,
      maxValue: 80,
      icon: Icons.directions_run,
      description: 'Обхват левого бедра в самой широкой части',
    ),
    MeasurementType(
      id: 'thigh_right',
      name: 'Бедро (правое)',
      shortName: 'Бедро П',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 30,
      maxValue: 80,
      icon: Icons.directions_run,
      description: 'Обхват правого бедра в самой широкой части',
    ),
    MeasurementType(
      id: 'neck',
      name: 'Шея',
      shortName: 'Шея',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 25,
      maxValue: 50,
      icon: Icons.person,
      description: 'Обхват шеи',
    ),
    MeasurementType(
      id: 'forearm_left',
      name: 'Предплечье (левое)',
      shortName: 'Предпл. Л',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 15,
      maxValue: 40,
      icon: Icons.sports_handball,
      description: 'Обхват левого предплечья',
    ),
    MeasurementType(
      id: 'forearm_right',
      name: 'Предплечье (правое)',
      shortName: 'Предпл. П',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 15,
      maxValue: 40,
      icon: Icons.sports_handball,
      description: 'Обхват правого предплечья',
    ),
    MeasurementType(
      id: 'calf_left',
      name: 'Икра (левая)',
      shortName: 'Икра Л',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 20,
      maxValue: 50,
      icon: Icons.directions_walk,
      description: 'Обхват левой икры',
    ),
    MeasurementType(
      id: 'calf_right',
      name: 'Икра (правая)',
      shortName: 'Икра П',
      category: MeasurementCategory.body,
      unit: MeasurementUnit.cm,
      minValue: 20,
      maxValue: 50,
      icon: Icons.directions_walk,
      description: 'Обхват правой икры',
    ),

    // Композиция тела
    MeasurementType(
      id: 'body_fat',
      name: 'Процент жира',
      shortName: 'Жир',
      category: MeasurementCategory.composition,
      unit: MeasurementUnit.percent,
      minValue: 3,
      maxValue: 50,
      icon: Icons.water_drop,
      description: 'Процент жировой ткани в организме',
    ),
    MeasurementType(
      id: 'muscle_mass',
      name: 'Мышечная масса',
      shortName: 'Мышцы',
      category: MeasurementCategory.composition,
      unit: MeasurementUnit.kg,
      minValue: 15,
      maxValue: 100,
      icon: Icons.fitness_center,
      description: 'Масса мышечной ткани',
    ),
    MeasurementType(
      id: 'bone_mass',
      name: 'Костная масса',
      shortName: 'Кости',
      category: MeasurementCategory.composition,
      unit: MeasurementUnit.kg,
      minValue: 1,
      maxValue: 10,
      icon: Icons.account_tree,
      description: 'Масса костной ткани',
    ),
    MeasurementType(
      id: 'water_percent',
      name: 'Вода в организме',
      shortName: 'Вода',
      category: MeasurementCategory.composition,
      unit: MeasurementUnit.percent,
      minValue: 45,
      maxValue: 75,
      icon: Icons.opacity,
      description: 'Процент воды в организме',
    ),
    MeasurementType(
      id: 'bmr',
      name: 'Базальный метаболизм',
      shortName: 'БМР',
      category: MeasurementCategory.composition,
      unit: MeasurementUnit.kcal,
      minValue: 800,
      maxValue: 3000,
      icon: Icons.local_fire_department,
      description: 'Количество калорий, сжигаемых в покое',
      allowsDecimal: false,
    ),

    // Витальные показатели
    MeasurementType(
      id: 'heart_rate',
      name: 'Пульс в покое',
      shortName: 'Пульс',
      category: MeasurementCategory.vital,
      unit: MeasurementUnit.bpm,
      minValue: 40,
      maxValue: 120,
      icon: Icons.favorite,
      description: 'Частота сердечных сокращений в покое',
      allowsDecimal: false,
    ),
    MeasurementType(
      id: 'blood_pressure_systolic',
      name: 'Давление (верхнее)',
      shortName: 'Сист.',
      category: MeasurementCategory.vital,
      unit: MeasurementUnit.mmhg,
      minValue: 80,
      maxValue: 200,
      icon: Icons.water_drop,
      description: 'Систолическое артериальное давление',
      allowsDecimal: false,
    ),
    MeasurementType(
      id: 'blood_pressure_diastolic',
      name: 'Давление (нижнее)',
      shortName: 'Диаст.',
      category: MeasurementCategory.vital,
      unit: MeasurementUnit.mmhg,
      minValue: 40,
      maxValue: 120,
      icon: Icons.water_drop,
      description: 'Диастолическое артериальное давление',
      allowsDecimal: false,
    ),
    MeasurementType(
      id: 'body_temperature',
      name: 'Температура тела',
      shortName: 'Темп.',
      category: MeasurementCategory.vital,
      unit: MeasurementUnit.celsius,
      minValue: 35,
      maxValue: 42,
      icon: Icons.thermostat,
      description: 'Температура тела',
    ),
  ];

  static List<MeasurementType> getByCategory(MeasurementCategory category) {
    return all.where((type) => type.category == category).toList();
  }

  static MeasurementType? getById(String id) {
    try {
      return all.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<MeasurementType> getRequired() {
    return all.where((type) => type.isRequired).toList();
  }

  static List<MeasurementType> getPopular() {
    // Самые популярные типы измерений
    const popularIds = ['weight', 'chest', 'waist', 'hips', 'body_fat', 'muscle_mass', 'heart_rate'];
    return popularIds.map((id) => getById(id)).where((type) => type != null).cast<MeasurementType>().toList();
  }
}

// Условия измерения
class MeasurementConditions {
  static const List<MeasurementCondition> timeOfDay = [
    MeasurementCondition(id: 'morning', name: 'Утром', icon: Icons.wb_sunny),
    MeasurementCondition(id: 'afternoon', name: 'Днем', icon: Icons.wb_sunny_outlined),
    MeasurementCondition(id: 'evening', name: 'Вечером', icon: Icons.wb_twilight),
    MeasurementCondition(id: 'night', name: 'Ночью', icon: Icons.nightlight),
  ];

  static const List<MeasurementCondition> clothing = [
    MeasurementCondition(id: 'naked', name: 'Без одежды', icon: Icons.person_outline),
    MeasurementCondition(id: 'underwear', name: 'В белье', icon: Icons.person),
    MeasurementCondition(id: 'light_clothes', name: 'Легкая одежда', icon: Icons.checkroom),
    MeasurementCondition(id: 'normal_clothes', name: 'Обычная одежда', icon: Icons.accessibility_new),
  ];

  static const List<MeasurementCondition> bodyState = [
    MeasurementCondition(id: 'fasting', name: 'Натощак', icon: Icons.no_food),
    MeasurementCondition(id: 'after_eating', name: 'После еды', icon: Icons.restaurant),
    MeasurementCondition(id: 'after_workout', name: 'После тренировки', icon: Icons.fitness_center),
    MeasurementCondition(id: 'before_workout', name: 'До тренировки', icon: Icons.sports_gymnastics),
    MeasurementCondition(id: 'relaxed', name: 'В расслабленном состоянии', icon: Icons.self_improvement),
    MeasurementCondition(id: 'tense', name: 'В напряженном состоянии', icon: Icons.sports_martial_arts),
  ];

  static const List<MeasurementCondition> mood = [
    MeasurementCondition(id: 'great', name: 'Отлично', icon: Icons.sentiment_very_satisfied),
    MeasurementCondition(id: 'good', name: 'Хорошо', icon: Icons.sentiment_satisfied),
    MeasurementCondition(id: 'normal', name: 'Нормально', icon: Icons.sentiment_neutral),
    MeasurementCondition(id: 'bad', name: 'Плохо', icon: Icons.sentiment_dissatisfied),
    MeasurementCondition(id: 'terrible', name: 'Ужасно', icon: Icons.sentiment_very_dissatisfied),
  ];
}
