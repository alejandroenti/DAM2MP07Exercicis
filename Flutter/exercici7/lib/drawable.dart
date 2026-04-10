import 'dart:ui' as ui;
import 'package:flutter/material.dart';

abstract class Drawable {
  void draw(Canvas canvas);
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
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  Line({
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
}

class Rectangle extends Drawable {
  final Offset topLeft;
  final Offset bottomRight;
  final Color strokeColor;
  final double strokeWidth;
  final Color? fillColor;
  final GradientInfo? gradient;

  Rectangle({
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
}

class Circle extends Drawable {
  final Offset center;
  final double radius;
  final Color strokeColor;
  final double strokeWidth;
  final Color? fillColor;
  final GradientInfo? gradient;

  Circle({
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
}

class TextElement extends Drawable {
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;
  final String fontFamily;
  final FontWeight fontWeight;
  final FontStyle fontStyle;

  TextElement({
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
}
