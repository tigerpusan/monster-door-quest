import 'package:flutter_test/flutter_test.dart';
import 'package:monster_door_quest/game/components/door_component.dart';
import 'package:monster_door_quest/game/core/game_rules.dart';

void main() {
  test('door reacts immediately before open animation completes', () {
    final door = DoorComponent(side: DoorSide.left, onSelected: (_) {});
    door.pressDown();
    expect(door.isPressed, isTrue);
    door.open(correct: true);
    expect(door.isOpening, isTrue);
    expect(door.openDuration, inInclusiveRange(.25, .35));
  });
}
