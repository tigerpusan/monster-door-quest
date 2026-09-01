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
    addAll([
      _ready,
      _settings,
      _settingsClose,
      _settingsContinue,
      _settingsMusic,
      _settingsReset,
    ]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _ready
      ..size = Vector2(size.x * .74, size.y * .072)
      ..position = Vector2(size.x * .13, size.y * .894);
    _settings
      ..size = Vector2(size.x * .145, size.y * .060)
      ..position = Vector2(size.x * .805, size.y * .022);
    _settingsClose
      ..size = Vector2(size.x * .09, size.y * .050)
      ..position = Vector2(size.x * .82, size.y * .090);
    _settingsMusic
      ..size = Vector2(size.x * .72, size.y * .060)
      ..position = Vector2(size.x * .14, size.y * .245);
    _settingsReset
      ..size = Vector2(size.x * .35, size.y * .062)
      ..position = Vector2(size.x * .13, size.y * .812);
    _settingsContinue
      ..size = Vector2(size.x * .35, size.y * .062)
      ..position = Vector2(size.x * .52, size.y * .812);
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
    double? maxWidth,
    double yOffset = 0,
    TextAlign align = TextAlign.center,
    double height = 1.12,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color, height: height),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth ?? rect.width);
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
    );
  }

  @override
  void render(Canvas canvas) {
    _pixelArt.renderBackground(canvas, size);
    GameHelpOverlay.drawSettingsButton(canvas, size.x, size.y);

    final panelRect = Rect.fromLTWH(size.x * .05, size.y * .090, size.x * .90, size.y * .770);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(30));
    canvas.drawRRect(panel, Paint()..color = const Color(0xF5FFF8E8));
    canvas.drawRRect(panel, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.5..color = const Color(0xFF3A76B7));
    canvas.drawRRect(panel.deflate(10), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = const Color(0x99FFFFFF));

    _drawText(
      canvas,
      '문 순서를 기억하세요',
      Rect.fromLTWH(size.x * .10, size.y * .120, size.x * .80, size.y * .044),
      27,
      const Color(0xFF174B87),
      FontWeight.w900,
    );
    _drawText(
      canvas,
      'STAGE ${session.stage} · ${session.route.length} DOORS',
      Rect.fromLTWH(size.x * .18, size.y * .176, size.x * .64, size.y * .024),
      15,
      const Color(0xFF2F5F8A),
      FontWeight.w800,
    );

    final count = session.route.length;
    final listTop = size.y * .224;
    final timerTop = size.y * .790;
    final listBottom = timerTop - size.y * .040;
    final listHeight = listBottom - listTop;
    final gap = count >= 14 ? 4.0 : count >= 10 ? 6.0 : 8.0;
    final rowHeight = ((listHeight - gap * (count - 1)) / count).clamp(24.0, 58.0);

    for (var i = 0; i < count; i++) {
      final isLeft = session.route[i].name == 'left';
      final y = listTop + i * (rowHeight + gap);
      final rowRect = Rect.fromLTWH(size.x * .17, y, size.x * .66, rowHeight);
      final rr = RRect.fromRectAndRadius(rowRect, Radius.circular(rowHeight / 2));
      canvas.drawRRect(rr, Paint()..color = isLeft ? const Color(0xFF5A91E8) : const Color(0xFFFF7EA8));
      canvas.drawRRect(rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 2..color = const Color(0xFFFFC84B));
      final fontSize = (rowHeight * (count >= 14 ? .42 : .48)).clamp(14.0, 25.0);
      _drawText(
        canvas,
        isLeft ? '← 왼쪽' : '오른쪽 →',
        rowRect,
        fontSize,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
        yOffset: -0.5,
      );
    }

    final remain = memorySeconds == null ? 0.0 : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    final timerText = memorySeconds == null ? '준비되면 바로 도전하세요' : '기억 시간  ${remain.toStringAsFixed(1)}초';
    _drawText(
      canvas,
      timerText,
      Rect.fromLTWH(size.x * .16, timerTop, size.x * .68, size.y * .052),
      19,
      const Color(0xFF9A5C00),
      FontWeight.w900,
    );

    final btnRect = Rect.fromLTWH(size.x * .13, size.y * .894, size.x * .74, size.y * .072);
    final btn = RRect.fromRectAndRadius(btnRect, const Radius.circular(28));
    canvas.drawRRect(btn, Paint()..color = _ready.pressed ? const Color(0xFF4AC75B) : const Color(0xFF76E56D));
    canvas.drawRRect(btn, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.8..color = const Color(0xFFFFFFFF));
    _drawText(canvas, _ready.pressed ? '도전!' : '기억 완료 · 도전!', btnRect, 20,
        const Color(0xFF12341B), FontWeight.w900, yOffset: -1);

    if (_settingsOpen) _drawSettingsOverlay(canvas);
  }
}
