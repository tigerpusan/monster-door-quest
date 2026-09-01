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
import '../ui/pixel_art_kit.dart';

class DoorScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  DoorScene(this.session);

  final GameSessionState session;
  late PixelArtKit _pixelArt;
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
    _pixelArt = await PixelArtKit.load();
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
    final settingsRect = GameHelpOverlay.settingsButtonRect(size.x, size.y);
    _settings
      ..size = Vector2(settingsRect.width, settingsRect.height)
      ..position = Vector2(settingsRect.left, settingsRect.top)
      ..priority = 2000;
    final closeRect = GameHelpOverlay.closeRect(size.x, size.y);
    _settingsClose
      ..size = Vector2(closeRect.width, closeRect.height)
      ..position = Vector2(closeRect.left, closeRect.top)
      ..priority = 2200;
    final musicRect = GameHelpOverlay.musicRect(size.x, size.y);
    _settingsMusic
      ..size = Vector2(musicRect.width, musicRect.height)
      ..position = Vector2(musicRect.left, musicRect.top)
      ..priority = 2200;
    final resetRect = GameHelpOverlay.resetRect(size.x, size.y);
    _settingsReset
      ..size = Vector2(resetRect.width, resetRect.height)
      ..position = Vector2(resetRect.left, resetRect.top)
      ..priority = 2200;
    final continueRect = GameHelpOverlay.continueRect(size.x, size.y);
    _settingsContinue
      ..size = Vector2(continueRect.width, continueRect.height)
      ..position = Vector2(continueRect.left, continueRect.top)
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
    if (result != ChoiceResult.clear) {
      unawaited(game.audioManager.playCorrect());
    }
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
      pixelArt: _pixelArt,
    );
  }

  @override
  void render(Canvas canvas) {
    final shake = feedback.shakeActive ? sin(elapsed * 170) * 4 : 0.0;
    canvas.save();
    canvas.translate(shake, 0);
    _pixelArt.renderBackground(canvas, size);
    _pixelArt.renderHero(canvas, size, x: .39, y: .70, scale: .22);

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y * .366), Paint()..color = const Color(0xEFFFF8E8));
    final topCard = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .070, size.y * .084, size.x * .84, size.y * .248),
      const Radius.circular(25),
    );
    canvas.drawRRect(topCard, Paint()..color = const Color(0xFFF7FFF0));
    canvas.drawRRect(topCard, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xFF4F86BF));

    _center(canvas, '기억의 문을 여세요!', size.y * .105, 25.5, const Color(0xFF174B87), FontWeight.w900);
    _center(canvas, stageRealmLabel(session.stage), size.y * .158, 13.8, const Color(0xFF52779A), FontWeight.w800);
    _center(
      canvas,
      'STAGE ${session.stage}   ${min(session.step + 1, session.route.length)} / ${session.route.length}',
      size.y * .190,
      14.5,
      const Color(0xFF1C456D),
      FontWeight.w800,
    );

    final remain = (GameRules.playSeconds - elapsed).clamp(0.0, GameRules.playSeconds);
    final timerRect = Rect.fromLTWH(size.x * .24, size.y * .222, size.x * .52, size.y * .060);
    final timerPainter = TextPainter(
      text: TextSpan(
        text: '${remain.toStringAsFixed(1)}초',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: remain < 2.5 ? const Color(0xFFE65353) : const Color(0xFFB66A00),
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: timerRect.width);
    timerPainter.paint(
      canvas,
      Offset(
        timerRect.left + (timerRect.width - timerPainter.width) / 2,
        timerRect.top + (timerRect.height - timerPainter.height) / 2,
      ),
    );

    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);

    if (_feedbackTimer > 0) {
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .43, size.y * .348, size.x * .14, 44),
        const Radius.circular(22),
      );
      canvas.drawRRect(rr, Paint()..color = const Color(0xEFFFFFF2));
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
