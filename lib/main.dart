import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game/audio/audio_manager.dart';
import 'game/core/progress_store.dart';
import 'game/monster_door_game.dart';

const appDisplayName = 'MonsterDoor';
const appVersion = '0.7.0';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final game = MonsterDoorGame(
    progressStore: ProgressStore(prefs),
    audioManager: AudioManager(),
  );

  runApp(
    MaterialApp(
      title: '$appDisplayName v$appVersion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SizedBox.expand(
            child: GameWidget(game: game),
          ),
        ),
      ),
    ),
  );
}
