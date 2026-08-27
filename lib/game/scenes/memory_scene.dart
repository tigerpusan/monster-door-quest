import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, LinearGradient, TextPainter, TextSpan, TextStyle, TextDirection, FontWeight;
import '../components/action_button.dart';
import '../core/game_state.dart';
import '../monster_door_game.dart';

class MemoryScene extends PositionComponent with HasGameReference<MonsterDoorGame> {
  MemoryScene(this.session, this.memorySeconds);
  final GameSessionState session;
  final double? memorySeconds;
  double elapsed=0;
  late final ActionButton ready;
  bool _transitioned=false;

  @override Future<void> onLoad() async {
    ready=ActionButton(label:'기억 완료 · 도전!',onPressed:_goDoor);
    add(ready);
  }
  void _goDoor(){ if(_transitioned)return; _transitioned=true; game.showDoorScene(session); }
  @override void onGameResize(Vector2 size){ super.onGameResize(size); this.size=size; ready.size=Vector2(size.x-40,62); ready.position=Vector2(20,size.y-86); }
  @override void update(double dt){ super.update(dt); if(memorySeconds!=null && !_transitioned){ elapsed+=dt; if(elapsed>=memorySeconds! && isMounted){ _goDoor(); } } }
  void _text(Canvas c,String text,double y,double fs,{Color color=const Color(0xFFFFFFFF),FontWeight fw=FontWeight.w700}){
    final tp=TextPainter(text:TextSpan(text:text,style:TextStyle(color:color,fontSize:fs,fontWeight:fw)),textDirection:TextDirection.ltr)..layout(maxWidth:size.x-40);
    tp.paint(c,Offset((size.x-tp.width)/2,y));
  }
  @override void render(Canvas canvas){
    super.render(canvas);
    canvas.drawRect(size.toRect(),Paint()..shader=const LinearGradient(colors:[Color(0xFF261044),Color(0xFF090312)],begin:Alignment.topCenter,end:Alignment.bottomCenter).createShader(size.toRect()));
    _text(canvas,'문 순서를 기억하세요',42,28,color:const Color(0xFFFFDF72),fw:FontWeight.w900);
    _text(canvas,'STAGE ${session.stage} · ${session.route.length} DOORS',82,14,color:const Color(0xFFD9C9F5));
    final top=132.0;
    final rowH=((size.y-300)/session.route.length).clamp(34.0,58.0);
    for(var i=0;i<session.route.length;i++){
      final y=top+i*rowH;
      final r=RRect.fromRectAndRadius(Rect.fromLTWH(30,y,size.x-60,rowH-7),const Radius.circular(20));
      canvas.drawRRect(r,Paint()..color=const Color(0xFF32164D));
      _text(canvas,'${i+1}   ${session.route[i].name=='left'?'← 왼쪽':'오른쪽 →'}',y+8,17,color:session.route[i].name=='left'?const Color(0xFF80DFFF):const Color(0xFFFFC2F5));
    }
    if(memorySeconds!=null){ final remain=(memorySeconds!-elapsed).clamp(0,memorySeconds!); _text(canvas,'기억 시간 ${remain.toStringAsFixed(1)}초',size.y-132,17,color:const Color(0xFFFFE38A)); }
  }
}
