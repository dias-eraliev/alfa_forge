import 'package:flutter/material.dart';

/// Брутальные минималистичные иконки для целей в стиле geometric brutalism
class BrutalGoalIcons {
  /// ДЕНЬГИ - строгий геометрический символ доллара
  static Widget money({required Color color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MoneyIconPainter(color: color),
    );
  }

  /// ТЕЛО - геометрическая фигура человека
  static Widget body({required Color color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _BodyIconPainter(color: color),
    );
  }

  /// ВОЛЯ - угловатый кулак/молот
  static Widget willpower({required Color color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _WillpowerIconPainter(color: color),
    );
  }

  /// ФОКУС - острый треугольник/стрела
  static Widget focus({required Color color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _FocusIconPainter(color: color),
    );
  }

  /// РАЗУМ - геометрический чип/мозг
  static Widget mind({required Color color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _MindIconPainter(color: color),
    );
  }

  /// СПОКОЙСТВИЕ - концентрические квадраты
  static Widget peace({required Color color, double size = 24}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PeaceIconPainter(color: color),
    );
  }

  /// Получить иконку по ID цели
  static Widget getIconById(String goalId, {required Color color, double size = 24}) {
    switch (goalId) {
      case 'money_goal':
        return money(color: color, size: size);
      case 'weight_goal':
        return body(color: color, size: size);
      case 'will_goal':
        return willpower(color: color, size: size);
      case 'focus_goal':
        return focus(color: color, size: size);
      case 'mind_goal':
        return mind(color: color, size: size);
      case 'peace_goal':
        return peace(color: color, size: size);
      default:
        return money(color: color, size: size);
    }
  }
}

/// Painter для иконки денег - геометрический символ доллара
class _MoneyIconPainter extends CustomPainter {
  final Color color;

  _MoneyIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.square;

    final rect = Rect.fromLTWH(
      size.width * 0.15,
      size.height * 0.25,
      size.width * 0.7,
      size.height * 0.5,
    );

    // Квадратная рамка
    canvas.drawRect(rect, paint);

    // Вертикальная линия доллара
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.1),
      Offset(size.width * 0.5, size.height * 0.9),
      paint,
    );

    // S-образная линия
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.35)
      ..lineTo(size.width * 0.75, size.height * 0.35)
      ..moveTo(size.width * 0.25, size.height * 0.5)
      ..lineTo(size.width * 0.75, size.height * 0.5)
      ..moveTo(size.width * 0.25, size.height * 0.65)
      ..lineTo(size.width * 0.75, size.height * 0.65);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter для иконки тела - геометрический человек
class _BodyIconPainter extends CustomPainter {
  final Color color;

  _BodyIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.square;

    // Голова - квадрат
    final headRect = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.05,
      size.width * 0.3,
      size.height * 0.3,
    );
    canvas.drawRect(headRect, paint);

    // Тело - прямоугольник
    final bodyRect = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.35,
      size.width * 0.2,
      size.height * 0.4,
    );
    canvas.drawRect(bodyRect, paint);

    // Руки - линии
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.45),
      Offset(size.width * 0.15, size.height * 0.55),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.85, size.height * 0.55),
      paint,
    );

    // Ноги - линии
    canvas.drawLine(
      Offset(size.width * 0.45, size.height * 0.75),
      Offset(size.width * 0.35, size.height * 0.95),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.75),
      Offset(size.width * 0.65, size.height * 0.95),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter для иконки воли - угловатый кулак
class _WillpowerIconPainter extends CustomPainter {
  final Color color;

  _WillpowerIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.square;

    // Основание кулака
    final baseRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.6,
      size.width * 0.6,
      size.height * 0.3,
    );
    canvas.drawRect(baseRect, paint);

    // Пальцы - прямоугольники
    final fingerRects = [
      Rect.fromLTWH(size.width * 0.25, size.height * 0.3, size.width * 0.1, size.height * 0.3),
      Rect.fromLTWH(size.width * 0.4, size.height * 0.15, size.width * 0.1, size.height * 0.45),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.2, size.width * 0.1, size.height * 0.4),
      Rect.fromLTWH(size.width * 0.7, size.height * 0.35, size.width * 0.1, size.height * 0.25),
    ];

    for (final rect in fingerRects) {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter для иконки фокуса - острая стрела
class _FocusIconPainter extends CustomPainter {
  final Color color;

  _FocusIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter;

    final path = Path()
      // Основной треугольник стрелы
      ..moveTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.5, size.height * 0.1)
      ..lineTo(size.width * 0.5, size.height * 0.35)
      ..lineTo(size.width * 0.15, size.height * 0.35)
      ..lineTo(size.width * 0.15, size.height * 0.65)
      ..lineTo(size.width * 0.5, size.height * 0.65)
      ..lineTo(size.width * 0.5, size.height * 0.9)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter для иконки разума - геометрический чип
class _MindIconPainter extends CustomPainter {
  final Color color;

  _MindIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.square;

    // Основной квадрат
    final mainRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.2,
      size.width * 0.6,
      size.height * 0.6,
    );
    canvas.drawRect(mainRect, paint);

    // Внутренние схемы - сетка
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.2),
      Offset(size.width * 0.35, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.2),
      Offset(size.width * 0.5, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.2),
      Offset(size.width * 0.65, size.height * 0.8),
      paint,
    );

    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.35),
      Offset(size.width * 0.8, size.height * 0.35),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.65),
      Offset(size.width * 0.8, size.height * 0.65),
      paint,
    );

    // Внешние контакты
    final contacts = [
      [Offset(size.width * 0.05, size.height * 0.35), Offset(size.width * 0.2, size.height * 0.35)],
      [Offset(size.width * 0.05, size.height * 0.65), Offset(size.width * 0.2, size.height * 0.65)],
      [Offset(size.width * 0.8, size.height * 0.35), Offset(size.width * 0.95, size.height * 0.35)],
      [Offset(size.width * 0.8, size.height * 0.65), Offset(size.width * 0.95, size.height * 0.65)],
    ];

    for (final contact in contacts) {
      canvas.drawLine(contact[0], contact[1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter для иконки спокойствия - концентрические квадраты
class _PeaceIconPainter extends CustomPainter {
  final Color color;

  _PeaceIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.square;

    // Внешний квадрат
    final outerRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.8,
    );
    canvas.drawRect(outerRect, paint);

    // Средний квадрат
    final middleRect = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.25,
      size.width * 0.5,
      size.height * 0.5,
    );
    canvas.drawRect(middleRect, paint);

    // Внутренний квадрат
    final innerRect = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.4,
      size.width * 0.2,
      size.height * 0.2,
    );
    canvas.drawRect(innerRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
