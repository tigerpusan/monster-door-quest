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
    _bg = await Sprite.load(clear ? 'ui/stage_clear_rebuild.png' : 'ui/monster_attack.webp');
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
      ..size = Vector2(size.x * .78, clear ? size.y * .086 : size.y * .10)
      ..position = Vector2(size.x * .11, clear ? size.y * .836 : size.y * .835)
      ..priority = 1000;
    _home
      ..size = Vector2(size.x * .17, size.y * .060)
      ..position = Vector2(size.x * .775, size.y * .020)
      ..priority = 1100;
  }

  void _drawCenteredText(
    Canvas canvas,
    String text,
    Rect rect,
    double fontSize,
    Color color,
    FontWeight weight, {
    double? maxWidth,
    double yOffset = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: 1.12,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxWidth ?? rect.width);
    final dx = rect.left + (rect.width - tp.width) / 2;
    final dy = rect.top + (rect.height - tp.height) / 2 + yOffset;
    tp.paint(canvas, Offset(dx, dy));
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);

    final homeRect = Rect.fromLTWH(size.x * .775, size.y * .020, size.x * .17, size.y * .060);
    final homeBox = RRect.fromRectAndRadius(homeRect, const Radius.circular(22));
    canvas.drawRRect(homeBox, Paint()..color = const Color(0xDE16082F));
    canvas.drawRRect(
      homeBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xCCFFD86D),
    );
    _drawCenteredText(canvas, '처음', homeRect, 16, const Color(0xFFFFEDB1), FontWeight.w900, yOffset: -1);

    if (clear) {
      // Slightly darken the lower UI area but keep the art visible.
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .58, size.x, size.y * .42),
        Paint()..color = const Color(0x2409041D),
      );

      final milestoneRect = Rect.fromLTWH(size.x * .10, size.y * .355, size.x * .72, size.y * .048);
      final milestone = RRect.fromRectAndRadius(milestoneRect, const Radius.circular(22));
      canvas.drawRRect(milestone, Paint()..color = const Color(0xC1261248));
      canvas.drawRRect(
        milestone,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0x88FFD96A),
      );
      _drawCenteredText(
        canvas,
        '공주에게 한 걸음 더 가까워졌습니다.',
        milestoneRect,
        15.5,
        const Color(0xFFF6EDFF),
        FontWeight.w800,
      );

      final cardRect = Rect.fromLTWH(size.x * .11, size.y * .655, size.x * .78, size.y * .150);
      final card = RRect.fromRectAndRadius(cardRect, const Radius.circular(30));
      canvas.drawRRect(card, Paint()..color = const Color(0xEC241046));
      canvas.drawRRect(
        card,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = const Color(0xFFFFD86D),
      );

      final innerRect = Rect.fromLTWH(cardRect.left + 24, cardRect.top + 31, cardRect.width - 48, cardRect.height - 62);
      final inner = RRect.fromRectAndRadius(innerRect, const Radius.circular(22));
      canvas.drawRRect(inner, Paint()..color = const Color(0x4C3A1A62));
      canvas.drawRRect(
        inner,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0x99FFD96A),
      );

      final titleRect = Rect.fromLTWH(innerRect.left, innerRect.top + 2, innerRect.width, innerRect.height * .54);
      final subtitleRect = Rect.fromLTWH(innerRect.left, innerRect.top + innerRect.height * .49, innerRect.width, innerRect.height * .30);
      _drawCenteredText(
        canvas,
        '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초',
        titleRect,
        21,
        const Color(0xFFFFE08A),
        FontWeight.w900,
      );
      _drawCenteredText(
        canvas,
        '${stageRealmLabel(stage)} · STAGE $stage 완료',
        subtitleRect,
        13.2,
        const Color(0xFFE7DBFF),
        FontWeight.w800,
        yOffset: -1,
      );

      final primaryRect = Rect.fromLTWH(size.x * .11, size.y * .836, size.x * .78, size.y * .086);
      final primary = RRect.fromRectAndRadius(primaryRect, const Radius.circular(30));
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
      _drawCenteredText(canvas, '다음 스테이지', primaryRect, 23, const Color(0xFF13240B), FontWeight.w900, yOffset: -1);
    } else {
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .65, size.x, size.y * .35),
        Paint()..color = const Color(0xF214082C),
      );
      _drawCenteredText(
        canvas,
        '문 뒤에서 몬스터가 나타났습니다.',
        Rect.fromLTWH(size.x * .10, size.y * .690, size.x * .80, size.y * .028),
        17,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
      _drawCenteredText(
        canvas,
        '기억한 순서를 다시 확인하세요.',
        Rect.fromLTWH(size.x * .12, size.y * .732, size.x * .76, size.y * .026),
        15,
        const Color(0xFFD8C4FF),
        FontWeight.w800,
      );

      final retryRect = Rect.fromLTWH(size.x * .11, size.y * .835, size.x * .78, size.y * .10);
      final retry = RRect.fromRectAndRadius(retryRect, const Radius.circular(32));
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
      _drawCenteredText(
        canvas,
        _handled ? '다시 시작 중...' : '다시 도전',
        retryRect,
        24,
        const Color(0xFF13240B),
        FontWeight.w900,
      );
    }
  }
}
