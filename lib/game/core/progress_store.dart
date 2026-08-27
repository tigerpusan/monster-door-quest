import 'package:shared_preferences/shared_preferences.dart';
import 'game_rules.dart';

class GameProgress {
  const GameProgress({required this.currentStage, required this.bestStage});
  final int currentStage;
  final int bestStage;
}

abstract class ProgressStorePort {
  GameProgress load();
  Future<void> saveClear(int stage);
  Future<void> saveCurrentStage(int stage);
}

class ProgressStore implements ProgressStorePort {
  ProgressStore(this.prefs);
  final SharedPreferences prefs;
  static const _currentKey = 'current_stage';
  static const _bestKey = 'best_stage';
  @override GameProgress load() => GameProgress(currentStage: prefs.getInt(_currentKey) ?? GameRules.initialStage, bestStage: prefs.getInt(_bestKey) ?? 0);
  @override Future<void> saveClear(int stage) async {
    final oldBest = prefs.getInt(_bestKey) ?? 0;
    await prefs.setInt(_bestKey, stage > oldBest ? stage : oldBest);
    await prefs.setInt(_currentKey, stage + 1);
  }
  @override Future<void> saveCurrentStage(int stage) => prefs.setInt(_currentKey, stage);
}
