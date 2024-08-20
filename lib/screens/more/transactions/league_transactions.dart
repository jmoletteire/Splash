import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/more/transactions/transactions_cache.dart';
import 'package:splash/screens/more/transactions/transactions_network_helper.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/custom_icon_button.dart';
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
        _isLoading = false;
      });
    } else {
      var fetchedTransactions = await TransactionsNetworkHelper().getTransactions();
      setState(() {
        transactions = fetchedTransactions;
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
    return _isLoading
        ? const SpinningIcon()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey.shade900,
              surfaceTintColor: Colors.grey.shade900,
              title: Text(
                'Transactions',
                style: kBebasBold.copyWith(fontSize: 24.0),
              ),
              actions: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      border: Border.all(color: Colors.deepOrange),
                      borderRadius: BorderRadius.circular(10.0)),
                  margin: const EdgeInsets.fromLTRB(0.0, 11.0, 0.0, 11.0),
                  child: DropdownButton<String>(
                    menuMaxHeight: 300.0,
                    isExpanded: false,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    borderRadius: BorderRadius.circular(10.0),
                    underline: Container(),
                    dropdownColor: Colors.grey.shade900,
                    value: selectedSeason.substring(0, 4),
                    items: kSeasons.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value.substring(0, 4),
                        child: Text(
                          value.substring(0, 4),
                          style: kBebasNormal,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      setState(() {
                        selectedSeason = newValue!.substring(0, 4);
                        _scrollController.jumpTo(0);
                      });
                      getTransactions();
                    },
                  ),
                ),
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
              ],
            ),
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    minHeight: 40.0,
                    maxHeight: 40.0,
                    child: Container(
                      color: Colors.grey.shade800,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Date',
                                  style: kBebasNormal.copyWith(fontSize: 18.0),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'TEAM',
                                  style: kBebasNormal.copyWith(fontSize: 18.0),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  'Details',
                                  textAlign: TextAlign.start,
                                  style: kBebasNormal.copyWith(fontSize: 18.0),
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

                        String formatDate(String date) {
                          DateTime dateTime = DateTime.parse(date);

                          String formattedDate = DateFormat('M/d/yy').format(dateTime);
                          return formattedDate;
                        }

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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
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
                                  child: Text(
                                    formatDate(transactions[index]['TRANSACTION_DATE']),
                                    style: kBebasNormal.copyWith(
                                        color: Colors.grey, fontSize: 14.0),
                                  ),
                                ),
                                const SizedBox(width: 8.0),
                                Image.asset(
                                  'images/NBA_Logos/${transactions[index]['TEAM_ID'].toStringAsFixed(0)}.png',
                                  width: 28.0,
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: PlayerAvatar(
                                    radius: 12.0,
                                    backgroundColor: Colors.white10,
                                    playerImageUrl:
                                        'https://cdn.nba.com/headshots/nba/latest/1040x760/${transactions[index]['PLAYER_ID'].toStringAsFixed(0)}.png',
                                  ),
                                ),
                                Expanded(
                                  flex: 6,
                                  child: AutoSizeText(
                                    transactions[index]['TRANSACTION_DESCRIPTION'],
                                    maxLines: 1,
                                    textAlign: TextAlign.end,
                                    style: kBebasNormal.copyWith(fontSize: 16.0),
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
