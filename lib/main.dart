import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game/audio/audio_manager.dart';
import 'game/core/progress_store.dart';
import 'game/monster_door_game.dart';

const appDisplayName = 'MonsterDoor';
const appVersion = '7.1.6';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final game = MonsterDoorGame(
    progressStore: ProgressStore(prefs),
    audioManager: AudioManager(),
  );

  runApp(MonsterDoorApp(game: game));
}

class MonsterDoorApp extends StatefulWidget {
  const MonsterDoorApp({super.key, required this.game});
  final MonsterDoorGame game;

  @override
  State<MonsterDoorApp> createState() => _MonsterDoorAppState();
}

class _MonsterDoorAppState extends State<MonsterDoorApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.game.audioManager.stopBgm();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.game.audioManager.startBgm();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      widget.game.audioManager.stopBgm();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$appDisplayName v$appVersion',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: SizedBox.expand(
            child: GameWidget(game: widget.game),
          ),
        ),
      ),
    );
  }
}
