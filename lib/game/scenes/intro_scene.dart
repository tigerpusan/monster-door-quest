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
      ..size = Vector2(size.x * .76, size.y * .068)
      ..position = Vector2(size.x * .12, size.y * .912);
  }

  void _centerText(
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
        style: TextStyle(fontSize: fs, fontWeight: weight, color: color, height: 1.18),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.x * .86);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(
      canvas,
      position: Vector2(0, -size.y * .125),
      size: Vector2(size.x, size.y * 1.125),
    );

    // Dim the baked top title so it no longer collides with the real intro copy.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y * .12),
      Paint()..color = const Color(0xB014082C),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .045, size.y * .07, size.x * .91, size.y * .34),
        const Radius.circular(30),
      ),
      Paint()..color = const Color(0xFF1A0C38),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .065, size.y * .088, size.x * .87, size.y * .302),
        const Radius.circular(26),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x99FFD968),
    );

    _centerText(
      canvas,
      '몬스터 문 열기',
      size.y * .112,
      31,
      const Color(0xFFFFD968),
      FontWeight.w900,
    );
    _centerText(
      canvas,
      '공주가 몬스터에게 납치되었습니다!',
      size.y * .172,
      18,
      const Color(0xFFFFFFFF),
      FontWeight.w900,
    );
    _centerText(
      canvas,
      '문 순서를 기억하고',
      size.y * .214,
      16,
      const Color(0xFFF4EFFF),
      FontWeight.w700,
    );
    _centerText(
      canvas,
      '같은 순서로 빠르게 문을 열어주세요.',
      size.y * .251,
      15,
      const Color(0xFFF4EFFF),
      FontWeight.w700,
    );
    _centerText(
      canvas,
      '용사의 기억력이 공주를 구합니다.',
      size.y * .288,
      16,
      const Color(0xFFFFE7A0),
      FontWeight.w800,
    );
    _centerText(
      canvas,
      '① 기억하기   ② 문 열기   ③ 틀리면 몬스터 출현',
      size.y * .347,
      13,
      const Color(0xFFDCCBFF),
      FontWeight.w700,
    );

    // Separate the CTA area from the character while still allowing the hero to sit
    // naturally between the two doors.
    final bottomShade = Rect.fromLTWH(0, size.y * .885, size.x, size.y * .115);
    canvas.drawRect(
      bottomShade,
      Paint()
        ..shader = Gradient.linear(
          bottomShade.topCenter,
          bottomShade.bottomCenter,
          const [Color(0x660D041A), Color(0xE114082C)],
        ),
    );

    final btn = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .12, size.y * .912, size.x * .76, size.y * .068),
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
    _centerText(
      canvas,
      '시작',
      size.y * .928,
      23,
      const Color(0xFF102408),
      FontWeight.w900,
    );
  }
}
