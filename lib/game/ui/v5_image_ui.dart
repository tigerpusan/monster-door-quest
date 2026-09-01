import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;

class V5ImageUI {
  V5ImageUI._();

  late Sprite intro;
  late Sprite memory;
  late Sprite clear;
  late Sprite settings;
  late Sprite fail;

  static Future<V5ImageUI> load() async {
    final ui = V5ImageUI._();
    ui.intro = await Sprite.load('ui/v5/intro_template.png');
    ui.memory = await Sprite.load('ui/v5/memory_template.png');
    ui.clear = await Sprite.load('ui/v5/clear_template.png');
    ui.settings = await Sprite.load('ui/v5/settings_template.png');
    ui.fail = await Sprite.load('ui/v5/fail_template.png');
    return ui;
  }

  void drawFull(Canvas canvas, Vector2 size, Sprite sprite) {
    sprite.render(canvas, position: Vector2.zero(), size: size);
  }

  static void text(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    TextAlign align = TextAlign.center,
    double height = 1.08,
    double yOffset = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: height,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
      maxLines: null,
    )..layout(maxWidth: rect.width);
    final dx = align == TextAlign.center
        ? rect.left + (rect.width - tp.width) / 2
        : rect.left;
    final dy = rect.top + (rect.height - tp.height) / 2 + yOffset;
    tp.paint(canvas, Offset(dx, dy));
  }

  static void roundedCover(Canvas canvas, Rect rect, Color fill,
      {Color? border, double radius = 18, double stroke = 2}) {
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rr, Paint()..color = fill);
    if (border != null) {
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = border,
      );
    }
  }
}
