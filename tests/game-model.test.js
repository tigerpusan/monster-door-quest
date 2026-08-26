import test from 'node:test';
import assert from 'node:assert/strict';
import {
  chapterOneDoorCount,
  memorySecondsForDoors,
  createRoute,
  GameEngine,
  nextProgress,
  chapterOneStageLabel
} from '../src/game-model.js';

test('chapter 1 uses 3, 4, then 5 doors across ten stages', () => {
  assert.equal(chapterOneDoorCount(1), 3);
  assert.equal(chapterOneDoorCount(3), 3);
  assert.equal(chapterOneDoorCount(4), 4);
  assert.equal(chapterOneDoorCount(6), 4);
  assert.equal(chapterOneDoorCount(7), 5);
  assert.equal(chapterOneDoorCount(10), 5);
});

test('memory time falls as door count rises', () => {
  assert.equal(memorySecondsForDoors(3), 5);
  assert.equal(memorySecondsForDoors(4), 4);
  assert.equal(memorySecondsForDoors(5), 3);
});

test('route length equals door count and uses only L/R', () => {
  const route = createRoute(5, () => 0.2);
  assert.deepEqual(route, ['L','L','L','L','L']);
});

test('correct route clears and wrong route fails', () => {
  const ok = new GameEngine({ route: ['L','R','L'] });
  ok.beginPlay();
  assert.equal(ok.choose('L').status, 'correct');
  assert.equal(ok.choose('R').status, 'correct');
  assert.equal(ok.choose('L').status, 'clear');

  const bad = new GameEngine({ route: ['R','L','R'] });
  bad.beginPlay();
  assert.equal(bad.choose('L').status, 'fail');
});

test('nextProgress advances stages and marks chapter clear after stage 10', () => {
  assert.deepEqual(nextProgress({ chapter: 1, stage: 4 }), { chapter: 1, stage: 5, chapterClear: false });
  assert.deepEqual(nextProgress({ chapter: 1, stage: 10 }), { chapter: 2, stage: 1, chapterClear: true });
});

test('stage 10 is boss stage', () => {
  assert.equal(chapterOneStageLabel(9), 'STAGE 9');
  assert.equal(chapterOneStageLabel(10), 'BOSS');
});
