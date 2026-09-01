import 'dart:ui';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;

/// Full-screen game-style settings panel.
/// The scene behind it is intentionally covered completely so no background UI
/// can bleed through or overlap the settings text.
class GameHelpOverlay {
  static Rect settingsButtonRect(double w, double h) =>
      Rect.fromLTWH(w * .815, h * .024, w * .135, h * .057);
  static Rect closeRect(double w, double h) =>
      Rect.fromLTWH(w * .82, h * .080, w * .09, h * .050);
  static Rect musicRect(double w, double h) =>
      Rect.fromLTWH(w * .12, h * .238, w * .76, h * .064);
  static Rect resetRect(double w, double h) =>
      Rect.fromLTWH(w * .11, h * .804, w * .38, h * .068);
  static Rect continueRect(double w, double h) =>
      Rect.fromLTWH(w * .51, h * .804, w * .38, h * .068);

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
    canvas.drawRRect(rr, Paint()..color = fill ?? const Color(0xFFFFF8E8));
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = const Color(0xFF5A8FC3),
    );
  }

  static void drawSettingsButton(Canvas canvas, double w, double h) {
    final rect = settingsButtonRect(w, h);
    final box = RRect.fromRectAndRadius(rect, const Radius.circular(22));
    canvas.drawRRect(box, Paint()..color = const Color(0xFFF7FFF0));
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xFF4F86BF),
    );
    _drawText(
      canvas,
      '⚙',
      rect,
      20,
      const Color(0xFF174B87),
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
    final bg = Paint()
      ..shader = Gradient.linear(
        const Offset(0, 0),
        Offset(0, h),
        const [Color(0xFF5BB9EE), Color(0xFF93D9F5), Color(0xFFE9F8FF)],
        const [0.0, .58, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bg);

    // Decorative glow rings make this feel like a game menu rather than a report page.
    canvas.drawCircle(Offset(w * .18, h * .10), w * .18, Paint()..color = const Color(0x220073B8));
    canvas.drawCircle(Offset(w * .88, h * .22), w * .24, Paint()..color = const Color(0x221DBA67));

    final panelRect = Rect.fromLTWH(w * .055, h * .055, w * .89, h * .855);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(30));
    canvas.drawRRect(panel, Paint()..color = const Color(0xFFFFF9EA));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = const Color(0xFF3E7DB9),
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
      '⚙  게임 설정',
      Rect.fromLTWH(w * .18, h * .075, w * .64, h * .052),
      24,
      const Color(0xFF174B87),
      FontWeight.w900,
    );
    _drawText(canvas, '✕', closeRect(w, h), 20, const Color(0xFF174B87), FontWeight.w900);

    final record = Rect.fromLTWH(w * .11, h * .142, w * .78, h * .078);
    _card(canvas, record, fill: const Color(0xFFEAF7FF));
    _drawText(
      canvas,
      '🏆  현재 STAGE $currentStage     최고 ${bestStage == 0 ? '-' : bestStage}',
      record,
      14.5,
      const Color(0xFF174B87),
      FontWeight.w900,
    );

    final music = musicRect(w, h);
    _card(canvas, music, fill: const Color(0xFFF2FBFF));
    _drawText(
      canvas,
      '🎵  배경음악',
      Rect.fromLTWH(music.left + 18, music.top, music.width * .55, music.height),
      15.5,
      const Color(0xFF17345B),
      FontWeight.w800,
      align: TextAlign.left,
    );
    final sw = Rect.fromLTWH(music.right - 78, music.top + 11, 58, music.height - 22);
    final swBox = RRect.fromRectAndRadius(sw, Radius.circular(sw.height / 2));
    canvas.drawRRect(swBox, Paint()..color = bgmEnabled ? const Color(0xFF74E63C) : const Color(0xFF4A3A60));
    final knobX = bgmEnabled ? sw.right - sw.height / 2 : sw.left + sw.height / 2;
    canvas.drawCircle(Offset(knobX, sw.center.dy), sw.height * .34, Paint()..color = const Color(0xFF17345B));

    final how = Rect.fromLTWH(w * .11, h * .323, w * .78, h * .125);
    _card(canvas, how, fill: const Color(0xFF24104A));
    _drawText(
      canvas,
      '🎮  게임 방법',
      Rect.fromLTWH(how.left + 16, how.top + 8, how.width - 32, 25),
      15.5,
      const Color(0xFFFFE08B),
      FontWeight.w900,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      '1  문 순서를 기억   2  같은 순서로 선택\n3  성공하면 다음 스테이지로 전진',
      Rect.fromLTWH(how.left + 16, how.top + 38, how.width - 32, how.height - 44),
      12.8,
      const Color(0xFFF4EEFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.36,
    );

    final level = Rect.fromLTWH(w * .11, h * .465, w * .78, h * .168);
    _card(canvas, level, fill: const Color(0xFFF7FBEA));
    _drawText(
      canvas,
      '🗺  단계 안내',
      Rect.fromLTWH(level.left + 16, level.top + 8, level.width - 32, 25),
      15.5,
      const Color(0xFF2E6D32),
      FontWeight.w900,
      align: TextAlign.left,
    );

    final guideItems = <String>[
      '인간의 영역',
      '초인의 영역',
      '기억의 한계를 넘어',
      '신의 영역에 도전',
    ];
    for (var i = 0; i < guideItems.length; i++) {
      final cy = level.top + 49 + i * 25.5;
      canvas.drawCircle(
        Offset(level.left + 28, cy),
        10.5,
        Paint()..color = const Color(0xFF6DBA4A),
      );
      _drawText(
        canvas,
        '${i + 1}',
        Rect.fromLTWH(level.left + 17.5, cy - 10.5, 21, 21),
        11.5,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
      _drawText(
        canvas,
        guideItems[i],
        Rect.fromLTWH(level.left + 48, cy - 12, level.width - 64, 24),
        12.8,
        const Color(0xFF315B46),
        FontWeight.w800,
        align: TextAlign.left,
      );
    }

    final fail = Rect.fromLTWH(w * .11, h * .650, w * .78, h * .105);
    _card(canvas, fail, fill: const Color(0xFF351342));
    _drawText(
      canvas,
      '💥  실패 규칙',
      Rect.fromLTWH(fail.left + 16, fail.top + 7, fail.width - 32, 25),
      15.0,
      const Color(0xFFFFD18A),
      FontWeight.w900,
      align: TextAlign.left,
    );
    _drawText(
      canvas,
      '실패하면 기본적으로 두 단계 전으로 돌아가 다시 도전합니다.',
      Rect.fromLTWH(fail.left + 16, fail.top + 35, fail.width - 32, fail.height - 40),
      12.2,
      const Color(0xFFFFE8C2),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.28,
    );

    final reset = resetRect(w, h);
    final resetBox = RRect.fromRectAndRadius(reset, const Radius.circular(24));
    canvas.drawRRect(resetBox, Paint()..color = const Color(0xFF7EEB42));
    canvas.drawRRect(resetBox, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.4..color = const Color(0xFF17345B));
    _drawText(canvas, '↺ 처음부터', reset, 16.5, const Color(0xFF102408), FontWeight.w900);

    final cont = continueRect(w, h);
    final contBox = RRect.fromRectAndRadius(cont, const Radius.circular(24));
    canvas.drawRRect(contBox, Paint()..color = const Color(0xFF7EEB42));
    canvas.drawRRect(contBox, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.4..color = const Color(0xFF17345B));
    _drawText(canvas, '▶ 계속하기', cont, 16.8, const Color(0xFF102408), FontWeight.w900);

    _drawText(
      canvas,
      '처음부터: 진행 기록을 초기화하고 STAGE 3에서 다시 시작',
      Rect.fromLTWH(w * .12, h * .878, w * .76, h * .020),
      9.1,
      const Color(0xFFBDAED8),
      FontWeight.w600,
    );
  }
}
