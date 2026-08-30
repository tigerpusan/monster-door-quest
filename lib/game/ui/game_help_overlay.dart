import 'dart:ui';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;

/// Full-screen game-style settings panel.
/// The scene behind it is intentionally covered completely so no background UI
/// can bleed through or overlap the settings text.
class GameHelpOverlay {
  static Rect settingsButtonRect(double w, double h) =>
      Rect.fromLTWH(w * .805, h * .022, w * .145, h * .060);
  static Rect closeRect(double w, double h) =>
      Rect.fromLTWH(w * .82, h * .090, w * .09, h * .050);
  static Rect musicRect(double w, double h) =>
      Rect.fromLTWH(w * .14, h * .245, w * .72, h * .060);
  static Rect resetRect(double w, double h) =>
      Rect.fromLTWH(w * .13, h * .812, w * .35, h * .062);
  static Rect continueRect(double w, double h) =>
      Rect.fromLTWH(w * .52, h * .812, w * .35, h * .062);

  static void _drawText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    TextAlign align = TextAlign.center,
    double height = 1.18,
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
    )..layout(maxWidth: rect.width);
    final dx = align == TextAlign.center
        ? rect.left + (rect.width - tp.width) / 2
        : rect.left;
    final dy = rect.top + (rect.height - tp.height) / 2;
    tp.paint(canvas, Offset(dx, dy));
  }

  static void _card(Canvas canvas, Rect rect, {Color? fill}) {
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(20));
    canvas.drawRRect(rr, Paint()..color = fill ?? const Color(0xFF28104E));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0x99FFD86D),
    );
  }

  static void drawSettingsButton(Canvas canvas, double w, double h) {
    final rect = settingsButtonRect(w, h);
    final box = RRect.fromRectAndRadius(rect, const Radius.circular(22));
    canvas.drawRRect(box, Paint()..color = const Color(0xEE180832));
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xDDFFD86D),
    );
    _drawText(
      canvas,
      '⚙',
      rect.translate(0, -2),
      21,
      const Color(0xFFFFEDB1),
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
  }) {
    // Fully opaque base: prevents the title/doors/buttons from the game scene
    // showing through the settings screen.
    final bg = Paint()
      ..shader = Gradient.linear(
        const Offset(0, 0),
        Offset(0, h),
        const [Color(0xFF100722), Color(0xFF1B0A3B), Color(0xFF0C061B)],
        const [0.0, .55, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    final panelRect = Rect.fromLTWH(w * .055, h * .065, w * .89, h * .845);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(30));
    canvas.drawRRect(panel, Paint()..color = const Color(0xFF1D0B40));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xDDFFD86D),
    );
    canvas.drawRRect(
      panel.deflate(9),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0x33FFFFFF),
    );

    _drawText(
      canvas,
      '⚙  설정',
      Rect.fromLTWH(w * .20, h * .088, w * .60, h * .050),
      24,
      const Color(0xFFFFDD78),
      FontWeight.w900,
    );
    _drawText(
      canvas,
      '✕',
      closeRect(w, h),
      20,
      const Color(0xFFFFF0BC),
      FontWeight.w900,
    );

    final record = Rect.fromLTWH(w * .12, h * .155, w * .76, h * .070);
    _card(canvas, record, fill: const Color(0xFF32145C));
    _drawText(
      canvas,
      '현재 STAGE $currentStage     ★ 최고 STAGE ${bestStage == 0 ? '-' : bestStage}',
      record,
      14.2,
      const Color(0xFFFFEDB1),
      FontWeight.w900,
    );

    final music = musicRect(w, h);
    _card(canvas, music, fill: const Color(0xFF241149));
    _drawText(
      canvas,
      '♫  배경음악',
      Rect.fromLTWH(music.left + 18, music.top, music.width * .55, music.height),
      15.5,
      const Color(0xFFFFFFFF),
      FontWeight.w800,
      align: TextAlign.left,
    );
    final sw = Rect.fromLTWH(music.right - 78, music.top + 11, 58, music.height - 22);
    final swBox = RRect.fromRectAndRadius(sw, Radius.circular(sw.height / 2));
    canvas.drawRRect(
      swBox,
      Paint()..color = bgmEnabled ? const Color(0xFF74E63C) : const Color(0xFF4A3A60),
    );
    final knobX = bgmEnabled ? sw.right - sw.height / 2 : sw.left + sw.height / 2;
    canvas.drawCircle(
      Offset(knobX, sw.center.dy),
      sw.height * .34,
      Paint()..color = const Color(0xFFFFFFFF),
    );

    final how = Rect.fromLTWH(w * .12, h * .330, w * .76, h * .130);
    _card(canvas, how);
    _drawText(
      canvas,
      '게임 방법',
      Rect.fromLTWH(how.left + 16, how.top + 9, how.width - 32, 26),
      15.5,
      const Color(0xFFFFE08B),
      FontWeight.w900,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      '① 순서를 기억한다   ② 같은 순서로 문을 연다\n③ 성공하면 다음 스테이지로 전진한다',
      Rect.fromLTWH(how.left + 16, how.top + 40, how.width - 32, how.height - 49),
      13.3,
      const Color(0xFFF4EEFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.34,
    );

    final level = Rect.fromLTWH(w * .12, h * .480, w * .76, h * .185);
    _card(canvas, level);
    _drawText(
      canvas,
      '단계 안내',
      Rect.fromLTWH(level.left + 16, level.top + 9, level.width - 32, 26),
      15.5,
      const Color(0xFFFFE08B),
      FontWeight.w900,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      '인간 I~III  ·  좌우 문 순서 기억\n초인  ·  더 긴 순서와 복합 규칙\n기록  ·  집중력 한계 도전\n신  ·  최종 기억 관문',
      Rect.fromLTWH(level.left + 16, level.top + 39, level.width - 32, level.height - 48),
      13.1,
      const Color(0xFFE8DDFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.33,
    );

    final fail = Rect.fromLTWH(w * .12, h * .685, w * .76, h * .095);
    _card(canvas, fail, fill: const Color(0xFF301343));
    _drawText(
      canvas,
      '실패 규칙',
      Rect.fromLTWH(fail.left + 16, fail.top + 8, fail.width - 32, 24),
      15.0,
      const Color(0xFFFFD18A),
      FontWeight.w900,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      '실패하면 두 단계 전으로 돌아가 다시 도전합니다.',
      Rect.fromLTWH(fail.left + 16, fail.top + 35, fail.width - 32, fail.height - 42),
      12.8,
      const Color(0xFFFFE8C2),
      FontWeight.w700,
      align: TextAlign.left,
    );

    final reset = resetRect(w, h);
    final resetBox = RRect.fromRectAndRadius(reset, const Radius.circular(24));
    canvas.drawRRect(resetBox, Paint()..color = const Color(0xFF5B2A75));
    canvas.drawRRect(
      resetBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xCCFFD86D),
    );
    _drawText(canvas, '↺ 도전 리셋', reset, 16.5, const Color(0xFFFFEDB1), FontWeight.w900);

    final cont = continueRect(w, h);
    final contBox = RRect.fromRectAndRadius(cont, const Radius.circular(24));
    canvas.drawRRect(contBox, Paint()..color = const Color(0xFF7EEB42));
    canvas.drawRRect(
      contBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xFFFFFFFF),
    );
    _drawText(canvas, '닫기', cont, 18, const Color(0xFF102408), FontWeight.w900);

    _drawText(
      canvas,
      '도전 리셋: 진행 기록만 STAGE 3부터 다시 시작합니다.',
      Rect.fromLTWH(w * .14, h * .882, w * .72, h * .020),
      9.3,
      const Color(0xFFBDAED8),
      FontWeight.w600,
    );
  }
}
