import 'dart:async';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../core/game_rules.dart';
import '../components/tap_zone.dart';
import '../monster_door_game.dart';

class ResultScene extends PositionComponent
    with HasGameReference<MonsterDoorGame> {
  ResultScene({
    required this.clear,
    required this.stage,
    required this.elapsedSeconds,
  });

  final bool clear;
  final int stage;
  final double elapsedSeconds;
  late Sprite _bg;
  late TapZone _primary;
  late TapZone _home;
  bool _handled = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load(
      clear ? 'ui/stage_clear.webp' : 'ui/monster_attack.webp',
    );
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

    _home
      ..size = Vector2(size.x * .145, size.y * .043)
      ..position = Vector2(size.x * .815, size.y * .014)
      ..priority = 1100;

    _primary
      ..size = Vector2(size.x * .78, clear ? size.y * .076 : size.y * .10)
      ..position = Vector2(size.x * .11, clear ? size.y * .835 : size.y * .835)
      ..priority = 1000;
  }

  void _center(
    Canvas canvas,
    String text,
    double y,
    double fs,
    Color color,
    FontWeight weight, {
    double? maxWidth,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fs,
          fontWeight: weight,
          color: color,
          height: 1.05,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: maxWidth ?? double.infinity);
    tp.paint(canvas, Offset((size.x - tp.width) / 2, y));
  }

  void _renderHomeButton(Canvas canvas) {
    final homeBox = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.x * .815, size.y * .014, size.x * .145, size.y * .043),
      const Radius.circular(16),
    );
    canvas.drawRRect(homeBox, Paint()..color = const Color(0xE51A0B35));
    canvas.drawRRect(
      homeBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0xCCFFD86D),
    );

    final tp = TextPainter(
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
    tp.paint(
      canvas,
      Offset(size.x * .8875 - tp.width / 2, size.y * .026),
    );
  }

  @override
  void render(Canvas canvas) {
    // Keep the original illustration fully visible. No full-width black masks
    // are used on the clear screen; every replacement is a local card that
    // matches the existing fantasy UI.
    _bg.render(canvas, size: size);

    if (clear) {
      // Replace only the baked English subtitle area with one compact Korean
      // milestone capsule. This removes the previous horizontal black band.
      final milestone = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .15, size.y * .228, size.x * .70, size.y * .052),
        const Radius.circular(20),
      );
      canvas.drawRRect(milestone, Paint()..color = const Color(0xE3271150));
      canvas.drawRRect(
        milestone,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0x80FFD86D),
      );
      _center(
        canvas,
        '공주에게 한 걸음 더 가까워졌습니다.',
        size.y * .241,
        14.8,
        const Color(0xFFF7EEFF),
        FontWeight.w900,
        maxWidth: size.x * .64,
      );

      // Cover the complete baked result card as one single coherent panel.
      // This removes remaining-time/accuracy/star text underneath instead of
      // stacking several rectangular masks on top of each other.
      final statsCard = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .105, size.y * .585, size.x * .79, size.y * .205),
        const Radius.circular(30),
      );
      canvas.drawRRect(statsCard, Paint()..color = const Color(0xFF26104B));
      canvas.drawRRect(
        statsCard,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = const Color(0xFFFFD86D),
      );

      // Inner info card is vertically centered inside the replacement panel.
      final infoRect = Rect.fromLTWH(
        size.x * .16,
        size.y * .635,
        size.x * .68,
        size.y * .105,
      );
      final info = RRect.fromRectAndRadius(
        infoRect,
        const Radius.circular(24),
      );
      canvas.drawRRect(info, Paint()..color = const Color(0xFF32165F));
      canvas.drawRRect(
        info,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xCCFFD86D),
      );

      _center(
        canvas,
        '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초',
        infoRect.top + infoRect.height * .22,
        21.5,
        const Color(0xFFFFE08A),
        FontWeight.w900,
        maxWidth: size.x * .60,
      );
      _center(
        canvas,
        '${stageRealmLabel(stage)} · STAGE $stage 완료',
        infoRect.top + infoRect.height * .61,
        13.2,
        const Color(0xFFDCCEFF),
        FontWeight.w800,
        maxWidth: size.x * .60,
      );

      // Cover only the old pink retry button, not the full lower screen.
      // This prevents "다시 보기" from ghosting behind the new CTA.
      final retryMask = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .245, size.y * .925, size.x * .51, size.y * .055),
        const Radius.circular(22),
      );
      canvas.drawRRect(retryMask, Paint()..color = const Color(0xE31A0B35));

      final primary = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .11, size.y * .835, size.x * .78, size.y * .076),
        const Radius.circular(30),
      );
      canvas.drawRRect(
        primary,
        Paint()
          ..color = _primary.pressed || _handled
              ? const Color(0xFF4FCF27)
              : const Color(0xFF78EA3F),
      );
      canvas.drawRRect(
        primary,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFFFFF),
      );
      _center(
        canvas,
        '다음 스테이지',
        size.y * .855,
        23,
        const Color(0xFF13240B),
        FontWeight.w900,
      );
    } else {
      // Failure screen keeps the working layout but uses one coherent lower
      // panel so text/CTA cannot overlap the baked art.
      final failPanel = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .06, size.y * .675, size.x * .88, size.y * .285),
        const Radius.circular(30),
      );
      canvas.drawRRect(failPanel, Paint()..color = const Color(0xF21A0B35));
      _center(
        canvas,
        '문 뒤에서 몬스터가 나타났습니다.',
        size.y * .705,
        17,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
      _center(
        canvas,
        '기억한 순서를 다시 확인하세요.',
        size.y * .748,
        15,
        const Color(0xFFD8C4FF),
        FontWeight.w800,
      );

      final retry = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.x * .11, size.y * .835, size.x * .78, size.y * .10),
        const Radius.circular(32),
      );
      canvas.drawRRect(
        retry,
        Paint()
          ..color = _primary.pressed || _handled
              ? const Color(0xFF4FCF27)
              : const Color(0xFF78EA3F),
      );
      canvas.drawRRect(
        retry,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0xFFFFFFFF),
      );
      _center(
        canvas,
        _handled ? '다시 시작 중...' : '다시 도전',
        size.y * .864,
        24,
        const Color(0xFF13240B),
        FontWeight.w900,
      );
    }

    _renderHomeButton(canvas);
  }
}
