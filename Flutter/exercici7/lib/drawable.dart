import 'dart:ui' as ui;
import 'package:flutter/material.dart';

abstract class Drawable {
  final int id;
  bool isSelected;

  Drawable({required this.id, this.isSelected = false});

  void draw(Canvas canvas);
  void drawSelectionHighlight(Canvas canvas);
  bool hitTest(Offset point);
  Drawable copyWith();
}

/// Tipus de gradient disponibles
enum GradientType { linear, radial }

/// Informació de gradient per a emplenats
class GradientInfo {
  final GradientType type;
  final List<Color> colors;

  GradientInfo({required this.type, required this.colors});
}

class Line extends Drawable {
  Offset start;
  Offset end;
  Color color;
  double strokeWidth;

  Line({
    required super.id,
    required this.start,
    required this.end,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
  });

  @override
  void draw(Canvas canvas) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }

  @override
  void drawSelectionHighlight(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue.withAlpha(100)
      ..strokeWidth = strokeWidth + 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }

  @override
  bool hitTest(Offset point) {
    const threshold = 8.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final lengthSq = dx * dx + dy * dy;
    if (lengthSq == 0) return (point - start).distance <= threshold;
    var t = ((point.dx - start.dx) * dx + (point.dy - start.dy) * dy) / lengthSq;
    t = t.clamp(0.0, 1.0);
    final projection = Offset(start.dx + t * dx, start.dy + t * dy);
    return (point - projection).distance <= threshold;
  }

  @override
  Line copyWith() => Line(id: id, start: start, end: end, color: color, strokeWidth: strokeWidth);
}

class Rectangle extends Drawable {
  Offset topLeft;
  Offset bottomRight;
  Color strokeColor;
  double strokeWidth;
  Color? fillColor;
  GradientInfo? gradient;

  Rectangle({
    required super.id,
    required this.topLeft,
    required this.bottomRight,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
    this.fillColor,
    this.gradient,
  });

  @override
  void draw(Canvas canvas) {
    final rect = Rect.fromPoints(topLeft, bottomRight);

    // Emplenat
    if (gradient != null && gradient!.colors.length >= 2) {
      final fillPaint = Paint()..style = PaintingStyle.fill;
      if (gradient!.type == GradientType.radial) {
        fillPaint.shader = ui.Gradient.radial(
          rect.center,
          rect.longestSide / 2,
          gradient!.colors,
        );
      } else {
        fillPaint.shader = ui.Gradient.linear(
          rect.topLeft,
          rect.bottomRight,
          gradient!.colors,
        );
      }
      canvas.drawRect(rect, fillPaint);
    } else if (fillColor != null) {
      final fillPaint = Paint()
        ..color = fillColor!
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, fillPaint);
    }

    // Contorn
    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, strokePaint);
  }

  @override
  void drawSelectionHighlight(Canvas canvas) {
    final rect = Rect.fromPoints(topLeft, bottomRight).inflate(4);
    final paint = Paint()
      ..color = Colors.blue.withAlpha(100)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  @override
  bool hitTest(Offset point) {
    final rect = Rect.fromPoints(topLeft, bottomRight);
    return rect.inflate(6).contains(point);
  }

  @override
  Rectangle copyWith() => Rectangle(
    id: id, topLeft: topLeft, bottomRight: bottomRight,
    strokeColor: strokeColor, strokeWidth: strokeWidth,
    fillColor: fillColor, gradient: gradient,
  );
}

class Circle extends Drawable {
  Offset center;
  double radius;
  Color strokeColor;
  double strokeWidth;
  Color? fillColor;
  GradientInfo? gradient;

  Circle({
    required super.id,
    required this.center,
    required this.radius,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
    this.fillColor,
    this.gradient,
  });

  @override
  void draw(Canvas canvas) {
    // Emplenat
    if (gradient != null && gradient!.colors.length >= 2) {
      final fillPaint = Paint()..style = PaintingStyle.fill;
      if (gradient!.type == GradientType.radial) {
        fillPaint.shader = ui.Gradient.radial(
          center,
          radius,
          gradient!.colors,
        );
      } else {
        fillPaint.shader = ui.Gradient.linear(
          Offset(center.dx - radius, center.dy),
          Offset(center.dx + radius, center.dy),
          gradient!.colors,
        );
      }
      canvas.drawCircle(center, radius, fillPaint);
    } else if (fillColor != null) {
      final fillPaint = Paint()
        ..color = fillColor!
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fillPaint);
    }

    // Contorn
    final strokePaint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, strokePaint);
  }

  @override
  void drawSelectionHighlight(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.blue.withAlpha(100)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius + 4, paint);
  }

  @override
  bool hitTest(Offset point) {
    return (point - center).distance <= radius + 6;
  }

  @override
  Circle copyWith() => Circle(
    id: id, center: center, radius: radius,
    strokeColor: strokeColor, strokeWidth: strokeWidth,
    fillColor: fillColor, gradient: gradient,
  );
}

class TextElement extends Drawable {
  String text;
  Offset position;
  Color color;
  double fontSize;
  String fontFamily;
  FontWeight fontWeight;
  FontStyle fontStyle;

  TextElement({
    required super.id,
    required this.text,
    required this.position,
    this.color = Colors.black,
    this.fontSize = 14.0,
    this.fontFamily = 'Roboto',
    this.fontWeight = FontWeight.normal,
    this.fontStyle = FontStyle.normal,
  });

  @override
  void draw(Canvas canvas) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
    );
    final textSpan = TextSpan(
      text: text,
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  void drawSelectionHighlight(Canvas canvas) {
    final textStyle = TextStyle(fontSize: fontSize, fontFamily: fontFamily, fontWeight: fontWeight, fontStyle: fontStyle);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    final rect = Rect.fromLTWH(position.dx - 2, position.dy - 2, textPainter.width + 4, textPainter.height + 4);
    final paint = Paint()
      ..color = Colors.blue.withAlpha(100)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  @override
  bool hitTest(Offset point) {
    final textStyle = TextStyle(fontSize: fontSize, fontFamily: fontFamily, fontWeight: fontWeight, fontStyle: fontStyle);
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    textPainter.layout();
    final rect = Rect.fromLTWH(position.dx, position.dy, textPainter.width, textPainter.height);
    return rect.inflate(4).contains(point);
  }

  @override
  TextElement copyWith() => TextElement(
    id: id, text: text, position: position, color: color,
    fontSize: fontSize, fontFamily: fontFamily,
    fontWeight: fontWeight, fontStyle: fontStyle,
  );
}
