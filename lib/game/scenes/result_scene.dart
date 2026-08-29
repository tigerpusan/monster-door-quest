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
      ..size = Vector2(size.x * .82, clear ? size.y * .09 : size.y * .11)
      ..position = Vector2(size.x * .09, clear ? size.y * .815 : size.y * .80)
      ..priority = 1000;
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
      // Cover the baked English banner entirely. The Korean celebration title in the art remains,
      // but the duplicate English line is removed for a cleaner result.
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.x * .18, size.y * .145, size.x * .64, size.y * .11),
          const Radius.circular(24),
        ),
        Paint()..color = const Color(0xEE241047),
      );

      // Replace the busy baked stats with one clean, simple card.
      final info = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .14, size.y * .59, size.x * .72, size.y * .14),
        const Radius.circular(28),
      );
      canvas.drawRRect(info, Paint()..color = const Color(0xFF2A1454));
      canvas.drawRRect(
        info,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFFFFD86D),
      );
      _center(
        canvas,
        '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초',
        size.y * .642,
        22,
        const Color(0xFFFFE08A),
        FontWeight.w900,
      );

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
    } else {
      // Mask the busy lower copy from the background and redraw the retry area cleanly.
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .66, size.x, size.y * .30),
        Paint()..color = const Color(0xD9100724),
      );
      _center(
        canvas,
        '문 뒤에서 몬스터가 나타났습니다.',
        size.y * .685,
        17,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
      _center(
        canvas,
        '기억한 순서를 다시 확인하세요.',
        size.y * .727,
        15,
        const Color(0xFFD8C4FF),
        FontWeight.w800,
      );

      final retry = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .09, size.y * .80, size.x * .82, size.y * .11),
        const Radius.circular(32),
      );
      canvas.drawRRect(
        retry,
        Paint()..color = _primary.pressed || _handled
            ? const Color(0xFF4FCF27)
            : const Color(0xFF78EA3F),
      );
      canvas.drawRRect(
        retry,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFFFFF),
      );
      _center(
        canvas,
        _handled ? '다시 시작 중...' : '다시 도전',
        size.y * .832,
        25,
        const Color(0xFF13240B),
        FontWeight.w900,
      );
    }
  }
}
