import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart'
    show FontWeight, TextAlign, TextDirection, TextPainter, TextSpan, TextStyle;
import 'pixel_art_kit.dart';

class GameHelpOverlay {
  static Rect settingsButtonRect(double w,double h)=>Rect.fromLTWH(w*.825,h*.020,w*.125,h*.060);
  static Rect closeRect(double w,double h)=>Rect.fromLTWH(w*.82,h*.067,w*.09,h*.050);
  static Rect musicRect(double w,double h)=>Rect.fromLTWH(w*.10,h*.205,w*.80,h*.070);
  static Rect resetRect(double w,double h)=>Rect.fromLTWH(w*.105,h*.825,w*.385,h*.070);
  static Rect continueRect(double w,double h)=>Rect.fromLTWH(w*.51,h*.825,w*.385,h*.070);

  static void _text(Canvas c,String t,Rect r,double fs,Color color,FontWeight fw,{TextAlign align=TextAlign.center,double height=1.15}){
    final tp=TextPainter(text:TextSpan(text:t,style:TextStyle(fontSize:fs,fontWeight:fw,color:color,height:height)),textDirection:TextDirection.ltr,textAlign:align)..layout(maxWidth:r.width);
    final dx=align==TextAlign.center?r.left+(r.width-tp.width)/2:r.left;
    final dy=r.top+(r.height-tp.height)/2;
    tp.paint(c,Offset(dx,dy));
  }
  static void _card(Canvas c,Rect r,Color fill,Color border,{double radius=18}){
    final rr=RRect.fromRectAndRadius(r,Radius.circular(radius));
    c.drawRRect(rr.shift(const Offset(0,3)),Paint()..color=const Color(0x330B3768));
    c.drawRRect(rr,Paint()..color=fill);
    c.drawRRect(rr,Paint()..style=PaintingStyle.stroke..strokeWidth=2.2..color=border);
  }
  static void _banner(Canvas c,Rect r,Color fill,String text){
    final rr=RRect.fromRectAndRadius(r,const Radius.circular(10));
    c.drawRRect(rr,Paint()..color=fill);
    _text(c,text,r,15.2,const Color(0xFFFFFFFF),FontWeight.w900,align:TextAlign.left);
  }

  static void drawSettingsButton(Canvas c,double w,double h){
    final r=settingsButtonRect(w,h); final rr=RRect.fromRectAndRadius(r,const Radius.circular(24));
    c.drawRRect(rr.shift(const Offset(0,3)),Paint()..color=const Color(0x440E4C83));
    c.drawRRect(rr,Paint()..color=const Color(0xFFFFF9E8));
    c.drawRRect(rr,Paint()..style=PaintingStyle.stroke..strokeWidth=2.2..color=const Color(0xFF2C6DB1));
    _text(c,'⚙',r,21,const Color(0xFF1D5D9D),FontWeight.w900);
  }

