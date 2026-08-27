import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, FontWeight, RadialGradient, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/door_component.dart';
import '../components/hero_component.dart';
import '../components/princess_component.dart';
import '../components/monster_component.dart';
import '../components/route_progress.dart';
import '../core/game_rules.dart';
import '../core/game_state.dart';
import '../effects/hit_effects.dart';
import '../monster_door_game.dart';

class DoorScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  DoorScene(this.session);
  final GameSessionState session;
  late final DoorComponent leftDoor,rightDoor;
  late final HeroComponent hero;
  late final PrincessComponent princess;
  late final MonsterComponent monster;
  late final RouteProgress progress;
  final feedback=HitFeedbackController();
  double elapsed=0;
  double transitionDelay=-1;
  bool _transitioning=false;

  @override Future<void> onLoad() async {
    session.beginDoorRun();
    leftDoor=DoorComponent(side:DoorSide.left,onSelected:_choose);
    rightDoor=DoorComponent(side:DoorSide.right,onSelected:_choose);
    hero=HeroComponent(); princess=PrincessComponent(); monster=MonsterComponent(); progress=RouteProgress(total:session.route.length);
    addAll([leftDoor,rightDoor,hero,princess,monster,progress]);
  }
  @override void onGameResize(Vector2 size){
    super.onGameResize(size); this.size=size;
    final dw=size.x*.36, dh=size.y*.42;
    leftDoor..size=Vector2(dw,dh)..position=Vector2(size.x*.08,size.y*.31);
    rightDoor..size=Vector2(dw,dh)..position=Vector2(size.x*.56,size.y*.31);
    hero..size=Vector2(82,120)..position=Vector2(size.x/2-41,size.y*.72);
    princess..size=Vector2(62,90)..position=Vector2(size.x*.76,size.y*.14);
    monster..size=Vector2(80,80)..position=Vector2(size.x/2-40,size.y*.43);
    progress..size=Vector2(size.x*.76,34)..position=Vector2(size.x*.12,size.y*.19);
  }
  Future<void> _choose(DoorSide side) async {
    if(session.phase!=SessionPhase.playing || _transitioning)return;
    await game.audioManager.playDoorTap();
    final result=session.choose(side);
    final door=side==DoorSide.left?leftDoor:rightDoor;
    door.open(correct:result!=ChoiceResult.wrong);
    await game.audioManager.playDoorOpen();
    if(result==ChoiceResult.wrong){
      feedback.playWrong(); monster.showMonster(); await game.audioManager.playWrong(); _transitioning=true; transitionDelay=.72;
    } else {
      feedback.playCorrect(); hero.triggerDash(); progress.setCurrent(session.step); await game.audioManager.playCorrect();
      if(result==ChoiceResult.clear){ _transitioning=true; transitionDelay=.58; await game.audioManager.playClear(milestoneStage:[5,10,15,20].contains(session.stage)); }
      else { _transitioning=true; transitionDelay=.48; }
    }
  }
  @override void update(double dt){
    super.update(dt); elapsed+=dt; feedback.update(dt);
    if(session.phase==SessionPhase.playing && elapsed>=GameRules.playSeconds && !_transitioning){
      session.phase=SessionPhase.failed; feedback.playWrong(); monster.showMonster(); game.audioManager.playWrong(); _transitioning=true; transitionDelay=.55;
    }
    if(_transitioning){
      transitionDelay-=dt;
      if(transitionDelay<=0){
        if(session.phase==SessionPhase.cleared){ game.showResult(clear:true,stage:session.stage); }
        else if(session.phase==SessionPhase.failed){ game.showResult(clear:false,stage:session.stage); }
        else { leftDoor.resetDoor(); rightDoor.resetDoor(); monster.hideMonster(); _transitioning=false; transitionDelay=-1; }
      }
    }
  }
  void _text(Canvas c,String t,double y,double fs,{Color color=const Color(0xFFFFFFFF),FontWeight w=FontWeight.w700}){
    final tp=TextPainter(text:TextSpan(text:t,style:TextStyle(color:color,fontSize:fs,fontWeight:w)),textDirection:TextDirection.ltr)..layout();
    tp.paint(c,Offset((size.x-tp.width)/2,y));
  }
  @override void render(Canvas canvas){
    final shake=feedback.shakeActive ? sin(elapsed*150)*5 : 0.0;
    canvas.save(); canvas.translate(shake,0);
    canvas.drawRect(size.toRect(),Paint()..shader=const RadialGradient(center:Alignment(0,-.3),radius:1.1,colors:[Color(0xFF39245E),Color(0xFF160A32),Color(0xFF07020F)]).createShader(size.toRect()));
    final star=Paint()..color=const Color(0x99FFFFFF);
    for(var i=0;i<18;i++){ final x=(i*79)%size.x; final y=45+((i*53)%(size.y*.42)).toDouble(); canvas.drawCircle(Offset(x,y),i%3==0?1.6:1,star); }
    _text(canvas,'문을 여세요!',28,28,color:const Color(0xFFFFE072),w:FontWeight.w900);
    _text(canvas,'STAGE ${session.stage}   ${min(session.step+1,session.route.length)} / ${session.route.length}',66,15,color:const Color(0xFFE4D7F7));
    final remain=(GameRules.playSeconds-elapsed).clamp(0,GameRules.playSeconds);
    _text(canvas,'${remain.toStringAsFixed(1)}초',102,34,color:remain<2.5?const Color(0xFFFF866F):const Color(0xFFFFE595),w:FontWeight.w900);
    if(feedback.flashKind!=FlashKind.none){ final alpha=(90*(1-feedback.elapsed/.28).clamp(0,1)).round(); canvas.drawRect(size.toRect(),Paint()..color=(feedback.flashKind==FlashKind.correct?const Color(0xFF62FFB0):const Color(0xFFFF4E71)).withAlpha(alpha)); }
    canvas.restore();
    super.render(canvas);
  }
}
