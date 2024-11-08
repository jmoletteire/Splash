import 'dart:async';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:splash/components/custom_icon_button.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/game/game_odds.dart';
import 'package:splash/screens/game/play_by_play/play_by_play.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/scroll/scroll_controller_notifier.dart';

import '../../utilities/game.dart';
import '../../utilities/scroll/scroll_controller_provider.dart';
import '../search_screen.dart';
import '../team/team_home.dart';
import 'boxscore/game_boxscore.dart';
import 'boxscore/game_preview/game_preview_stats.dart';
import 'matchup/game_matchup.dart';

class GameHome extends StatefulWidget {
  static const String id = 'game_home';
  final Map<String, dynamic>? gameData;
  final String gameId;
  final String homeId;
  final String awayId;
  final String gameDate;
  final String? gameTime;

  const GameHome({
    super.key,
    this.gameData,
    required this.gameId,
    required this.homeId,
    required this.awayId,
    required this.gameDate,
    this.gameTime,
  });

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  Map<int, double> _scrollPositions = {};
  Map<String, dynamic> game = {};
  bool _showImages = false;
  bool _isLoading = false;
  bool _isUpcoming = false;
  late Timer _timer;
  Map<String, dynamic> odds = {};
  String moneyLine = '';
  String spread = '';
  String overUnder = '';
  String countdown = '';

  int decimalToMoneyline(double decimalOdds) {
    if (decimalOdds <= 1.0) {
      throw ArgumentError('Decimal odds must be greater than 1.');
    }

    if (decimalOdds >= 2.0) {
      // Positive moneyline odds
      return ((decimalOdds - 1.0) * 100).round();
    } else {
      // Negative moneyline odds
      return (-100 / (decimalOdds - 1.0)).round();
    }
  }

  void setOdds(Map<String, dynamic> game) {
    bool _isLive = false;

    try {
      if (game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] != 1 &&
          game['ODDS']?['LIVE'].containsKey('26338')) {
        odds = game['ODDS']?['LIVE']?['26338'];
        _isLive = true;
      } else {
        odds = game['ODDS']?['BOOK']?['18186'];
      }
    } catch (e) {
      odds = {};
      return;
    }

    // MoneyLine
    try {
      int raw = decimalToMoneyline(
          double.parse(odds['oddstypes'][_isLive ? '19' : '1']['outcomes']['1']['odds']));
      if (raw > 0) {
        moneyLine = '+${raw.toString()}';
      } else {
        moneyLine = raw.toString();
      }
    } catch (e) {
      moneyLine = '';
    }

    // Spread
    try {
      double raw = double.parse(odds['oddstypes'][_isLive ? '168' : '4']['hcp']['value']);
      if (raw > 0) {
        spread = '+${raw.toStringAsFixed(1)}';
      } else {
        spread = raw.toStringAsFixed(1);
      }
    } catch (e) {
      spread = '';
    }

    // Over/Under
    try {
      double raw = double.parse(odds['oddstypes'][_isLive ? '18' : '3']['hcp']['value']);
      overUnder = raw.toStringAsFixed(1);
    } catch (e) {
      overUnder = '';
    }

