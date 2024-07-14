import 'package:flutter/material.dart';
import 'package:splash/screens/more/stats_query/filters_bottom_sheet.dart';
import 'package:splash/screens/more/stats_query/players_table.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/custom_icon_button.dart';
import '../../player/player_career.dart';
import '../../search_screen.dart';

class Leaders extends StatefulWidget {
  const Leaders({super.key});

  @override
  State<Leaders> createState() => _LeadersState();
}

class _LeadersState extends State<Leaders> {
  List<dynamic>? queryData;
  String? selectedSeason;
  final ScrollController _scrollController = ScrollController();

  void _handleFiltersDone(Map<String, dynamic> data) {
    print('Data: ${data['data']}');
    setState(() {
      queryData = data['data'];
      selectedSeason = data['selectedSeason'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        surfaceTintColor: Colors.grey.shade900,
        title: const Text(
          'STATS',
          style: TextStyle(
              color: Colors.white, fontFamily: 'Bebas_Neue', fontSize: 28.0),
        ),
        actions: [
          CustomIconButton(
            icon: Icons.search,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                ),
              );
            },
          ),
          FiltersBottomSheet(onDone: _handleFiltersDone)
        ],
      ),
      body: Center(
        child: queryData == null
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Select Filters',
                    style: kBebasNormal,
                  ),
                  SizedBox(width: 5.0),
                  Icon(
                    Icons.filter_alt,
                    size: 20.0,
                  )
                ],
              )
            : ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    PlayersTable(
                      columnNames: const [
                        'PLAYER',
                        'TEAM',
                        'AGE',
                        'POS',
                        'PPG',
                        'RPG',
                        'APG',
                        'SPG',
                        'BPG',
                        'TOPG',
                        'FG%',
                        '3P%',
                        'FT%',
                        'EFG%',
                        'TS%',
                        'USG%',
                        'NRTG',
                        'ORTG',
                        'DRTG',
                        'WO 3P%',
                        'NW',
                        'PAC',
                        'SW',
                      ],
                      selectedSeason: selectedSeason!,
                      players: queryData!,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
