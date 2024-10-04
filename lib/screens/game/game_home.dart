import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/custom_icon_button.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/scroll/scroll_controller_notifier.dart';

import '../../utilities/game.dart';
import '../../utilities/scroll/scroll_controller_provider.dart';
import '../search_screen.dart';
import '../team/team_home.dart';
import 'boxscore/game_boxscore.dart';
import 'boxscore/game_preview/game_preview_stats.dart';
import 'game_cache.dart';
import 'matchup/game_matchup.dart';

class GameHome extends StatefulWidget {
  static const String id = 'game_home';
  final Map<String, dynamic>? gameData;
  final String gameId;
  final String homeId;
  final String awayId;
  final String? gameTime;

  const GameHome({
    super.key,
    this.gameData,
    required this.gameId,
    required this.homeId,
    required this.awayId,
    this.gameTime,
  });

  @override
  State<GameHome> createState() => _GameHomeState();
}

class _GameHomeState extends State<GameHome> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  Map<String, dynamic> game = {};
  bool _showImages = false;
  bool _isLoading = false;
  bool _isUpcoming = false;

  Map<int, double> _scrollPositions = {};

  Future<void> getGame(String gameId) async {
    final gameCache = Provider.of<GameCache>(context, listen: false);
    if (gameCache.containsGame(gameId)) {
      setState(() {
        game = gameCache.getGame(gameId)!;
      });
    } else {
      var fetchedGame = await Game().getGame(gameId);
      setState(() {
        game = fetchedGame;
      });
      gameCache.addGame(gameId, game);
    }
  }

  Future<void> setValues(String gameId) async {
    setState(() {
      _isLoading = true;
    });
    await getGame(gameId);
    setState(() {
      _isUpcoming = game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 1;
      _isLoading = false;
    });
  }

  /// ******************************************************
  ///                 Initialize page
  ///        --> Tab Controller length = # of Tabs
  /// ******************************************************

  @override
  void initState() {
    super.initState();

    if (widget.gameData == null) {
      setValues(widget.gameId);
    } else {
      game = widget.gameData!;
      _isUpcoming = game['SUMMARY']['GameSummary'][0]['GAME_STATUS_ID'] == 1;
      _isLoading = false;
    }

    _tabController = TabController(length: _gamePages.length, vsync: this);

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
      if (_scrollController.offset < (201 - kToolbarHeight)) {
        // Remain at current offset
        _scrollController.jumpTo(_scrollController.offset);
      }
      // Else, app bar collapsed and no collapsed position saved
      else {
        // Go to top collapsed position
        _scrollController.jumpTo(201 - kToolbarHeight);
      }
    });
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients && _scrollController.offset > (200 - kToolbarHeight);
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
      String status, Map<String, dynamic> homeLinescore, Map<String, dynamic> awayLinescore) {
    if (_isUpcoming) {
      return Row(
        children: [
          SizedBox(width: 15.0.r),
          Text(widget.gameTime!, style: kBebasBold.copyWith(fontSize: 22.0.r)),
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
                fontSize: 22.0.r,
                color: awayScore > homeScore
                    ? Colors.white
                    : (status == 'Final' ? Colors.grey : Colors.white)),
          ),
          SizedBox(width: 15.0.r),
          Text('-', style: kBebasBold.copyWith(fontSize: 22.0.r)),
          SizedBox(width: 15.0.r),
          Text(
            homeScore.toString(),
            style: kBebasBold.copyWith(
                fontSize: 22.0.r,
                color: homeScore > awayScore
                    ? Colors.white
                    : (status == 'Final' ? Colors.grey : Colors.white)),
          ),
        ],
      );
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
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 40.0.r, maxHeight: 40.0.r),
                      child: Image.asset(
                        'images/NBA_Logos/$awayTeamId.png',
                        width: awayTeamId == '0' ||
                                MediaQuery.of(context).orientation == Orientation.landscape
                            ? MediaQuery.of(context).size.width * 0.0375
                            : MediaQuery.of(context).size.width * 0.09,
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    getTitle(summary['GAME_STATUS_TEXT'], homeLinescore, awayLinescore),
                    const SizedBox(width: 15.0),
                    ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 40.0.r, maxHeight: 40.0.r),
                      child: Image.asset(
                        'images/NBA_Logos/${widget.homeId}.png',
                        width: widget.homeId == '0' ||
                                MediaQuery.of(context).orientation == Orientation.landscape
                            ? MediaQuery.of(context).size.width * 0.0375
                            : MediaQuery.of(context).size.width * 0.09,
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
                        gameSummary: summary,
                        homeLinescore: homeLinescore,
                        awayLinescore: awayLinescore,
                        homeId: widget.homeId,
                        awayId: awayTeamId,
                        isUpcoming: _isUpcoming,
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
                labelStyle: kBebasNormal.copyWith(fontSize: 18.0.r),
                tabs: [
                  const Tab(text: 'Matchup'),
                  Tab(text: _isUpcoming ? 'Teams' : 'Box Score'),
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
          return 104.0 +
              MediaQuery.of(context).padding.top -
              ((kToolbarHeight - 15.0.r) + ((kToolbarHeight - 15.0.r) / 4.5.r) + 93.0.r);
        },
        onlyOneScrollInBody: true,
        body: TabBarView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _tabController,
          children: _gamePages.map((page) {
            return page(
              game: game,
              homeId: widget.homeId,
              awayId: awayTeamId,
              isUpcoming: _isUpcoming,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class GameInfo extends StatelessWidget {
  const GameInfo({
    super.key,
    required this.gameSummary,
    required this.homeLinescore,
    required this.awayLinescore,
    required this.homeId,
    required this.awayId,
    required this.isUpcoming,
    this.gameTime,
  });

  final Map<String, dynamic> gameSummary;
  final Map<String, dynamic> homeLinescore;
  final Map<String, dynamic> awayLinescore;
  final String homeId;
  final String awayId;
  final bool isUpcoming;
  final String? gameTime;

  Widget getStatus(String status) {
    if (status == 'Final') {
      return Text('FINAL',
          style: kBebasBold.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300));
    }
    if (status.contains('Q')) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(status.toString().trimRight(), style: kBebasBold.copyWith(fontSize: 16.0.r)),
          Text(gameSummary['LIVE_PC_TIME'].toString().trimRight(),
              style: kBebasBold.copyWith(fontSize: 16.0.r)),
        ],
      );
    } else {
      return Column(
        children: [
          if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'NBA TV' &&
              gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ESPN' &&
              gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'ABC' &&
              gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != 'TNT')
            Text(gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] ?? 'LEAGUE PASS',
                style: kBebasBold.copyWith(fontSize: 19.0.r)),
          if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] != null) ...[
            if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'NBA TV')
              SvgPicture.asset(
                'images/NBA_TV.svg',
                width: 30.0.r,
                height: 30.0.r,
              ),
            if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'TNT')
              SvgPicture.asset(
                'images/TNT.svg',
                width: 32.0.r,
                height: 32.0.r,
              ),
            if (gameSummary['NATL_TV_BROADCASTER_ABBREVIATION'] == 'ESPN')
              SvgPicture.asset(
                'images/ESPN.svg',
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
          Text(gameTime!, style: kBebasBold.copyWith(fontSize: 19.0.r)),
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
                          'images/NBA_Logos/$awayId.png',
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
                          : gameSummary['GAME_STATUS_TEXT'] == 'Final'
                              ? Colors.grey
                              : Colors.white),
                ),
              if (!isUpcoming) const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getStatus(gameSummary['GAME_STATUS_TEXT']),
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
                          : gameSummary['GAME_STATUS_TEXT'] == 'Final'
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
                        'images/NBA_Logos/$homeId.png',
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
      ],
    );
  }
}
