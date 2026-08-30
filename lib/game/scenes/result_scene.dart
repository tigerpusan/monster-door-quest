import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../core/game_rules.dart';
import '../monster_door_game.dart';

class ResultScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  ResultScene({required this.clear, required this.stage, required this.elapsedSeconds});

  final bool clear;
  final int stage;
  final double elapsedSeconds;
  late Sprite _bg;
  late TapZone _primary;
  bool _handled = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load(clear ? 'ui/stage_clear.webp' : 'ui/monster_attack.webp');
    _primary = TapZone(onTap: _goNext, triggerOnDown: true);
    add(_primary);
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
      ..size = Vector2(size.x * .78, clear ? size.y * .085 : size.y * .10)
      ..position = Vector2(size.x * .11, clear ? size.y * .825 : size.y * .835)
      ..priority = 1000;
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
    if (stage == 5) return '인간의 영역 I 돌파!';
    if (stage == 10) return '인간의 영역 II 돌파!';
    if (stage == 15) return '인간의 영역 III 돌파!';
    if (stage == 20) return '초인의 영역 돌파!';
    return '공주에게 한 걸음 더 가까워졌습니다.';
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    if (clear) {
      // Rebuild the upper title zone so the old black/English area disappears.
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .145, size.x, size.y * .20),
        Paint()..color = const Color(0xFF1D0C40),
      );
      final clearHeader = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .18, size.y * .172, size.x * .64, size.y * .075),
        const Radius.circular(24),
      );
      canvas.drawRRect(clearHeader, Paint()..color = const Color(0xCC2A1454));
      canvas.drawRRect(
        clearHeader,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0x88FFD96A),
      );
      _center(canvas, '스테이지 클리어!', size.y * .192, 22, const Color(0xFFFFE49B), FontWeight.w900);
      _center(canvas, _milestoneText(), size.y * .252, 14.5, const Color(0xFFE9D9FF), FontWeight.w800, maxWidth: size.x * .82);

      // Remove all baked lower stats/buttons completely.
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .55, size.x, size.y * .45),
        Paint()..color = const Color(0xFF14082C),
      );

      final info = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .16, size.y * .635, size.x * .68, size.y * .115),
        const Radius.circular(28),
      );
      canvas.drawRRect(info, Paint()..color = const Color(0xFF2A1454));
      canvas.drawRRect(
        info,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..color = const Color(0xFFFFD86D),
      );
      _center(canvas, '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초', size.y * .673, 22,
          const Color(0xFFFFE08A), FontWeight.w900);
      _center(canvas, '${stageRealmLabel(stage)} · STAGE $stage 완료', size.y * .715, 12.5,
          const Color(0xFFD9CAFF), FontWeight.w800);

      final primary = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .11, size.y * .825, size.x * .78, size.y * .085),
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
      _center(canvas, '다음 스테이지', size.y * .846, 23, const Color(0xFF13240B), FontWeight.w900);
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
  }
}
