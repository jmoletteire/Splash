import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/game/game_cache.dart';
import 'package:splash/screens/player/player_cache.dart';
import 'package:splash/screens/search_screen.dart';
import 'package:splash/screens/team/team_cache.dart';
import 'package:splash/utilities/scroll/tap_status_bar_to_scroll.dart';
import 'package:splash/utilities/tab_home.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerCache()),
        ChangeNotifierProvider(create: (_) => TeamCache()),
        ChangeNotifierProvider(create: (_) => GameCache()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: Splash(),
    ),
  );
}

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF111111),
        textTheme: Typography.whiteCupertino.copyWith(
          bodyMedium: const TextStyle(fontSize: 18.0),
        ),
      ),
      home: TapStatusBarToScroll(child: TabHomeScreen()),
    );
  }
}
