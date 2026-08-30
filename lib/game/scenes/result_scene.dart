import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../core/game_rules.dart';
import '../components/tap_zone.dart';
import '../monster_door_game.dart';

class ResultScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  ResultScene({required this.clear, required this.stage, required this.elapsedSeconds});

  final bool clear;
  final int stage;
  final double elapsedSeconds;
  late Sprite _bg;
  late TapZone _primary;
  late TapZone _home;
  bool _handled = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load(clear ? 'ui/stage_clear.webp' : 'ui/monster_attack.webp');
    _primary = TapZone(onTap: _goNext, triggerOnDown: true);
    _home = TapZone(onTap: game.goHome, triggerOnDown: true);
    addAll([_primary, _home]);
  }

  void _goNext() {
    if (_handled) return;
    _handled = true;

    if (clear) {
      unawaited(game.advanceAfterClear());
    } else {
      unawaited(game.retryCurrentStage());
    }
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _primary
      ..size = Vector2(size.x * .78, clear ? size.y * .082 : size.y * .10)
      ..position = Vector2(size.x * .11, clear ? size.y * .846 : size.y * .835)
      ..priority = 1000;
    _home
      ..size = Vector2(size.x * .15, size.y * .042)
      ..position = Vector2(size.x * .81, size.y * .018)
      ..priority = 1100;
  }

  void _center(Canvas canvas, String text, double y, double fs, Color color, FontWeight weight, {double? maxWidth}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fs, fontWeight: weight, color: color)),
      textDirection: TextDirection.ltr,
      textAlign: maxWidth == null ? TextAlign.left : TextAlign.center,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  String _milestoneText() {
    return '공주에게 한 걸음 더 가까워졌습니다.';
  }

  void _renderHomeButton(Canvas canvas) {
    final homeBox = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .81, size.y * .018, size.x * .15, size.y * .042),
      const Radius.circular(16),
    );
    canvas.drawRRect(homeBox, Paint()..color = const Color(0xCC16082F));
    canvas.drawRRect(
      homeBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = const Color(0x99FFD86D),
    );
    final homeText = TextPainter(
      text: const TextSpan(
        text: '처음',
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
          color: Color(0xFFFFEDB1),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    homeText.paint(
      canvas,
      Offset(size.x * .885 - homeText.width / 2, size.y * .027),
    );
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    if (clear) {
      // Hide the baked English STAGE COMPLETE line cleanly, then place only the Korean milestone below it.
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .242, size.x, size.y * .058),
        Paint()..color = const Color(0xFF16082F),
      );
      _center(
        canvas,
        _milestoneText(),
        size.y * .302,
        15.5,
        const Color(0xFFF4E9FF),
        FontWeight.w800,
        maxWidth: size.x * .86,
      );

      // Fully cover the baked remaining-time/stat panel so no old text can show through.
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .602, size.x, size.y * .205),
        Paint()..color = const Color(0xFF16082F),
      );
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .812, size.x, size.y * .165),
        Paint()..color = const Color(0xE616082F),
      );

      final infoRect = Rect.fromLTWH(size.x * .16, size.y * .650, size.x * .68, size.y * .100);
      final info = RRect.fromRectAndRadius(infoRect, const Radius.circular(26));
      canvas.drawRRect(info, Paint()..color = const Color(0xF22A1454));
      canvas.drawRRect(
        info,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFFFFD86D),
      );
      final firstLineY = infoRect.top + infoRect.height * .22;
      final secondLineY = infoRect.top + infoRect.height * .58;
      _center(
        canvas,
        '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초',
        firstLineY,
        22,
        const Color(0xFFFFE08A),
        FontWeight.w900,
        maxWidth: size.x * .62,
      );
      _center(
        canvas,
        '${stageRealmLabel(stage)} · STAGE $stage 완료',
        secondLineY,
        13,
        const Color(0xFFD9CAFF),
        FontWeight.w800,
        maxWidth: size.x * .62,
      );

      final primary = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .11, size.y * .846, size.x * .78, size.y * .082),
        const Radius.circular(30),
      );
      canvas.drawRRect(
        primary,
        Paint()..color = _primary.pressed || _handled ? const Color(0xFF4FCF27) : const Color(0xFF78EA3F),
      );
      canvas.drawRRect(
        primary,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFFFFF),
      );
      _center(canvas, '다음 스테이지', size.y * .867, 23, const Color(0xFF13240B), FontWeight.w900);
    } else {
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .65, size.x, size.y * .35),
        Paint()..color = const Color(0xF214082C),
      );
      _center(canvas, '문 뒤에서 몬스터가 나타났습니다.', size.y * .695, 17, const Color(0xFFFFFFFF), FontWeight.w900);
      _center(canvas, '기억한 순서를 다시 확인하세요.', size.y * .738, 15, const Color(0xFFD8C4FF), FontWeight.w800);

      final retry = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .11, size.y * .835, size.x * .78, size.y * .10),
        const Radius.circular(32),
      );
      canvas.drawRRect(
        retry,
        Paint()..color = _primary.pressed || _handled ? const Color(0xFF4FCF27) : const Color(0xFF78EA3F),
      );
      canvas.drawRRect(
        retry,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFFFFF),
      );
      _center(canvas, _handled ? '다시 시작 중...' : '다시 도전', size.y * .864, 24, const Color(0xFF13240B), FontWeight.w900);
    }

    _renderHomeButton(canvas);
  }
}
