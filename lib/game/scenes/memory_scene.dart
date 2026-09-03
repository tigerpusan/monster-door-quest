import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';
import '../ui/v5_image_ui.dart';

class MemoryScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  MemoryScene(this.session, this.memorySeconds);

  final GameSessionState session;
  final double? memorySeconds;
  late V5ImageUI _v5;
  late TapZone _ready;
  late TapZone _settings;
  late TapZone _settingsClose;
  late TapZone _settingsContinue;
  late TapZone _settingsMusic;
  late TapZone _settingsReset;
  double elapsed = 0;
  bool _transitioned = false;
  bool _settingsOpen = false;

  @override
  Future<void> onLoad() async {
    _v5 = await V5ImageUI.load();
    _ready = TapZone(onTap: _goDoor, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsMusic = TapZone(onTap: _toggleBgm, triggerOnDown: true);
    _settingsReset = TapZone(onTap: _resetChallenge, triggerOnDown: true);
    addAll([_ready, _settings, _settingsClose, _settingsContinue, _settingsMusic, _settingsReset]);
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
    _placeZone(_ready, Rect.fromLTWH(size.x * .14, size.y * .862, size.x * .72, size.y * .104), priority: 1000);
    _placeZone(_settings, GameHelpOverlay.settingsButtonRect(size.x, size.y), priority: 2000);
    _syncSettingsZones();
  }

  void _toggleSettings() {
    _settingsOpen = !_settingsOpen;
    _syncSettingsZones();
  }

  void _closeSettings() {
    _settingsOpen = false;
    _syncSettingsZones();
  }

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

  void _goDoor() {
    if (_settingsOpen || _transitioned) return;
    _transitioned = true;
    game.showDoorScene(session);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (memorySeconds != null && !_transitioned && !_settingsOpen) {
      elapsed += dt;
      if (elapsed >= memorySeconds! && isMounted) _goDoor();
    }
  }

  void _drawLiveMemory(Canvas canvas) {
    V5ImageUI.text(
      canvas,
      'STAGE ${session.stage} · ${session.route.length} DOORS',
      Rect.fromLTWH(size.x * .18, size.y * .265, size.x * .64, size.y * .045),
      19,
      const Color(0xFF173F70),
      FontWeight.w900,
    );

    final count = session.route.length;
    final listTop = size.y * .340;
    final listBottom = size.y * .735;
    final totalH = listBottom - listTop;
    final gap = count >= 12 ? 4.0 : count >= 9 ? 6.0 : 10.0;
    final rowH = ((totalH - gap * (count - 1)) / count).clamp(25.0, 72.0);

    for (var i = 0; i < count; i++) {
      final isLeft = session.route[i].name == 'left';
      final y = listTop + i * (rowH + gap);
      final r = Rect.fromLTWH(size.x * .145, y, size.x * .71, rowH);
      final rr = RRect.fromRectAndRadius(r, Radius.circular(rowH / 2));
      canvas.drawRRect(rr.shift(const Offset(0, 3)), Paint()..color = const Color(0x33214D78));
      canvas.drawRRect(rr, Paint()..color = isLeft ? const Color(0xFF176ED8) : const Color(0xFFFF3E74));
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = const Color(0xFFFFB531),
      );
      final fs = (rowH * .48).clamp(14.0, 27.0);
      V5ImageUI.text(
        canvas,
        isLeft ? '←  왼쪽' : '오른쪽  →',
        r,
        fs,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
    }

    final remain = memorySeconds == null ? 0.0 : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    final timer = memorySeconds == null ? '기억 시간 준비' : '기억 시간 ${remain.toStringAsFixed(1)}초';
    V5ImageUI.text(
      canvas,
      timer,
      Rect.fromLTWH(size.x * .27, size.y * .777, size.x * .46, size.y * .040),
      18,
      const Color(0xFF9C5700),
      FontWeight.w900,
    );
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
    _v5.drawFull(canvas, size, _v5.memory);
    _drawLiveMemory(canvas);
    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
