import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:monster_door_quest/game/core/game_rules.dart';

void main() {
  test('native game starts at stage 3', () {
    expect(GameRules.initialStage, 3);
    expect(stageConfig(3).doorCount, 3);
    expect(stageConfig(3).memorySeconds, 5.0);
    expect(stageConfig(3).playSeconds, 10.0);
  });

  test('memory timing follows the approved curve', () {
    expect(stageConfig(5).memorySeconds, 4.5);
    expect(stageConfig(8).memorySeconds, 4.0);
    expect(stageConfig(11).memorySeconds, 3.5);
    expect(stageConfig(15).memorySeconds, 3.0);
    expect(stageConfig(20).memorySeconds, 2.5);
    expect(stageConfig(21).memorySeconds, isNull);
  });

  test('stage 5+ never creates three identical directions in a row', () {
    final route = createRoute(20, Random(1), stage: 8);
    for (var i = 2; i < route.length; i++) {
      expect(route[i] == route[i - 1] && route[i] == route[i - 2], isFalse);
    }
  });

  test('stage 3-4 can allow at most three same directions', () {
    final route = createRoute(30, Random(2), stage: 3);
    for (var i = 3; i < route.length; i++) {
      expect(route.sublist(i - 3, i + 1).toSet().length == 1, isFalse);
    }
  });
}
