import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight, TextAlign;
import 'v5_image_ui.dart';
import 'responsive_game_layout.dart';

class GameHelpOverlay {
  static Rect settingsButtonRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.845, .018, .115, .068);
  }

  static Rect closeRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.80, .055, .12, .070);
  }

  static Rect musicRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.105, .270, .79, .068);
  }

  static Rect resetRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.095, .845, .39, .085);
  }

  static Rect continueRect(double w, double h) {
    final ui = ResponsiveGameLayout(w, h);
    return ui.rect(.515, .845, .39, .085);
  }

  static void drawSettingsButton(Canvas canvas, double w, double h) {
    final r = settingsButtonRect(w, h);
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(26));
    canvas.drawRRect(
      rr.shift(const Offset(0, 3)),
      Paint()..color = const Color(0x44235A8A),
    );
    canvas.drawRRect(rr, Paint()..color = const Color(0xFFFFF8E8));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.3
        ..color = const Color(0xFF2D6FB4),
    );
    V5ImageUI.text(
      canvas,
      '⚙',
      r,
      23,
      const Color(0xFF2D6FB4),
      FontWeight.w900,
    );
  }

  static void _panel(
    Canvas canvas,
    Rect rect, {
    required Color fill,
    required Color border,
    required Color tabColor,
    required String title,
    required String icon,
  }) {
    V5ImageUI.roundedCover(
      canvas,
      rect,
      fill,
      border: border,
      radius: 20,
      stroke: 2,
    );

    final tab = Rect.fromLTWH(
      rect.left + rect.width * .035,
      rect.top + rect.height * .055,
      rect.width * .46,
      rect.height * .22,
    );
    V5ImageUI.roundedCover(
      canvas,
      tab,
      tabColor,
      radius: 13,
    );
    V5ImageUI.text(
      canvas,
      '$icon  $title',
      tab,
      rect.height * .095,
      const Color(0xFFFFFFFF),
      FontWeight.w900,
    );
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

    // V5.2: cover the complete dynamic body of the generated concept image.
    // This removes all baked sample text/controls before runtime UI is drawn.
    final body = ui.rect(.055, .118, .89, .710);
    V5ImageUI.roundedCover(
      canvas,
      body,
      const Color(0xFFFFFAEC),
      border: const Color(0xFF2D6FB4),
      radius: 26,
      stroke: 2.0,
    );

    V5ImageUI.text(
      canvas,
      '⚙  게임 설정',
      ui.rect(.20, .125, .60, .060),
      26,
      const Color(0xFF173F70),
      FontWeight.w900,
    );

    final record = ui.rect(.105, .190, .79, .068);
    V5ImageUI.roundedCover(
      canvas,
      record,
      const Color(0xFFF7FCFF),
      border: const Color(0xFF2D6FB4),
      radius: 18,
      stroke: 1.7,
    );
    V5ImageUI.text(
      canvas,
      '🏆  현재 STAGE $currentStage   │   최고 ${bestStage == 0 ? '-' : bestStage}',
      record,
      14.5,
      const Color(0xFF123E73),
      FontWeight.w900,
    );

    final musicRow = ui.rect(.105, .270, .79, .068);
    V5ImageUI.roundedCover(
      canvas,
      musicRow,
      const Color(0xFFF7FCFF),
      border: const Color(0xFF2D6FB4),
      radius: 18,
      stroke: 1.7,
    );
    V5ImageUI.text(
      canvas,
      '♪  배경음악',
      ui.rect(.145, .277, .37, .050),
      17,
      const Color(0xFF173F70),
      FontWeight.w900,
      align: TextAlign.left,
    );
    final sw = ui.rect(.695, .281, .145, .043);
    final rr = RRect.fromRectAndRadius(sw, Radius.circular(sw.height / 2));
    canvas.drawRRect(rr, Paint()..color = bgmEnabled ? const Color(0xFF75E736) : const Color(0xFF9BA7B5));
    canvas.drawRRect(rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.6..color = const Color(0xFF315B84));
    final knobRadius = sw.height * .38;
    final knobX = bgmEnabled ? sw.right - sw.height * .50 : sw.left + sw.height * .50;
    canvas.drawCircle(Offset(knobX, sw.center.dy), knobRadius, Paint()..color = const Color(0xFF154A7F));

    final how = ui.rect(.10, .355, .80, .150);
    _panel(canvas, how, fill: const Color(0xFFF1F8FF), border: const Color(0xFF4F8CC9), tabColor: const Color(0xFF347CCB), title: '게임 방법', icon: '🎮');
    V5ImageUI.text(
      canvas,
      '1  문 순서를 기억합니다\n2  같은 순서로 선택합니다\n3  성공하면 다음 스테이지로 이동합니다',
      ui.rect(.145, .399, .70, .092),
      12.3,
      const Color(0xFF173F70),
      FontWeight.w800,
      align: TextAlign.left,
      height: 1.34,
    );

    final stage = ui.rect(.10, .520, .80, .180);
    _panel(canvas, stage, fill: const Color(0xFFFFFCE8), border: const Color(0xFF6AAF4B), tabColor: const Color(0xFF4CA83A), title: '단계 안내', icon: '🗺️');
    V5ImageUI.text(
      canvas,
      '①  인간의 영역  I · II · III\n②  초인의 영역  I · II · III\n③  신의 영역',
      ui.rect(.145, .575, .68, .100),
      13.0,
      const Color(0xFF285B3B),
      FontWeight.w900,
      align: TextAlign.left,
      height: 1.46,
    );

    final fail = ui.rect(.10, .715, .80, .110);
    _panel(canvas, fail, fill: const Color(0xFFFFF2EF), border: const Color(0xFFD5685B), tabColor: const Color(0xFFE35B49), title: '실패 규칙', icon: '💥');
    V5ImageUI.text(
      canvas,
      '실패하면 두 단계 전으로 돌아가 다시 도전합니다.',
      ui.rect(.145, .755, .68, .052),
      12.6,
      const Color(0xFF6E2E28),
      FontWeight.w900,
      align: TextAlign.left,
      height: 1.30,
    );

    // Bottom buttons are still provided by the concept image; only their hit
    // zones are active. The body cover stops above them.
  }

}
