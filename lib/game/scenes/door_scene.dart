import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, FontWeight, RadialGradient, TextDirection, TextPainter, TextSpan, TextStyle;
import 'package:flutter/services.dart';
import '../components/door_component.dart';
import '../components/hero_component.dart';
import '../components/princess_component.dart';
import '../components/monster_component.dart';
import '../components/route_progress.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../effects/hit_effects.dart';
import '../monster_door_game.dart';

class DoorScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  DoorScene(this.session);

  final GameSessionState session;
  late final DoorComponent leftDoor, rightDoor;
  late final HeroComponent hero;
  late final PrincessComponent princess;
  late final MonsterComponent monster;
  late final RouteProgress progress;
  final feedback = HitFeedbackController();

  double elapsed = 0;
  double transitionDelay = -1;
  bool _transitioning = false;
  bool _roundResetOnly = false;
  double _inputCooldown = 0;
  String _feedbackText = '빠르게 문을 열어보세요';
  double _feedbackTimer = 0;

  @override
  Future<void> onLoad() async {
    session.beginDoorRun();
    leftDoor = DoorComponent(side: DoorSide.left, onSelected: _choose);
    rightDoor = DoorComponent(side: DoorSide.right, onSelected: _choose);
    hero = HeroComponent();
    princess = PrincessComponent();
    monster = MonsterComponent();
    progress = RouteProgress(total: session.route.length);
    addAll([leftDoor, rightDoor, hero, princess, monster, progress]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    final dw = size.x * .36, dh = size.y * .46;
    leftDoor
      ..size = Vector2(dw, dh)
      ..position = Vector2(size.x * .08, size.y * .25);
    rightDoor
      ..size = Vector2(dw, dh)
      ..position = Vector2(size.x * .56, size.y * .25);
    hero
      ..size = Vector2(92, 136)
      ..position = Vector2(size.x / 2 - 46, size.y * .73);
    princess
      ..size = Vector2(76, 106)
      ..position = Vector2(size.x * .78, size.y * .11);
    monster
      ..size = Vector2(116, 116)
      ..position = Vector2(size.x / 2 - 58, size.y * .38);
    progress
      ..size = Vector2(size.x * .78, 42)
      ..position = Vector2(size.x * .10, size.y * .16);
  }

  Future<void> _choose(DoorSide side) async {
    if (session.phase != SessionPhase.playing || _transitioning || _inputCooldown > 0) return;
    _inputCooldown = .08;

    unawaited(game.audioManager.playDoorTap());
    unawaited(HapticFeedback.selectionClick());

    final result = session.choose(side);
    final door = side == DoorSide.left ? leftDoor : rightDoor;
    door.open(correct: result != ChoiceResult.wrong);
    unawaited(game.audioManager.playDoorOpen());

    if (result == ChoiceResult.wrong) {
      _feedbackText = '몬스터 출현!';
      _feedbackTimer = .7;
      feedback.playWrong();
      monster.showMonster();
      unawaited(HapticFeedback.heavyImpact());
      unawaited(game.audioManager.playWrong());
      _transitioning = true;
      _roundResetOnly = false;
      transitionDelay = .78;
    } else {
      feedback.playCorrect();
      hero.triggerDash();
      progress.setCurrent(session.step);
      _feedbackText = result == ChoiceResult.clear ? '클리어!' : '정답! 계속!';
      _feedbackTimer = .42;
      unawaited(HapticFeedback.lightImpact());
      unawaited(game.audioManager.playCorrect());
      if (result == ChoiceResult.clear) {
        _transitioning = true;
        _roundResetOnly = false;
        transitionDelay = .52;
        unawaited(game.audioManager.playClear(milestoneStage: [5, 10, 15, 20].contains(session.stage)));
      } else {
        _transitioning = true;
        _roundResetOnly = true;
        transitionDelay = .13;
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    elapsed += dt;
    feedback.update(dt);
    if (_inputCooldown > 0) {
      _inputCooldown = (_inputCooldown - dt).clamp(0, 1).toDouble();
    }
    if (_feedbackTimer > 0) {
      _feedbackTimer = (_feedbackTimer - dt).clamp(0, 1).toDouble();
    }

    if (session.phase == SessionPhase.playing && elapsed >= GameRules.playSeconds && !_transitioning) {
      session.phase = SessionPhase.failed;
      _feedbackText = '시간 종료!';
      _feedbackTimer = .8;
      feedback.playWrong();
      monster.showMonster();
      unawaited(HapticFeedback.heavyImpact());
      unawaited(game.audioManager.playWrong());
      _transitioning = true;
      _roundResetOnly = false;
      transitionDelay = .70;
    }

    if (_transitioning) {
      transitionDelay -= dt;
      if (transitionDelay <= 0) {
        if (_roundResetOnly && session.phase == SessionPhase.playing) {
          leftDoor.resetDoor();
          rightDoor.resetDoor();
          monster.hideMonster();
          _transitioning = false;
          _roundResetOnly = false;
          transitionDelay = -1;
          return;
        }
        if (session.phase == SessionPhase.cleared) {
          game.showResult(clear: true, stage: session.stage);
        } else if (session.phase == SessionPhase.failed) {
          game.showResult(clear: false, stage: session.stage);
        }
      }
    }
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
    )..layout();
    tp.paint(c, Offset((size.x - tp.width) / 2, y));
  }

  @override
  void render(Canvas canvas) {
    final shake = feedback.shakeActive ? sin(elapsed * 170) * 6 : 0.0;
    canvas.save();
    canvas.translate(shake, 0);
    canvas.drawRect(
      size.toRect(),
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.36),
          radius: 1.12,
          colors: [Color(0xFF2F1852), Color(0xFF15092E), Color(0xFF05010B)],
        ).createShader(size.toRect()),
    );

    final star = Paint()..color = const Color(0xB3FFFFFF);
    for (var i = 0; i < 22; i++) {
      final x = (i * 67) % size.x;
      final y = 32 + ((i * 59) % (size.y * .40).toInt()).toDouble();
      canvas.drawCircle(Offset(x, y), i % 4 == 0 ? 1.7 : 1.0, star);
    }

    _text(canvas, '문을 여세요!', 26, 30, color: const Color(0xFFFFE072), w: FontWeight.w900);
    _text(canvas, 'STAGE ${session.stage}   ${min(session.step + 1, session.route.length)} / ${session.route.length}', 64, 16, color: const Color(0xFFE4D7F7));
    final remain = (GameRules.playSeconds - elapsed).clamp(0, GameRules.playSeconds);
    _text(
      canvas,
      '${remain.toStringAsFixed(1)}초',
      100,
      38,
      color: remain < 2.5 ? const Color(0xFFFF866F) : const Color(0xFFFFE595),
      w: FontWeight.w900,
    );

    if (feedback.flashKind != FlashKind.none) {
      final alpha = (88 * (1 - feedback.elapsed / .28).clamp(0, 1)).round();
      canvas.drawRect(
        size.toRect(),
        Paint()..color = (feedback.flashKind == FlashKind.correct ? const Color(0xFF62FFB0) : const Color(0xFFFF4E71)).withAlpha(alpha),
      );
    }

    final leftPill = RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .12, size.y * .66, 100, 38), const Radius.circular(20));
    final rightPill = RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .64, size.y * .66, 100, 38), const Radius.circular(20));
    canvas.drawRRect(leftPill, Paint()..color = const Color(0x88264170));
    canvas.drawRRect(leftPill, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = const Color(0x884CC6FF));
    canvas.drawRRect(rightPill, Paint()..color = const Color(0x88401862));
    canvas.drawRRect(rightPill, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.4..color = const Color(0x88FF95F0));
    final leftTp = TextPainter(
      text: const TextSpan(text: '← 왼쪽', style: TextStyle(color: Color(0xFF8FE6FF), fontSize: 20, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    leftTp.paint(canvas, Offset(leftPill.left + (leftPill.width - leftTp.width) / 2, leftPill.top + 7));
    final rightTp = TextPainter(
      text: const TextSpan(text: '오른쪽 →', style: TextStyle(color: Color(0xFFFFC2F5), fontSize: 20, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.ltr,
    )..layout();
    rightTp.paint(canvas, Offset(rightPill.left + (rightPill.width - rightTp.width) / 2, rightPill.top + 7));

    if (_feedbackTimer > 0) {
      final panel = RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .23, size.y * .21, size.x * .54, 36), const Radius.circular(18));
      canvas.drawRRect(panel, Paint()..color = const Color(0xAA1D0F32));
      canvas.drawRRect(panel, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0x55FFFFFF));
      _text(canvas, _feedbackText, size.y * .21 + 7, 18, color: const Color(0xFFFFFFFF), w: FontWeight.w900);
    }

    canvas.restore();
    super.render(canvas);
  }
}
