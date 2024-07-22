import 'package:flutter/material.dart';

class LeagueHistory extends StatefulWidget {
  const LeagueHistory({super.key});

  @override
  State<LeagueHistory> createState() => _LeagueHistoryState();
}

class _LeagueHistoryState extends State<LeagueHistory> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of main tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Main Tabs with Subtabs'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Main Tab 1'),
              Tab(text: 'Main Tab 2'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MainTabContent(index: 1),
            MainTabContent(index: 2),
          ],
        ),
      ),
    );
  }
}

class MainTabContent extends StatelessWidget {
  final int index;

  MainTabContent({required this.index});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of subtabs
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove the back button
          bottom: TabBar(
            tabs: [
              Tab(text: 'Subtab 1.$index'),
              Tab(text: 'Subtab 2.$index'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SubTabContent(subIndex: 1, mainIndex: index),
            SubTabContent(subIndex: 2, mainIndex: index),
          ],
        ),
      ),
    );
  }
}

class SubTabContent extends StatelessWidget {
  final int mainIndex;
  final int subIndex;

  SubTabContent({required this.mainIndex, required this.subIndex});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Text('Content of Main Tab $mainIndex, Subtab $subIndex'),
          ],
        ),
      ),
    );
  }
}
