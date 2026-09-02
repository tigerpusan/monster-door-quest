import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';
import '../ui/v5_image_ui.dart';

class IntroScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  late V5ImageUI _v5;
  late TapZone _start;
  late TapZone _settings;
  late TapZone _settingsClose;
  late TapZone _settingsContinue;
  late TapZone _settingsMusic;
  late TapZone _settingsReset;
  bool _settingsOpen = false;

  @override
  Future<void> onLoad() async {
    _v5 = await V5ImageUI.load();
    _start = TapZone(onTap: _startGame, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsMusic = TapZone(onTap: _toggleBgm, triggerOnDown: true);
    _settingsReset = TapZone(onTap: _resetChallenge, triggerOnDown: true);
    addAll([_start, _settings, _settingsClose, _settingsContinue, _settingsMusic, _settingsReset]);
  }

  void _startGame() {
    if (_settingsOpen) return;
    game.startCurrentStage();
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

  void _hideZone(TapZone zone) => zone..size = Vector2.zero()..position = Vector2.zero();
  void _placeZone(TapZone zone, Rect r, {int? priority}) {
    zone..size = Vector2(r.width, r.height)..position = Vector2(r.left, r.top);
    if (priority != null) zone.priority = priority;
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

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _placeZone(_start, Rect.fromLTWH(size.x * .145, size.y * .846, size.x * .71, size.y * .105), priority: 1000);
    _placeZone(_settings, GameHelpOverlay.settingsButtonRect(size.x, size.y), priority: 2000);
    _syncSettingsZones();
  }

  void _drawLiveProgress(Canvas canvas) {
    final progress = game.progressStore.load();
    final stage = game.currentStage;
    final best = progress.bestStage;
    final labels = ['인간 I', '인간 II', '인간 III', '초인 I', '초인 II', '초인 III', '신'];
    final active = currentRealmIndex(stage).clamp(0, labels.length - 1);

    // Preserve the artwork's outer frame. Remove only the baked sample contents.
    V5ImageUI.roundedCover(
      canvas,
      Rect.fromLTWH(size.x * .066, size.y * .286, size.x * .868, size.y * .120),
      const Color(0xFFFFF7E8),
      radius: 18,
    );

    V5ImageUI.text(
      canvas,
      '현재 진행   ${stageRealmLabel(stage)}   ·   STAGE $stage   ·   최고 ${best == 0 ? '-' : best}',
      Rect.fromLTWH(size.x * .11, size.y * .294, size.x * .78, size.y * .034),
      12.6,
      const Color(0xFF173F70),
      FontWeight.w900,
    );

    final x1 = size.x * .13;
    final x2 = size.x * .87;
    final y = size.y * .351;
    final step = (x2 - x1) / (labels.length - 1);
    canvas.drawLine(Offset(x1, y), Offset(x2, y), Paint()..color = const Color(0xFF9B95C7)..strokeWidth = 2.3);
    for (var i = 0; i < labels.length; i++) {
      final x = x1 + step * i;
      final isActive = i == active;
      canvas.drawCircle(Offset(x, y), isActive ? 10 : 8, Paint()..color = isActive ? const Color(0xFF2C78F3) : const Color(0xFF625477));
      canvas.drawCircle(Offset(x, y), isActive ? 10 : 8, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xFFFFFFFF));
      V5ImageUI.text(
        canvas,
        labels[i],
        Rect.fromLTWH(x - size.x * .06, y + 8, size.x * .12, size.y * .025),
        8.4,
        isActive ? const Color(0xFF2D69B1) : const Color(0xFF625477),
        FontWeight.w900,
      );
    }
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
    _v5.drawFull(canvas, size, _v5.intro);
    _drawLiveProgress(canvas);
    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
