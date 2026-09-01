import 'dart:ui';
import 'package:flame/components.dart';

class PixelArtKit {
  PixelArtKit._();

  late Sprite hero;
  late Sprite princess;
  late Sprite monster;
  late Sprite chest;
  late Sprite blueDoor;
  late Sprite pinkDoor;
  late Sprite tree;
  late Sprite castle;
  late Sprite cloud;

  static Future<PixelArtKit> load() async {
    final kit = PixelArtKit._();
    kit.hero = await Sprite.load('ui/pixel_hero.png');
    kit.princess = await Sprite.load('ui/pixel_princess.png');
    kit.monster = await Sprite.load('ui/pixel_monster.png');
    kit.chest = await Sprite.load('ui/pixel_chest.png');
    kit.blueDoor = await Sprite.load('ui/pixel_door_blue.png');
    kit.pinkDoor = await Sprite.load('ui/pixel_door_pink.png');
    kit.tree = await Sprite.load('ui/pixel_tree.png');
    kit.castle = await Sprite.load('ui/pixel_castle.png');
    kit.cloud = await Sprite.load('ui/pixel_cloud.png');
    return kit;
  }

  void renderBackground(Canvas canvas, Vector2 size, {
    bool showPath = true,
    bool showCastle = false,
    bool showTrees = false,
    bool rich = true,
  }) {
    final sky = Rect.fromLTWH(0, 0, size.x, size.y);
    canvas.drawRect(sky, Paint()..shader = Gradient.linear(
      Offset(size.x * .5, 0), Offset(size.x * .5, size.y),
      const [Color(0xFF159CE8), Color(0xFF74D5FF), Color(0xFFC9F1FF)],
      const [0.0, .52, 1.0],
    ));
    if (rich) {
      cloud.render(canvas, position: Vector2(size.x * .02, size.y * .19), size: Vector2(size.x * .21, size.x * .10));
      cloud.render(canvas, position: Vector2(size.x * .77, size.y * .16), size: Vector2(size.x * .18, size.x * .085));
      _sparkle(canvas, size.x * .15, size.y * .12, 10);
      _sparkle(canvas, size.x * .80, size.y * .15, 9);
    }
    final hill = Path()
      ..moveTo(0, size.y * .69)
      ..quadraticBezierTo(size.x * .22, size.y * .61, size.x * .42, size.y * .69)
      ..quadraticBezierTo(size.x * .62, size.y * .59, size.x, size.y * .68)
      ..lineTo(size.x, size.y)
      ..lineTo(0, size.y)
      ..close();
    canvas.drawPath(hill, Paint()..color = const Color(0xFF8BDE55));
    canvas.drawRect(Rect.fromLTWH(0, size.y * .77, size.x, size.y * .23), Paint()..color = const Color(0xFF61BC3D));
    if (showPath) _drawPath(canvas, size);
    if (showCastle) renderCastle(canvas, size);
    if (showTrees) renderTrees(canvas, size);
  }

  void renderCastle(Canvas canvas, Vector2 size, {double x=.31,double y=.34,double width=.38,double height=.285}) {
    castle.render(canvas, position: Vector2(size.x*x, size.y*y), size: Vector2(size.x*width, size.x*height));
  }

  void renderTrees(Canvas canvas, Vector2 size, {double top=.56,double leftScale=.23,double rightScale=.23}) {
    tree.render(canvas, position: Vector2(size.x*.015,size.y*top), size: Vector2(size.x*leftScale,size.x*leftScale));
    tree.render(canvas, position: Vector2(size.x*(1-.015-rightScale),size.y*(top+.01)), size: Vector2(size.x*rightScale,size.x*rightScale));
  }

  void renderDoorPair(Canvas canvas, Vector2 size, {double top=.52,double scale=.34,double heightScale=.31,double leftX=.07,double rightX=.59}) {
    final w=size.x*scale; final h=size.y*heightScale;
    blueDoor.render(canvas, position: Vector2(size.x*leftX,size.y*top), size: Vector2(w,h));
    pinkDoor.render(canvas, position: Vector2(size.x*rightX,size.y*top), size: Vector2(w,h));
  }

  void renderHero(Canvas canvas, Vector2 size, {double x=.36,double y=.69,double scale=.30}) {
    hero.render(canvas, position: Vector2(size.x*x,size.y*y), size: Vector2(size.x*scale,size.x*scale));
  }

  void renderIntroWorld(Canvas canvas, Vector2 size) {
    renderBackground(canvas,size,showPath:true,rich:true);
    renderCastle(canvas,size,x:.29,y:.39,width:.42,height:.31);
    renderTrees(canvas,size,top:.55,leftScale:.22,rightScale:.22);
    renderDoorPair(canvas,size,top:.55,scale:.34,heightScale:.31,leftX:.055,rightX:.605);
    renderHero(canvas,size,x:.35,y:.715,scale:.30);
  }

  void renderClearParty(Canvas canvas, Vector2 size) {
    renderBackground(canvas,size,showPath:true,rich:true);
    renderTrees(canvas,size,top:.40,leftScale:.25,rightScale:.25);
    renderCastle(canvas,size,x:.28,y:.31,width:.44,height:.33);
    chest.render(canvas,position:Vector2(size.x*.06,size.y*.50),size:Vector2(size.x*.24,size.x*.24));
    hero.render(canvas,position:Vector2(size.x*.29,size.y*.46),size:Vector2(size.x*.30,size.x*.30));
    princess.render(canvas,position:Vector2(size.x*.52,size.y*.43),size:Vector2(size.x*.34,size.x*.34));
  }

  void renderFailWorld(Canvas canvas, Vector2 size) {
    renderBackground(canvas,size,showPath:true,rich:true);
    renderTrees(canvas,size,top:.55,leftScale:.22,rightScale:.22);
    renderCastle(canvas,size,x:.36,y:.30,width:.28,height:.21);
    monster.render(canvas,position:Vector2(size.x*.29,size.y*.38),size:Vector2(size.x*.42,size.x*.42));
  }

  void _sparkle(Canvas canvas,double cx,double cy,double r){
    final p=Paint()..color=const Color(0xFFFFF0A3)..strokeWidth=3..strokeCap=StrokeCap.square;
    canvas.drawLine(Offset(cx-r,cy),Offset(cx+r,cy),p); canvas.drawLine(Offset(cx,cy-r),Offset(cx,cy+r),p);
  }

  void _drawPath(Canvas canvas,Vector2 size){
    final p=Path()..moveTo(size.x*.40,size.y)..lineTo(size.x*.60,size.y)..lineTo(size.x*.545,size.y*.70)..lineTo(size.x*.455,size.y*.70)..close();
    canvas.drawPath(p,Paint()..color=const Color(0xFFE7D09A));
    for(var i=0;i<15;i++){
      final y=size.y*(.72+i*.018); final l=size.x*(.466-i*.006); final r=size.x*(.534+i*.006);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(l,y,r-l,size.y*.0085),const Radius.circular(4)),Paint()..color=const Color(0xFFD2B982));
    }
  }
}
