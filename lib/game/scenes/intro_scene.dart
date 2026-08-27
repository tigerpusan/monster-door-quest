import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../monster_door_game.dart';

class IntroScene extends SpriteComponent with TapCallbacks, HasGameReference<MonsterDoorGame> {
  IntroScene({required super.sprite}) : super(anchor: Anchor.topLeft);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    position = Vector2.zero();
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.startCurrentStage();
  }
}
