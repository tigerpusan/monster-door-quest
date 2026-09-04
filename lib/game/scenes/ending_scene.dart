import 'dart:ui';
import 'package:flame/components.dart';
import '../components/tap_zone.dart';
import '../monster_door_game.dart';

class EndingScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  late Sprite _ending;
  late TapZone _home;

  @override
  Future<void> onLoad() async {
    _ending = await Sprite.load('ui/v6/princess_rescued.webp');
    _home = TapZone(onTap: game.goHome, triggerOnDown: true);
    add(_home);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _home
      ..size = Vector2(size.x * .72, size.y * .105)
      ..position = Vector2(size.x * .14, size.y * .855)
      ..priority = 1000;
  }

  @override
  void render(Canvas canvas) {
    _ending.render(canvas, position: Vector2.zero(), size: size);
  }
}
