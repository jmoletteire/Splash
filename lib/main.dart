import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:provider/provider.dart';
import 'package:splash/screens/game/game_cache.dart';
import 'package:splash/screens/more/draft/draft_cache.dart';
import 'package:splash/screens/more/transactions/transactions_cache.dart';
import 'package:splash/screens/player/player_cache.dart';
import 'package:splash/screens/player/shot_chart/shot_chart_cache.dart';
import 'package:splash/screens/search_screen.dart';
import 'package:splash/screens/standings/nba_cup/nba_cup_cache.dart';
import 'package:splash/screens/standings/playoffs/playoffs_cache.dart';
import 'package:splash/screens/team/team_cache.dart';
import 'package:splash/utilities/game_dates.dart';
import 'package:splash/utilities/global_variables.dart';
import 'package:splash/utilities/scroll/tap_status_bar_to_scroll.dart';
import 'package:splash/utilities/tab_home.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set the time zone when the app starts
  await setGlobalTimeZone();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerCache()),
        ChangeNotifierProvider(create: (_) => PlayerShotChartCache()),
        ChangeNotifierProvider(create: (_) => TeamCache()),
        ChangeNotifierProvider(create: (_) => GameCache()),
        ChangeNotifierProvider(create: (_) => PlayoffCache()),
        ChangeNotifierProvider(create: (_) => NbaCupCache()),
        ChangeNotifierProvider(create: (_) => TransactionsCache()),
        ChangeNotifierProvider(create: (_) => DraftCache()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => DatesProvider()..fetchDates()),
      ],
      child: const Splash(),
    ),
  );
}

Future<void> setGlobalTimeZone() async {
  // Initialize time zone data
  initializeTimeZones();

  // Get the device's time zone
  String timeZoneName = await FlutterTimezone.getLocalTimezone();

  // Set the global location variable
  GlobalTimeZone.location = getLocation(timeZoneName);
}

class DeviceSize extends InheritedWidget {
  final double width;
  final double height;

  DeviceSize({required this.width, required this.height, required Widget child})
      : super(child: child);

  static DeviceSize? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DeviceSize>();
  }

  @override
  bool updateShouldNotify(DeviceSize oldWidget) {
    return width != oldWidget.width || height != oldWidget.height;
  }
}

class Splash extends StatelessWidget {
  const Splash({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone 11 design size
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF111111),
          textTheme: Typography.whiteCupertino.copyWith(
            bodyMedium: const TextStyle(fontSize: 18.0),
          ),
        ),
        home: const TapStatusBarToScroll(child: TabHomeScreen()),
      ),
    );
  }
}
