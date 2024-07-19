import 'package:flutter/material.dart';
import 'package:splash/screens/more/stats_query/filters_bottom_sheet.dart';
import 'package:splash/screens/more/stats_query/players_table.dart';
import 'package:splash/screens/more/stats_query/util/column_options.dart';
import 'package:splash/screens/more/stats_query/util/custom_bottom_sheet.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/scroll/scroll_controller_notifier.dart';

import '../../../components/custom_icon_button.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import '../../player/career/player_career.dart';
import '../../search_screen.dart';

class StatsQuery extends StatefulWidget {
  const StatsQuery({super.key});

  @override
  State<StatsQuery> createState() => _StatsQueryState();
}

class _StatsQueryState extends State<StatsQuery> {
  List<dynamic>? queryData;
  String? selectedSeason;
  String? selectedSeasonType;
  String? selectedPosition;
  List<ColumnOption> selectedColumns = [];
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;

  void _handleFiltersDone(Map<String, dynamic> data) {
    setState(() {
      queryData = data['data'];
      selectedSeason = data['selectedSeason'];
      selectedSeasonType = data['selectedSeasonType'];
      selectedPosition = data['selectedPosition'];
    });
    print(queryData?.length);
  }

  void _showColumnSelector() {
    showModalBottomSheet(
      scrollControlDisabledMaxHeightRatio: 0.75,
      backgroundColor: const Color(0xFF111111),
      context: context,
      builder: (context) {
        return CustomBottomSheet(
          selectedColumns: selectedColumns,
          updateSelectedColumns: updateSelectedColumns,
        );
      },
    );
  }

  void updateSelectedColumns(List<ColumnOption> newColumns) {
    setState(() {
      selectedColumns = newColumns;
    });
  }

  @override
  void initState() {
    super.initState();
    selectedColumns = List.from(kAllColumns); // Initially select all columns
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController(_scrollController);
  }

  @override
  void dispose() {
    _notifier.removeController(_scrollController);
    _scrollController.dispose();
    super.dispose();
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
          style: TextStyle(color: Colors.white, fontFamily: 'Bebas_Neue', fontSize: 28.0),
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
          CustomIconButton(
            icon: Icons.table_rows,
            onPressed: _showColumnSelector,
          ),
          FiltersBottomSheet(onDone: _handleFiltersDone)
        ],
      ),
      body: Center(
        child: queryData == null || queryData!.isEmpty
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (queryData == null)
                    const Text(
                      'Select Filters',
                      style: kBebasNormal,
                    )
                  else
                    const Text(
                      'No Results',
                      style: kBebasNormal,
                    ),
                  const SizedBox(width: 5.0),
                  if (queryData == null)
                    const Icon(
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
                      selectedColumns: selectedColumns,
                      selectedSeason: selectedSeason!,
                      selectedSeasonType: selectedSeasonType!,
                      players: queryData!,
                      updateSelectedColumns: updateSelectedColumns,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
