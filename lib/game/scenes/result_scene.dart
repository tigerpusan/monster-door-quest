import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, FontWeight, RadialGradient, TextDirection, TextPainter, TextSpan, TextStyle;
import '../components/action_button.dart';
import '../monster_door_game.dart';

class ResultScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  ResultScene({required this.clear,required this.stage});
  final bool clear; final int stage; late ActionButton primary;
  @override Future<void> onLoad() async { primary=ActionButton(label:clear?'다음 도전':'다시 도전',onPressed:clear?game.advanceAfterClear:game.retryCurrentStage); add(primary); }
  @override void onGameResize(Vector2 size){ super.onGameResize(size); this.size=size; primary..size=Vector2(size.x-50,64)..position=Vector2(25,size.y*.72); }
  void _text(Canvas c,String t,double y,double fs,{Color color=const Color(0xFFFFFFFF),FontWeight w=FontWeight.w700}){ final tp=TextPainter(text:TextSpan(text:t,style:TextStyle(color:color,fontSize:fs,fontWeight:w)),textDirection:TextDirection.ltr)..layout(maxWidth:size.x-40); tp.paint(c,Offset((size.x-tp.width)/2,y)); }
  @override void render(Canvas canvas){
    super.render(canvas);
    canvas.drawRect(size.toRect(),Paint()..shader=RadialGradient(center:const Alignment(0,-.5),radius:1,colors:clear?const[Color(0xFF5B347F),Color(0xFF180A31),Color(0xFF07020F)]:const[Color(0xFF60223C),Color(0xFF1D091F),Color(0xFF07020F)]).createShader(size.toRect()));
    _text(canvas,clear?'STAGE CLEAR!':'MONSTER ATTACK!',size.y*.19,30,color:clear?const Color(0xFFFFD85D):const Color(0xFFFF738D),w:FontWeight.w900);
    canvas.drawCircle(Offset(size.x/2,size.y*.38),58,Paint()..color=clear?const Color(0xFFFFCF54):const Color(0xFF8B2DB7));
    _text(canvas,clear?'⚔':'MONSTER',size.y*.33,26,color:clear?const Color(0xFF241236):const Color(0xFFFFFFFF),w:FontWeight.w900);
    _text(canvas,clear?'$stage DOORS 성공!':'문 뒤에서 몬스터가 나타났습니다.',size.y*.50,clear?27:21,w:FontWeight.w900);
    _text(canvas,clear?'공주에게 한 걸음 더 가까워졌습니다.':'기억한 순서를 다시 확인하세요.',size.y*.57,16,color:const Color(0xFFDCCEF3));
  }
}
