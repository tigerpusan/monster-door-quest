import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart' show TextPainter, TextSpan, TextStyle, TextDirection, FontWeight;
class ActionButton extends PositionComponent with TapCallbacks {
  ActionButton({required this.label, required this.onPressed, this.green=true}); final String label; final void Function() onPressed; final bool green;
  @override void onTapDown(TapDownEvent event){ scale=Vector2.all(.985); }
  @override void onTapCancel(TapCancelEvent event){ scale=Vector2.all(1); }
  @override void onTapUp(TapUpEvent event){ scale=Vector2.all(1); onPressed(); }
  @override void render(Canvas canvas){ super.render(canvas); final rect=RRect.fromRectAndRadius(size.toRect(),const Radius.circular(22)); canvas.drawRRect(rect,Paint()..color=green?const Color(0xFF79E94C):const Color(0xFF2D174A)); final tp=TextPainter(text:TextSpan(text:label,style:TextStyle(color:green?const Color(0xFF10220B):const Color(0xFFFFFFFF),fontSize:18,fontWeight:FontWeight.w800)),textDirection:TextDirection.ltr)..layout(); tp.paint(canvas,Offset((size.x-tp.width)/2,(size.y-tp.height)/2)); }
}
