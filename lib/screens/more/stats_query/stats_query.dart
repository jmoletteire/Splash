import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/more/stats_query/filters_bottom_sheet.dart';
import 'package:splash/screens/more/stats_query/players_table.dart';
import 'package:splash/screens/more/stats_query/util/column_options.dart';
import 'package:splash/screens/more/stats_query/util/custom_bottom_sheet.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/scroll/scroll_controller_notifier.dart';

import '../../../components/custom_icon_button.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import '../../search_screen.dart';

class StatsQuery extends StatefulWidget {
  const StatsQuery({super.key});

  @override
  State<StatsQuery> createState() => _StatsQueryState();
}

class _StatsQueryState extends State<StatsQuery> with SingleTickerProviderStateMixin {
  List<dynamic>? queryData;
  String? selectedSeason;
  String? selectedSeasonType;
  String? selectedPosition;
  List<ColumnOption> selectedColumns = [];
  bool _isLoading = false;
  late ScrollController _scrollController;
  late TabController _tabController;
  late ScrollControllerNotifier _notifier;

  void _showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: kBebasNormal.copyWith(
          color: Colors.white,
          fontSize: 16.0.r,
        ),
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 3),
      showCloseIcon: true,
      closeIconColor: Colors.white,
      dismissDirection: DismissDirection.vertical,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _handleFiltersDone(Map<String, dynamic> data) {
    setState(() {
      queryData = data['data'];
      selectedSeason = data['selectedSeason'];
      selectedSeasonType = data['selectedSeasonType'];
      selectedPosition = data['selectedPosition'];
    });
  }

  void _showColumnSelector() {
    showModalBottomSheet(
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
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

  Future<void> initialQuery() async {
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse('http://$kFlaskUrl/stats_query');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'selectedSeason': kCurrentSeason,
        'selectedSeasonType': 'REGULAR SEASON',
        'selectedPosition': 'ALL',
        'filters': [],
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      _handleFiltersDone({
        'data': data,
        'selectedSeason': kCurrentSeason,
        'selectedSeasonType': 'REGULAR SEASON',
        'selectedPosition': 'ALL',
      });
    } else {
      _showErrorSnackBar(context, 'Error fetching data from server');
    }
  }

  @override
  void initState() {
    super.initState();
    selectedColumns = List.from(kAllColumns); // Initially select all columns
    _tabController = TabController(length: 2, vsync: this);
    initialQuery();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController('stats_query', _scrollController);
  }

  @override
  void dispose() {
    _notifier.removeController('stats_query');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SpinningIcon()
        : Scaffold(
            backgroundColor: const Color(0xFF111111),
            appBar: AppBar(
              backgroundColor: Colors.grey.shade900,
              surfaceTintColor: Colors.grey.shade900,
              title: Text(
                'STATS',
                style:
                    TextStyle(color: Colors.white, fontFamily: 'Bebas_Neue', fontSize: 26.0.r),
              ),
              actions: [
                CustomIconButton(
                  icon: Icons.search,
                  size: 30.0.r,
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
                  size: 30.0.r,
                  onPressed: _showColumnSelector,
                ),
                FiltersBottomSheet(onDone: _handleFiltersDone)
              ],
              /*
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Colors.deepOrange,
          indicatorWeight: 3.0,
          unselectedLabelColor: Colors.grey,
          labelColor: Colors.white,
          labelStyle: kBebasNormal.copyWith(fontSize: 16.0.r),
          tabs: const [Tab(text: 'Players'), Tab(text: 'Teams')],
        ),

         */
            ),
            body: Center(
              child: queryData == null || queryData!.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (queryData == null)
                          Text(
                            'Select Filters',
                            style: kBebasNormal.copyWith(fontSize: 18.0.r),
                          )
                        else
                          Text(
                            'No Results',
                            style: kBebasNormal.copyWith(fontSize: 18.0.r),
                          ),
                        SizedBox(width: 5.0.r),
                        if (queryData == null)
                          Icon(
                            Icons.filter_alt,
                            size: 20.0.r,
                          )
                      ],
                    )
                  : CustomScrollView(
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
          );
  }
}
