import 'dart:math';

enum DoorSide { left, right }

class StageConfig {
  const StageConfig({required this.stage, required this.doorCount, required this.memorySeconds, required this.playSeconds, required this.maxSameRun});
  final int stage;
  final int doorCount;
  final double? memorySeconds;
  final double playSeconds;
  final int maxSameRun;
}

abstract final class GameRules {
  static const initialStage = 3;
  static const playSeconds = 10.0;
  static const doorOpenSeconds = .30;
}

StageConfig stageConfig(int stage) {
  final s = max(GameRules.initialStage, stage);
  final memory = s <= 3 ? 5.0 : s <= 5 ? 4.5 : s <= 8 ? 4.0 : s <= 11 ? 3.5 : s <= 15 ? 3.0 : s <= 20 ? 2.5 : null;
  return StageConfig(stage: s, doorCount: s, memorySeconds: memory, playSeconds: GameRules.playSeconds, maxSameRun: s <= 4 ? 3 : 2);
}

List<DoorSide> createRoute(int count, Random rng, {required int stage}) {
  final out = <DoorSide>[];
  final maxRun = stageConfig(stage).maxSameRun;
  for (var i = 0; i < count; i++) {
    var pick = rng.nextBool() ? DoorSide.left : DoorSide.right;
    if (out.length >= maxRun) {
      final recent = out.sublist(out.length - maxRun);
      if (recent.every((v) => v == pick)) pick = pick == DoorSide.left ? DoorSide.right : DoorSide.left;
    }
    out.add(pick);
  }
  return out;
}
