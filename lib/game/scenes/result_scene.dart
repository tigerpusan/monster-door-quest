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
  late TapZone _settings;
  late TapZone _settingsClose;
  late TapZone _settingsContinue;
  late TapZone _settingsHome;
  bool _handled = false;
  bool _settingsOpen = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load(clear ? 'ui/stage_clear_final_clean_v2.png' : 'ui/monster_attack.webp');
    _primary = TapZone(onTap: _goNext, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsHome = TapZone(onTap: game.goHome, triggerOnDown: true);
    addAll([_primary, _settings, _settingsClose, _settingsContinue, _settingsHome]);
  }

  void _toggleSettings() {
    _settingsOpen = !_settingsOpen;
  }

  void _closeSettings() {
    _settingsOpen = false;
  }

  Future<void> _retryWithPenalty() async {
    final dynamic g = game;
    final targetStage = stage <= 2 ? 1 : stage - 2;
    try {
      await g.retryWithPenalty(targetStage: targetStage, penaltySteps: 2);
      return;
    } catch (_) {}
    try {
      await g.retryFromStage(targetStage);
      return;
    } catch (_) {}
    try {
      g.currentStage = targetStage;
      await g.startCurrentStage();
      return;
    } catch (_) {}
    await game.retryCurrentStage();
  }

  void _goNext() {
    if (_settingsOpen || _handled) return;
    _handled = true;
    if (clear) {
      unawaited(game.advanceAfterClear());
    } else {
      unawaited(_retryWithPenalty());
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
    _settings
      ..size = Vector2(size.x * .17, size.y * .060)
      ..position = Vector2(size.x * .775, size.y * .020)
      ..priority = 1100;

    _settingsClose
      ..size = Vector2(size.x * .10, size.y * .055)
      ..position = Vector2(size.x * .79, size.y * .165)
      ..priority = 2001;
    _settingsContinue
      ..size = Vector2(size.x * .30, size.y * .068)
      ..position = Vector2(size.x * .17, size.y * .705)
      ..priority = 2001;
    _settingsHome
      ..size = Vector2(size.x * .30, size.y * .068)
      ..position = Vector2(size.x * .53, size.y * .705)
      ..priority = 2001;
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
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: weight,
          color: color,
          height: height,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: align,
    )..layout(maxWidth: maxWidth ?? rect.width);
    final dx = align == TextAlign.center ? rect.left + (rect.width - tp.width) / 2 : rect.left;
    final dy = rect.top + (rect.height - tp.height) / 2 + yOffset;
    tp.paint(canvas, Offset(dx, dy));
  }

  void _drawSettingsButton(Canvas canvas) {
    final rect = Rect.fromLTWH(size.x * .775, size.y * .020, size.x * .17, size.y * .060);
    final box = RRect.fromRectAndRadius(rect, const Radius.circular(22));
    canvas.drawRRect(box, Paint()..color = const Color(0xDE16082F));
    canvas.drawRRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xCCFFD86D),
    );
    _drawText(canvas, '⚙', rect, 21, const Color(0xFFFFEDB1), FontWeight.w900, yOffset: -1);
  }

  void _drawSettingsOverlay(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint()..color = const Color(0xB3000000));

    final panelRect = Rect.fromLTWH(size.x * .08, size.y * .12, size.x * .84, size.y * .66);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(28));
    canvas.drawRRect(panel, Paint()..color = const Color(0xF01D0D41));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..color = const Color(0xCCFFD86D),
    );

    _drawText(canvas, '설정', Rect.fromLTWH(size.x * .18, size.y * .145, size.x * .52, size.y * .04), 26,
        const Color(0xFFFFDD7A), FontWeight.w900);
    _drawText(canvas, '✕', Rect.fromLTWH(size.x * .80, size.y * .155, size.x * .08, size.y * .03), 18,
        const Color(0xFFFFEDB1), FontWeight.w900);

    _drawText(
      canvas,
      '스토리\n몬스터에게 납치된 공주를 구하기 위해\n비밀의 문 순서를 기억하며 끝까지 전진하세요.',
      Rect.fromLTWH(size.x * .16, size.y * .225, size.x * .68, size.y * .13),
      14.5,
      const Color(0xFFFFFFFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.35,
    );
    _drawText(
      canvas,
      '게임 방법\n1) 순서를 기억합니다\n2) 문을 차례대로 선택합니다\n3) 성공하면 다음 스테이지로 이동합니다',
      Rect.fromLTWH(size.x * .16, size.y * .36, size.x * .68, size.y * .15),
      14.5,
      const Color(0xFFFFF2C7),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.34,
    );
    _drawText(
      canvas,
      '단계 설명\n인간 I~III : 좌우 문의 순서를 기억\n초인 : 더 긴 순서와 복합 규칙\n기록 : 집중력 한계 도전\n신 : 최종 기억 관문',
      Rect.fromLTWH(size.x * .16, size.y * .515, size.x * .68, size.y * .16),
      14.2,
      const Color(0xFFE8DDFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.34,
    );
    _drawText(
      canvas,
      '실패 규칙\n다시 도전 시 기본적으로 두 단계 전으로 돌아갑니다.',
      Rect.fromLTWH(size.x * .16, size.y * .655, size.x * .68, size.y * .07),
      13.8,
      const Color(0xFFFFD98D),
      FontWeight.w800,
      align: TextAlign.left,
      height: 1.30,
    );

    final continueRect = Rect.fromLTWH(size.x * .17, size.y * .705, size.x * .30, size.y * .068);
    final continueBox = RRect.fromRectAndRadius(continueRect, const Radius.circular(24));
    canvas.drawRRect(continueBox, Paint()..color = const Color(0xFF7EEB42));
    canvas.drawRRect(
      continueBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..color = const Color(0xFFFFFFFF),
    );
    _drawText(canvas, '계속하기', continueRect, 18, const Color(0xFF102408), FontWeight.w900, yOffset: -1);

    final homeRect = Rect.fromLTWH(size.x * .53, size.y * .705, size.x * .30, size.y * .068);
    final homeBox = RRect.fromRectAndRadius(homeRect, const Radius.circular(24));
    canvas.drawRRect(homeBox, Paint()..color = const Color(0xFF45206A));
    canvas.drawRRect(
      homeBox,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = const Color(0xCCFFD86D),
    );
    _drawText(canvas, '처음 화면', homeRect, 17, const Color(0xFFFFEDB1), FontWeight.w900);
  }

  @override
  void render(Canvas canvas) {
    _bg.render(canvas, size: size);
    _drawSettingsButton(canvas);

    if (clear) {
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .59, size.x, size.y * .41),
        Paint()..color = const Color(0x1809041D),
      );

      final milestoneRect = Rect.fromLTWH(size.x * .09, size.y * .445, size.x * .82, size.y * .047);
      final milestone = RRect.fromRectAndRadius(milestoneRect, const Radius.circular(22));
      canvas.drawRRect(milestone, Paint()..color = const Color(0xB3251247));
      canvas.drawRRect(
        milestone,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = const Color(0x88FFD96A),
      );
      _drawText(
        canvas,
        '공주에게 한 걸음 더 가까워졌습니다.',
        milestoneRect,
        15.5,
        const Color(0xFFF6EDFF),
        FontWeight.w800,
      );

      final cardRect = Rect.fromLTWH(size.x * .10, size.y * .675, size.x * .80, size.y * .145);
      final card = RRect.fromRectAndRadius(cardRect, const Radius.circular(30));
      canvas.drawRRect(card, Paint()..color = const Color(0xEC241046));
      canvas.drawRRect(
        card,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..color = const Color(0xFFFFD86D),
      );

      final titleRect = Rect.fromLTWH(cardRect.left + 18, cardRect.top + 20, cardRect.width - 36, 34);
      final subtitleRect = Rect.fromLTWH(cardRect.left + 24, cardRect.top + 66, cardRect.width - 48, 34);
      _drawText(
        canvas,
        '완료 시간  ${elapsedSeconds.toStringAsFixed(1)}초',
        titleRect,
        24,
        const Color(0xFFFFE08A),
        FontWeight.w900,
      );
      _drawText(
        canvas,
        '${stageRealmLabel(stage)}\nSTAGE $stage 완료',
        subtitleRect,
        16.2,
        const Color(0xFFE7DBFF),
        FontWeight.w800,
        height: 1.20,
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
      _drawText(canvas, '다음 스테이지', primaryRect, 23, const Color(0xFF13240B), FontWeight.w900, yOffset: -1);
    } else {
      canvas.drawRect(
        Rect.fromLTWH(0, size.y * .64, size.x, size.y * .36),
        Paint()..color = const Color(0xF214082C),
      );
      _drawText(
        canvas,
        '문 뒤에서 몬스터가 나타났습니다.',
        Rect.fromLTWH(size.x * .10, size.y * .682, size.x * .80, size.y * .032),
        17,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
      );
      _drawText(
        canvas,
        '실패 시 기본적으로 두 단계 전으로 돌아갑니다.',
        Rect.fromLTWH(size.x * .12, size.y * .724, size.x * .76, size.y * .034),
        14,
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
      _drawText(
        canvas,
        _handled ? '다시 시작 중...' : '다시 도전',
        retryRect,
        24,
        const Color(0xFF13240B),
        FontWeight.w900,
      );
    }

    if (_settingsOpen) {
      _drawSettingsOverlay(canvas);
    }
  }
}
