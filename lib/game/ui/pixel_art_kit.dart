import 'dart:ui';
import 'package:flame/components.dart';

class PixelArtKit {
  PixelArtKit._();

  late Sprite hero;
  late Sprite princess;
  late Sprite monster;
  late Sprite chest;
  late Sprite blueDoor;
  late Sprite pinkDoor;
  late Sprite tree;
  late Sprite castle;

  static Future<PixelArtKit> load() async {
    final kit = PixelArtKit._();
    kit.hero = await Sprite.load('ui/pixel_hero.png');
    kit.princess = await Sprite.load('ui/pixel_princess.png');
    kit.monster = await Sprite.load('ui/pixel_monster.png');
    kit.chest = await Sprite.load('ui/pixel_chest.png');
    kit.blueDoor = await Sprite.load('ui/pixel_door_blue.png');
    kit.pinkDoor = await Sprite.load('ui/pixel_door_pink.png');
    kit.tree = await Sprite.load('ui/pixel_tree.png');
    kit.castle = await Sprite.load('ui/pixel_castle.png');
    return kit;
  }

  void renderBackground(
    Canvas canvas,
    Vector2 size, {
    bool showPath = true,
    bool showCastle = true,
    bool showTrees = true,
  }) {
    final skyRect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = Gradient.linear(
          Offset(size.x * .5, 0),
          Offset(size.x * .5, size.y),
          const <Color>[
            Color(0xFF69C7FF),
            Color(0xFFAEE6FF),
            Color(0xFFF7FCFF),
          ],
          const <double>[0.0, .58, 1.0],
        ),
    );

    _sparkle(canvas, size.x * .20, size.y * .10, 16);
    _sparkle(canvas, size.x * .78, size.y * .14, 16);
    _sparkle(canvas, size.x * .58, size.y * .18, 12);

    final hill = Path()
      ..moveTo(0, size.y * .71)
      ..quadraticBezierTo(size.x * .15, size.y * .66, size.x * .30, size.y * .69)
      ..quadraticBezierTo(size.x * .48, size.y * .63, size.x * .66, size.y * .68)
      ..quadraticBezierTo(size.x * .84, size.y * .64, size.x, size.y * .67)
      ..lineTo(size.x, size.y * .77)
      ..lineTo(0, size.y * .77)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF8BD85B));
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * .77, size.x, size.y * .23),
      Paint()..color = const Color(0xFF61B63E),
    );

    if (showCastle) {
      renderCastle(canvas, size);
    }
    if (showTrees) {
      renderTrees(canvas, size);
    }
    if (showPath) {
      _drawPath(canvas, size);
    }
  }

  void renderCastle(
    Canvas canvas,
    Vector2 size, {
    double x = .35,
    double y = .35,
    double width = .30,
    double height = .23,
  }) {
    castle.render(
      canvas,
      position: Vector2(size.x * x, size.y * y),
      size: Vector2(size.x * width, size.x * height),
    );
  }

  void renderTrees(Canvas canvas, Vector2 size) {
    tree.render(
      canvas,
      position: Vector2(size.x * .02, size.y * .53),
      size: Vector2(size.x * .26, size.x * .26),
    );
    tree.render(
      canvas,
      position: Vector2(size.x * .76, size.y * .54),
      size: Vector2(size.x * .22, size.x * .22),
    );
  }

  void renderDoorPair(
    Canvas canvas,
    Vector2 size, {
    double top = .43,
    double scale = .30,
    double heightScale = .28,
    double leftX = .10,
    double rightX = .58,
  }) {
    final h = size.y * heightScale;
    final w = size.x * scale;
    blueDoor.render(
      canvas,
      position: Vector2(size.x * leftX, size.y * top),
      size: Vector2(w, h),
    );
    pinkDoor.render(
      canvas,
      position: Vector2(size.x * rightX, size.y * top),
      size: Vector2(w, h),
    );
  }

  void renderHero(
    Canvas canvas,
    Vector2 size, {
    double x = .39,
    double y = .69,
    double scale = .27,
  }) {
    hero.render(
      canvas,
      position: Vector2(size.x * x, size.y * y),
      size: Vector2(size.x * scale, size.x * scale),
    );
  }

  void renderClearParty(Canvas canvas, Vector2 size) {
    tree.render(
      canvas,
      position: Vector2(size.x * .015, size.y * .47),
      size: Vector2(size.x * .28, size.x * .28),
    );
    tree.render(
      canvas,
      position: Vector2(size.x * .73, size.y * .48),
      size: Vector2(size.x * .27, size.x * .27),
    );
    castle.render(
      canvas,
      position: Vector2(size.x * .31, size.y * .34),
      size: Vector2(size.x * .38, size.x * .29),
    );
    chest.render(
      canvas,
      position: Vector2(size.x * .09, size.y * .54),
      size: Vector2(size.x * .22, size.x * .22),
    );
    hero.render(
      canvas,
      position: Vector2(size.x * .29, size.y * .47),
      size: Vector2(size.x * .27, size.x * .27),
    );
    princess.render(
      canvas,
      position: Vector2(size.x * .52, size.y * .44),
      size: Vector2(size.x * .31, size.x * .31),
    );
  }

  void renderMonster(Canvas canvas, Vector2 size) {
    monster.render(
      canvas,
      position: Vector2(size.x * .29, size.y * .39),
      size: Vector2(size.x * .42, size.x * .42),
    );
  }

  void _sparkle(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()
      ..color = const Color(0xFFFFF2AF)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.5;
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), paint);
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), paint);
  }

  void _drawPath(Canvas canvas, Vector2 size) {
    final path = Path()
      ..moveTo(size.x * .42, size.y)
      ..lineTo(size.x * .58, size.y)
      ..lineTo(size.x * .54, size.y * .74)
      ..lineTo(size.x * .46, size.y * .74)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFDCC79B));

    for (var i = 0; i < 15; i++) {
      final y = size.y * (.75 + i * .0145);
      final left = size.x * (.465 - i * .006);
      final right = size.x * (.535 + i * .006);
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, y, right - left, size.y * .008),
        const Radius.circular(4),
      );
      canvas.drawRRect(rr, Paint()..color = const Color(0xFFCCB88D));
    }
  }
}
