import 'dart:ui';
import 'package:flame/components.dart';

/// Bright modular pixel-art world kit.
/// Each visual element is a separate sprite so later stages can swap/reposition
/// backgrounds, characters and props without redrawing a single full-screen image.
class PixelArtKit {
  PixelArtKit._();

  late Sprite cloud;
  late Sprite castle;
  late Sprite tree;
  late Sprite bush;
  late Sprite hero;
  late Sprite princess;
  late Sprite chest;
  late Sprite monster;
  late Sprite blueDoor;
  late Sprite pinkDoor;

  static Future<PixelArtKit> load() async {
    final k = PixelArtKit._();
    k.cloud = await Sprite.load('ui/pixel_cloud.png');
    k.castle = await Sprite.load('ui/pixel_castle.png');
    k.tree = await Sprite.load('ui/pixel_tree.png');
    k.bush = await Sprite.load('ui/pixel_bush.png');
    k.hero = await Sprite.load('ui/pixel_hero.png');
    k.princess = await Sprite.load('ui/pixel_princess.png');
    k.chest = await Sprite.load('ui/pixel_chest.png');
    k.monster = await Sprite.load('ui/pixel_monster.png');
    k.blueDoor = await Sprite.load('ui/pixel_door_blue.png');
    k.pinkDoor = await Sprite.load('ui/pixel_door_pink.png');
    return k;
  }

  void renderDecor(Canvas canvas, Vector2 size, {bool dense = false}) {
    cloud.render(canvas, position: Vector2(size.x * .03, size.y * .04), size: Vector2(size.x * .26, size.y * .10));
    cloud.render(canvas, position: Vector2(size.x * .67, size.y * .08), size: Vector2(size.x * .22, size.y * .08));
    castle.render(canvas, position: Vector2(size.x * .36, size.y * .12), size: Vector2(size.x * .28, size.y * .23));
    tree.render(canvas, position: Vector2(-size.x * .08, size.y * .29), size: Vector2(size.x * .34, size.y * .48));
    tree.render(canvas, position: Vector2(size.x * .74, size.y * .31), size: Vector2(size.x * .34, size.y * .48));
    if (dense) {
      bush.render(canvas, position: Vector2(size.x * .02, size.y * .64), size: Vector2(size.x * .28, size.y * .22));
      bush.render(canvas, position: Vector2(size.x * .70, size.y * .66), size: Vector2(size.x * .28, size.y * .22));
    }
  }

  void renderDoorPair(Canvas canvas, Vector2 size, {double top = .39, double scale = .34}) {
    final h = size.y * .37;
    final w = size.x * scale;
    blueDoor.render(canvas, position: Vector2(size.x * .11, size.y * top), size: Vector2(w, h));
    pinkDoor.render(canvas, position: Vector2(size.x * .55, size.y * top), size: Vector2(w, h));
  }

  void renderHero(Canvas canvas, Vector2 size, {double x = .39, double y = .68, double scale = .24}) {
    hero.render(canvas, position: Vector2(size.x * x, size.y * y), size: Vector2(size.x * scale, size.y * .24));
  }

  void renderClearParty(Canvas canvas, Vector2 size) {
    chest.render(canvas, position: Vector2(size.x * .12, size.y * .50), size: Vector2(size.x * .23, size.y * .18));
    hero.render(canvas, position: Vector2(size.x * .34, size.y * .39), size: Vector2(size.x * .25, size.y * .27));
    princess.render(canvas, position: Vector2(size.x * .56, size.y * .40), size: Vector2(size.x * .25, size.y * .27));
  }

  void renderMonster(Canvas canvas, Vector2 size) {
    monster.render(canvas, position: Vector2(size.x * .31, size.y * .38), size: Vector2(size.x * .38, size.y * .36));
  }
}
