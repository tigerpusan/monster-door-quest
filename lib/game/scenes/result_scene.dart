import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../monster_door_game.dart';

class ResultScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  ResultScene({required this.clear, required this.stage, required this.elapsedSeconds});

  final bool clear;
  final int stage;
  final double elapsedSeconds;
  late Sprite _bg;
  late TapZone _primary;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load(clear ? 'ui/stage_clear.webp' : 'ui/monster_attack.webp');
    _primary = TapZone(onTap: clear ? game.advanceAfterClear : game.retryCurrentStage);
    add(_primary);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _primary
      ..size = Vector2(size.x * .72, size.y * .085)
      ..position = Vector2(size.x * .14, clear ? size.y * .82 : size.y * .73);
  }

  void _center(Canvas canvas, String text, double y, double fs, Color color, FontWeight weight) {
    final tp = TextPainter(text: TextSpan(text: text, style: TextStyle(fontSize: fs, fontWeight: weight, color: color)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);
    if (clear) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .28, size.y * .205, size.x * .44, 42), const Radius.circular(18)),
        Paint()..color = const Color(0xE5241150),
      );
      _center(canvas, 'STAGE $stage COMPLETE', size.y * .214, 18, const Color(0xFFFFFFFF), FontWeight.w900);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .18, size.y * .59, size.x * .64, size.y * .16), const Radius.circular(24)),
        Paint()..color = const Color(0xE52B1554),
      );
      _center(canvas, '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초', size.y * .615, 20, const Color(0xFFFFE08A), FontWeight.w900);
      _center(canvas, '정답률 100%   ★★★', size.y * .665, 19, const Color(0xFFFFFFFF), FontWeight.w800);
    }
  }
}
