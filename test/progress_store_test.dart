import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monster_door_quest/game/core/progress_store.dart';

void main() {
  test('first launch starts at stage 3', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = ProgressStore(prefs);
    final progress = store.load();
    expect(progress.currentStage, 3);
    expect(progress.bestStage, 0);
  });

  test('clear stores next stage and best', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = ProgressStore(prefs);
    await store.saveClear(6);
    final progress = store.load();
    expect(progress.currentStage, 7);
    expect(progress.bestStage, 6);
  });
}
