import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, FontWeight, RadialGradient, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/action_button.dart';
import '../components/hero_component.dart';
import '../components/monster_component.dart';
import '../components/princess_component.dart';
import '../monster_door_game.dart';

class ResultScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  ResultScene({required this.clear, required this.stage});

  final bool clear;
  final int stage;
  late ActionButton primary;
  late PositionComponent visual;

  @override
  Future<void> onLoad() async {
    primary = ActionButton(
      label: clear ? '다음 도전' : '다시 도전',
      onPressed: clear ? game.advanceAfterClear : game.retryCurrentStage,
    );
    visual = clear ? _ClearVisual() : _FailVisual();
    addAll([visual, primary]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    visual
      ..size = Vector2(size.x * .48, size.y * .23)
      ..position = Vector2(size.x * .26, size.y * .28);
    primary
      ..size = Vector2(size.x - 50, 64)
      ..position = Vector2(25, size.y * .75);
  }

  void _text(
    Canvas c,
    String t,
    double y,
    double fs, {
    Color color = const Color(0xFFFFFFFF),
    FontWeight w = FontWeight.w700,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: t, style: TextStyle(color: color, fontSize: fs, fontWeight: w)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.x - 40);
    tp.paint(c, Offset((size.x - tp.width) / 2, y));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, -.5),
          radius: 1,
          colors: clear
              ? const [Color(0xFF5B347F), Color(0xFF180A31), Color(0xFF07020F)]
              : const [Color(0xFF60223C), Color(0xFF1D091F), Color(0xFF07020F)],
        ).createShader(size.toRect()),
    );
    _text(canvas, clear ? 'STAGE CLEAR!' : 'MONSTER ATTACK!', size.y * .12, 30, color: clear ? const Color(0xFFFFD85D) : const Color(0xFFFF738D), w: FontWeight.w900);
    _text(canvas, clear ? '$stage DOORS 성공!' : '문 뒤에서 몬스터가 나타났습니다.', size.y * .56, clear ? 27 : 21, w: FontWeight.w900);
    _text(canvas, clear ? '공주에게 한 걸음 더 가까워졌습니다.' : '기억한 순서를 다시 확인하세요.', size.y * .63, 16, color: const Color(0xFFDCCEF3));
  }
}

class _ClearVisual extends PositionComponent {
  final HeroComponent hero = HeroComponent();
  final PrincessComponent princess = PrincessComponent();

  @override
  Future<void> onLoad() async {
    hero.triggerDash();
    addAll([hero, princess]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    hero
      ..size = Vector2(size.x * .34, size.y * .82)
      ..position = Vector2(size.x * .06, size.y * .18);
    princess
      ..size = Vector2(size.x * .28, size.y * .70)
      ..position = Vector2(size.x * .64, size.y * .12);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final line = Paint()..color = const Color(0x66FFD86D)..strokeWidth = 4;
    canvas.drawLine(Offset(size.x * .26, size.y * .72), Offset(size.x * .72, size.y * .52), line);
    canvas.drawCircle(Offset(size.x * .56, size.y * .34), 12, Paint()..color = const Color(0xFFFFD85D));
  }
}

class _FailVisual extends PositionComponent {
  final MonsterComponent monster = MonsterComponent();

  @override
  Future<void> onLoad() async {
    monster.showMonster();
    add(monster);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    monster
      ..size = Vector2(size.x * .44, size.x * .44)
      ..position = Vector2(size.x * .28, size.y * .12);
  }
}