    setState(() {
      odds = {
        'ML': moneyLine,
        'SPREAD': spread,
        'OU': overUnder,
      };
    });
  }

  void startPolling(String gameId, String gameDate) {
    // Poll every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getGame(gameId, gameDate); // Call fetchGames every 10 seconds to get updated data
    });
  }

  Future<void> getGame(String gameId, String gameDate) async {
    var fetchedGame = await Game().getGame(gameId, gameDate);
    setState(() {
      game = fetchedGame;
    });
  }

  Future<void> setValues(String gameId, String gameDate) async {
    setState(() {
      _isLoading = true;
    });
    await getGame(gameId, gameDate);
    setOdds(game);
    _isUpcoming = game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 1;
    setState(() {
      _isLoading = false;
    });

    if (_isUpcoming) {
      if (game.containsKey('BOXSCORE')) {
        if (game['BOXSCORE']['gameStatusText'] == 'pregame') {
          setState(() {
            countdown = game['BOXSCORE']['gameClock'];
          });
        }
      }
    }
  }

  /// ******************************************************
  ///                 Initialize page
  ///        --> Tab Controller length = # of Tabs
  /// ******************************************************

  @override
  void initState() {
    super.initState();

    if (widget.gameData == null) {
      setValues(widget.gameId, widget.gameDate);
    } else {
      game = widget.gameData!;
      setOdds(game);
      _isUpcoming = game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 1;
      if (_isUpcoming) {
        if (game.containsKey('BOXSCORE')) {
          if (game['BOXSCORE']['gameStatusText'] == 'pregame') {
            setState(() {
              countdown = game['BOXSCORE']['gameClock'];
            });
          }
        }
      }
      _isLoading = false;
    }
    startPolling(widget.gameId, widget.gameDate);

    int tabLength = 4;

    if (_isUpcoming) {
      tabLength -= 1;
    }

    _tabController = TabController(length: tabLength, vsync: this);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showImages = _isSliverAppBarExpanded ? true : false;
        });

        // Save the scroll position of the current tab
        _scrollPositions[_tabController.index] = _scrollController.offset;
      });

    _tabController.addListener(() {
      // If app bar expanded
      if (_scrollController.offset < (201.r - kToolbarHeight)) {
        // Remain at current offset
        _scrollController.jumpTo(_scrollController.offset);
      }
      // Else, app bar collapsed and no collapsed position saved
      else {
        // Go to top collapsed position
        _scrollController.jumpTo(201.r - kToolbarHeight);
      }
    });
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients && _scrollController.offset > (200.r - kToolbarHeight);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _showImages = _isSliverAppBarExpanded ? true : false;
        });
      });
    _notifier.addController('game', _scrollController);
  }

  /// ******************************************************
  ///    Dispose of Controllers with page to conserve
  ///    memory & improve performance.
  /// ******************************************************

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeController('game');
    _scrollController.dispose();
    _timer.cancel();
    super.dispose();
  }

  /// ******************************************************
  ///      Initialize each tab via anonymous function.
  /// ******************************************************

  final List<
      Widget Function({
        required Map<String, dynamic> game,
        required String homeId,
        required String awayId,
        required bool isUpcoming,
      })> _gamePages = [
    ({
      required Map<String, dynamic> game,
      required String homeId,
      required String awayId,
      required bool isUpcoming,
    }) =>
        GameMatchup(
          game: game,
          homeId: homeId,
          awayId: awayId,
          isUpcoming: isUpcoming,
        ),
    ({
      required Map<String, dynamic> game,
      required String homeId,
      required String awayId,
      required bool isUpcoming,
    }) =>
        PlayByPlay(
          game: game,
          homeId: homeId,
          awayId: awayId,
        ),
    ({
      required Map<String, dynamic> game,
      required String homeId,
      required String awayId,
      required bool isUpcoming,
    }) {
      if (isUpcoming) {
        return GamePreviewStats(
          game: game,
          homeId: homeId,
          awayId: awayId,
        );
      } else {
        return GameBoxScore(
          game: game,
          homeId: homeId,
          awayId: awayId,
          inProgress: game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2,
        );
      }
    }
  ];

  /// ******************************************************
  ///                   Build the page.
  /// ******************************************************

  Widget getTitle(
      int status, Map<String, dynamic> homeLinescore, Map<String, dynamic> awayLinescore) {
    if (_isUpcoming) {
      return Row(
        children: [
          SizedBox(width: 15.0.r),
          if (countdown == '')
            Text(widget.gameTime!, style: kBebasBold.copyWith(fontSize: 22.0.r)),
          if (countdown != '') CountdownTimer(durationString: countdown),
          SizedBox(width: 15.0.r),
        ],
      );
    } else {
      int homeScore = homeLinescore['PTS'];
      int awayScore = awayLinescore['PTS'];
      return Row(
        children: [
          Text(
            awayScore.toString(),
            style: kBebasBold.copyWith(
                fontSize: 26.0.r,
                color: awayScore > homeScore
                    ? Colors.white
                    : (status == 3 ? Colors.grey : Colors.white)),
          ),
          SizedBox(width: 20.0.r),
          getStatus(status, game['SUMMARY']['GameSummary'][0]),
          //Text('-', style: kBebasBold.copyWith(fontSize: 22.0.r)),
          SizedBox(width: 20.0.r),
          Text(
            homeScore.toString(),
            style: kBebasBold.copyWith(
                fontSize: 26.0.r,
                color: homeScore > awayScore
                    ? Colors.white
                    : (status == 3 ? Colors.grey : Colors.white)),
          ),
        ],
      );
    }
  }

  Widget getStatus(int status, Map<String, dynamic> summary) {
    if (status == 3) {
      switch (summary['LIVE_PERIOD']) {
        case 4:
          return Text('FINAL',
              style: kBebasBold.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300));
        case 5:
          return Text('FINAL/OT',
              style: kBebasBold.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300));
        default:
          return Text('FINAL/${summary['LIVE_PERIOD'] - 4}OT',
              style: kBebasBold.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300));
      }
    }
    if (status == 2) {
      if (summary['LIVE_PC_TIME'] == ":0.0") {
        switch (summary['LIVE_PERIOD']) {
          case 1:
            return Text('END 1ST', style: kBebasBold.copyWith(fontSize: 16.0.r));
          case 2:
            return Text('HALF', style: kBebasBold.copyWith(fontSize: 16.0.r));
          case 3:
            return Text('END 3RD', style: kBebasBold.copyWith(fontSize: 16.0.r));
          case 4:
            return Text('FINAL', style: kBebasBold.copyWith(fontSize: 16.0.r));
          case 5:
            return Text('FINAL/OT', style: kBebasBold.copyWith(fontSize: 16.0.r));
          default:
            return Text('FINAL/${summary['LIVE_PERIOD'] - 4}OT',
                style: kBebasBold.copyWith(fontSize: 16.0.r));
        }
      } else {
        int period = summary['LIVE_PERIOD'];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                period <= 4
                    ? '$period${period == 1 ? 'ST' : period == 2 ? 'ND' : period == 3 ? 'RD' : 'TH'}'
                    : period == 5
                        ? 'OT'
                        : '${(period - 4).toString()}OT',
                style: kBebasBold.copyWith(fontSize: 12.0.r)),
            Text(summary['LIVE_PC_TIME'].toString(),
                style: kBebasBold.copyWith(fontSize: 14.0.r)),
          ],
        );
      }
    } else {
      return Text(widget.gameTime!, style: kBebasBold.copyWith(fontSize: 22.0.r));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SpinningIcon();
    }

    var summary = game['SUMMARY']['GameSummary'][0];
    var linescore = game['SUMMARY']['LineScore'];

    Map<String, dynamic> homeLinescore =
        linescore[0]['TEAM_ID'].toString() == widget.homeId ? linescore[0] : linescore[1];
    Map<String, dynamic> awayLinescore =
        linescore[1]['TEAM_ID'].toString() == widget.homeId ? linescore[0] : linescore[1];

    String awayTeamId = '0';

    if (kTeamIdToName.containsKey(widget.awayId.toString())) {
      awayTeamId = widget.awayId;
    }

    return Scaffold(
      body: ExtendedNestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.grey.shade900,
              pinned: true,
              expandedHeight: MediaQuery.of(context).size.height * 0.28,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_showImages) ...[
                    if (awayTeamId == '0')
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                    GestureDetector(
                      onTap: () {
                        if (awayTeamId != '0') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamHome(
                                teamId: widget.awayId,
                              ),
                            ),
                          );
                        }
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 40.0.r, maxHeight: 40.0.r),
                        child: Image.asset(
                          awayTeamId == '1610612761'
                              ? 'images/NBA_Logos/${awayTeamId}_alt.png'
                              : 'images/NBA_Logos/$awayTeamId.png',
                          width: awayTeamId == '0' ||
                                  MediaQuery.of(context).orientation == Orientation.landscape
                              ? MediaQuery.of(context).size.width * 0.0375
                              : MediaQuery.of(context).size.width * 0.09,
                        ),
                      ),
                    ),
                    SizedBox(width: 15.0.r),
                    getTitle(summary['GAME_STATUS_ID'], homeLinescore, awayLinescore),
                    SizedBox(width: 15.0.r),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamHome(
                              teamId: widget.homeId,
                            ),
                          ),
                        );
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 40.0.r, maxHeight: 40.0.r),
                        child: Image.asset(
                          widget.homeId == '1610612761'
                              ? 'images/NBA_Logos/${widget.homeId}_alt.png'
                              : 'images/NBA_Logos/${widget.homeId}.png',
                          width: widget.homeId == '0' ||
                                  MediaQuery.of(context).orientation == Orientation.landscape
                              ? MediaQuery.of(context).size.width * 0.0375
                              : MediaQuery.of(context).size.width * 0.09,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              centerTitle: true,
              flexibleSpace: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient team colors
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          kTeamIdToName[awayTeamId] == null
                              ? Colors.grey
                              : kTeamColors[kTeamIdToName[awayTeamId]![1]]![
                                  'primaryColor']!, // Transparent at the top
                          kTeamColors[kTeamIdToName[widget.homeId]?[1]]![
                              'primaryColor']!, // Opaque at the bottom
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: -MediaQuery.of(context).size.width * 0.5,
                    child: Opacity(
                      opacity:
                          0.97 - kTeamColorOpacity[kTeamIdToName[awayTeamId][1]]!['opacity']!,
                      child: SvgPicture.asset(
                        'images/NBA_Logos/$awayTeamId.svg',
                        width: MediaQuery.of(context).size.width / 1.1,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -MediaQuery.of(context).size.width * 0.5,
                    child: Opacity(
                      opacity: 0.97 -
                          kTeamColorOpacity[kTeamIdToName[widget.homeId][1]]!['opacity']!,
                      child: SvgPicture.asset(
                        'images/NBA_Logos/${widget.homeId}.svg',
                        width: MediaQuery.of(context).size.width / 1.1,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: FlexibleSpaceBar(
                      background: GameInfo(
                        countdown: countdown == '' ? null : countdown,
                        gameSummary: summary,
                        homeLinescore: homeLinescore,
                        awayLinescore: awayLinescore,
                        homeId: widget.homeId,
                        awayId: awayTeamId,
                        isUpcoming: _isUpcoming,
                        odds: odds,
                        gameTime: widget.gameTime,
                      ),
                      collapseMode: CollapseMode.pin,
                    ),
                  ),
                ],
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Colors.white70,
                indicatorWeight: 3.0,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.white,
                labelStyle: kBebasNormal.copyWith(fontSize: !_isUpcoming ? 16.5.r : 18.0.r),
                tabs: [
                  const Tab(text: 'Matchup'),
                  if (!_isUpcoming && game.containsKey('PBP')) const Tab(text: 'Play-By-Play'),
                  Tab(text: _isUpcoming ? 'Stats' : 'Box Score'),
                  if (odds.isNotEmpty) const Tab(text: 'Odds')
                ],
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
              ],
            ),
          ];
        },
        pinnedHeaderSliverHeightBuilder: () {
          if (_tabController.index == 1) {
            return 104.0 + MediaQuery.of(context).padding.top;
          }
          /*
            * The extra subtraction here is really just for the BoxScore so
            * that it pins the secondary tab after we scroll past the LineScore.
            * Other pages like Matchup and Odds aren't pinning anything, so it
            * doesn't matter as much where we set the pin height.
            * */
          return 104.0 +
              MediaQuery.of(context).padding.top -
              ((kToolbarHeight - 15.0.r) + ((kToolbarHeight - 15.0.r) / 4.5.r) + 93.0.r);
        },
        onlyOneScrollInBody: true,
        body: TabBarView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              GameMatchup(
                game: game,
                homeId: widget.homeId,
                awayId: widget.awayId,
                isUpcoming: _isUpcoming,
              ),
              if (!_isUpcoming && game.containsKey('PBP'))
                PlayByPlay(
                  game: game,
                  homeId: widget.homeId,
                  awayId: widget.awayId,
                ),
              if (_isUpcoming)
                GamePreviewStats(
                  game: game,
                  homeId: widget.homeId,
                  awayId: awayTeamId,
                ),
              if (!_isUpcoming)
                GameBoxScore(
                  game: game,
                  homeId: widget.homeId,
                  awayId: awayTeamId,
                  inProgress: game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2,
                ),
              if (odds.isNotEmpty) Odds(odds: game['ODDS']?['BOOK']),
            ]),
      ),
    );
  }
}

