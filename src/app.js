import { GameEngine, realmForDoors } from './game-engine.js';

const $ = (q) => document.querySelector(q);
const $$ = (q) => [...document.querySelectorAll(q)];

const COPY = {
  ko: {
    title: '몬스터 문 열기',
    subtitle: '길을 기억하고 공주를 구하라',
    start: 'GAME START',
    remember: '길을 기억하세요!',
    memoryHint: '문 순서는 한 번만 보여집니다.',
    ready: '기억 완료 · 공주를 구하러 가기',
    choose: '기억한 문을 여세요!',
    left: '왼쪽',
    right: '오른쪽',
    correct: '정답! 다음 문으로',
    clear: 'STAGE CLEAR!',
    saved: '공주를 구했습니다!',
    next: 'NEXT STAGE',
    fail: 'MONSTER!',
    captured: '잘못된 문입니다. 몬스터가 공주를 잡아갔습니다.',
    retry: '다시 도전',
    best: '최고 기록',
    human: '인간의 영역',
    superhuman: '초인의 영역',
    god: '신의 영역'
  },
  en: {
    title: 'Monster Door Quest',
    subtitle: 'Remember the path. Rescue the princess.',
    start: 'GAME START',
    remember: 'Remember the Path!',
    memoryHint: 'The route is shown only once.',
    ready: 'READY · RESCUE THE PRINCESS',
    choose: 'Open the remembered door!',
    left: 'LEFT',
    right: 'RIGHT',
    correct: 'Correct! Next door',
    clear: 'STAGE CLEAR!',
    saved: 'Princess rescued!',
    next: 'NEXT STAGE',
    fail: 'MONSTER!',
    captured: 'Wrong door. The monster captured the princess.',
    retry: 'TRY AGAIN',
    best: 'BEST',
    human: 'HUMAN REALM',
    superhuman: 'SUPERHUMAN REALM',
    god: 'GOD REALM'
  },
  zh: {
    title: '怪物开门',
    subtitle: '记住路线，救出公主',
    start: '开始游戏',
    remember: '记住路线！',
    memoryHint: '路线只显示一次。',
    ready: '记忆完成 · 去救公主',
    choose: '打开你记住的门！',
    left: '左边',
    right: '右边',
    correct: '正确！下一扇门',
    clear: '闯关成功！',
    saved: '成功救出公主！',
    next: '下一关',
    fail: '怪物出现！',
    captured: '选错门了。怪物抓走了公主。',
    retry: '再试一次',
    best: '最高纪录',
    human: '人类领域',
    superhuman: '超人领域',
    god: '神之领域'
  }
};

let lang = localStorage.getItem('mdq-lang') || 'ko';
let stage = Number(localStorage.getItem('mdq-stage') || 1);
let bestDoors = Number(localStorage.getItem('mdq-best') || 3);
let engine;
let memoryTimer;

function t(key) { return COPY[lang][key] ?? key; }
function realmLabel() { return t(realmForDoors(engine.doorCount)); }

function show(name) {
  $$('.screen').forEach(el => el.classList.add('hidden'));
  $('#' + name).classList.remove('hidden');
}

function applyCopy() {
  $$('[data-t]').forEach(el => el.textContent = t(el.dataset.t));
  $('#lang').value = lang;
  $('#homeBest').textContent = `${t('best')} ${bestDoors} DOORS`;
}

function newEngine() {
  engine = new GameEngine({ stage });
  updateHeader();
}

function updateHeader() {
  $$('.stageBadge').forEach(el => el.textContent = `STAGE ${stage} · ${engine.doorCount} DOORS`);
  $$('.realmLabel').forEach(el => el.textContent = realmLabel());
}

