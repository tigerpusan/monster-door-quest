import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight;
import 'v5_image_ui.dart';

class GameHelpOverlay {
  static Rect settingsButtonRect(double w, double h) =>
      Rect.fromLTWH(w * .835, h * .020, w * .125, h * .070);
  static Rect closeRect(double w, double h) =>
      Rect.fromLTWH(w * .80, h * .055, w * .12, h * .070);
  static Rect musicRect(double w, double h) =>
      Rect.fromLTWH(w * .10, h * .205, w * .80, h * .075);
  static Rect resetRect(double w, double h) =>
      Rect.fromLTWH(w * .095, h * .845, w * .39, h * .085);
  static Rect continueRect(double w, double h) =>
      Rect.fromLTWH(w * .515, h * .845, w * .39, h * .085);

  static void drawSettingsButton(Canvas canvas, double w, double h) {
    final r = settingsButtonRect(w, h);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(26));
    canvas.drawRRect(rr.shift(const Offset(0, 3)), Paint()..color = const Color(0x44235A8A));
    canvas.drawRRect(rr, Paint()..color = const Color(0xFFFFF8E8));
    canvas.drawRRect(rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.3..color = const Color(0xFF2D6FB4));
    V5ImageUI.text(canvas, '⚙', r, 23, const Color(0xFF2D6FB4), FontWeight.w900);
  }

  static void draw(
    Canvas canvas,
    double w,
    double h, {
    required int currentStage,
    required int bestStage,
    required bool bgmEnabled,
    required V5ImageUI v5,
  }) {
    final size = Vector2(w, h);
    v5.drawFull(canvas, size, v5.settings);

    // Cover the baked-in sample record line and redraw live values.
    final record = Rect.fromLTWH(w * .14, h * .145, w * .72, h * .055);
    V5ImageUI.roundedCover(
      canvas,
      record,
      const Color(0xFFF7FCFF),
      border: const Color(0xFF2D6FB4),
      radius: 18,
      stroke: 1.5,
    );
    V5ImageUI.text(
      canvas,
      '🏆  현재 STAGE $currentStage   │   최고 ${bestStage == 0 ? '-' : bestStage}',
      record,
      14.2,
      const Color(0xFF123E73),
      FontWeight.w900,
    );

    // Live BGM switch. The entire row remains tappable.
    final sw = Rect.fromLTWH(w * .695, h * .222, w * .145, h * .047);
    final rr = RRect.fromRectAndRadius(sw, Radius.circular(sw.height / 2));
    canvas.drawRRect(
      rr,
      Paint()..color = bgmEnabled ? const Color(0xFF75E736) : const Color(0xFF9BA7B5),
    );
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF315B84),
    );
    final knobRadius = sw.height * .38;
    final knobX = bgmEnabled ? sw.right - sw.height * .50 : sw.left + sw.height * .50;
    canvas.drawCircle(
      Offset(knobX, sw.center.dy),
      knobRadius,
      Paint()..color = const Color(0xFF154A7F),
    );
  }
}
