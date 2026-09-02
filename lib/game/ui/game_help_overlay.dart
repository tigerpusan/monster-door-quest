import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight;
import 'v5_image_ui.dart';
import 'responsive_game_layout.dart';

class GameHelpOverlay {
  static Rect settingsButtonRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.845, .018, .115, .068);
  }

  static Rect closeRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.805, .070, .105, .060);
  }

  static Rect musicRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.635, .232, .205, .058);
  }

  static Rect resetRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.095, .855, .39, .078);
  }

  static Rect continueRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.515, .855, .39, .078);
  }

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
    final ui = ResponsiveGameLayout(w, h);

    v5.drawFull(canvas, size, v5.settings);

    // Match the pale blue record panel and erase the baked sample values only.
    V5ImageUI.roundedCover(
      canvas,
      ui.rect(.235, .158, .585, .050),
      const Color(0xFFF2F8FE),
      radius: 14,
    );
    V5ImageUI.text(
      canvas,
      '현재 STAGE $currentStage   │   최고 ${bestStage == 0 ? '-' : bestStage}',
      ui.rect(.255, .158, .545, .050),
      15.4,
      const Color(0xFF123E73),
      FontWeight.w900,
    );

    // Match the ivory music-row background, erase the static switch, then draw one live switch.
    V5ImageUI.roundedCover(
      canvas,
      ui.rect(.635, .231, .205, .058),
      const Color(0xFFFFF7E8),
      radius: 18,
    );

    final sw = ui.rect(.682, .239, .145, .043);
    final rr = RRect.fromRectAndRadius(sw, Radius.circular(sw.height / 2));
    canvas.drawRRect(rr, Paint()..color = bgmEnabled ? const Color(0xFF75E736) : const Color(0xFFB3BBC4));
    canvas.drawRRect(rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.6..color = const Color(0xFF315B84));
    final knobRadius = sw.height * .38;
    final knobX = bgmEnabled ? sw.right - sw.height * .50 : sw.left + sw.height * .50;
    canvas.drawCircle(Offset(knobX, sw.center.dy), knobRadius, Paint()..color = const Color(0xFF154A7F));
  }

}
