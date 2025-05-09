import 'dart:async';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/custom_icon_button.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/game/play_by_play/play_by_play.dart';
import 'package:splash/screens/standings/playoffs/playoff_bracket.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/scroll/scroll_controller_notifier.dart';

import '../../utilities/game.dart';
import '../../utilities/scroll/scroll_controller_provider.dart';
import '../../utilities/team.dart';
import '../search_screen.dart';
import '../standings/playoffs/playoffs_cache.dart';
import '../standings/playoffs/playoffs_network_helper.dart';
import '../team/team_cache.dart';
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
  Map<String, dynamic> homeTeam = {};
  Map<String, dynamic> awayTeam = {};
  late List lineScore;
  final ValueNotifier<bool> _showImagesNotifier = ValueNotifier<bool>(false);
  Map<String, dynamic> game = {};
  bool _isLoading = false;
  bool _isUpcoming = false;
  bool pregame = false;
  Map<String, dynamic> odds = {};
  String moneyLine = '';
  String spread = '';
  String overUnder = '';
  late Map<String, dynamic> playoffData;

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
    setState(() {
      game = fetchedGame.first;
    });
    _setTeams();
  }

  Future<void> _setTeams() async {
    homeTeam = await getTeam(widget.homeId.toString());
    awayTeam = await getTeam(widget.awayId.toString());
  }

  Future<Map<String, dynamic>> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    if (teamCache.containsTeam(teamId)) {
      return teamCache.getTeam(teamId)!;
    } else {
      var fetchedTeam = await Team().getTeam(teamId);
      var team = fetchedTeam;
      teamCache.addTeam(teamId, team);
      return team;
    }
  }

  Future<void> getPlayoffs(String season) async {
    final playoffsCache = Provider.of<PlayoffCache>(context, listen: false);
    if (playoffsCache.containsPlayoffs(season)) {
      playoffData = playoffsCache.getPlayoffs(season)!;
      setState(() {});
    } else {
      var fetchedPlayoffs = await PlayoffsNetworkHelper().getPlayoffs(season);
      playoffData = fetchedPlayoffs;
      playoffsCache.addPlayoffs(season, playoffData);
      setState(() {});
    }
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

    // Check if upcoming
    _isUpcoming = game['status'] == 1;

    if (_isUpcoming) {
      if (game.containsKey('gameClock')) {
        if (game['gameClock'] == 'pregame') {
          pregame = true;
        }
      }
    }

    await _setTeams();

    setState(() {
      _isLoading = false;
    });
  }

  void _initializeControllers() {
    int tabLength = 5;

    if (_isUpcoming) {
      tabLength -= 1;
    }
    if (!game.containsKey('ODDS')) {
      tabLength -= 1;
    }
    if (game['seasonType'] != 'PLAYOFFS') {
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

    if (widget.gameId.substring(2, 3) == '4') {
      String season =
          '20${widget.gameId.substring(3, 5)}-${int.parse(widget.gameId.substring(3, 5)) + 1}';
      getPlayoffs(season);
    }

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

  Widget getTitleDetails() {
    if (_isUpcoming) {
      return Row(
        children: [
          SizedBox(width: 15.0.r),
          Text(pregame ? 'PREGAME' : widget.gameTime!,
              style: kBebasBold.copyWith(fontSize: 20.0.r)),
          SizedBox(width: 15.0.r),
        ],
      );
    } else {
      int homeScore = game['homeScore'];
      int awayScore = game['awayScore'];
      List<String> gameTime = game['gameClock'].split(" ");
      return Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              awayScore.toString(),
              key: ValueKey<int>(awayScore), // Important to use a key to detect changes
              style: kBebasBold.copyWith(
                fontSize: 26.0.r,
                color: awayScore > homeScore
                    ? Colors.white
                    : (game['status'] == 3 ? Colors.grey : Colors.white),
              ),
            ),
          ),
          SizedBox(width: 20.0.r),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (gameTime.length > 1)
                Text(gameTime.first, style: kBebasBold.copyWith(fontSize: 12.0.r)),
              Text(gameTime.last, style: kBebasBold.copyWith(fontSize: 14.0.r)),
            ],
          ),
          SizedBox(width: 20.0.r),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Text(
              homeScore.toString(),
              key: ValueKey<int>(homeScore), // Important to use a key to detect changes
              style: kBebasBold.copyWith(
                fontSize: 26.0.r,
                color: homeScore > awayScore
                    ? Colors.white
                    : (game['status'] == 3 ? Colors.grey : Colors.white),
              ),
            ),
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
                        game: game,
                        isUpcoming: _isUpcoming,
                        odds: odds,
                        gameTime: pregame ? 'PREGAME' : game['gameClock'],
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
                  if (!_isUpcoming && game.containsKey('pbp')) const Tab(text: 'Play-By-Play'),
                  Tab(text: _isUpcoming ? 'Stats' : 'Box Score'),
                  if (game['seasonType'] == 'PLAYOFFS') const Tab(text: 'Bracket')
                  // if (odds.isNotEmpty) const Tab(text: 'Odds')
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
            homeTeam: homeTeam,
            awayTeam: awayTeam,
            isUpcoming: _isUpcoming,
          ),
          if (!_isUpcoming && game.containsKey('pbp'))
            PlayByPlay(
              key: const PageStorageKey('PlayByPlay'),
              game: game,
              homeTeam: homeTeam,
              awayTeam: awayTeam,
            ),
          if (_isUpcoming)
            GamePreviewStats(
              key: const PageStorageKey('GamePreviewStats'),
              game: game,
              homeTeam: homeTeam,
              awayTeam: awayTeam,
            ),
          if (!_isUpcoming)
            GameBoxScore(
              key: const PageStorageKey('GameBoxScore'),
              game: game,
              homeTeam: homeTeam,
              awayTeam: awayTeam,
              inProgress: game['status'] == 2,
            ),
          if (game['seasonType'] == 'PLAYOFFS') PlayoffBracket(playoffData: playoffData)
          // if (odds.isNotEmpty)
          // Odds(key: const PageStorageKey('GameOdds'), odds: game['ODDS']?['BOOK']),
        ]),
      ),
    );
  }
}