function renderMemory() {
  const route = $('#memoryRoute');
  route.innerHTML = '';
  engine.route.forEach((side, i) => {
    const node = document.createElement('div');
    node.className = 'routeStep';
    node.innerHTML = `<span>${i + 1}</span><b class="${side === 'L' ? 'blueText' : 'goldText'}">${side === 'L' ? '← ' + t('left') : t('right') + ' →'}</b>`;
    route.appendChild(node);
  });
  $('#memoryTitle').textContent = t('remember');
  $('#memoryHint').textContent = t('memoryHint');
  $('#memoryGo').textContent = t('ready');
  $('#memoryGo').disabled = true;
  $('#memoryBar').style.width = '100%';
  let seconds = engine.doorCount <= 6 ? 5 : engine.doorCount <= 10 ? 3 : 2.5;
  $('#memorySeconds').textContent = `${seconds.toFixed(seconds % 1 ? 1 : 0)}s`;
  clearInterval(memoryTimer);
  const start = performance.now();
  const total = seconds * 1000;
  memoryTimer = setInterval(() => {
    const remain = Math.max(0, total - (performance.now() - start));
    $('#memoryBar').style.width = `${(remain / total) * 100}%`;
    $('#memorySeconds').textContent = `${(remain / 1000).toFixed(1)}s`;
    if (remain <= 0) {
      clearInterval(memoryTimer);
      route.classList.add('blurred');
      $('#memoryGo').disabled = false;
      $('#memorySeconds').textContent = 'GO!';
    }
  }, 50);
}

function startStage() {
  newEngine();
  show('memory');
  renderMemory();
}

function beginPlay() {
  engine.beginPlay();
  $('#memoryRoute').classList.remove('blurred');
  show('game');
  renderProgress();
  resetDoors();
  $('#feedback').textContent = '';
}

function renderProgress() {
  $('#stepCounter').textContent = `${engine.currentStep + 1} / ${engine.doorCount}`;
  const dots = $('#progressDots');
  dots.innerHTML = '';
  for (let i = 0; i < engine.doorCount; i++) {
    const d = document.createElement('span');
    d.className = 'dot' + (i < engine.currentStep ? ' done' : i === engine.currentStep ? ' active' : '');
    dots.appendChild(d);
  }
}

function resetDoors() {
  $$('.doorBtn').forEach(b => b.classList.remove('open','correct','wrong'));
}

function choose(side) {
  if (engine.state !== 'playing') return;
  const btn = side === 'L' ? $('#leftDoor') : $('#rightDoor');
  btn.classList.add('open');
  const result = engine.choose(side);
  if (result.status === 'fail') {
    btn.classList.add('wrong');
    setTimeout(() => {
      $('#failAt').textContent = `${engine.currentStep + 1} / ${engine.doorCount}`;
      show('fail');
    }, 360);
    return;
  }
  btn.classList.add('correct');
  $('#feedback').textContent = t('correct');
  if (result.status === 'clear') {
    bestDoors = Math.max(bestDoors, engine.doorCount);
    localStorage.setItem('mdq-best', String(bestDoors));
    localStorage.setItem('mdq-stage', String(Math.min(13, stage + 1)));
    setTimeout(() => show('clear'), 430);
    return;
  }
  setTimeout(() => {
    resetDoors();
    $('#feedback').textContent = '';
    renderProgress();
  }, 360);
}

function retry() { startStage(); }
function nextStage() {
  stage = Math.min(13, stage + 1);
  localStorage.setItem('mdq-stage', String(stage));
  startStage();
}
function goHome() { show('home'); applyCopy(); }

$('#startGame').addEventListener('click', startStage);
$('#memoryGo').addEventListener('click', beginPlay);
$('#leftDoor').addEventListener('click', () => choose('L'));
$('#rightDoor').addEventListener('click', () => choose('R'));
$('#retryBtn').addEventListener('click', retry);
$('#nextBtn').addEventListener('click', nextStage);
$('#clearHome').addEventListener('click', goHome);
$('#failHome').addEventListener('click', goHome);
$('#lang').addEventListener('change', e => {
  lang = e.target.value;
  localStorage.setItem('mdq-lang', lang);
  applyCopy();
});

applyCopy();
newEngine();
show('home');
