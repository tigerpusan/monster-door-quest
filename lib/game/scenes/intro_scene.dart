import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../monster_door_game.dart';

class IntroScene extends PositionComponent
    with HasGameReference<MonsterDoorGame> {
  late Sprite _bg;
  late TapZone _start;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load('ui/gameplay.webp');
    _start = TapZone(onTap: game.startCurrentStage, triggerOnDown: true);
    add(_start);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _start
      ..size = Vector2(size.x * .74, size.y * .068)
      ..position = Vector2(size.x * .13, size.y * .915);
  }

  void _centerText(Canvas canvas, String text, double y, double fs, Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fs, fontWeight: weight, color: color, height: 1.18)),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.x * .86);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(
      canvas,
      position: Vector2(0, -size.y * .055),
      size: Vector2(size.x, size.y * 1.055),
    );

    // Completely cover the baked title block so no hidden title can show behind the panel.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y * .30),
      Paint()..color = const Color(0xFF16082F),
    );

    final panel = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .05, size.y * .065, size.x * .90, size.y * .335),
      const Radius.circular(30),
    );
    canvas.drawRRect(panel, Paint()..color = const Color(0xFF1B0C3A));
    canvas.drawRRect(
      panel.deflate(12),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x99FFD968),
    );

    _centerText(canvas, '몬스터 문 열기', size.y * .100, 31,
        const Color(0xFFFFD968), FontWeight.w900);
    _centerText(canvas, '공주가 몬스터에게 납치되었습니다!', size.y * .158, 18,
        const Color(0xFFFFFFFF), FontWeight.w900);
    _centerText(canvas, '문 순서를 기억하고', size.y * .205, 16,
        const Color(0xFFF4EFFF), FontWeight.w700);
    _centerText(canvas, '같은 순서로 빠르게 문을 열어주세요.', size.y * .243, 15,
        const Color(0xFFF4EFFF), FontWeight.w700);
    _centerText(canvas, '용사의 기억력이 공주를 구합니다.', size.y * .287, 16,
        const Color(0xFFFFE7A0), FontWeight.w800);
    _centerText(canvas, '① 기억하기   ② 문 열기   ③ 틀리면 몬스터 출현', size.y * .342, 13,
        const Color(0xFFDCCBFF), FontWeight.w700);

    // Use a dark separator so the hero and CTA are visually separated.
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * .865, size.x, size.y * .135),
      Paint()..color = const Color(0xD516082F),
    );
    final btn = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .13, size.y * .915, size.x * .74, size.y * .068),
      const Radius.circular(28),
    );
    canvas.drawRRect(
      btn,
      Paint()..color = _start.pressed ? const Color(0xFF5FD82C) : const Color(0xFF7EEB42),
    );
    canvas.drawRRect(
      btn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFFFFF),
    );
    _centerText(canvas, '시작', size.y * .931, 23,
        const Color(0xFF102408), FontWeight.w900);
  }
}
