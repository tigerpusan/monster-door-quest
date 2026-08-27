import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game/audio/audio_manager.dart';
import 'game/core/progress_store.dart';
import 'game/monster_door_game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs=await SharedPreferences.getInstance();
  final game=MonsterDoorGame(progressStore:ProgressStore(prefs),audioManager:AudioManager());
  runApp(MaterialApp(
    debugShowCheckedModeBanner:false,
    home:Scaffold(
      backgroundColor:Colors.black,
      body:SafeArea(top:false,bottom:false,child:GameWidget(game:game)),
    ),
  ));
}
