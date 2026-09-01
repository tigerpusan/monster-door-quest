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
import '../ui/v5_image_ui.dart';

class DoorScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  DoorScene(this.session);

  final GameSessionState session;
  late PixelArtKit _pixelArt;
  late V5ImageUI _v5;
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
    _v5 = await V5ImageUI.load();
    session.beginDoorRun();
    leftDoor = DoorComponent(side: DoorSide.left, onSelected: _choose);
    rightDoor = DoorComponent(side: DoorSide.right, onSelected: _choose);
    progress = RouteProgress(total: session.route.length);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsMusic = TapZone(onTap: _toggleBgm, triggerOnDown: true);
    _settingsReset = TapZone(onTap: _resetChallenge, triggerOnDown: true);
    addAll([leftDoor, rightDoor, progress, _settings, _settingsClose, _settingsContinue, _settingsMusic, _settingsReset]);
  }

  void _hideZone(TapZone z) => z..size = Vector2.zero()..position = Vector2.zero();
  void _placeZone(TapZone z, Rect r, {int? priority}) {
    z..size = Vector2(r.width, r.height)..position = Vector2(r.left, r.top);
    if (priority != null) z.priority = priority;
  }

  void _syncSettingsZones() {
    if (size.x <= 0 || size.y <= 0) return;
    if (_settingsOpen) {
      _placeZone(_settingsClose, GameHelpOverlay.closeRect(size.x, size.y), priority: 2200);
      _placeZone(_settingsMusic, GameHelpOverlay.musicRect(size.x, size.y), priority: 2200);
      _placeZone(_settingsReset, GameHelpOverlay.resetRect(size.x, size.y), priority: 2200);
      _placeZone(_settingsContinue, GameHelpOverlay.continueRect(size.x, size.y), priority: 2200);
    } else {
      _hideZone(_settingsClose); _hideZone(_settingsMusic); _hideZone(_settingsReset); _hideZone(_settingsContinue);
    }
  }

  void _toggleSettings() { _settingsOpen = !_settingsOpen; _syncSettingsZones(); }
  void _closeSettings() { _settingsOpen = false; _syncSettingsZones(); }

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

    // V5: move the interactive world lower and give the castle its own visible band.
    leftDoor
      ..size = Vector2(size.x * .35, size.y * .34)
      ..position = Vector2(size.x * .075, size.y * .455);
    rightDoor
      ..size = Vector2(size.x * .35, size.y * .34)
      ..position = Vector2(size.x * .575, size.y * .455);
    progress
      ..size = Vector2(size.x * .56, 24)
      ..position = Vector2(size.x * .22, size.y * .302);

    _placeZone(_settings, GameHelpOverlay.settingsButtonRect(size.x, size.y), priority: 2000);
    _syncSettingsZones();
  }

  Future<void> _choose(DoorSide side) async {
    if (_settingsOpen || session.phase != SessionPhase.playing || _transitioning || _inputCooldown > 0) return;
    _inputCooldown = .016;
    final result = session.choose(side);
    final door = side == DoorSide.left ? leftDoor : rightDoor;
    door.open(correct: result != ChoiceResult.wrong);
    if (result == ChoiceResult.wrong) {
      unawaited(HapticFeedback.heavyImpact());
      _feedbackText = 'X'; _feedbackTimer = .55; feedback.playWrong();
      unawaited(game.audioManager.playWrong());
      _transitioning = true; transitionDelay = .44; return;
    }
    unawaited(HapticFeedback.selectionClick());
    feedback.playCorrect();
    if (result != ChoiceResult.clear) unawaited(game.audioManager.playCorrect());
    progress.setCurrent(session.step);
    _feedbackText = 'O'; _feedbackTimer = .20;
    if (result == ChoiceResult.clear) {
      _transitioning = true; transitionDelay = .34;
      unawaited(game.audioManager.playClear(milestoneStage: [5,10,15,20].contains(session.stage)));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_settingsOpen) return;
    elapsed += dt;
    feedback.update(dt);
    if (_inputCooldown > 0) _inputCooldown = (_inputCooldown - dt).clamp(0,1).toDouble();
    if (_feedbackTimer > 0) _feedbackTimer = (_feedbackTimer - dt).clamp(0,1).toDouble();
    if (session.phase == SessionPhase.playing && elapsed >= GameRules.playSeconds && !_transitioning) {
      session.phase = SessionPhase.failed;
      _feedbackText = 'X'; _feedbackTimer = .6; feedback.playWrong();
      unawaited(HapticFeedback.heavyImpact()); unawaited(game.audioManager.playWrong());
      _transitioning = true; transitionDelay = .44;
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
      v5: _v5,
    );
  }

  @override
  void render(Canvas canvas) {
    final shake = feedback.shakeActive ? sin(elapsed * 170) * 4 : 0.0;
    canvas.save();
    canvas.translate(shake, 0);

    _pixelArt.renderBackground(canvas, size, showPath: true, rich: false);
    // Larger, fully visible castle below the top panel.
    _pixelArt.renderCastle(canvas, size, x: .335, y: .355, width: .33, height: .245);
    _pixelArt.renderTrees(canvas, size, top: .58, leftScale: .20, rightScale: .20);
    _pixelArt.renderHero(canvas, size, x: .355, y: .755, scale: .30);

    // Compact top panel; progress dots live inside it and no longer overlap the timer.
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y * .345), Paint()..color = const Color(0xF4FFF8E8));
    final cardRect = Rect.fromLTWH(size.x * .07, size.y * .082, size.x * .84, size.y * .248);
    final card = RRect.fromRectAndRadius(cardRect, const Radius.circular(25));
    canvas.drawRRect(card, Paint()..color = const Color(0xFFF9FFF2));
    canvas.drawRRect(card, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..color = const Color(0xFF4F86BF));

    _center(canvas, '기억의 문을 여세요!', size.y * .108, 25.5, const Color(0xFF174B87), FontWeight.w900);
    _center(canvas, stageRealmLabel(session.stage), size.y * .158, 13.8, const Color(0xFF52779A), FontWeight.w800);
    _center(canvas, 'STAGE ${session.stage}   ${min(session.step + 1, session.route.length)} / ${session.route.length}', size.y * .190, 14.5, const Color(0xFF1C456D), FontWeight.w800);
    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);

    final remain = (GameRules.playSeconds - elapsed).clamp(0.0, GameRules.playSeconds);
    _center(
      canvas,
      '${remain.toStringAsFixed(1)}초',
      size.y * .226,
      28,
      remain < 2.5 ? const Color(0xFFE65353) : const Color(0xFFB66A00),
      FontWeight.w900,
    );

    if (_feedbackTimer > 0) {
      final rr = RRect.fromRectAndRadius(Rect.fromLTWH(size.x * .43, size.y * .355, size.x * .14, 42), const Radius.circular(22));
      canvas.drawRRect(rr, Paint()..color = const Color(0xEFFFFFF2));
      _center(canvas, _feedbackText, size.y * .360, 24, _feedbackText == 'O' ? const Color(0xFF48D96D) : const Color(0xFFFF5A73), FontWeight.w900);
    }

    if (feedback.flashKind != FlashKind.none) {
      final alpha = (42 * (1 - feedback.elapsed / .25).clamp(0,1)).round();
      canvas.drawRect(size.toRect(), Paint()..color = (feedback.flashKind == FlashKind.correct ? const Color(0xFF6FFF98) : const Color(0xFFFF4C6E)).withAlpha(alpha));
    }
    canvas.restore();
    super.render(canvas);
    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
