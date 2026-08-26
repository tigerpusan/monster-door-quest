import { CHAPTERS, chapterOneDoorCount, memorySecondsForDoors, GameEngine, nextProgress, chapterOneStageLabel } from './game-model.js';

const $ = s => document.querySelector(s);
const $$ = s => [...document.querySelectorAll(s)];

const STORAGE = 'mdq-v0.2-progress';
const COPY = {
  ko: {continue:'계속하기', world:'WORLD MAP', enter:'몬스터 빌리지 입장', start:'시작', memory:'기억 완료 · 바로 시작', next:'다음 스테이지'},
  en: {continue:'CONTINUE', world:'WORLD MAP', enter:'ENTER MONSTER VILLAGE', start:'START', memory:'READY · START NOW', next:'NEXT STAGE'},
  zh: {continue:'继续', world:'世界地图', enter:'进入怪物村', start:'开始', memory:'记忆完成 · 立即开始', next:'下一关'}
};

let data = loadData();
let lang = localStorage.getItem('mdq-lang') || 'ko';
let engine = null;
let timerId = null;
let storyIndex = 0;
let movingFromStage = 1;

function defaultData(){
  return {openingSeen:false,currentChapter:1,currentStage:1,bestStage:1,unlockedChapters:[1],clearedStages:[]};
}
function loadData(){
  try { return {...defaultData(), ...JSON.parse(localStorage.getItem(STORAGE) || '{}')}; }
  catch { return defaultData(); }
}
function saveData(){ localStorage.setItem(STORAGE, JSON.stringify(data)); }
function show(id){
  $$('.screen').forEach(x=>x.classList.add('hidden'));
  $('#'+id).classList.remove('hidden');
}
function c(key){ return COPY[lang][key] || key; }

function applyLang(){
  $('#langSelect').value = lang;
  $('#continueBtn').textContent = c('continue');
  $('#worldBtn').textContent = c('world');
  $('#enterChapterBtn').textContent = c('enter');
  $('#memoryReadyBtn').textContent = c('memory');
  $('#nextStageBtn').textContent = c('next');
}

function showOpening(reset=false){
  storyIndex = 0;
  $$('.storyLine').forEach((el,i)=>el.classList.toggle('active', i===0));
  $('#nextStory').textContent = 'NEXT';
  show('opening');
  if(reset) data.openingSeen = false;
}
function finishOpening(){
  data.openingSeen = true; saveData(); renderHome(); show('home');
}
$('#nextStory').onclick = () => {
  storyIndex++;
  const lines = $$('.storyLine');
  if(storyIndex >= lines.length){ finishOpening(); return; }
  lines.forEach((el,i)=>el.classList.toggle('active',i===storyIndex));
  $('#nextStory').textContent = storyIndex === lines.length-1 ? 'START' : 'NEXT';
};
$('#skipOpening').onclick = finishOpening;

function renderHome(){
  const chapter = CHAPTERS[Math.max(0,data.currentChapter-1)] || CHAPTERS[0];
  $('#homeProgress').textContent = data.currentChapter === 1
    ? `${chapter.en.toUpperCase()} · ${chapterOneStageLabel(data.currentStage)}`
    : `${chapter.en.toUpperCase()} · NEXT CHAPTER`;
  $('#continueBtn').textContent = data.currentChapter === 1 ? c('continue') : c('world');
}
$('#continueBtn').onclick = () => {
  if(data.currentChapter === 1){ renderChapter(); show('chapter'); }
  else { renderWorld(); show('world'); }
};
$('#worldBtn').onclick = () => { renderWorld(); show('world'); };
$('#langSelect').onchange = e => {lang=e.target.value;localStorage.setItem('mdq-lang',lang);applyLang();};

