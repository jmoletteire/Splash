import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/more/transactions/transactions_cache.dart';
import 'package:splash/screens/more/transactions/transactions_network_helper.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/custom_icon_button.dart';
import '../../../components/player_avatar.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import '../../player/player_home.dart';
import '../../search_screen.dart';

class LeagueTransactions extends StatefulWidget {
  const LeagueTransactions({super.key});

  @override
  State<LeagueTransactions> createState() => _LeagueTransactionsState();
}

class _LeagueTransactionsState extends State<LeagueTransactions> {
  late List transactions;
  late String selectedSeason;
  bool _isLoading = true;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;

  Future<void> getTransactions() async {
    final transactionsCache = Provider.of<TransactionsCache>(context, listen: false);
    if (transactionsCache.containsTransactions()) {
      setState(() {
        transactions = transactionsCache.getTransactions()!;
        transactions.sort((a, b) => b['TRANSACTION_DATE'].compareTo(a['TRANSACTION_DATE']));
        _isLoading = false;
      });
    } else {
      var fetchedTransactions = await TransactionsNetworkHelper().getTransactions();
      setState(() {
        transactions = fetchedTransactions;
        transactions.sort((a, b) => b['TRANSACTION_DATE'].compareTo(a['TRANSACTION_DATE']));
        _isLoading = false;
      });
      transactionsCache.addTransactions(transactions);
    }
  }

  @override
  void initState() {
    super.initState();
    selectedSeason = kCurrentSeason;
    getTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController('lg_transactions', _scrollController);
  }

  @override
  void dispose() {
    _notifier.removeController('lg_transactions');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SpinningIcon()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey.shade900,
              surfaceTintColor: Colors.grey.shade900,
              title: Text(
                'Transactions',
                style: kBebasBold.copyWith(fontSize: 22.0.r),
              ),
              actions: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      border: Border.all(color: Colors.deepOrange),
                      borderRadius: BorderRadius.circular(10.0)),
                  margin: EdgeInsets.symmetric(vertical: 6.0.r),
                  child: DropdownButton<String>(
                    menuMaxHeight: 300.0.r,
                    isExpanded: false,
                    padding: EdgeInsets.symmetric(horizontal: 15.0.r),
                    borderRadius: BorderRadius.circular(10.0),
                    underline: Container(),
                    dropdownColor: Colors.grey.shade900,
                    value: selectedSeason,
                    items: kSeasons.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: kBebasNormal.copyWith(fontSize: 18.0.r),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      setState(() {
                        selectedSeason = newValue!;
                        _scrollController.jumpTo(0);
                      });
                      getTransactions();
                    },
                  ),
                ),
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
              ],
            ),
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    minHeight: 38.0.r,
                    maxHeight: 38.0.r,
                    child: Container(
                      color: Colors.grey.shade800,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 11.0.r),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Date',
                                  style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'TEAM',
                                  style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  'Details',
                                  style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    bottom: kBottomNavigationBarHeight,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        // List to hold the widgets to be returned
                        List<Widget> widgets = [];

                        List<String> formatDate(String date) {
                          // Parse the string to a DateTime object
                          DateTime dateTime = DateTime.parse(date);

                          // Create a DateFormat for the abbreviated day of the week
                          DateFormat dayOfWeekFormat = DateFormat('E');
                          String dayOfWeek = dayOfWeekFormat.format(dateTime);

                          // Create a DateFormat for the month and date
                          DateFormat monthDateFormat = DateFormat('M/d');
                          String monthDate = monthDateFormat.format(dateTime);

                          return [dayOfWeek, monthDate];
                        }

                        List<String> gameDate =
                            formatDate(transactions[index]['TRANSACTION_DATE']);

                        // Define the main container to return
                        Widget gameContainer = GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerHome(
                                  playerId:
                                      transactions[index]['PLAYER_ID'].toStringAsFixed(0),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.0.r, vertical: 8.0.r),
                            height: MediaQuery.sizeOf(context).height * 0.065,
                            decoration: const BoxDecoration(
                              color: Color(0xFF1B1B1B),
                              border: Border(
                                  bottom: BorderSide(color: Colors.white70, width: 0.125)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gameDate[0],
                                        style: kBebasNormal.copyWith(
                                            fontSize: 11.0.r, color: Colors.white70),
                                      ),
                                      Text(
                                        gameDate[1],
                                        style: kBebasNormal.copyWith(fontSize: 11.5.r),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset(
                                  'images/NBA_Logos/${transactions[index]['TEAM_ID'].toStringAsFixed(0)}.png',
                                  width: 22.0.r,
                                ),
                                SizedBox(width: 15.0.r),
                                PlayerAvatar(
                                  radius: 13.0.r,
                                  backgroundColor: Colors.white10,
                                  playerImageUrl:
                                      'https://cdn.nba.com/headshots/nba/latest/1040x760/${transactions[index]['PLAYER_ID'].toStringAsFixed(0)}.png',
                                ),
                                SizedBox(width: 12.0.r),
                                Expanded(
                                  flex: 6,
                                  child: AutoSizeText(
                                    transactions[index]['TRANSACTION_DESCRIPTION'],
                                    maxLines: 3,
                                    textAlign: TextAlign.start,
                                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );

                        widgets.add(gameContainer);

                        return Column(
                          children: widgets,
                        );
                      },
                      childCount: transactions.length,
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(child: child);
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxExtent ||
        minHeight != oldDelegate.minExtent ||
        child != oldDelegate;
  }
}
