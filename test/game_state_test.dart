import 'package:flutter_test/flutter_test.dart';
import 'package:monster_door_quest/game/core/game_rules.dart';
import 'package:monster_door_quest/game/core/game_state.dart';

void main() {
  test('correct choices advance and clear the stage', () {
    final s = GameSessionState(stage: 3, route: const [DoorSide.left, DoorSide.right, DoorSide.left]);
    s.beginDoorRun();
    expect(s.choose(DoorSide.left), ChoiceResult.correct);
    expect(s.choose(DoorSide.right), ChoiceResult.correct);
    expect(s.choose(DoorSide.left), ChoiceResult.clear);
  });

  test('wrong choice fails immediately', () {
    final s = GameSessionState(stage: 3, route: const [DoorSide.right, DoorSide.left, DoorSide.right]);
    s.beginDoorRun();
    expect(s.choose(DoorSide.left), ChoiceResult.wrong);
    expect(s.phase, SessionPhase.failed);
  });
}