function renderWorld(){
  const box = $('#worldRoute'); box.innerHTML='';
  CHAPTERS.forEach(ch=>{
    const unlocked = data.unlockedChapters.includes(ch.id);
    const current = ch.id===data.currentChapter;
    const row=document.createElement('div');
    row.className='worldNode '+(current?'current ':'')+(unlocked?'':'locked');
    const name = lang==='ko'?ch.ko:lang==='zh'?ch.zh:ch.en;
    row.innerHTML=`<div class="worldIcon">${ch.icon}</div><div class="worldName"><b>${name}</b><span>CHAPTER ${ch.id}</span></div><div class="worldHero">${current?'🤴⚔️':unlocked?'✓':'🔒'}</div>`;
    box.appendChild(row);
  });
  $('#enterChapterBtn').disabled = data.currentChapter !== 1;
  $('#enterChapterBtn').textContent = data.currentChapter===1 ? c('enter') : 'COMING NEXT PATCH';
}
$('#enterChapterBtn').onclick = ()=>{renderChapter();show('chapter');};

function nodePosition(stage){
  const positions=[
    [28,88],[68,80],[34,70],[66,61],[31,52],[69,43],[35,34],[65,25],[34,16],[70,8]
  ];
  return positions[Math.max(0,Math.min(9,stage-1))];
}
function fillChapterPath(container, currentStage, completedStage=currentStage-1, hero=true){
  container.innerHTML='';
  for(let s=1;s<=10;s++){
    const [x,y]=nodePosition(s);
    const node=document.createElement('div');
    node.className='stageNode '+(s===10?'boss ':'')+(s<=completedStage?'done ':s===currentStage?'current ':'locked ');
    node.style.left=x+'%'; node.style.top=y+'%';
    node.textContent=s===10?'👹':s;
    container.appendChild(node);
  }
  if(hero){
    const [x,y]=nodePosition(currentStage);
    const h=document.createElement('div');h.className='pathHero';h.textContent='🤴⚔️';h.style.left=x+'%';h.style.top=y+'%';container.appendChild(h);
  }
}
function renderChapter(){
  fillChapterPath($('#chapterPath'), data.currentStage, Math.max(0,data.currentStage-1), true);
  const doors=chapterOneDoorCount(data.currentStage);
  $('#chapterDoorBadge').textContent=`${doors} DOORS`;
  $('#chapterHint').textContent=`현재 위치: ${chapterOneStageLabel(data.currentStage)}`;
  $('#startStageBtn').textContent=`${chapterOneStageLabel(data.currentStage)} ${c('start')}`;
}
$('#startStageBtn').onclick = startMemory;

function startMemory(){
  engine=new GameEngine({stage:data.currentStage});
  show('memory');
  $('#memoryStage').textContent=`${chapterOneStageLabel(data.currentStage)} · ${engine.doorCount} DOORS`;
  renderRoute();
  startMemoryTimer();
}
function renderRoute(){
  const box=$('#routeList');box.innerHTML='';
  engine.route.forEach((side,i)=>{
    const row=document.createElement('div');row.className='routeItem';
    row.innerHTML=`<span class="routeNum">${i+1}</span><b class="${side==='L'?'leftTxt':'rightTxt'}">${side==='L'?'← 왼쪽':'오른쪽 →'}</b>`;
    box.appendChild(row);
  });
}
function startMemoryTimer(){
  clearInterval(timerId);
  const total=memorySecondsForDoors(engine.doorCount)*1000;
  const started=performance.now();
  $('#timerBar').style.width='100%';
  const tick=()=>{
    const remain=Math.max(0,total-(performance.now()-started));
    $('#timerBar').style.width=`${remain/total*100}%`;
    $('#timerText').textContent=`${(remain/1000).toFixed(1)}s`;
    if(remain<=0){clearInterval(timerId); beginGame('timeout');}
  };
  tick(); timerId=setInterval(tick,50);
}
function beginGame(reason){
  if(!engine || engine.state!=='memory') return;
  clearInterval(timerId);
  engine.beginPlay();
  show('game');
  $('#gameStage').textContent=`${chapterOneStageLabel(data.currentStage)} · ${engine.doorCount} DOORS`;
  renderGameProgress();
  $('#gameFeedback').textContent=reason==='manual'?'기억 완료! 시작합니다.':'시간 종료! 자동 시작';
  setTimeout(()=>$('#gameFeedback').textContent='',650);
}
$('#memoryReadyBtn').onclick=()=>beginGame('manual');

