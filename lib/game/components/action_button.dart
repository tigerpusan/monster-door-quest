import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show TextPainter, TextSpan, TextStyle, TextDirection, FontWeight, LinearGradient, Alignment;

class ActionButton extends PositionComponent with TapCallbacks {
  ActionButton({required this.label, required this.onPressed, this.green = true});

  final String label;
  final void Function() onPressed;
  final bool green;

  @override
  void onTapDown(TapDownEvent event) {
    scale = Vector2.all(.985);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    scale = Vector2.all(1);
  }

  @override
  void onTapUp(TapUpEvent event) {
    scale = Vector2.all(1);
    onPressed();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final rect = RRect.fromRectAndRadius(size.toRect(), const Radius.circular(24));
    final shadowRect = rect.shift(const Offset(0, 8));
    canvas.drawRRect(shadowRect, Paint()..color = const Color(0x66000000));
    canvas.drawRRect(
      rect,
      Paint()
        ..shader = (green
                ? const LinearGradient(colors: [Color(0xFF9AF35B), Color(0xFF6EDB38)])
                : const LinearGradient(colors: [Color(0xFF412063), Color(0xFF23113D)]))
            .createShader(size.toRect()),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = green ? const Color(0xCCFFFFFF) : const Color(0x66D3B8FF),
    );
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: green ? const Color(0xFF10220B) : const Color(0xFFFFFFFF),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, (size.y - tp.height) / 2));
  }
}
