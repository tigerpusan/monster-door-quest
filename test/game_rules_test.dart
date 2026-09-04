import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:monster_door_quest/game/core/game_rules.dart';

void main() {
  test('keeps the existing stage 3 start and caps memory rows at 12', () {
    expect(GameRules.initialStage, 3);
    expect(GameRules.finalStage, 36);
    expect(stageConfig(3).doorCount, 3);
    expect(stageConfig(12).doorCount, 12);
    expect(stageConfig(13).doorCount, 3);
    expect(stageConfig(22).doorCount, 12);
    expect(stageConfig(23).doorCount, 12);
    expect(stageConfig(25).doorCount, 3);
    expect(stageConfig(34).doorCount, 12);
    expect(stageConfig(36).doorCount, 12);
  });

  test('human stages 10 to 12 stay at 3.5 seconds while later realms keep the existing curve', () {
    expect(stageConfig(3).memorySeconds, 5.0);
    expect(stageConfig(5).memorySeconds, 4.5);
    expect(stageConfig(8).memorySeconds, 4.0);
    expect(stageConfig(9).memorySeconds, 3.5);
    expect(stageConfig(10).memorySeconds, 3.5);
    expect(stageConfig(11).memorySeconds, 3.5);
    expect(stageConfig(12).memorySeconds, 3.5);

    // Superhuman and god realms retain the currently approved timing curve.
    expect(stageConfig(13).memorySeconds, 5.0);
    expect(stageConfig(20).memorySeconds, 3.5);
    expect(stageConfig(24).memorySeconds, 3.0);
    expect(stageConfig(36).memorySeconds, 3.0);
  });

  test('realms use direction, color, then mixed cues', () {
    expect(memoryCueModeForStage(12), MemoryCueMode.direction);
    expect(memoryCueModeForStage(13), MemoryCueMode.color);
    expect(memoryCueModeForStage(24), MemoryCueMode.color);
    expect(memoryCueModeForStage(25), MemoryCueMode.mixed);
    expect(memoryCueModeForStage(36), MemoryCueMode.mixed);
    expect(stageRealmLabel(3), '인간의 영역');
    expect(stageRealmLabel(13), '초인의 영역');
    expect(stageRealmLabel(25), '신의 영역');
  });

  test('color cues preserve the existing left-blue right-red answer mapping', () {
    final labels = createMemoryLabels(
      const [DoorSide.left, DoorSide.right, DoorSide.left],
      13,
      Random(1),
    );
    expect(labels, const ['파랑', '빨강', '파랑']);
  });

  test('god realm mixes direction and color wording without changing answers', () {
    final labels = createMemoryLabels(
      const [
        DoorSide.left,
        DoorSide.right,
        DoorSide.left,
        DoorSide.right,
        DoorSide.left,
        DoorSide.right,
      ],
      25,
      Random(7),
    );
    expect(labels.length, 6);
    expect(labels.any((v) => v.contains('왼쪽') || v.contains('오른쪽')), isTrue);
    expect(labels.any((v) => v == '파랑' || v == '빨강'), isTrue);
  });

  test('stage 5+ never creates three identical directions in a row', () {
    final route = createRoute(20, Random(1), stage: 8);
    for (var i = 2; i < route.length; i++) {
      expect(route[i] == route[i - 1] && route[i] == route[i - 2], isFalse);
    }
  });
}