function renderGameProgress(){
  $('#stepText').textContent=`${Math.min(engine.currentStep+1,engine.doorCount)} / ${engine.doorCount}`;
  const box=$('#gameDots');box.innerHTML='';
  for(let i=0;i<engine.doorCount;i++){
    const d=document.createElement('span');
    d.className='gameDot '+(i<engine.currentStep?'done':i===engine.currentStep?'current':'');
    box.appendChild(d);
  }
  $$('.doorChoice').forEach(b=>b.classList.remove('open','correct','wrong'));
}
function choose(side){
  if(!engine || engine.state!=='playing') return;
  const btn=side==='L'?$('#leftDoor'):$('#rightDoor');
  btn.classList.add('open');
  const res=engine.choose(side);
  if(res.status==='fail'){
    btn.classList.add('wrong');
    $('#gameFeedback').textContent='MONSTER!';
    setTimeout(()=>{
      $('#failProgress').textContent=`${engine.currentStep+1}번째 문에서 실패`;
      show('fail');
    },420);
    return;
  }
  btn.classList.add('correct');
  if(res.status==='clear'){
    $('#gameFeedback').textContent='CLEAR!';
    movingFromStage=data.currentStage;
    if(!data.clearedStages.includes(data.currentStage)) data.clearedStages.push(data.currentStage);
    data.bestStage=Math.max(data.bestStage,data.currentStage);
    saveData();
    setTimeout(()=>show('clear'),460);
    return;
  }
  $('#gameFeedback').textContent='정답!';
  setTimeout(()=>{renderGameProgress();$('#gameFeedback').textContent='';},330);
}
$('#leftDoor').onclick=()=>choose('L');
$('#rightDoor').onclick=()=>choose('R');
$('#retryBtn').onclick=startMemory;

function showMapMove(){
  show('mapmove');
  $('#moveStageBadge').textContent=`${chapterOneStageLabel(movingFromStage)} CLEAR`;
  const next = nextProgress({chapter:1,stage:movingFromStage});
  const visualNextStage = next.chapterClear ? 10 : next.stage;
  fillChapterPath($('#movePath'), visualNextStage, movingFromStage, false);
  const hero=$('#movingHero');
  const [sx,sy]=nodePosition(movingFromStage);
  const [ex,ey]=nodePosition(visualNextStage);
  hero.style.left=sx+'%';hero.style.top=sy+'%';
  $('#nextStageBtn').disabled=true;
  requestAnimationFrame(()=>requestAnimationFrame(()=>{
    hero.style.left=ex+'%';hero.style.top=ey+'%';
  }));
  setTimeout(()=>{
    if(next.chapterClear){
      data.currentChapter=2;data.currentStage=1;
      if(!data.unlockedChapters.includes(2)) data.unlockedChapters.push(2);
      saveData();
      show('chapterclear');
    }else{
      data.currentStage=next.stage;saveData();
      $('#nextStageBtn').disabled=false;
      $('#nextStageBtn').textContent=`${chapterOneStageLabel(data.currentStage)} ${c('next')}`;
    }
  },1450);
}
$('#showMoveBtn').onclick=showMapMove;
$('#nextStageBtn').onclick=()=>{renderChapter();show('chapter');};
$('#chapterClearWorldBtn').onclick=()=>{renderWorld();show('world');};

$$('[data-back]').forEach(b=>b.onclick=()=>{
  const target=b.dataset.back;
  if(target==='home')renderHome();
  if(target==='world')renderWorld();
  if(target==='chapter')renderChapter();
  show(target);
});

applyLang();
renderHome();
if(data.openingSeen) show('home'); else showOpening();
