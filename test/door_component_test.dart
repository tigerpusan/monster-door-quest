import 'package:flutter_test/flutter_test.dart';
import 'package:monster_door_quest/game/components/door_component.dart';
import 'package:monster_door_quest/game/core/game_rules.dart';

void main() {
  test('door reacts immediately with V0.7 fast open timing', () {
    final door = DoorComponent(side: DoorSide.left, onSelected: (_) {});

    door.pressDown();
    expect(door.isPressed, isTrue);

    door.open(correct: true);
    expect(door.isOpening, isTrue);

    // V0.7.0 intentionally shortened the door animation for rapid sequential input.
    expect(door.openDuration, inInclusiveRange(.12, .20));
  });
}
