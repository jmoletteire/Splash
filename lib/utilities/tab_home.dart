import 'package:flutter/material.dart';
import 'package:splash/screens/game/scoreboard.dart';
import 'package:splash/screens/standings/standings.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/scroll/scroll_controller_notifier.dart';
import 'package:splash/utilities/scroll/scroll_controller_provider.dart';

import '../screens/more/more.dart';

class TabHomeScreen extends StatefulWidget {
  const TabHomeScreen({super.key});

  @override
  State<TabHomeScreen> createState() => _TabHomeScreenState();
}

class _TabHomeScreenState extends State<TabHomeScreen> {
  int _selectedIndex = 0;

  /// ******************************************************
  ///     Different Navigator Key for each tab in
  ///     Bottom Navigation Bar.
  ///
  ///     Allows each tab to "remember" the user's
  ///     location in its stack when changing tabs.
  /// ******************************************************

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  /// ******************************************************
  ///     Update selected index in Bottom Nav Bar,
  ///     or navigate to tab root.
  /// ******************************************************

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        // Switch to selected tab (index).
        _selectedIndex = index;
      });
    } else {
      // If already at the root of the stack, scroll to top
      if (_navigatorKeys[index].currentState?.canPop() == false) {
        ScrollControllerNotifier notifier = ScrollControllerProvider.of(context)!.notifier;
        notifier.scrollToTop();
      } else {
        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      }
    }
  }

  /// ******************************************************
  ///                 Initialize page
  ///        --> Tab Controller length = # of Tabs
  /// ******************************************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildNavigator(_navigatorKeys[0], "Scoreboard"),
          _buildNavigator(_navigatorKeys[1], "Standings"),
          _buildNavigator(_navigatorKeys[2], "More"),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey.shade900,
        //selectedFontSize: 0.0,
        selectedItemColor: Colors.white,
        selectedLabelStyle: kBebasNormal.copyWith(fontSize: 12.0),
        unselectedItemColor: Colors.grey,
        unselectedLabelStyle: kBebasNormal.copyWith(fontSize: 12.0),
        iconSize: 32.0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.scoreboard_outlined),
            label: 'Scores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stacked_bar_chart),
            label: 'Standings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: 'More',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  /// ******************************************************
  ///          Use Navigator for the selected tab.
  /// ******************************************************

  Widget _buildNavigator(GlobalKey<NavigatorState> key, String screen) {
    return Navigator(
      key: key,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => _buildScreen(screen),
        );
      },
    );
  }

  /// ******************************************************
  ///                 Build selected page.
  /// ******************************************************

  Widget _buildScreen(String screen) {
    switch (screen) {
      case "Scoreboard":
        return const Scoreboard();
      case "Standings":
        return const Standings();
      case "More":
        return const More();
      default:
        return Center(
          child: Text(
            'S',
            style: kBebasNormal.copyWith(fontSize: 100.0),
          ),
        );
    }
  }
}
