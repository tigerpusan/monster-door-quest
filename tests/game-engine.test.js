import test from 'node:test';
import assert from 'node:assert/strict';
import { GameEngine, doorsForStage, realmForDoors } from '../src/game-engine.js';

test('stage 1 starts with 3 doors and stage 13 caps at 15', () => {
  assert.equal(doorsForStage(1), 3);
  assert.equal(doorsForStage(13), 15);
  assert.equal(doorsForStage(99), 15);
});

test('realms follow human, superhuman, god bands', () => {
  assert.equal(realmForDoors(3), 'human');
  assert.equal(realmForDoors(7), 'superhuman');
  assert.equal(realmForDoors(11), 'god');
});

test('new round generates one route entry per door', () => {
  const engine = new GameEngine({ stage: 4, rng: () => 0.1 });
  assert.equal(engine.doorCount, 6);
  assert.equal(engine.route.length, 6);
  assert.deepEqual(engine.route, Array(6).fill('L'));
});

test('correct choices advance and final correct choice clears', () => {
  const engine = new GameEngine({ stage: 1, route: ['L', 'R', 'L'] });
  engine.beginPlay();
  assert.equal(engine.choose('L').status, 'correct');
  assert.equal(engine.currentStep, 1);
  assert.equal(engine.choose('R').status, 'correct');
  const result = engine.choose('L');
  assert.equal(result.status, 'clear');
  assert.equal(engine.state, 'clear');
});

test('wrong choice fails without advancing', () => {
  const engine = new GameEngine({ stage: 1, route: ['R', 'L', 'L'] });
  engine.beginPlay();
  const result = engine.choose('L');
  assert.equal(result.status, 'fail');
  assert.equal(engine.currentStep, 0);
  assert.equal(engine.state, 'fail');
});
