import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextDirection, TextPainter, TextSpan, TextStyle;
import 'package:flutter/services.dart';
import '../components/door_component.dart';
import '../components/route_progress.dart';
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../effects/hit_effects.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';

class DoorScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  DoorScene(this.session);

  final GameSessionState session;
  late Sprite _bg;
  late final DoorComponent leftDoor, rightDoor;
  late final RouteProgress progress;
  late TapZone _settings;
  late TapZone _settingsClose;
  late TapZone _settingsContinue;
  late TapZone _settingsMusic;
  late TapZone _settingsReset;
  final feedback = HitFeedbackController();

  double elapsed = 0;
  double transitionDelay = -1;
  bool _transitioning = false;
  bool _settingsOpen = false;
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
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsMusic = TapZone(onTap: _toggleBgm, triggerOnDown: true);
    _settingsReset = TapZone(onTap: _resetChallenge, triggerOnDown: true);
    addAll([
      leftDoor,
      rightDoor,
      progress,
      _settings,
      _settingsClose,
      _settingsContinue,
      _settingsMusic,
      _settingsReset,
    ]);
  }

  void _toggleSettings() => _settingsOpen = !_settingsOpen;
  void _closeSettings() => _settingsOpen = false;

  void _toggleBgm() {
    if (!_settingsOpen) return;
    game.audioManager.bgmEnabled = !game.audioManager.bgmEnabled;
    if (game.audioManager.bgmEnabled) {
      game.audioManager.startBgm();
    } else {
      game.audioManager.stopBgm();
    }
  }

  Future<void> _resetChallenge() async {
    if (!_settingsOpen) return;
    await game.progressStore.saveCurrentStage(GameRules.initialStage);
    game.currentStage = GameRules.initialStage;
    _settingsOpen = false;
    game.goHome();
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
      ..size = Vector2(size.x * .60, 32)
      ..position = Vector2(size.x * .20, size.y * .302);
    _settings
      ..size = Vector2(size.x * .145, size.y * .060)
      ..position = Vector2(size.x * .805, size.y * .022)
      ..priority = 2000;
    _settingsClose
      ..size = Vector2(size.x * .09, size.y * .050)
      ..position = Vector2(size.x * .82, size.y * .090)
      ..priority = 2200;
    _settingsMusic
      ..size = Vector2(size.x * .72, size.y * .060)
      ..position = Vector2(size.x * .14, size.y * .245)
      ..priority = 2200;
    _settingsReset
      ..size = Vector2(size.x * .35, size.y * .062)
      ..position = Vector2(size.x * .13, size.y * .812)
      ..priority = 2200;
    _settingsContinue
      ..size = Vector2(size.x * .35, size.y * .062)
      ..position = Vector2(size.x * .52, size.y * .812)
      ..priority = 2200;
  }

  Future<void> _choose(DoorSide side) async {
    if (_settingsOpen || session.phase != SessionPhase.playing || _transitioning || _inputCooldown > 0) {
      return;
    }
    _inputCooldown = .016;
    final result = session.choose(side);
    final door = side == DoorSide.left ? leftDoor : rightDoor;
    door.open(correct: result != ChoiceResult.wrong);
    unawaited(game.audioManager.playDoorOpen());
    if (result == ChoiceResult.wrong) {
      unawaited(HapticFeedback.heavyImpact());
    } else {
      unawaited(HapticFeedback.selectionClick());
    }
    if (result == ChoiceResult.wrong) {
      _feedbackText = 'X';
      _feedbackTimer = .55;
      feedback.playWrong();
      unawaited(game.audioManager.playWrong());
      _transitioning = true;
      transitionDelay = .44;
      return;
    }
    feedback.playCorrect();
    progress.setCurrent(session.step);
    _feedbackText = 'O';
    _feedbackTimer = .20;
    if (result == ChoiceResult.clear) {
      _transitioning = true;
      transitionDelay = .34;
      unawaited(game.audioManager.playClear(
        milestoneStage: [5, 10, 15, 20].contains(session.stage),
      ));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_settingsOpen) return;
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
      _feedbackText = 'X';
      _feedbackTimer = .6;
      feedback.playWrong();
      unawaited(HapticFeedback.heavyImpact());
      unawaited(game.audioManager.playWrong());
      _transitioning = true;
      transitionDelay = .44;
    }
    if (_transitioning) {
      transitionDelay -= dt;
      if (transitionDelay <= 0) {
        if (session.phase == SessionPhase.cleared) {
          game.showResult(clear: true, stage: session.stage, elapsedSeconds: elapsed);
        } else if (session.phase == SessionPhase.failed) {
          game.showResult(clear: false, stage: session.stage, elapsedSeconds: elapsed);
        }
      }
    }
  }

  void _center(Canvas canvas, String text, double y, double fs, Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fs, fontWeight: weight, color: color)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  void _drawSettingsOverlay(Canvas canvas) {
    final p = game.progressStore.load();
    GameHelpOverlay.draw(
      canvas,
      size.x,
      size.y,
      currentStage: game.currentStage,
      bestStage: p.bestStage,
      bgmEnabled: game.audioManager.bgmEnabled,
    );
  }

  @override
  void render(Canvas canvas) {
    final shake = feedback.shakeActive ? sin(elapsed * 170) * 4 : 0.0;
    canvas.save();
    canvas.translate(shake, 0);
    _bg.render(canvas, position: Vector2(0, -size.y * .035), size: Vector2(size.x, size.y * 1.035));

    // Clean top HUD. The gear lives above and outside this card, so borders never intersect.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y * .350), Paint()..color = const Color(0xFF15082F));
    final topCard = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .075, size.y * .080, size.x * .85, size.y * .235),
      const Radius.circular(25),
    );
    canvas.drawRRect(topCard, Paint()..color = const Color(0xFF1B0C3A));
    canvas.drawRRect(topCard, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0x88FFD96A));

    _center(canvas, '기억의 문을 여세요!', size.y * .102, 26, const Color(0xFFFFD96A), FontWeight.w900);
    _center(canvas, stageRealmLabel(session.stage), size.y * .153, 13.5, const Color(0xFFDCCBFF), FontWeight.w800);
    _center(
      canvas,
      'STAGE ${session.stage}   ${min(session.step + 1, session.route.length)} / ${session.route.length}',
      size.y * .180,
      14.5,
      const Color(0xFFFFFFFF),
      FontWeight.w800,
    );

    final remain = (GameRules.playSeconds - elapsed).clamp(0.0, GameRules.playSeconds);
    // No oval timer box: centered text only, with enough vertical breathing room.
    _center(
      canvas,
      '${remain.toStringAsFixed(1)}초',
      size.y * .226,
      28,
      remain < 2.5 ? const Color(0xFFFF7777) : const Color(0xFFFFE08B),
      FontWeight.w900,
    );

    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);

    if (_feedbackTimer > 0) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .43, size.y * .348, size.x * .14, 44),
        const Radius.circular(22),
      );
      canvas.drawRRect(rr, Paint()..color = const Color(0xD91B0E38));
      _center(
        canvas,
        _feedbackText,
        size.y * .354,
        24,
        _feedbackText == 'O' ? const Color(0xFF8DFF9E) : const Color(0xFFFF6D86),
        FontWeight.w900,
      );
    }

    if (feedback.flashKind != FlashKind.none) {
      final alpha = (42 * (1 - feedback.elapsed / .25).clamp(0, 1)).round();
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
    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
