import 'package:flame/components.dart';
import 'package:flame/events.dart';
import '../monster_door_game.dart';

class IntroScene extends SpriteComponent with TapCallbacks, HasGameReference<MonsterDoorGame> {
  IntroScene({required super.sprite});
  @override void onGameResize(Vector2 newSize){ super.onGameResize(newSize); size=newSize; position=Vector2.zero(); }
  @override void onTapUp(TapUpEvent event){ game.startCurrentStage(); }
}
