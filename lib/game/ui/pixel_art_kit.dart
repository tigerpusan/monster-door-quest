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
  late Sprite cloud;
  late Sprite bush;
  late Sprite fence;
  late Sprite flower;

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
    kit.cloud = await Sprite.load('ui/pixel_cloud.png');
    kit.bush = await Sprite.load('ui/pixel_bush.png');
    kit.fence = await Sprite.load('ui/pixel_fence.png');
    kit.flower = await Sprite.load('ui/pixel_flower.png');
    return kit;
  }

  void renderBackground(
    Canvas canvas,
    Vector2 size, {
    bool showPath = true,
    bool showCastle = true,
    bool showTrees = true,
    bool rich = true,
  }) {
    final skyRect = Offset.zero & Size(size.x, size.y);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = Gradient.linear(
          Offset(size.x * .5, 0),
          Offset(size.x * .5, size.y),
          const <Color>[
            Color(0xFF22A9F3),
            Color(0xFF73D0FF),
            Color(0xFFBFEAFF),
          ],
          const <double>[0.0, .52, 1.0],
        ),
    );

    if (rich) {
      cloud.render(canvas,
          position: Vector2(size.x * .02, size.y * .18),
          size: Vector2(size.x * .23, size.x * .10));
      cloud.render(canvas,
          position: Vector2(size.x * .75, size.y * .14),
          size: Vector2(size.x * .20, size.x * .09));
      cloud.render(canvas,
          position: Vector2(size.x * .68, size.y * .30),
          size: Vector2(size.x * .15, size.x * .07));
      _sparkle(canvas, size.x * .13, size.y * .10, 12);
      _sparkle(canvas, size.x * .78, size.y * .12, 10);
      _sparkle(canvas, size.x * .52, size.y * .20, 8);
    }

    final hill = Path()
      ..moveTo(0, size.y * .70)
      ..quadraticBezierTo(size.x * .18, size.y * .63, size.x * .36, size.y * .69)
      ..quadraticBezierTo(size.x * .52, size.y * .61, size.x * .70, size.y * .67)
      ..quadraticBezierTo(size.x * .88, size.y * .62, size.x, size.y * .67)
      ..lineTo(size.x, size.y * .79)
      ..lineTo(0, size.y * .79)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF8CDC54));
    canvas.drawRect(
      Rect.fromLTWH(0, size.y * .77, size.x, size.y * .23),
      Paint()..color = const Color(0xFF5DB73D),
    );

    if (rich) {
      bush.render(canvas,
          position: Vector2(size.x * .03, size.y * .69),
          size: Vector2(size.x * .20, size.x * .10));
      bush.render(canvas,
          position: Vector2(size.x * .77, size.y * .69),
          size: Vector2(size.x * .19, size.x * .10));
      fence.render(canvas,
          position: Vector2(size.x * .02, size.y * .73),
          size: Vector2(size.x * .24, size.x * .08));
      fence.render(canvas,
          position: Vector2(size.x * .74, size.y * .73),
          size: Vector2(size.x * .24, size.x * .08));
      flower.render(canvas,
          position: Vector2(size.x * .05, size.y * .82),
          size: Vector2(size.x * .06, size.x * .06));
      flower.render(canvas,
          position: Vector2(size.x * .88, size.y * .84),
          size: Vector2(size.x * .06, size.x * .06));
      flower.render(canvas,
          position: Vector2(size.x * .19, size.y * .92),
          size: Vector2(size.x * .05, size.x * .05));
      flower.render(canvas,
          position: Vector2(size.x * .72, size.y * .91),
          size: Vector2(size.x * .05, size.x * .05));
    }

    if (showCastle) renderCastle(canvas, size);
    if (showTrees) renderTrees(canvas, size);
    if (showPath) _drawPath(canvas, size);
  }

  void renderCastle(
    Canvas canvas,
    Vector2 size, {
    double x = .34,
    double y = .35,
    double width = .32,
    double height = .25,
  }) {
    castle.render(
      canvas,
      position: Vector2(size.x * x, size.y * y),
      size: Vector2(size.x * width, size.x * height),
    );
  }

  void renderTrees(Canvas canvas, Vector2 size, {
    double top = .53,
    double leftScale = .25,
    double rightScale = .23,
  }) {
    tree.render(
      canvas,
      position: Vector2(size.x * .015, size.y * top),
      size: Vector2(size.x * leftScale, size.x * leftScale),
    );
    tree.render(
      canvas,
      position: Vector2(size.x * .765, size.y * (top + .01)),
      size: Vector2(size.x * rightScale, size.x * rightScale),
    );
  }

  void renderDoorPair(
    Canvas canvas,
    Vector2 size, {
    double top = .50,
    double scale = .35,
    double heightScale = .33,
    double leftX = .05,
    double rightX = .60,
  }) {
    final h = size.y * heightScale;
    final w = size.x * scale;
    blueDoor.render(canvas,
        position: Vector2(size.x * leftX, size.y * top), size: Vector2(w, h));
    pinkDoor.render(canvas,
        position: Vector2(size.x * rightX, size.y * top), size: Vector2(w, h));
  }

  void renderHero(
    Canvas canvas,
    Vector2 size, {
    double x = .36,
    double y = .69,
    double scale = .30,
  }) {
    hero.render(
      canvas,
      position: Vector2(size.x * x, size.y * y),
      size: Vector2(size.x * scale, size.x * scale),
    );
  }

  void renderIntroWorld(Canvas canvas, Vector2 size) {
    renderBackground(canvas, size, showCastle: false, showTrees: true, rich: true);
    renderCastle(canvas, size, x: .28, y: .39, width: .44, height: .32);
    renderDoorPair(canvas, size, top: .54, scale: .36, heightScale: .34, leftX: .045, rightX: .595);
    renderHero(canvas, size, x: .34, y: .705, scale: .32);
  }

  void renderClearParty(Canvas canvas, Vector2 size) {
    tree.render(canvas,
        position: Vector2(size.x * .00, size.y * .43),
        size: Vector2(size.x * .30, size.x * .30));
    tree.render(canvas,
        position: Vector2(size.x * .72, size.y * .43),
        size: Vector2(size.x * .30, size.x * .30));
    castle.render(canvas,
        position: Vector2(size.x * .27, size.y * .29),
        size: Vector2(size.x * .46, size.x * .34));
    chest.render(canvas,
        position: Vector2(size.x * .07, size.y * .52),
        size: Vector2(size.x * .25, size.x * .25));
    hero.render(canvas,
        position: Vector2(size.x * .28, size.y * .47),
        size: Vector2(size.x * .30, size.x * .30));
    princess.render(canvas,
        position: Vector2(size.x * .52, size.y * .43),
        size: Vector2(size.x * .34, size.x * .34));
  }

  void renderMonster(Canvas canvas, Vector2 size) {
    monster.render(
      canvas,
      position: Vector2(size.x * .28, size.y * .37),
      size: Vector2(size.x * .44, size.x * .44),
    );
  }

  void _sparkle(Canvas canvas, double cx, double cy, double r) {
    final paint = Paint()
      ..color = const Color(0xFFFFF0A3)
      ..strokeCap = StrokeCap.square
      ..strokeWidth = 3.2;
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), paint);
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), paint);
  }

  void _drawPath(Canvas canvas, Vector2 size) {
    final path = Path()
      ..moveTo(size.x * .40, size.y)
      ..lineTo(size.x * .60, size.y)
      ..lineTo(size.x * .545, size.y * .72)
      ..lineTo(size.x * .455, size.y * .72)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFE2C994));

    for (var i = 0; i < 16; i++) {
      final y = size.y * (.735 + i * .0165);
      final left = size.x * (.465 - i * .0063);
      final right = size.x * (.535 + i * .0063);
      final rr = RRect.fromRectAndRadius(
        Rect.fromLTWH(left, y, right - left, size.y * .0085),
        const Radius.circular(4),
      );
      canvas.drawRRect(rr, Paint()..color = const Color(0xFFCDB580));
    }
  }
}
