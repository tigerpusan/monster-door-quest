import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/tap_zone.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';

class MemoryScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  MemoryScene(this.session, this.memorySeconds);

  final GameSessionState session;
  final double? memorySeconds;
  late Sprite _bg;
  late TapZone _ready;
  late TapZone _settings;
  late TapZone _settingsClose;
  late TapZone _settingsContinue;
  late TapZone _settingsHome;
  double elapsed = 0;
  bool _transitioned = false;
  bool _settingsOpen = false;

  @override
  Future<void> onLoad() async {
    _bg = await Sprite.load('ui/gameplay_final_clean_v2.png');
    _ready = TapZone(onTap: _goDoor, triggerOnDown: true);
    _settings = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsClose = TapZone(onTap: _toggleSettings, triggerOnDown: true);
    _settingsContinue = TapZone(onTap: _closeSettings, triggerOnDown: true);
    _settingsHome = TapZone(onTap: game.goHome, triggerOnDown: true);
    addAll([_ready, _settings, _settingsClose, _settingsContinue, _settingsHome]);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _ready
      ..size = Vector2(size.x * .74, size.y * .072)
      ..position = Vector2(size.x * .13, size.y * .894);
    _settings
      ..size = Vector2(size.x * .17, size.y * .060)
      ..position = Vector2(size.x * .775, size.y * .020);
    _settingsClose
      ..size = Vector2(size.x * .10, size.y * .055)
      ..position = Vector2(size.x * .79, size.y * .165);
    _settingsContinue
      ..size = Vector2(size.x * .30, size.y * .068)
      ..position = Vector2(size.x * .17, size.y * .705);
    _settingsHome
      ..size = Vector2(size.x * .30, size.y * .068)
      ..position = Vector2(size.x * .53, size.y * .705);
  }

  void _toggleSettings() {
    _settingsOpen = !_settingsOpen;
  }

  void _closeSettings() {
    _settingsOpen = false;
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
      if (elapsed >= memorySeconds! && isMounted) {
        _goDoor();
      }
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
      '게임 방법\n문 순서를 외운 뒤 아래 버튼으로 도전하세요.\n시간이 지나면 자동으로 문 선택 화면으로 넘어갑니다.',
      Rect.fromLTWH(size.x * .16, size.y * .245, size.x * .68, size.y * .12),
      14.5,
      const Color(0xFFFFFFFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.35,
    );
    _drawText(
      canvas,
      '단계 목표\n인간 I~III를 넘어 초인 · 기록 · 신 단계까지\n점점 더 많은 문과 규칙을 기억하세요.',
      Rect.fromLTWH(size.x * .16, size.y * .385, size.x * .68, size.y * .12),
      14.5,
      const Color(0xFFFFF2C7),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.35,
    );
    _drawText(
      canvas,
      '실패 규칙\n다시 도전 시 기본적으로 두 단계 전으로 돌아갑니다.\n끝까지 가기 위해서는 실수 없이 집중해야 합니다.',
      Rect.fromLTWH(size.x * .16, size.y * .525, size.x * .68, size.y * .13),
      14.2,
      const Color(0xFFE8DDFF),
      FontWeight.w700,
      align: TextAlign.left,
      height: 1.34,
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

    canvas.drawRect(size.toRect(), Paint()..color = const Color(0x1809041D));
    _drawSettingsButton(canvas);

    final panelRect = Rect.fromLTWH(size.x * .05, size.y * .090, size.x * .90, size.y * .770);
    final panel = RRect.fromRectAndRadius(panelRect, const Radius.circular(30));
    canvas.drawRRect(panel, Paint()..color = const Color(0xEE220F46));
    canvas.drawRRect(
      panel,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = const Color(0xCCFFD86D),
    );
    canvas.drawRRect(
      panel.deflate(10),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0x40FFFFFF),
    );

    _drawText(
      canvas,
      '문 순서를 기억하세요',
      Rect.fromLTWH(size.x * .10, size.y * .120, size.x * .80, size.y * .044),
      27,
      const Color(0xFFFFD96C),
      FontWeight.w900,
    );
    _drawText(
      canvas,
      'STAGE ${session.stage} · ${session.route.length} DOORS',
      Rect.fromLTWH(size.x * .18, size.y * .176, size.x * .64, size.y * .024),
      15,
      const Color(0xFFF0E7FF),
      FontWeight.w800,
    );

    final count = session.route.length;
    final listTop = size.y * .224;
    final listBottom = size.y * .662;
    final listHeight = listBottom - listTop;
    final gap = count >= 14 ? 4.0 : count >= 10 ? 6.0 : 8.0;
    final rowHeight = ((listHeight - gap * (count - 1)) / count).clamp(24.0, 58.0);

    for (var i = 0; i < count; i++) {
      final isLeft = session.route[i].name == 'left';
      final y = listTop + i * (rowHeight + gap);
      final rowRect = Rect.fromLTWH(size.x * .17, y, size.x * .66, rowHeight);
      final rr = RRect.fromRectAndRadius(rowRect, Radius.circular(rowHeight / 2));
      canvas.drawRRect(
        rr,
        Paint()..color = isLeft ? const Color(0xFF365BDA) : const Color(0xFFE34389),
      );
      canvas.drawRRect(
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFD86D),
      );
      final fontSize = (rowHeight * (count >= 14 ? .42 : .48)).clamp(14.0, 25.0);
      _drawText(
        canvas,
        '${i + 1}   ${isLeft ? '← 왼쪽' : '오른쪽 →'}',
        rowRect,
        fontSize,
        const Color(0xFFFFFFFF),
        FontWeight.w900,
        yOffset: -0.5,
      );
    }

    final remain = memorySeconds == null
        ? 0.0
        : (memorySeconds! - elapsed).clamp(0.0, memorySeconds!);
    final timerText = memorySeconds == null
        ? '준비되면 바로 도전하세요'
        : '기억 시간  ${remain.toStringAsFixed(1)}초';
    _drawText(
      canvas,
      timerText,
      Rect.fromLTWH(size.x * .18, size.y * .714, size.x * .64, size.y * .038),
      18,
      const Color(0xFFFFE38B),
      FontWeight.w900,
    );

    final btnRect = Rect.fromLTWH(size.x * .13, size.y * .894, size.x * .74, size.y * .072);
    final btn = RRect.fromRectAndRadius(btnRect, const Radius.circular(28));
    canvas.drawRRect(
      btn,
      Paint()..color = _ready.pressed ? const Color(0xFF58D22B) : const Color(0xFF7EEB42),
    );
    canvas.drawRRect(
      btn,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..color = const Color(0xFFFFFFFF),
    );
    _drawText(
      canvas,
      _ready.pressed ? '도전!' : '✨ 기억 완료 · 도전! ✨',
      btnRect,
      20,
      const Color(0xFF12230B),
      FontWeight.w900,
      yOffset: -1,
    );

    if (_settingsOpen) {
      _drawSettingsOverlay(canvas);
    }
  }
}
