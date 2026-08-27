import 'package:flutter_test/flutter_test.dart';
import 'package:monster_door_quest/game/effects/hit_effects.dart';

void main() {
  test('correct feedback enables flash and hero dash', () {
    final f = HitFeedbackController();
    f.playCorrect();
    expect(f.flashKind, FlashKind.correct);
    expect(f.heroDashActive, isTrue);
    expect(f.monsterPopActive, isFalse);
  });

  test('wrong feedback enables monster pop, shake and red flash', () {
    final f = HitFeedbackController();
    f.playWrong();
    expect(f.flashKind, FlashKind.wrong);
    expect(f.monsterPopActive, isTrue);
    expect(f.shakeActive, isTrue);
  });
}
