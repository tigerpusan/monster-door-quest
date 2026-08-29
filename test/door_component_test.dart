import 'package:flutter_test/flutter_test.dart';
import 'package:monster_door_quest/game/components/door_component.dart';
import 'package:monster_door_quest/game/core/game_rules.dart';

void main() {
  test('door input reacts immediately and keeps fast compatibility timing', () {
    final door = DoorComponent(side: DoorSide.left, onSelected: (_) {});

    door.pressDown();
    expect(door.isPressed, isTrue);

    door.open(correct: true);
    expect(door.isOpening, isTrue);

    // Input reaction target remains under 200 ms even though the full visible
    // door-open/close flourish may continue a little longer.
    expect(door.openDuration, inInclusiveRange(.12, .20));
  });
}
