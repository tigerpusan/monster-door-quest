import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import 'pixel_art_kit.dart';

class GameHelpOverlay {
  static Rect settingsButtonRect(double w, double h) =>
      Rect.fromLTWH(w * .825, h * .020, w * .125, h * .060);
  static Rect closeRect(double w, double h) =>
      Rect.fromLTWH(w * .82, h * .067, w * .09, h * .050);
  static Rect musicRect(double w, double h) =>
      Rect.fromLTWH(w * .10, h * .205, w * .80, h * .070);
  static Rect resetRect(double w, double h) =>
      Rect.fromLTWH(w * .105, h * .825, w * .385, h * .070);
  static Rect continueRect(double w, double h) =>
      Rect.fromLTWH(w * .51, h * .825, w * .385, h * .070);

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

  static void _pixelCard(
    Canvas canvas,
    Rect rect, {
    required Color fill,
    required Color border,
    double radius = 19,
  }) {
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rr.shift(const Offset(0, 4)), Paint()..color = const Color(0x330B3768));
    canvas.drawRRect(rr, Paint()..color = fill);
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.1
        ..color = border,
    );
    canvas.drawRRect(
      rr.deflate(6),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .9
        ..color = const Color(0x77FFFFFF),
    );
  }

  static void _banner(Canvas canvas, Rect rect, Color fill, String text, Color textColor) {
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    canvas.drawRRect(rr.shift(const Offset(0, 3)), Paint()..color = const Color(0x33000000));
    canvas.drawRRect(rr, Paint()..color = fill);
    canvas.drawRRect(
      rr,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x99FFFFFF),
    );
    _drawText(canvas, text, rect, 15.6, textColor, FontWeight.w900, align: TextAlign.left);
  }

  static void drawSettingsButton(Canvas canvas, double w, double h) {
    final rect = settingsButtonRect(w, h);
    final box = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    canvas.drawRRect(box.shift(const Offset(0, 3)), Paint()..color = const Color(0x440E4C83));
    canvas.drawRRect(box, Paint()..color = const Color(0xFFFFF9E8));
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFF2C6DB1),
    );
    _drawText(canvas, '⚙', rect, 21, const Color(0xFF1D5D9D), FontWeight.w900);
  }

  static void draw(
    Canvas canvas,
    double w,
    double h, {
    required int currentStage,
    required int bestStage,
    required bool bgmEnabled,
    PixelArtKit? pixelArt,
  }) {
    final size = Vector2(w, h);
    if (pixelArt != null) {
      pixelArt.renderBackground(canvas, size, showCastle: false, showTrees: true, rich: true);
    } else {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, w, h),
        Paint()
          ..shader = Gradient.linear(
            const Offset(0, 0),
            Offset(0, h),
            const [Color(0xFF27AAF2), Color(0xFF86D9FF), Color(0xFFEAF9FF)],
            const [0.0, .60, 1.0],
          ),
      );
    }

    final panelRect = Rect.fromLTWH(w * .045, h * .045, w * .91, h * .885);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(30));
    canvas.drawRRect(panel.shift(const Offset(0, 5)), Paint()..color = const Color(0x440E4B85));
    canvas.drawRRect(panel, Paint()..color = const Color(0xFFFFF9EA));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..color = const Color(0xFF2F70B2),
    );
    canvas.drawRRect(
      panel.deflate(9),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = const Color(0x66FFFFFF),
    );

    _drawText(
      canvas,
      '⚙  게임 설정',
      Rect.fromLTWH(w * .19, h * .065, w * .58, h * .060),
      25,
      const Color(0xFF174B87),
      FontWeight.w900,
    );
    _drawText(canvas, '✕', closeRect(w, h), 22, const Color(0xFF174B87), FontWeight.w900);

    final record = Rect.fromLTWH(w * .105, h * .133, w * .79, h * .060);
    _pixelCard(canvas, record, fill: const Color(0xFFF1FAFF), border: const Color(0xFF4C8CCA));
    _drawText(
      canvas,
      '🏆  현재 STAGE $currentStage     │     최고 ${bestStage == 0 ? '-' : bestStage}',
      record,
      14.2,
      const Color(0xFF174B87),
      FontWeight.w900,
    );

    final music = musicRect(w, h);
    _pixelCard(canvas, music, fill: const Color(0xFFF6FCFF), border: const Color(0xFF4C8CCA));
    _drawText(
      canvas,
      '♪  배경음악',
      Rect.fromLTWH(music.left + 18, music.top, music.width * .55, music.height),
      16.0,
      const Color(0xFF17345B),
      FontWeight.w900,
      align: TextAlign.left,
    );
    final sw = Rect.fromLTWH(music.right - 78, music.top + 12, 58, music.height - 24);
    final swBox = RRect.fromRectAndRadius(sw, Radius.circular(sw.height / 2));
    canvas.drawRRect(swBox, Paint()..color = bgmEnabled ? const Color(0xFF7BE63C) : const Color(0xFF8A8F9A));
    final knobX = bgmEnabled ? sw.right - sw.height / 2 : sw.left + sw.height / 2;
    canvas.drawCircle(Offset(knobX, sw.center.dy), sw.height * .34, Paint()..color = const Color(0xFF174B87));

    final how = Rect.fromLTWH(w * .105, h * .293, w * .79, h * .142);
    _pixelCard(canvas, how, fill: const Color(0xFFEAF6FF), border: const Color(0xFF4A8BCB));
    _banner(canvas, Rect.fromLTWH(how.left + 13, how.top + 10, how.width * .44, 34),
        const Color(0xFF2D73C6), '🎮  게임 방법', const Color(0xFFFFFFFF));
    final colW = (how.width - 34) / 3;
    final items = ['1\n문 순서를 기억', '2\n같은 순서로 선택', '3\n성공하면 다음 스테이지'];
    for (var i = 0; i < 3; i++) {
      final r = Rect.fromLTWH(how.left + 12 + colW * i, how.top + 51, colW - 2, how.height - 58);
      _drawText(canvas, items[i], r, 11.6, const Color(0xFF214A73), FontWeight.w900, height: 1.22);
      if (i < 2) {
        canvas.drawLine(
          Offset(r.right + 2, r.top + 3),
          Offset(r.right + 2, r.bottom - 3),
          Paint()..color = const Color(0x665C9ED6)..strokeWidth = 1.2,
        );
      }
    }

    final level = Rect.fromLTWH(w * .105, h * .455, w * .79, h * .190);
    _pixelCard(canvas, level, fill: const Color(0xFFFFF9D8), border: const Color(0xFF79A84F));
    _banner(canvas, Rect.fromLTWH(level.left + 13, level.top + 10, level.width * .44, 34),
        const Color(0xFF55A53D), '🗺  단계 안내', const Color(0xFFFFFFFF));

    final guideItems = <String>[
      '인간의 영역  I · II · III',
      '초인의 영역  I · II · III',
      '신의 영역',
    ];
    for (var i = 0; i < guideItems.length; i++) {
      final cy = level.top + 61 + i * 36;
      canvas.drawCircle(Offset(level.left + 28, cy), 11.5, Paint()..color = const Color(0xFF65B94D));
      _drawText(canvas, '${i + 1}', Rect.fromLTWH(level.left + 16.5, cy - 11.5, 23, 23),
          11.8, const Color(0xFFFFFFFF), FontWeight.w900);
      _drawText(canvas, guideItems[i], Rect.fromLTWH(level.left + 51, cy - 13, level.width * .55, 26),
          12.8, const Color(0xFF315B46), FontWeight.w900, align: TextAlign.left);
    }
    if (pixelArt != null) {
      pixelArt.renderCastle(canvas, size,
          x: level.left / w + .57, y: level.top / h + .045, width: .20, height: .15);
    }

    final fail = Rect.fromLTWH(w * .105, h * .665, w * .79, h * .120);
    _pixelCard(canvas, fail, fill: const Color(0xFFFFEFE7), border: const Color(0xFFD56A59));
    _banner(canvas, Rect.fromLTWH(fail.left + 13, fail.top + 10, fail.width * .44, 34),
        const Color(0xFFD95545), '💥  실패 규칙', const Color(0xFFFFFFFF));
    _drawText(
      canvas,
      '실패하면 기본적으로 두 단계 전으로\n돌아가 다시 도전합니다.',
      Rect.fromLTWH(fail.left + 16, fail.top + 52, fail.width * .58, fail.height - 58),
      12.1,
      const Color(0xFF7C3A32),
      FontWeight.w800,
      align: TextAlign.left,
      height: 1.27,
    );
    if (pixelArt != null) {
      pixelArt.monster.render(canvas,
          position: Vector2(fail.left + fail.width * .69, fail.top + 39),
          size: Vector2(fail.width * .22, fail.width * .22));
    }

    final reset = resetRect(w, h);
    final resetBox = RRect.fromRectAndRadius(reset, const Radius.circular(24));
    canvas.drawRRect(resetBox.shift(const Offset(0, 3)), Paint()..color = const Color(0x442C6A1D));
    canvas.drawRRect(resetBox, Paint()..color = const Color(0xFF7EEB42));
    canvas.drawRRect(resetBox, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.4..color = const Color(0xFF17345B));
    _drawText(canvas, '↻  처음부터', reset, 16.6, const Color(0xFF102408), FontWeight.w900);

    final cont = continueRect(w, h);
    final contBox = RRect.fromRectAndRadius(cont, const Radius.circular(24));
    canvas.drawRRect(contBox.shift(const Offset(0, 3)), Paint()..color = const Color(0x442C6A1D));
    canvas.drawRRect(contBox, Paint()..color = const Color(0xFF7EEB42));
    canvas.drawRRect(contBox, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.4..color = const Color(0xFF17345B));
    _drawText(canvas, '▶  계속하기', cont, 16.6, const Color(0xFF102408), FontWeight.w900);

    _drawText(
      canvas,
      '처음부터: 진행 기록을 초기화하고 STAGE 3에서 다시 시작',
      Rect.fromLTWH(w * .12, h * .902, w * .76, h * .018),
      8.9,
      const Color(0xFF7F8792),
      FontWeight.w700,
    );
  }
}
