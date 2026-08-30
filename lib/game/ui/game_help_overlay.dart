import 'dart:ui';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;

/// Shared settings/help overlay used by all game scenes.
/// Keeping the geometry here prevents scene-by-scene drift and overlap bugs.
class GameHelpOverlay {
  static Rect settingsButtonRect(double w, double h) =>
      Rect.fromLTWH(w * .775, h * .020, w * .17, h * .060);
  static Rect closeRect(double w, double h) =>
      Rect.fromLTWH(w * .80, h * .135, w * .09, h * .050);
  static Rect continueRect(double w, double h, {required bool showHome}) => showHome
      ? Rect.fromLTWH(w * .15, h * .790, w * .32, h * .060)
      : Rect.fromLTWH(w * .34, h * .790, w * .32, h * .060);
  static Rect homeRect(double w, double h) =>
      Rect.fromLTWH(w * .53, h * .790, w * .32, h * .060);

  static void _drawText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    TextAlign align = TextAlign.center,
    double height = 1.20,
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

  static void drawSettingsButton(Canvas canvas, double w, double h) {
    final rect = settingsButtonRect(w, h);
    final box = RRect.fromRectAndRadius(rect, const Radius.circular(22));
    canvas.drawRRect(box, Paint()..color = const Color(0xDE16082F));
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xCCFFD86D),
    );
    // The gear glyph has a low visual baseline, so use a small optical lift.
    final gearRect = rect.translate(0, -2.5);
    _drawText(canvas, '⚙', gearRect, 21, const Color(0xFFFFEDB1), FontWeight.w900);
  }

  static void draw(
    Canvas canvas,
    double w,
    double h, {
    required bool showHome,
  }) {
    // Dim the scene, then cover the actual help region with a nearly opaque panel.
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xB8000000));

    final panelRect = Rect.fromLTWH(w * .07, h * .105, w * .86, h * .770);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(28));
    canvas.drawRRect(panel, Paint()..color = const Color(0xFC1D0D41));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xCCFFD86D),
    );

    _drawText(
      canvas,
      '설정',
      Rect.fromLTWH(w * .20, h * .130, w * .60, h * .050),
      25,
      const Color(0xFFFFDD7A),
      FontWeight.w900,
    );
    _drawText(
      canvas,
      '✕',
      Rect.fromLTWH(w * .80, h * .135, w * .09, h * .050),
      20,
      const Color(0xFFFFEDB1),
      FontWeight.w900,
    );

    // No separate "스토리" label: just the two-line premise.
    _drawText(
      canvas,
      '몬스터에게 납치된 공주를 구하세요.\n비밀의 문 순서를 기억하며 끝까지 전진합니다.',
      Rect.fromLTWH(w * .14, h * .205, w * .72, h * .085),
      14.2,
      const Color(0xFFFFFFFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.34,
    );

    _drawText(
      canvas,
      '게임 방법',
      Rect.fromLTWH(w * .14, h * .305, w * .72, h * .030),
      15.2,
      const Color(0xFFFFE39A),
      FontWeight.w900,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      '1) 문 순서를 기억합니다\n2) 같은 순서로 문을 선택합니다\n3) 성공하면 다음 스테이지로 이동합니다',
      Rect.fromLTWH(w * .14, h * .338, w * .72, h * .120),
      13.7,
      const Color(0xFFFFF2C7),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.36,
    );

    _drawText(
      canvas,
      '단계 안내',
      Rect.fromLTWH(w * .14, h * .475, w * .72, h * .030),
      15.2,
      const Color(0xFFFFE39A),
      FontWeight.w900,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      '인간 I~III  ·  좌우 문 순서 기억\n초인  ·  더 긴 순서와 복합 규칙\n기록  ·  집중력 한계 도전\n신  ·  최종 기억 관문',
      Rect.fromLTWH(w * .14, h * .508, w * .72, h * .135),
      13.5,
      const Color(0xFFE8DDFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.36,
    );

    _drawText(
      canvas,
      '실패 규칙',
      Rect.fromLTWH(w * .14, h * .665, w * .72, h * .030),
      15.2,
      const Color(0xFFFFD98D),
      FontWeight.w900,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      '다시 도전하면 기본적으로 두 단계 전으로 돌아갑니다.',
      Rect.fromLTWH(w * .14, h * .698, w * .72, h * .050),
      13.4,
      const Color(0xFFFFE5B7),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.30,
    );

    final contRect = continueRect(w, h, showHome: showHome);
    final contBox = RRect.fromRectAndRadius(contRect, const Radius.circular(24));
    canvas.drawRRect(contBox, Paint()..color = const Color(0xFF7EEB42));
    canvas.drawRRect(
      contBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = const Color(0xFFFFFFFF),
    );
    _drawText(
      canvas,
      showHome ? '계속하기' : '닫기',
      contRect,
      18,
      const Color(0xFF102408),
      FontWeight.w900,
    );

    if (showHome) {
      final hRect = homeRect(w, h);
      final hBox = RRect.fromRectAndRadius(hRect, const Radius.circular(24));
      canvas.drawRRect(hBox, Paint()..color = const Color(0xFF45206A));
      canvas.drawRRect(
        hBox,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..color = const Color(0xCCFFD86D),
      );
      _drawText(canvas, '처음 화면', hRect, 17, const Color(0xFFFFEDB1), FontWeight.w900);
    }
  }
}