  static void draw(Canvas canvas,double w,double h,{required int currentStage,required int bestStage,required bool bgmEnabled,PixelArtKit? pixelArt}){
    canvas.drawRect(Rect.fromLTWH(0,0,w,h),Paint()..shader=Gradient.linear(const Offset(0,0),Offset(0,h),const [Color(0xFF1EA7F2),Color(0xFF8BDEFF),Color(0xFFEAF8FF)],const [0,.58,1]));

    final panelRect=Rect.fromLTWH(w*.045,h*.045,w*.91,h*.885); final panel=RRect.fromRectAndRadius(panelRect,const Radius.circular(30));
    canvas.drawRRect(panel.shift(const Offset(0,5)),Paint()..color=const Color(0x440E4B85));
    canvas.drawRRect(panel,Paint()..color=const Color(0xFFFFF8E8));
    canvas.drawRRect(panel,Paint()..style=PaintingStyle.stroke..strokeWidth=2.8..color=const Color(0xFF2F70B2));

    _text(canvas,'⚙  게임 설정',Rect.fromLTWH(w*.19,h*.065,w*.58,h*.060),25,const Color(0xFF174B87),FontWeight.w900);
    _text(canvas,'✕',closeRect(w,h),22,const Color(0xFF174B87),FontWeight.w900);

    final record=Rect.fromLTWH(w*.105,h*.133,w*.79,h*.060); _card(canvas,record,const Color(0xFFF1FAFF),const Color(0xFF4C8CCA));
    _text(canvas,'🏆  현재 STAGE $currentStage    │    최고 ${bestStage==0?'-':bestStage}',record,14,const Color(0xFF174B87),FontWeight.w900);

    final music=musicRect(w,h); _card(canvas,music,const Color(0xFFF6FCFF),const Color(0xFF4C8CCA));
    _text(canvas,'♪  배경음악',Rect.fromLTWH(music.left+18,music.top,music.width*.55,music.height),16,const Color(0xFF17345B),FontWeight.w900,align:TextAlign.left);
    final sw=Rect.fromLTWH(music.right-78,music.top+12,58,music.height-24); final swr=RRect.fromRectAndRadius(sw,Radius.circular(sw.height/2));
    canvas.drawRRect(swr,Paint()..color=bgmEnabled?const Color(0xFF7BE63C):const Color(0xFF8A8F9A));
    final knobX=bgmEnabled?sw.right-sw.height/2:sw.left+sw.height/2; canvas.drawCircle(Offset(knobX,sw.center.dy),sw.height*.34,Paint()..color=const Color(0xFF174B87));

    final how=Rect.fromLTWH(w*.105,h*.292,w*.79,h*.145); _card(canvas,how,const Color(0xFFEAF6FF),const Color(0xFF4A8BCB));
    _banner(canvas,Rect.fromLTWH(how.left+13,how.top+10,how.width*.44,34),const Color(0xFF2D73C6),'🎮  게임 방법');
    final items=['1  문 순서를 기억','2  같은 순서로 선택','3  성공하면 다음 스테이지'];
    for(var i=0;i<3;i++){
      final y=how.top+55+i*25;
      _text(canvas,items[i],Rect.fromLTWH(how.left+18,y,how.width-36,23),12.4,const Color(0xFF214A73),FontWeight.w900,align:TextAlign.left);
    }

    final level=Rect.fromLTWH(w*.105,h*.458,w*.79,h*.195); _card(canvas,level,const Color(0xFFFFF9D8),const Color(0xFF79A84F));
    _banner(canvas,Rect.fromLTWH(level.left+13,level.top+10,level.width*.44,34),const Color(0xFF55A53D),'🗺  단계 안내');
    const guide=['인간의 영역  I · II · III','초인의 영역  I · II · III','신의 영역'];
    for(var i=0;i<guide.length;i++){
      final cy=level.top+62+i*35;
      canvas.drawCircle(Offset(level.left+28,cy),11.5,Paint()..color=const Color(0xFF65B94D));
      _text(canvas,'${i+1}',Rect.fromLTWH(level.left+16.5,cy-11.5,23,23),11.8,const Color(0xFFFFFFFF),FontWeight.w900);
      _text(canvas,guide[i],Rect.fromLTWH(level.left+51,cy-13,level.width*.60,26),12.8,const Color(0xFF315B46),FontWeight.w900,align:TextAlign.left);
    }
    if(pixelArt!=null){ pixelArt.castle.render(canvas,position:Vector2(level.right-level.width*.25,level.top+48),size:Vector2(level.width*.20,level.width*.15)); }

    final fail=Rect.fromLTWH(w*.105,h*.673,w*.79,h*.112); _card(canvas,fail,const Color(0xFFFFEFE7),const Color(0xFFD56A59));
    _banner(canvas,Rect.fromLTWH(fail.left+13,fail.top+10,fail.width*.44,34),const Color(0xFFD95545),'💥  실패 규칙');
    _text(canvas,'실패하면 두 단계 전으로 돌아가\n다시 도전합니다.',Rect.fromLTWH(fail.left+18,fail.top+50,fail.width*.60,fail.height-55),12.2,const Color(0xFF7C3A32),FontWeight.w900,align:TextAlign.left,height:1.25);
    if(pixelArt!=null){ pixelArt.monster.render(canvas,position:Vector2(fail.right-fail.width*.27,fail.top+34),size:Vector2(fail.width*.23,fail.width*.23)); }

    final reset=resetRect(w,h); final rr1=RRect.fromRectAndRadius(reset,const Radius.circular(24)); canvas.drawRRect(rr1,Paint()..color=const Color(0xFF7EEB42)); canvas.drawRRect(rr1,Paint()..style=PaintingStyle.stroke..strokeWidth=2.4..color=const Color(0xFF17345B)); _text(canvas,'↻  처음부터',reset,16.4,const Color(0xFF102408),FontWeight.w900);
    final cont=continueRect(w,h); final rr2=RRect.fromRectAndRadius(cont,const Radius.circular(24)); canvas.drawRRect(rr2,Paint()..color=const Color(0xFF7EEB42)); canvas.drawRRect(rr2,Paint()..style=PaintingStyle.stroke..strokeWidth=2.4..color=const Color(0xFF17345B)); _text(canvas,'▶  계속하기',cont,16.4,const Color(0xFF102408),FontWeight.w900);
    _text(canvas,'처음부터: 진행 기록을 초기화하고 STAGE 3에서 다시 시작',Rect.fromLTWH(w*.12,h*.902,w*.76,h*.018),8.8,const Color(0xFF7F8792),FontWeight.w700);
  }
}
