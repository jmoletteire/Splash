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
  late double availableWidth;
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  late Timer _timer;
  late Image awayTeamPng;
  late Image homeTeamPng;
  late String awayTeamId;
  late String homeTeamId;
  late String awayTeamAbbr;
  late String homeTeamAbbr;
  late Map<String, dynamic> summary;
  late List lineScore;
  late Map<String, dynamic> homeLineScore;
  late Map<String, dynamic> awayLineScore;
  final ValueNotifier<bool> _showImagesNotifier = ValueNotifier<bool>(false);
  Map<String, dynamic> game = {};
  bool _isLoading = false;
  bool _isUpcoming = false;
  bool pregame = false;
  Map<String, dynamic> odds = {};
  String moneyLine = '';
  String spread = '';
  String overUnder = '';

  /// ******************************************************
  ///                    Set Game Odds
  /// ******************************************************

  void calculateMoneyLineOdds(bool isLive) {
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

    // MoneyLine
    try {
      int raw = decimalToMoneyline(
          double.parse(odds['oddstypes'][isLive ? '19' : '1']['outcomes']['1']['odds']));
      if (raw > 0) {
        moneyLine = '+${raw.toString()}';
      } else {
        moneyLine = raw.toString();
      }
    } catch (e) {
      moneyLine = '';
    }
  }

  void calculateSpreadOdds(bool isLive) {
    // Spread
    try {
      double raw = double.parse(odds['oddstypes'][isLive ? '168' : '4']['hcp']['value']);
      if (raw > 0) {
        spread = '+${raw.toStringAsFixed(1)}';
      } else {
        spread = raw.toStringAsFixed(1);
      }
    } catch (e) {
      spread = '';
    }
  }

  void calculateOverUnderOdds(bool isLive) {
    // Over/Under
    try {
      double raw = double.parse(odds['oddstypes'][isLive ? '18' : '3']['hcp']['value']);
      overUnder = raw.toStringAsFixed(1);
    } catch (e) {
      overUnder = '';
    }
  }

  void setOdds(Map<String, dynamic> game) {
    bool isLive = false;

    try {
      if (game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] != 1 &&
          game['ODDS']?['LIVE'].containsKey('26338')) {
        odds = game['ODDS']?['LIVE']?['26338'];
        isLive = true;
      } else {
        odds = game['ODDS']?['BOOK']?['18186'];
      }
    } catch (e) {
      odds = {};
      return;
    }

    calculateMoneyLineOdds(isLive);
    calculateSpreadOdds(isLive);
    calculateOverUnderOdds(isLive);

    if (odds !=
        {
          'ML': moneyLine,
          'SPREAD': spread,
          'OU': overUnder,
        }) {
      setState(() {
        odds = {
          'ML': moneyLine,
          'SPREAD': spread,
          'OU': overUnder,
        };
      });
    }
  }

  /// ******************************************************
  ///             Initialize Game Data & Timer
  /// ******************************************************

  void startPolling(String gameId, String gameDate) {
    // Poll every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getGame(gameId, gameDate); // Call fetchGames every 10 seconds to get updated data
    });
  }

  Future<void> getGame(String gameId, String gameDate) async {
    var fetchedGame = await Game().getGame(gameId, gameDate);
    game = fetchedGame;
    setSummaryLineScore();
  }

  void setSummaryLineScore() {
    // Set all necessary variables and set state to update UI
    setState(() {
      summary = game['SUMMARY']['GameSummary'][0];
      lineScore = game['SUMMARY']['LineScore'];

      homeLineScore =
          lineScore[0]['TEAM_ID'].toString() == widget.homeId ? lineScore[0] : lineScore[1];
      awayLineScore =
          lineScore[1]['TEAM_ID'].toString() == widget.homeId ? lineScore[0] : lineScore[1];
    });
  }

  /// ******************************************************
  ///                 Initialize page
  ///        --> Tab Controller length = # of Tabs
  /// ******************************************************

  void _initializeGameState() async {
    setState(() {
      _isLoading = true;
    });

    if (widget.gameData == null) {
      await getGame(widget.gameId, widget.gameDate);
    } else {
      // Set game data
      game = widget.gameData!;
    }

    // Set odds
    setOdds(game);

    // Check if upcoming
    _isUpcoming = game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 1;

    if (_isUpcoming) {
      if (game.containsKey('BOXSCORE')) {
        if (game['BOXSCORE']['gameStatusText'] == 'pregame') {
          pregame = true;
        }
      }
    }

    setSummaryLineScore();

    setState(() {
      _isLoading = false;
    });
  }

  void _initializeControllers() {
    int tabLength = 4;

    if (_isUpcoming) {
      tabLength -= 1;
    }
    if (!game.containsKey('ODDS')) {
      tabLength -= 1;
    }

    _tabController = TabController(length: tabLength, vsync: this);

    _scrollController = ScrollController()
      ..addListener(() {
        _showImagesNotifier.value = _isSliverAppBarExpanded;
      });
  }

  void _initializeTabListener() {
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
  void initState() {
    super.initState();

    _initializeGameState();
    _initializeControllers();
    _initializeTabListener();

    startPolling(widget.gameId, widget.gameDate);

    awayTeamAbbr = kTeamIdToName[widget.awayId][1] ?? 'INT\'L';
    homeTeamAbbr = kTeamIdToName[widget.homeId][1] ?? 'INT\'L';
    awayTeamId = awayTeamAbbr == 'INT\'L' ? '0' : widget.awayId;
    homeTeamId = homeTeamAbbr == 'INT\'L' ? '0' : widget.homeId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    availableWidth = MediaQuery.of(context).size.width;
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController()
      ..addListener(() {
        _showImagesNotifier.value = _isSliverAppBarExpanded;
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
  ///                   Build the page.
  /// ******************************************************

  Widget getStatus() {
    if (summary['GAME_STATUS_ID'] == 3) {
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
    if (summary['GAME_STATUS_ID'] == 2) {
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

  Widget getTitleDetails() {
    if (_isUpcoming) {
      return Row(
        children: [
          SizedBox(width: 15.0.r),
          Text(pregame ? 'PREGAME' : widget.gameTime!,
              style: kBebasBold.copyWith(fontSize: 22.0.r)),
          SizedBox(width: 15.0.r),
        ],
      );
    } else {
      int homeScore = homeLineScore['PTS'];
      int awayScore = awayLineScore['PTS'];
      return Row(
        children: [
          Text(
            awayScore.toString(),
            style: kBebasBold.copyWith(
                fontSize: 26.0.r,
                color: awayScore > homeScore
                    ? Colors.white
                    : (summary['GAME_STATUS_ID'] == 3 ? Colors.grey : Colors.white)),
          ),
          SizedBox(width: 20.0.r),
          getStatus(),
          SizedBox(width: 20.0.r),
          Text(
            homeScore.toString(),
            style: kBebasBold.copyWith(
                fontSize: 26.0.r,
                color: homeScore > awayScore
                    ? Colors.white
                    : (summary['GAME_STATUS_ID'] == 3 ? Colors.grey : Colors.white)),
          ),
        ],
      );
    }
  }

  Widget getTitle() {
    return ValueListenableBuilder<bool>(
        valueListenable: _showImagesNotifier,
        builder: (context, showImages, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showImages) ...[
                if (awayTeamId == '0') SizedBox(width: availableWidth * 0.05),
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
                      gaplessPlayback: true,
                      width: awayTeamId == '0' ||
                              MediaQuery.of(context).orientation == Orientation.landscape
                          ? availableWidth * 0.0375
                          : availableWidth * 0.09,
                    ),
                  ),
                ),
                SizedBox(width: 15.0.r),
                getTitleDetails(),
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
                      gaplessPlayback: true,
                      width: widget.homeId == '0' ||
                              MediaQuery.of(context).orientation == Orientation.landscape
                          ? availableWidth * 0.0375
                          : availableWidth * 0.09,
                    ),
                  ),
                ),
              ],
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SpinningIcon();
    }

    return Scaffold(
      body: ExtendedNestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.grey.shade900,
              centerTitle: true,
              pinned: true,
              expandedHeight: MediaQuery.of(context).size.height * 0.28,
              title: getTitle(),
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
                          kTeamColors[awayTeamAbbr]?['primaryColor'] ?? Colors.grey,
                          kTeamColors[homeTeamAbbr]?['primaryColor'] ?? Colors.grey,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: -availableWidth * 0.5,
                    child: Opacity(
                      opacity: 0.97 - (kTeamColorOpacity[awayTeamAbbr]?['opacity'] ?? 0.94),
                      child: Image.asset(
                        'images/NBA_Logos/${awayTeamId}_full.png',
                        width: availableWidth / 1.1,
                        cacheWidth: (availableWidth / 1.1).round(),
                        gaplessPlayback: true,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -availableWidth * 0.5,
                    child: Opacity(
                      opacity: 0.97 - (kTeamColorOpacity[homeTeamAbbr]?['opacity'] ?? 0.94),
                      child: Image.asset(
                        'images/NBA_Logos/${homeTeamId}_full.png',
                        width: availableWidth / 1.1,
                        cacheWidth: (availableWidth / 1.1).round(),
                        gaplessPlayback: true,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: FlexibleSpaceBar(
                      background: GameInfo(
                        pregame: pregame,
                        gameSummary: summary,
                        homeLinescore: homeLineScore,
                        awayLinescore: awayLineScore,
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
          double devicePadding = MediaQuery.of(context).padding.top;

          if (_tabController.index == 1) {
            return 104.0 + devicePadding;
          }
          /*
            * The extra subtraction here is really just for the BoxScore so
            * that it pins the secondary tab after we scroll past the LineScore.
            * Other pages like Matchup and Odds aren't pinning anything, so it
            * doesn't matter as much where we set the pin height.
            * */
          return 104.0 +
              devicePadding -
              ((kToolbarHeight - 15.0.r) + ((kToolbarHeight - 15.0.r) / 4.5.r) + 90.0.r);
        },
        onlyOneScrollInBody: true,
        body: TabBarView(controller: _tabController, children: [
          GameMatchup(
            key: const PageStorageKey('GameMatchup'),
            game: game,
            homeId: widget.homeId,
            awayId: widget.awayId,
            isUpcoming: _isUpcoming,
          ),
          if (!_isUpcoming && game.containsKey('PBP'))
            PlayByPlay(
              key: const PageStorageKey('PlayByPlay'),
              game: game,
              homeId: widget.homeId,
              awayId: widget.awayId,
            ),
          if (_isUpcoming)
            GamePreviewStats(
              key: const PageStorageKey('GamePreviewStats'),
              game: game,
              homeId: widget.homeId,
              awayId: awayTeamId,
            ),
          if (!_isUpcoming)
            GameBoxScore(
              key: const PageStorageKey('GameBoxScore'),
              game: game,
              homeId: widget.homeId,
              awayId: awayTeamId,
              inProgress: game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 2,
            ),
          if (odds.isNotEmpty)
            Odds(key: const PageStorageKey('GameOdds'), odds: game['ODDS']?['BOOK']),
        ]),
      ),
    );
  }
}

class GameInfo extends StatelessWidget {
  const GameInfo({
    super.key,
    required this.pregame,
    required this.gameSummary,
    required this.homeLinescore,
    required this.awayLinescore,
    required this.homeId,
    required this.awayId,
    required this.isUpcoming,
    this.odds,
    this.gameTime,
  });

  final bool pregame;
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
          Text(pregame ? 'PREGAME' : gameTime ?? '',
              style: kBebasBold.copyWith(fontSize: 19.0.r)),
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
    double availableWidth = MediaQuery.of(context).size.width;

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
                if (isLandscape) SizedBox(width: availableWidth * 0.06),
              if (awayId == '0')
                if (!isLandscape) SizedBox(width: availableWidth * 0.1),
              if (isLandscape) SizedBox(width: availableWidth * 0.1),
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
                        width: isLandscape ? availableWidth * 0.04 : availableWidth * 0.1,
                      ),
                    if (awayId != '0')
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 80.0.r, maxHeight: 80.0.r),
                        child: Image.asset(
                          awayId == '1610612761'
                              ? 'images/NBA_Logos/${awayId}_alt.png'
                              : 'images/NBA_Logos/$awayId.png',
                          width: isLandscape ? availableWidth * 0.1 : availableWidth * 0.2,
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
                            ? availableWidth * 0.05
                            : isLandscape
                                ? availableWidth * 0.1
                                : availableWidth * 0.2,
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
              if (isLandscape) SizedBox(width: availableWidth * 0.1)
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
