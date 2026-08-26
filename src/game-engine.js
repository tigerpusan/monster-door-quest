export function doorsForStage(stage) {
  const safeStage = Math.max(1, Number(stage) || 1);
  return Math.min(15, safeStage + 2);
}

export function realmForDoors(doors) {
  if (doors >= 11) return 'god';
  if (doors >= 7) return 'superhuman';
  return 'human';
}

export class GameEngine {
  constructor({ stage = 1, rng = Math.random, route = null } = {}) {
    this.stage = Math.max(1, stage);
    this.rng = rng;
    this.doorCount = doorsForStage(this.stage);
    this.route = route ? [...route] : this.#makeRoute(this.doorCount);
    if (this.route.length !== this.doorCount) {
      this.doorCount = this.route.length;
    }
    this.currentStep = 0;
    this.state = 'memory';
  }

  #makeRoute(count) {
    return Array.from({ length: count }, () => this.rng() < 0.5 ? 'L' : 'R');
  }

  beginPlay() {
    this.state = 'playing';
    this.currentStep = 0;
  }

  choose(side) {
    if (this.state !== 'playing') {
      return { status: this.state, currentStep: this.currentStep };
    }
    const expected = this.route[this.currentStep];
    if (side !== expected) {
      this.state = 'fail';
      return { status: 'fail', expected, chosen: side, currentStep: this.currentStep };
    }
    this.currentStep += 1;
    if (this.currentStep >= this.route.length) {
      this.state = 'clear';
      return { status: 'clear', currentStep: this.currentStep };
    }
    return { status: 'correct', currentStep: this.currentStep };
  }
}
