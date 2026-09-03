import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight;
import 'v5_image_ui.dart';

class GameHelpOverlay {
  static Rect settingsButtonRect(double w, double h) =>
      Rect.fromLTWH(w * .835, h * .020, w * .125, h * .070);
  static Rect closeRect(double w, double h) =>
      Rect.fromLTWH(w * .80, h * .065, w * .12, h * .060);

  // Hit regions follow the baked V6 artwork rather than generic screen
  // percentages.  Keeping these regions on the actual pictured controls makes
  // the invisible touch layer reliable on tall phones and prevents taps from
  // landing above the buttons.
  static Rect musicRect(double w, double h) =>
      Rect.fromLTWH(w * .60, h * .235, w * .30, h * .085);
  static Rect resetRect(double w, double h) =>
      Rect.fromLTWH(w * .095, h * .895, w * .385, h * .075);
  static Rect continueRect(double w, double h) =>
      Rect.fromLTWH(w * .520, h * .895, w * .385, h * .075);

  static void drawSettingsButton(Canvas canvas, double w, double h) {
    final r = settingsButtonRect(w, h);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(26));
    canvas.drawRRect(rr.shift(const Offset(0, 3)), Paint()..color = const Color(0x44235A8A));
    canvas.drawRRect(rr, Paint()..color = const Color(0xFFFFF8E8));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3
        ..color = const Color(0xFF2D6FB4),
    );
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

    // Fixed-art layer: use one complete picture for each BGM state.
    // No Flutter switch is drawn on top, so the art never overlaps.
    v5.drawFull(canvas, size, bgmEnabled ? v5.settingsOn : v5.settingsOff);

    // The trophy row is intentionally blank in the base picture.
    // Only tiny labels and changing values are rendered transparently.
    V5ImageUI.text(
      canvas,
      '현재 STAGE',
      Rect.fromLTWH(w * .235, h * .166, w * .22, h * .026),
      10.5,
      const Color(0xFF173F70),
      FontWeight.w800,
    );
    V5ImageUI.text(
      canvas,
      '$currentStage',
      Rect.fromLTWH(w * .285, h * .190, w * .12, h * .038),
      19,
      const Color(0xFF173F70),
      FontWeight.w900,
    );
    V5ImageUI.text(
      canvas,
      '최고',
      Rect.fromLTWH(w * .615, h * .166, w * .16, h * .026),
      10.5,
      const Color(0xFF173F70),
      FontWeight.w800,
    );
    V5ImageUI.text(
      canvas,
      bestStage == 0 ? '-' : '$bestStage',
      Rect.fromLTWH(w * .635, h * .190, w * .12, h * .038),
      19,
      const Color(0xFF173F70),
      FontWeight.w900,
    );
  }
}
