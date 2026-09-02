import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight;
import '../core/game_rules.dart';
import '../components/tap_zone.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';
import '../ui/v5_image_ui.dart';
import '../ui/responsive_game_layout.dart';

class ResultScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  ResultScene({required this.clear, required this.stage, required this.elapsedSeconds});

  final bool clear;
  final int stage;
  final double elapsedSeconds;
  late V5ImageUI _v5;
  late TapZone _primary;
  late TapZone _settings;
  late TapZone _settingsClose;
  late TapZone _settingsContinue;
  late TapZone _settingsMusic;
  late TapZone _settingsReset;
  bool _handled = false;
  bool _settingsOpen = false;

  @override
  Future<void> onLoad() async {
    _v5 = await V5ImageUI.load();
    _primary = TapZone(onTap: _goNext, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsMusic = TapZone(onTap: _toggleBgm, triggerOnDown: true);
    _settingsReset = TapZone(onTap: _resetChallenge, triggerOnDown: true);
    addAll([_primary, _settings, _settingsClose, _settingsContinue, _settingsMusic, _settingsReset]);
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
      _hideZone(_settingsClose);
      _hideZone(_settingsMusic);
      _hideZone(_settingsReset);
      _hideZone(_settingsContinue);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    final ui = ResponsiveGameLayout(size.x, size.y);
    _placeZone(_primary, clear ? ui.rect(.12, .872, .76, .080) : ui.rect(.14, .865, .72, .110), priority: 1000);
    _hideZone(_settings);
    _syncSettingsZones();
  }

  void _toggleSettings() { _settingsOpen = !_settingsOpen; _syncSettingsZones(); }
  void _closeSettings() { _settingsOpen = false; _syncSettingsZones(); }

  void _toggleBgm() {
    if (!_settingsOpen) return;
    game.audioManager.bgmEnabled = !game.audioManager.bgmEnabled;
    if (game.audioManager.bgmEnabled) game.audioManager.startBgm(); else game.audioManager.stopBgm();
  }

  Future<void> _resetChallenge() async {
    if (!_settingsOpen) return;
    await game.progressStore.saveCurrentStage(GameRules.initialStage);
    game.currentStage = GameRules.initialStage;
    _settingsOpen = false;
    game.goHome();
  }

  Future<void> _retryWithPenalty() async {
    final dynamic g = game;
    final targetStage = stage <= 2 ? 1 : stage - 2;
    try { await g.retryWithPenalty(targetStage: targetStage, penaltySteps: 2); return; } catch (_) {}
    try { await g.retryFromStage(targetStage); return; } catch (_) {}
    try { g.currentStage = targetStage; await g.startCurrentStage(); return; } catch (_) {}
    await game.retryCurrentStage();
  }

  void _goNext() {
    if (_settingsOpen || _handled) return;
    _handled = true;
    if (clear) unawaited(game.advanceAfterClear()); else unawaited(_retryWithPenalty());
  }

  void _drawLiveClearData(Canvas canvas) {
    final ui = ResponsiveGameLayout(size.x, size.y);
    V5ImageUI.text(
      canvas,
      '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초',
      ui.rect(.15, .748, .70, .055),
      28,
      const Color(0xFFA45D00),
      FontWeight.w900,
    );
    V5ImageUI.text(
      canvas,
      '${stageRealmLabel(stage)}  ·  STAGE $stage 완료',
      ui.rect(.16, .810, .68, .040),
      16.3,
      const Color(0xFF174B87),
      FontWeight.w900,
    );
  }

  void _drawSettingsOverlay(Canvas canvas) {
    final p = game.progressStore.load();
    GameHelpOverlay.draw(canvas, size.x, size.y, currentStage: game.currentStage, bestStage: p.bestStage, bgmEnabled: game.audioManager.bgmEnabled, v5: _v5);
  }

  @override
  void render(Canvas canvas) {
    if (clear) {
      _v5.drawFull(canvas, size, _v5.clear);
      _drawLiveClearData(canvas);
    } else {
      _v5.drawFull(canvas, size, _v5.fail);
    }
    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
