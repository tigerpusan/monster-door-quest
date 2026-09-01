import 'dart:ui';
import 'package:flame/components.dart';

/// Casual, bright pixel-art kit for the rebuilt monster-door project.
/// All major visuals are split into individual sprite assets so scenes can
/// place UI and characters independently instead of relying on one flat image.
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

  void renderBackground(Canvas canvas, Vector2 size, {bool showPath = true}) {
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

    castle.render(
      canvas,
      position: Vector2(size.x * .35, size.y * .35),
      size: Vector2(size.x * .30, size.x * .23),
    );
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

    if (showPath) {
      _drawPath(canvas, size);
    }
  }

  void renderDoorPair(Canvas canvas, Vector2 size, {double top = .43, double scale = .30}) {
    final h = size.y * .28;
    final w = size.x * scale;
    blueDoor.render(
      canvas,
      position: Vector2(size.x * .10, size.y * top),
      size: Vector2(w, h),
    );
    pinkDoor.render(
      canvas,
      position: Vector2(size.x * .58, size.y * top),
      size: Vector2(w, h),
    );
  }

  void renderHero(Canvas canvas, Vector2 size,
      {double x = .39, double y = .69, double scale = .27}) {
    hero.render(
      canvas,
      position: Vector2(size.x * x, size.y * y),
      size: Vector2(size.x * scale, size.x * scale),
    );
  }

  void renderClearParty(Canvas canvas, Vector2 size) {
    chest.render(
      canvas,
      position: Vector2(size.x * .14, size.y * .53),
      size: Vector2(size.x * .18, size.x * .18),
    );
    hero.render(
      canvas,
      position: Vector2(size.x * .30, size.y * .46),
      size: Vector2(size.x * .23, size.x * .23),
    );
    princess.render(
      canvas,
      position: Vector2(size.x * .51, size.y * .43),
      size: Vector2(size.x * .28, size.x * .28),
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
