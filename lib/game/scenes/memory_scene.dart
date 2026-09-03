import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show FontWeight;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';
import '../ui/game_help_overlay.dart';
import '../ui/settings_overlay_layer.dart';
import '../ui/v5_image_ui.dart';

class MemoryScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  MemoryScene(this.session, this.memorySeconds);

  final GameSessionState session;
  final double? memorySeconds;
  late V5ImageUI _v5;
  late TapZone _ready;
  late TapZone _settings;
  late SettingsOverlayLayer _settingsLayer;
  double elapsed = 0;
  bool _transitioned = false;

  @override
  Future<void> onLoad() async {
    _v5 = await V5ImageUI.load();
    _ready = TapZone(onTap: _goDoor, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsLayer = SettingsOverlayLayer(v5: _v5)..priority = 10000;
    addAll([_ready, _settings, _settingsLayer]);
  }

  void _placeZone(TapZone z, Rect r, {int? priority}) {
    z
      ..size = Vector2(r.width, r.height)
      ..position = Vector2(r.left, r.top);
    if (priority != null) z.priority = priority;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _placeZone(_ready, Rect.fromLTWH(size.x * .14, size.y * .862, size.x * .72, size.y * .104), priority: 1000);
    _placeZone(_settings, GameHelpOverlay.settingsButtonRect(size.x, size.y), priority: 2000);
    _settingsLayer.resizeTo(size);
  }

  void _toggleSettings() {
    if (_settingsLayer.isOpen) {
      _settingsLayer.close();
    } else {
      _settingsLayer.open();
    }
  }

  void _goDoor() {
    if (_settingsLayer.isOpen || _transitioned) return;
    _transitioned = true;
    game.showDoorScene(session);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (memorySeconds != null && !_transitioned && !_settingsLayer.isOpen) {
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

  @override
  void render(Canvas canvas) {
    _v5.drawFull(canvas, size, _v5.memory);
    _drawLiveMemory(canvas);
  }
}
