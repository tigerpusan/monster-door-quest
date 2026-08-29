import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextDirection, TextPainter, TextSpan, TextStyle;
import 'package:flutter/services.dart';
import '../components/door_component.dart';
import '../components/route_progress.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../effects/hit_effects.dart';
import '../monster_door_game.dart';

class DoorScene extends PositionComponent
    with HasGameReference<MonsterDoorGame> {
  DoorScene(this.session);

  final GameSessionState session;
  late Sprite _bg;
  late final DoorComponent leftDoor, rightDoor;
  late final RouteProgress progress;
  final feedback = HitFeedbackController();

  double elapsed = 0;
  double transitionDelay = -1;
  bool _transitioning = false;
  double _inputCooldown = 0;
  String _feedbackText = '';
  double _feedbackTimer = 0;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load('ui/gameplay.webp');
    session.beginDoorRun();
    leftDoor = DoorComponent(side: DoorSide.left, onSelected: _choose);
    rightDoor = DoorComponent(side: DoorSide.right, onSelected: _choose);
    progress = RouteProgress(total: session.route.length);
    addAll([leftDoor, rightDoor, progress]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    leftDoor
      ..size = Vector2(size.x * .335, size.y * .405)
      ..position = Vector2(size.x * .105, size.y * .385);
    rightDoor
      ..size = Vector2(size.x * .335, size.y * .405)
      ..position = Vector2(size.x * .56, size.y * .385);
    progress
      ..size = Vector2(size.x * .68, 42)
      ..position = Vector2(size.x * .16, size.y * .255);
  }

  Future<void> _choose(DoorSide side) async {
    if (session.phase != SessionPhase.playing || _transitioning || _inputCooldown > 0) {
      return;
    }

    // Keep only one short gate against accidental double-fires while preserving fast rhythm.
    _inputCooldown = .026;

    final result = session.choose(side);
    final door = side == DoorSide.left ? leftDoor : rightDoor;
    door.open(correct: result != ChoiceResult.wrong);

    // Single immediate feedback path per tap keeps sound and vibration synced even on fast stages.
    unawaited(game.audioManager.playDoorOpen());

    if (result == ChoiceResult.wrong) {
      _feedbackText = '몬스터 출현!';
      _feedbackTimer = .72;
      feedback.playWrong();
      unawaited(HapticFeedback.heavyImpact());
      unawaited(game.audioManager.playWrong());
      _transitioning = true;
      transitionDelay = .48;
      return;
    }

    feedback.playCorrect();
    progress.setCurrent(session.step);
    _feedbackText = result == ChoiceResult.clear ? '클리어!' : '정답!';
    _feedbackTimer = result == ChoiceResult.clear ? .45 : .22;
    unawaited(HapticFeedback.lightImpact());

    if (result == ChoiceResult.clear) {
      _transitioning = true;
      transitionDelay = .38;
      unawaited(
        game.audioManager.playClear(
          milestoneStage: [5, 10, 15, 20].contains(session.stage),
        ),
      );
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

    if (session.phase == SessionPhase.playing &&
        elapsed >= GameRules.playSeconds &&
        !_transitioning) {
      session.phase = SessionPhase.failed;
      _feedbackText = '시간 종료!';
      _feedbackTimer = .8;
      feedback.playWrong();
      unawaited(HapticFeedback.heavyImpact());
      unawaited(game.audioManager.playWrong());
      _transitioning = true;
      transitionDelay = .48;
    }

    if (_transitioning) {
      transitionDelay -= dt;
      if (transitionDelay <= 0) {
        if (session.phase == SessionPhase.cleared) {
          game.showResult(
            clear: true,
            stage: session.stage,
            elapsedSeconds: elapsed,
          );
        } else if (session.phase == SessionPhase.failed) {
          game.showResult(
            clear: false,
            stage: session.stage,
            elapsedSeconds: elapsed,
          );
        }
      }
    }
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
    final shake = feedback.shakeActive ? sin(elapsed * 170) * 5 : 0.0;
    canvas.save();
    canvas.translate(shake, 0);
    _bg.render(
      canvas,
      position: Vector2(0, -size.y * .035),
      size: Vector2(size.x, size.y * 1.035),
    );

    // Hide the baked top title completely so the live HUD never overlaps it.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y * .14),
      Paint()..color = const Color(0xFF150830),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .08, size.y * .06, size.x * .84, size.y * .255),
        const Radius.circular(24),
      ),
      Paint()..color = const Color(0xF21A0D39),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .10, size.y * .08, size.x * .80, size.y * .215),
        const Radius.circular(20),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0x88FFD96A),
    );
    _center(
      canvas,
      '기억의 문을 여세요!',
      size.y * .108,
      27,
      const Color(0xFFFFD96A),
      FontWeight.w900,
    );
    _center(
      canvas,
      'STAGE ${session.stage}   ${min(session.step + 1, session.route.length)} / ${session.route.length}',
      size.y * .158,
      14,
      const Color(0xFFFFFFFF),
      FontWeight.w800,
    );
    final remain = (GameRules.playSeconds - elapsed).clamp(0.0, GameRules.playSeconds);
    _center(
      canvas,
      '${remain.toStringAsFixed(1)}초',
      size.y * .205,
      29,
      remain < 2.5 ? const Color(0xFFFF7777) : const Color(0xFFFFE08B),
      FontWeight.w900,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .33, size.y * .285, size.x * .34, size.y * .06),
        const Radius.circular(18),
      ),
      Paint()..color = const Color(0xF51A0D39),
    );

    if (_feedbackTimer > 0) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .32, size.y * .315, size.x * .36, 40),
        const Radius.circular(20),
      );
      canvas.drawRRect(rr, Paint()..color = const Color(0xF01B0E38));
      _center(
        canvas,
        _feedbackText,
        size.y * .323,
        17,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
    }

    if (feedback.flashKind != FlashKind.none) {
      final alpha = (60 * (1 - feedback.elapsed / .28).clamp(0, 1)).round();
      canvas.drawRect(
        size.toRect(),
        Paint()
          ..color = (feedback.flashKind == FlashKind.correct
                  ? const Color(0xFF6FFF98)
                  : const Color(0xFFFF4C6E))
              .withAlpha(alpha),
      );
    }
    canvas.restore();
    super.render(canvas);
  }
}
