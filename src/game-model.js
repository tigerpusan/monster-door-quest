export const CHAPTERS = [
  { id: 1, key: 'village', ko: '몬스터 빌리지', en: 'Monster Village', zh: '怪物村', icon: '🏘️' },
  { id: 2, key: 'forest', ko: '어둠의 숲', en: 'Dark Forest', zh: '黑暗森林', icon: '🌲' },
  { id: 3, key: 'canyon', ko: '고블린 협곡', en: 'Goblin Canyon', zh: '哥布林峡谷', icon: '⛰️' },
  { id: 4, key: 'ghost', ko: '유령의 성', en: 'Ghost Castle', zh: '幽灵城堡', icon: '🏰' },
  { id: 5, key: 'dragon', ko: '드래곤 산맥', en: 'Dragon Mountain', zh: '龙之山脉', icon: '🐉' },
  { id: 6, key: 'demon', ko: '마왕성', en: "Demon King's Castle", zh: '魔王城', icon: '🔥' }
];

export function chapterOneDoorCount(stage) {
  const s = Math.min(10, Math.max(1, Number(stage) || 1));
  if (s <= 3) return 3;
  if (s <= 6) return 4;
  return 5;
}

export function memorySecondsForDoors(doors) {
  if (doors <= 3) return 5;
  if (doors === 4) return 4;
  return 3;
}

export function createRoute(count, rng = Math.random) {
  return Array.from({ length: count }, () => rng() < 0.5 ? 'L' : 'R');
}

export function chapterOneStageLabel(stage) {
  return Number(stage) === 10 ? 'BOSS' : `STAGE ${stage}`;
}

export function nextProgress({ chapter, stage }) {
  if (chapter === 1 && stage >= 10) {
    return { chapter: 2, stage: 1, chapterClear: true };
  }
  return { chapter, stage: stage + 1, chapterClear: false };
}

export class GameEngine {
  constructor({ stage = 1, route = null, rng = Math.random } = {}) {
    this.stage = stage;
    this.doorCount = route ? route.length : chapterOneDoorCount(stage);
    this.route = route ? [...route] : createRoute(this.doorCount, rng);
    this.currentStep = 0;
    this.state = 'memory';
  }

  beginPlay() {
    this.state = 'playing';
    this.currentStep = 0;
  }

  choose(side) {
    if (this.state !== 'playing') return { status: this.state, currentStep: this.currentStep };
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
