import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../monster_door_game.dart';

class ResultScene extends PositionComponent
    with HasGameReference<MonsterDoorGame> {
  ResultScene({
    required this.clear,
    required this.stage,
    required this.elapsedSeconds,
  });

  final bool clear;
  final int stage;
  final double elapsedSeconds;
  late Sprite _bg;
  late TapZone _primary;
  bool _handled = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load(clear ? 'ui/stage_clear.webp' : 'ui/monster_attack.webp');
    _primary = TapZone(onTap: _goNext, triggerOnDown: true);
    add(_primary);
  }

  void _goNext() {
    if (_handled) return;
    _handled = true;
    if (clear) {
      unawaited(game.advanceAfterClear());
    } else {
      unawaited(game.retryCurrentStage());
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _primary
      ..size = Vector2(size.x * .74, size.y * .085)
      ..position = Vector2(size.x * .13, clear ? size.y * .815 : size.y * .73);
  }

  void _center(
    Canvas canvas,
    String text,
    double y,
    double fs,
    Color color,
    FontWeight weight,
  ) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fs, fontWeight: weight, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    if (clear) {
      // Cover the baked "STAGE 8 COMPLETE" entirely before drawing the real
      // stage value. This removes the doubled text seen on the phone.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.x * .19, size.y * .145, size.x * .62, size.y * .105),
          const Radius.circular(22),
        ),
        Paint()..color = const Color(0xFF241047),
      );
      _center(
        canvas,
        'STAGE $stage COMPLETE',
        size.y * .181,
        19,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );

      // Replace the baked stats with one clean, fully opaque information card.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.x * .14, size.y * .565, size.x * .72, size.y * .225),
          const Radius.circular(28),
        ),
        Paint()..color = const Color(0xFF2A1454),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.x * .14, size.y * .565, size.x * .72, size.y * .225),
          const Radius.circular(28),
        ),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFD86D),
      );
      _center(
        canvas,
        '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초',
        size.y * .602,
        20,
        const Color(0xFFFFE08A),
        FontWeight.w900,
      );
      _center(
        canvas,
        '정답률 100%',
        size.y * .655,
        20,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
      _center(
        canvas,
        '획득 별  ★★★',
        size.y * .708,
        20,
        const Color(0xFFFFD96A),
        FontWeight.w900,
      );

      // The pink "다시 보기" in the source artwork was never an actual game
      // function. Mask it completely so the result screen has one clear CTA.
      final fadeRect = Rect.fromLTWH(0, size.y * .90, size.x, size.y * .10);
      canvas.drawRect(
        fadeRect,
        Paint()
          ..shader = Gradient.linear(
            fadeRect.topCenter,
            fadeRect.bottomCenter,
            const [Color(0xE814082C), Color(0xFF0F061F)],
          ),
      );

      // Reassert the single functional next-stage button on top of the baked
      // green art, with a consistent press feedback.
      final primary = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .13, size.y * .815, size.x * .74, size.y * .085),
        const Radius.circular(30),
      );
      canvas.drawRRect(
        primary,
        Paint()..color = _primary.pressed || _handled
            ? const Color(0xFF4FCF27)
            : const Color(0xFF78EA3F),
      );
      canvas.drawRRect(
        primary,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFFFFF),
      );
      _center(
        canvas,
        '다음 스테이지',
        size.y * .837,
        23,
        const Color(0xFF13240B),
        FontWeight.w900,
      );
    } else if (_primary.pressed || _handled) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.x * .14, size.y * .73, size.x * .72, size.y * .085),
          const Radius.circular(28),
        ),
        Paint()..color = const Color(0x442B1400),
      );
    }
  }
}