class GameInfo extends StatelessWidget {
  const GameInfo({
    super.key,
    required this.pregame,
    required this.game,
    required this.isUpcoming,
    this.odds,
    this.gameTime,
  });

  final bool pregame;
  final Map<String, dynamic> game;
  final bool isUpcoming;
  final Map<String, dynamic>? odds;
  final String? gameTime;

  Widget getStatus(int status) {
    return Column(
      children: [
        if (game['broadcast'] != 'NBA TV' &&
            game['broadcast'] != 'ESPN' &&
            game['broadcast'] != 'ESPN2' &&
            game['broadcast'] != 'ABC' &&
            !game['broadcast'].contains('TNT') &&
            game['gameClock'] != 'Cancelled')
          Text(game['broadcast'] ?? 'LEAGUE PASS',
              style: kBebasBold.copyWith(fontSize: 19.0.r)),
        if (game['broadcast'] != null && game['gameClock'] != 'Cancelled') ...[
          if (game['broadcast'] == 'NBA TV')
            SvgPicture.asset(
              'images/NBA_TV.svg',
              width: 30.0.r,
              height: 30.0.r,
            ),
          if (game['broadcast'].contains('TNT'))
            SvgPicture.asset(
              'images/NBA_on_TNT.svg',
              width: 28.0.r,
              height: 28.0.r,
            ),
          if (game['broadcast'] == 'ESPN')
            SvgPicture.asset(
              'images/ESPN.svg',
              width: 12.0.r,
              height: 12.0.r,
            ),
          if (game['broadcast'] == 'ESPN2')
            SvgPicture.asset(
              'images/ESPN2.svg',
              width: 12.0.r,
              height: 12.0.r,
            ),
          if (game['broadcast'] == 'ABC')
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
        DateTime parsedDate = DateTime.parse(game['date']);

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
            gameTitle(game['gameId']),
            SizedBox(height: MediaQuery.sizeOf(context).height / 7)
          ],
        ),
        Padding(
          padding: EdgeInsets.all(15.0.r),
          child: Row(
            children: [
              if (game['awayTeamId'] == '0')
                if (isLandscape) SizedBox(width: availableWidth * 0.06),
              if (game['awayTeamId'] == '0')
                if (!isLandscape) SizedBox(width: availableWidth * 0.1),
              if (isLandscape) SizedBox(width: availableWidth * 0.1),
              GestureDetector(
                onTap: () {
                  if (game['awayTeamId'] != '0') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamHome(
                          teamId: game['awayTeamId'],
                        ),
                      ),
                    );
                  }
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (game['awayTeamId'] == '0')
                      Image.asset(
                        'images/NBA_Logos/${game['awayTeamId']}.png',
                        width: isLandscape ? availableWidth * 0.04 : availableWidth * 0.1,
                      ),
                    if (game['awayTeamId'] != '0')
                      ConstrainedBox(
                        constraints: BoxConstraints(minHeight: 80.0.r, maxHeight: 80.0.r),
                        child: Image.asset(
                          game['awayTeamId'] == '1610612761'
                              ? 'images/NBA_Logos/${game['awayTeamId']}_alt.png'
                              : 'images/NBA_Logos/${game['awayTeamId']}.png',
                          width: isLandscape ? availableWidth * 0.1 : availableWidth * 0.2,
                        ),
                      ),
                    SizedBox(height: 8.0.r),
                    Text(
                      game['matchup']?['teamRecords']?['away'] ?? '',
                      style:
                          kBebasNormal.copyWith(fontSize: 16.0.r, color: Colors.grey.shade300),
                    )
                  ],
                ),
              ),
              const Spacer(),
              if (!isUpcoming)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    game['awayScore'].toString(),
                    key: ValueKey<int>(game['awayScore']),
                    style: kBebasBold.copyWith(
                      fontSize: 36.0.r,
                      color: game['awayScore'] > game['homeScore']
                          ? Colors.white
                          : game['status'] == 3
                              ? Colors.grey
                              : Colors.white,
                    ),
                  ),
                ),
              if (!isUpcoming) const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [getStatus(game['status'])],
              ),
              if (!isUpcoming) const Spacer(),
              if (!isUpcoming)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Text(
                    game['homeScore'].toString(),
                    key: ValueKey<int>(game['homeScore']),
                    style: kBebasBold.copyWith(
                      fontSize: 36.0.r,
                      color: game['homeScore'] > game['awayScore']
                          ? Colors.white
                          : game['status'] == 3
                              ? Colors.grey
                              : Colors.white,
                    ),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamHome(
                        teamId: game['homeTeamId'],
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
                        game['homeTeamId'] == '1610612761'
                            ? 'images/NBA_Logos/${game['homeTeamId']}_alt.png'
                            : 'images/NBA_Logos/${game['homeTeamId']}.png',
                        width: game['homeTeamId'] == '0'
                            ? availableWidth * 0.05
                            : isLandscape
                                ? availableWidth * 0.1
                                : availableWidth * 0.2,
                      ),
                    ),
                    SizedBox(height: 8.0.r),
                    Text(
                      game['matchup']?['teamRecords']?['home'] ?? '',
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
                          odds?['SPREAD'] == null
                              ? ''
                              : kTeamIdToName[game['awayTeamId']]?[1] ?? 'INT\'L',
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
                          odds?['ML'] == null
                              ? ''
                              : kTeamIdToName[game['homeTeamId']]?[1] ?? 'INT\'L',
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
