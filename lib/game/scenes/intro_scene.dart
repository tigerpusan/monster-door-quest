import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show FontWeight, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../monster_door_game.dart';

class IntroScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  late Sprite _bg;
  late TapZone _start;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load('ui/gameplay.webp');
    _start = TapZone(onTap: game.startCurrentStage);
    add(_start);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _start
      ..size = Vector2(size.x * .82, size.y * .09)
      ..position = Vector2(size.x * .09, size.y * .84);
  }

  void _centerText(Canvas canvas, String text, double y, double fs, Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fs, fontWeight: weight, color: color)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x * .92);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0x66080016));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .06, size.y * .08, size.x * .88, size.y * .22), const Radius.circular(28)),
      Paint()..color = const Color(0xBB170B35),
    );
    _centerText(canvas, '몬스터 문 열기', size.y * .105, 34, const Color(0xFFFFD867), FontWeight.w900);
    _centerText(canvas, '문을 기억하여,', size.y * .17, 21, const Color(0xFFFFFFFF), FontWeight.w800);
    _centerText(canvas, '몬스터에게 빼앗긴 공주를 되찾아라', size.y * .205, 20, const Color(0xFFFFFFFF), FontWeight.w800);

    final btn = RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .09, size.y * .84, size.x * .82, size.y * .09), const Radius.circular(28));
    canvas.drawRRect(btn, Paint()..color = const Color(0xFF7EEB42));
    canvas.drawRRect(btn, Paint()..style = PaintingStyle.stroke..strokeWidth = 3..color = const Color(0xFFFFFFFF));
    _centerText(canvas, '✨ 바로 시작 ✨', size.y * .858, 26, const Color(0xFF102408), FontWeight.w900);
  }
}
