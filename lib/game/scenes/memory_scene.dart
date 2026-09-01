import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';
import '../ui/pixel_art_kit.dart';

class MemoryScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  MemoryScene(this.session, this.memorySeconds);

  final GameSessionState session;
  final double? memorySeconds;
  late PixelArtKit _pixelArt;
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
    _pixelArt = await PixelArtKit.load();
    _ready = TapZone(onTap: _goDoor, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsMusic = TapZone(onTap: _toggleBgm, triggerOnDown: true);
    _settingsReset = TapZone(onTap: _resetChallenge, triggerOnDown: true);
    addAll([_ready, _settings, _settingsClose, _settingsContinue, _settingsMusic, _settingsReset]);
  }

  void _hideZone(TapZone zone) { zone..size = Vector2.zero()..position = Vector2.zero(); }

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

  void _placeZone(TapZone zone, Rect r, {int? priority}) {
    zone
      ..size = Vector2(r.width, r.height)
      ..position = Vector2(r.left, r.top);
    if (priority != null) zone.priority = priority;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _placeZone(_ready, Rect.fromLTWH(size.x * .13, size.y * .894, size.x * .74, size.y * .072));
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

  void _drawText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    double yOffset = 0,
    TextAlign align = TextAlign.center,
    double height = 1.12,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color, height: height)),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: rect.width);
    final dx = align == TextAlign.center ? rect.left + (rect.width - tp.width) / 2 : rect.left;
    final dy = rect.top + (rect.height - tp.height) / 2 + yOffset;
    tp.paint(canvas, Offset(dx, dy));
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
    _pixelArt.renderBackground(canvas, size, showCastle: false, showTrees: true, rich: true);
    _pixelArt.renderCastle(canvas, size, x: .37, y: .035, width: .26, height: .19);
    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);

    final panelRect = Rect.fromLTWH(size.x * .055, size.y * .120, size.x * .89, size.y * .742);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(30));
    canvas.drawRRect(panel.shift(const Offset(0, 5)), Paint()..color = const Color(0x330B3768));
    canvas.drawRRect(panel, Paint()..color = const Color(0xFAFFF8E8));
    canvas.drawRRect(panel, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.6..color = const Color(0xFF3477BB));
    canvas.drawRRect(panel.deflate(10), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = const Color(0x77FFFFFF));

    _drawText(
      canvas,
      '문 순서를 기억하세요',
      Rect.fromLTWH(size.x * .10, size.y * .145, size.x * .80, size.y * .050),
      28,
      const Color(0xFF174B87),
      FontWeight.w900,
    );
    _drawText(
      canvas,
      '✦  STAGE ${session.stage} · ${session.route.length} DOORS  ✦',
      Rect.fromLTWH(size.x * .18, size.y * .200, size.x * .64, size.y * .028),
      14.6,
      const Color(0xFF2F5F8A),
      FontWeight.w900,
    );

    final count = session.route.length;
    final listTop = size.y * .258;
    final timerTop = size.y * .775;
    final listBottom = timerTop - size.y * .028;
    final listHeight = listBottom - listTop;
    final gap = count >= 14 ? 4.0 : count >= 10 ? 6.0 : 9.0;
    final rowHeight = ((listHeight - gap * (count - 1)) / count).clamp(24.0, 62.0);

    for (var i = 0; i < count; i++) {
      final isLeft = session.route[i].name == 'left';
      final y = listTop + i * (rowHeight + gap);
      final rowRect = Rect.fromLTWH(size.x * .17, y, size.x * .66, rowHeight);
      final rr = RRect.fromRectAndRadius(rowRect, Radius.circular(rowHeight / 2));
      final fill = isLeft ? const Color(0xFF2F79DB) : const Color(0xFFF15486);
      canvas.drawRRect(rr.shift(const Offset(0, 3)), Paint()..color = const Color(0x330B3768));
      canvas.drawRRect(rr, Paint()..color = fill);
      canvas.drawRRect(rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2..color = const Color(0xFFFFC846));
      canvas.drawRRect(rr.deflate(4), Paint()..style = PaintingStyle.stroke..strokeWidth = .8..color = const Color(0x77FFFFFF));
      final fontSize = (rowHeight * (count >= 14 ? .43 : .50)).clamp(14.0, 26.0);
      _drawText(
        canvas,
        isLeft ? '←  왼쪽' : '오른쪽  →',
        rowRect,
        fontSize,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
        yOffset: -0.5,
      );
    }

    final remain = memorySeconds == null ? 0.0 : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    final timerText = memorySeconds == null ? '⏳  준비되면 바로 도전하세요' : '⏳  기억 시간  ${remain.toStringAsFixed(1)}초';
    _drawText(
      canvas,
      timerText,
      Rect.fromLTWH(size.x * .16, timerTop, size.x * .68, size.y * .052),
      19,
      const Color(0xFFA55E00),
      FontWeight.w900,
    );

    final btnRect = Rect.fromLTWH(size.x * .13, size.y * .894, size.x * .74, size.y * .072);
    final btn = RRect.fromRectAndRadius(btnRect, const Radius.circular(28));
    canvas.drawRRect(btn.shift(const Offset(0, 4)), Paint()..color = const Color(0x44246016));
    canvas.drawRRect(btn, Paint()..color = _ready.pressed ? const Color(0xFF4FCB50) : const Color(0xFF72E83D));
    canvas.drawRRect(btn, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.8..color = const Color(0xFF174B87));
    _drawText(canvas, _ready.pressed ? '도전!' : '✦  기억 완료 · 도전!  ✦', btnRect, 20,
        const Color(0xFF12341B), FontWeight.w900, yOffset: -1);

    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