class GameInfo extends StatelessWidget {
  const GameInfo({
    super.key,
    this.countdown,
    required this.gameSummary,
    required this.homeLinescore,
    required this.awayLinescore,
    required this.homeId,
    required this.awayId,
    required this.isUpcoming,
    this.odds,
    this.gameTime,
  });

  final String? countdown;
  final Map<String, dynamic> gameSummary;
  final Map<String, dynamic> homeLinescore;
  final Map<String, dynamic> awayLinescore;
  final String homeId;
  final String awayId;
  final bool isUpcoming;
  final Map<String, dynamic>? odds;
  final String? gameTime;

  Widget getStatus(int status) {
    if (status == 3) {
      switch (gameSummary['LIVE_PERIOD']) {
        case 4:
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('FINAL',
                  style: kBebasBold.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300)),
            ],
          );
        case 5:
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('FINAL/OT',
                  style: kBebasBold.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300)),
            ],
          );
        default:
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('FINAL/${gameSummary['LIVE_PERIOD'] - 4}OT',
                  style: kBebasBold.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300)),
            ],
          );
      }
    }
    if (status == 2) {
      if (gameSummary['LIVE_PC_TIME'] == ":0.0") {
        switch (gameSummary['LIVE_PERIOD']) {
          case 1:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('END 1ST', style: kBebasBold.copyWith(fontSize: 20.0.r)),
              ],
            );
          case 2:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('HALF', style: kBebasBold.copyWith(fontSize: 20.0.r)),
              ],
            );
          case 3:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('END 3RD', style: kBebasBold.copyWith(fontSize: 20.0.r)),
              ],
            );
          case 4:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('FINAL', style: kBebasBold.copyWith(fontSize: 16.0.r)),
              ],
            );
          case 5:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('FINAL/OT', style: kBebasBold.copyWith(fontSize: 16.0.r)),
              ],
            );
          default:
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('FINAL/${gameSummary['LIVE_PERIOD'] - 4}OT',
                    style: kBebasBold.copyWith(fontSize: 16.0.r)),
              ],
            );
        }
      } else {
        int period = gameSummary['LIVE_PERIOD'];
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                period <= 4
                    ? '$period${period == 1 ? 'ST' : period == 2 ? 'ND' : period == 3 ? 'RD' : 'TH'}'
                    : period == 5
                        ? 'OT'
                        : '${(period - 4).toString()}OT',
                style: kBebasBold.copyWith(fontSize: 16.0.r)),
            Text(gameSummary['LIVE_PC_TIME'].toString(),
                style: kBebasBold.copyWith(fontSize: 16.0.r)),
          ],
        );
      }
    } else {
      return Column(
        children: [
          if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'NBA TV' &&
              gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ESPN' &&
              gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ESPN2' &&
              gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ABC' &&
              gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'TNT' &&
              gameSummary['GAME_STATUS_TEXT'] != 'Cancelled')
            Text(gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LEAGUE PASS',
                style: kBebasBold.copyWith(fontSize: 19.0.r)),
          if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != null &&
              gameSummary['GAME_STATUS_TEXT'] != 'Cancelled') ...[
            if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'NBA TV')
              SvgPicture.asset(
                'images/NBA_TV.svg',
                width: 30.0.r,
                height: 30.0.r,
              ),
            if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'TNT')
              SvgPicture.asset(
                'images/NBA_on_TNT.svg',
                width: 28.0.r,
                height: 28.0.r,
              ),
            if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ESPN')
              SvgPicture.asset(
                'images/ESPN.svg',
                width: 12.0.r,
                height: 12.0.r,
              ),
            if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ESPN2')
              SvgPicture.asset(
                'images/ESPN2.svg',
                width: 12.0.r,
                height: 12.0.r,
              ),
            if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ABC')
              SvgPicture.asset(
                'images/abc.svg',
                width: 32.0.r,
                height: 32.0.r,
              ),
            SizedBox(height: 8.0.r),
          ],
          if (countdown == '' || countdown == null)
            Text(gameTime ?? '', style: kBebasBold.copyWith(fontSize: 19.0.r)),
          if (countdown != '' && countdown != null) CountdownTimer(durationString: countdown!),
        ],
      );
    }
  }

  Widget gameTitle(String gameId) {
    String seasonTypeCode = gameId[2];

    Map<String, String> seasonTypes = {
      '1': 'Pre-Season',
      '2': 'Regular Season',
      '4': 'Playoffs',
      '5': 'Play-In',
      '6': 'In-Season Tournament',
    };

    switch (seasonTypes[seasonTypeCode]) {
      case 'Playoffs':
        String gameNum = gameId[9];
        String conf;
        String roundId = gameId[7];

        switch (roundId) {
          case '1':
            conf = int.parse(gameId[8]) < 4 ? 'East' : 'West';
          case '2':
            conf = int.parse(gameId[8]) < 2 ? 'East' : 'West';
          case '3':
            conf = gameId[8] == '0' ? 'East' : 'West';
          default:
            conf = '';
        }

        Map<String, String> poRounds = {
          '1': '1st Round',
          '2': 'Semis',
          '3': 'Conf Finals',
          '4': 'NBA Finals',
        };

        return Text('Game $gameNum - $conf ${poRounds[roundId]}',
            style: kBebasBold.copyWith(fontSize: 14.0.r, color: Colors.grey.shade300));
      case 'Play-In':
        return Text('Play-In Tourney',
            style: kBebasBold.copyWith(fontSize: 14.0.r, color: Colors.grey.shade300));
      case 'In-Season Tournament':
        return Text('Emirates NBA Cup Final',
            style: kBebasBold.copyWith(fontSize: 14.0.r, color: Colors.grey.shade300));
      default:
        // Parse the input string into a DateTime object
        DateTime parsedDate = DateTime.parse(gameSummary['GAME_DATE_EST']);

        // Format the DateTime object into the desired string format
        String formattedDate = DateFormat('EEE, MMM d, y').format(parsedDate).toUpperCase();

        return Text(
          formattedDate,
          style: kBebasNormal.copyWith(fontSize: 14.0.r, color: Colors.grey.shade300),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            gameTitle(gameSummary['GAME_ID']),
            SizedBox(height: MediaQuery.sizeOf(context).height / 7)
          ],
        ),
        Padding(
          padding: EdgeInsets.all(15.0.r),
          child: Row(
            children: [
              if (awayId == '0')
                if (isLandscape) SizedBox(width: MediaQuery.of(context).size.width * 0.06),
              if (awayId == '0')
                if (!isLandscape) SizedBox(width: MediaQuery.of(context).size.width * 0.1),
              if (isLandscape) SizedBox(width: MediaQuery.of(context).size.width * 0.1),
              GestureDetector(
                onTap: () {
                  if (awayId != '0') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamHome(
                          teamId: awayId,
                        ),
                      ),
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (awayId == '0')
                      Image.asset(
                        'images/NBA_Logos/$awayId.png',
                        width: isLandscape
                            ? MediaQuery.of(context).size.width * 0.04
                            : MediaQuery.of(context).size.width * 0.1,
                      ),
                    if (awayId != '0')
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 80.0.r, maxHeight: 80.0.r),
                        child: Image.asset(
                          awayId == '1610612761'
                              ? 'images/NBA_Logos/${awayId}_alt.png'
                              : 'images/NBA_Logos/$awayId.png',
                          width: isLandscape
                              ? MediaQuery.of(context).size.width * 0.1
                              : MediaQuery.of(context).size.width * 0.2,
                        ),
                      ),
                    SizedBox(height: 8.0.r),
                    Text(
                      awayLinescore['TEAM_WINS_LOSSES'],
                      style:
                          kBebasNormal.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300),
                    )
                  ],
                ),
              ),
              const Spacer(),
              if (!isUpcoming)
                Text(
                  awayLinescore['PTS'].toString(),
                  style: kBebasBold.copyWith(
                      fontSize: 36.0.r,
                      color: awayLinescore['PTS'] > homeLinescore['PTS']
                          ? Colors.white
                          : gameSummary['GAME_STATUS_ID'] == 3
                              ? Colors.grey
                              : Colors.white),
                ),
              if (!isUpcoming) const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getStatus(gameSummary['GAME_STATUS_ID']),
                ],
              ),
              if (!isUpcoming) const Spacer(),
              if (!isUpcoming)
                Text(
                  homeLinescore['PTS'].toString(),
                  style: kBebasBold.copyWith(
                      fontSize: 36.0.r,
                      color: homeLinescore['PTS'] > awayLinescore['PTS']
                          ? Colors.white
                          : gameSummary['GAME_STATUS_ID'] == 3
                              ? Colors.grey
                              : Colors.white),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamHome(
                        teamId: homeId,
                      ),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 80.0.r, maxHeight: 80.0.r),
                      child: Image.asset(
                        homeId == '1610612761'
                            ? 'images/NBA_Logos/${homeId}_alt.png'
                            : 'images/NBA_Logos/$homeId.png',
                        width: homeId == '0'
                            ? MediaQuery.of(context).size.width * 0.05
                            : isLandscape
                                ? MediaQuery.of(context).size.width * 0.1
                                : MediaQuery.of(context).size.width * 0.2,
                      ),
                    ),
                    SizedBox(height: 8.0.r),
                    Text(
                      homeLinescore['TEAM_WINS_LOSSES'],
                      style:
                          kBebasNormal.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300),
                    )
                  ],
                ),
              ),
              if (isLandscape) SizedBox(width: MediaQuery.of(context).size.width * 0.1)
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0.r),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          odds?['SPREAD'] == null ? '' : kTeamIdToName[awayId]?[1] ?? 'INT\'L',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(
                              fontSize: 14.0.r, color: Colors.grey.shade300),
                        ),
                        SizedBox(width: 5.0.r),
                        Text(
                          odds?['SPREAD'] ?? '',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(
                              fontSize: 14.0.r, color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          odds?['OU'] == null ? '' : 'O/U',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(
                              fontSize: 14.0.r, color: Colors.grey.shade300),
                        ),
                        SizedBox(width: 5.0.r),
                        Text(
                          odds?['OU'] ?? '',
                          style: kBebasNormal.copyWith(
                              fontSize: 14.0.r, color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          odds?['ML'] == null ? '' : kTeamIdToName[homeId]?[1] ?? 'INT\'L',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(
                              fontSize: 14.0.r, color: Colors.grey.shade300),
                        ),
                        SizedBox(width: 5.0.r),
                        Text(
                          odds?['ML'] ?? '',
                          textAlign: TextAlign.center,
                          style: kBebasNormal.copyWith(
                              fontSize: 14.0.r, color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.sizeOf(context).height / 12)
          ],
        ),
      ],
    );
  }
}

class CountdownTimer extends StatefulWidget {
  final String durationString;

  CountdownTimer({required this.durationString});

  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _duration;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _duration = _parseIso8601Duration(widget.durationString);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Function to parse the ISO 8601 duration string
  Duration _parseIso8601Duration(String isoDuration) {
    final regex = RegExp(r'PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+(\.\d+)?)S)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) {
      throw FormatException("Invalid ISO 8601 duration format: $isoDuration");
    }

    final hours = int.tryParse(match.group(1) ?? '0') ?? 0;
    final minutes = int.tryParse(match.group(2) ?? '0') ?? 0;
    final seconds = double.tryParse(match.group(3) ?? '0') ?? 0;

    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds.toInt(),
      milliseconds: ((seconds - seconds.toInt()) * 1000).round(),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds <= 0) {
          _timer?.cancel();
        } else {
          _duration -= Duration(seconds: 1);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = _duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return Center(
      child: Text(
        '$minutes:$seconds',
        style: kBebasBold.copyWith(fontSize: 22.0.r),
      ),
    );
  }
}
