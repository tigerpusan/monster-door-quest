import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';
import '../ui/v5_image_ui.dart';
import '../ui/responsive_game_layout.dart';

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
    final ui = ResponsiveGameLayout(size.x, size.y);
    _placeZone(_ready, ui.rect(.13, .866, .74, .085), priority: 1000);
    _placeZone(_settings, GameHelpOverlay.settingsButtonRect(size.x, size.y), priority: 2000);
    _syncSettingsZones();
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

  void _drawDirectionPill(Canvas canvas, Rect r, {required bool isLeft, required double fontSize}) {
    final rr = RRect.fromRectAndRadius(r, Radius.circular(r.height / 2));
    canvas.drawRRect(rr.shift(const Offset(0, 3)), Paint()..color = const Color(0x33214D78));
    canvas.drawRRect(rr, Paint()..color = isLeft ? const Color(0xFF176ED8) : const Color(0xFFFF3E74));
    canvas.drawRRect(
      rr,
      Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..color = const Color(0xFFFFB531),
    );
    // Direction is always shown as a single icon+label unit.
    // Never render an arrow by itself: LEFT = "← 왼쪽", RIGHT = "오른쪽 →".
    final label = isLeft ? '←  왼쪽' : '오른쪽  →';
    V5ImageUI.text(
      canvas,
      label,
      r,
      fontSize,
      const Color(0xFFFFFFFF),
      FontWeight.w900,
    );
  }

  void _drawLiveMemory(Canvas canvas) {
    final ui = ResponsiveGameLayout(size.x, size.y);

    // Only changing values are drawn at runtime. The template already owns the visual frame.
    V5ImageUI.text(
      canvas,
      'STAGE ${session.stage} · ${session.route.length} DOORS',
      ui.rect(.17, .287, .66, .050),
      17.0,
      const Color(0xFF173F70),
      FontWeight.w900,
    );

    final count = session.route.length;
    final listTop = ui.y(.345);
    final listBottom = ui.y(.780);
    final availableH = listBottom - listTop;
    final gap = count <= 5 ? 10.0 : count <= 8 ? 7.0 : count <= 11 ? 4.0 : 2.5;
    final totalGap = gap * (count - 1);
    final rowH = ((availableH - totalGap) / count).clamp(19.0, 74.0).toDouble();
    final usedH = rowH * count + totalGap;
    final firstY = listTop + (availableH - usedH) / 2;
    final rowLeft = ui.x(.155);
    final rowWidth = ui.w(.69);

    for (var i = 0; i < count; i++) {
      final isLeft = session.route[i].name == 'left';
      final r = Rect.fromLTWH(rowLeft, firstY + i * (rowH + gap), rowWidth, rowH);
      final fs = (rowH * .45).clamp(11.0, 27.0).toDouble();
      _drawDirectionPill(canvas, r, isLeft: isLeft, fontSize: fs);
    }

    final remain = memorySeconds == null ? 0.0 : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    final timer = memorySeconds == null ? '기억 시간  준비' : '기억 시간  ${remain.toStringAsFixed(1)}초';
    V5ImageUI.text(
      canvas,
      timer,
      ui.rect(.20, .797, .60, .055),
      20.5,
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
