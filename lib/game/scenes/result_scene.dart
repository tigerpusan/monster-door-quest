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
      ..size = Vector2(size.x * .72, size.y * .085)
      ..position = Vector2(size.x * .14, clear ? size.y * .82 : size.y * .73);
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
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.x * .25, size.y * .19, size.x * .50, 44),
          const Radius.circular(18),
        ),
        Paint()..color = const Color(0xF0241150),
      );
      _center(
        canvas,
        'STAGE $stage COMPLETE',
        size.y * .201,
        18,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.x * .17, size.y * .585, size.x * .66, size.y * .155),
          const Radius.circular(24),
        ),
        Paint()..color = const Color(0xF02B1554),
      );
      _center(
        canvas,
        '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초',
        size.y * .61,
        20,
        const Color(0xFFFFE08A),
        FontWeight.w900,
      );
      _center(
        canvas,
        '정답률 100%   ★★★',
        size.y * .66,
        19,
        const Color(0xFFFFFFFF),
        FontWeight.w800,
      );
    }

    if (_primary.pressed || _handled) {
      final y = clear ? size.y * .82 : size.y * .73;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.x * .14, y, size.x * .72, size.y * .085),
          const Radius.circular(28),
        ),
        Paint()..color = const Color(0x442B1400),
      );
    }
  }
}
