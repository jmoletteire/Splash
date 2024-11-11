import 'package:auto_size_text/auto_size_text.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/custom_icon_button.dart';
import 'package:splash/components/player_avatar.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/player/career/player_career.dart';
import 'package:splash/screens/player/comparison/player_comparison.dart';
import 'package:splash/screens/player/gamelogs/player_gamelogs.dart';
import 'package:splash/screens/player/player_cache.dart';
import 'package:splash/screens/player/profile/player_profile.dart';
import 'package:splash/screens/player/shot_chart/shot_chart.dart';
import 'package:splash/screens/player/stats/player_stats_home.dart';
import 'package:splash/utilities/constants.dart';
import 'package:splash/utilities/scroll/scroll_controller_notifier.dart';

import '../../utilities/player.dart';
import '../../utilities/scroll/scroll_controller_provider.dart';
import '../../utilities/team.dart';
import '../search_screen.dart';
import '../team/team_cache.dart';
import '../team/team_home.dart';

class PlayerHome extends StatefulWidget {
  static const String id = 'player_home';
  final String? teamId;
  final String playerId;

  const PlayerHome({super.key, this.teamId, required this.playerId});

  @override
  State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  Map<String, dynamic> _player = {};
  Map<String, dynamic> _team = {};
  String _title = '';
  bool _showImage = false;
  bool _isLoading = true;
  bool _isHistoric = false;
  late List<
      Widget Function(
          {required Map<String, dynamic> team,
          required Map<String, dynamic> player})> _playerPages;

  Map<int, double> _scrollPositions = {};

  Future<void> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    if (teamCache.containsTeam(teamId)) {
      setState(() {
        _team = teamCache.getTeam(teamId)!;
      });
    } else {
      var fetchedTeam = await Team().getTeam(teamId);
      setState(() {
        _team = fetchedTeam;
      });
      teamCache.addTeam(teamId, _team);
    }
  }

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

  Future<void> getPlayer(String playerId) async {
    final playerCache = Provider.of<PlayerCache>(context, listen: false);
    if (playerCache.containsPlayer(playerId)) {
      setState(() {
        _player = playerCache.getPlayer(playerId)!;
      });
    } else {
      var fetchedPlayer = await Player().getPlayer(playerId);
      setState(() {
        _player = fetchedPlayer;
      });
      if (_player.containsKey('error')) {
        Navigator.pop(context);
        _showErrorSnackBar(context, 'Player not found');
      } else {
        playerCache.addPlayer(playerId, _player);
      }
    }
  }

  Future<void> setValues(String playerId, String? teamId) async {
    if (teamId != null) {
      await Future.wait([
        getPlayer(playerId),
        getTeam(teamId),
      ]);
    } else {
      await getPlayer(playerId);
      await getTeam(_player['TEAM_ID'].toString());
    }

    setState(() {
      _isLoading = false;
      _isHistoric = (_player['TO_YEAR'] ?? _player['FROM_YEAR'] ?? 0) <= 1996;
      _playerPages = _isHistoric
          ? [
              ({required Map<String, dynamic> team, required Map<String, dynamic> player}) =>
                  PlayerProfile(team: team, player: player),
              ({required Map<String, dynamic> team, required Map<String, dynamic> player}) =>
                  PlayerCareer(team: team, player: player),
            ]
          : [
              ({required Map<String, dynamic> team, required Map<String, dynamic> player}) =>
                  PlayerProfile(team: team, player: player),
              ({required Map<String, dynamic> team, required Map<String, dynamic> player}) =>
                  PlayerStatsHome(team: team, player: player),
              ({required Map<String, dynamic> team, required Map<String, dynamic> player}) =>
                  PlayerGamelogs(team: team, player: player),
              ({required Map<String, dynamic> team, required Map<String, dynamic> player}) =>
                  PlayerShotChart(team: team, player: player),
              ({required Map<String, dynamic> team, required Map<String, dynamic> player}) =>
                  PlayerCareer(team: team, player: player),
            ];
    });
    _tabController = TabController(length: _playerPages.length, vsync: this);
    _tabController.addListener(() {
      // If app bar expanded
      if (_scrollController.offset < ((MediaQuery.of(context).size.height * 0.28) - 105.0)) {
        // Remain at current offset
        _scrollController.jumpTo(_scrollController.offset);
      }
      // Else, app bar collapsed and no collapsed position saved
      else {
        // Go to top collapsed position
        _scrollController.jumpTo((MediaQuery.of(context).size.height * 0.28) - 105.0);
      }
    });
  }

  /// ******************************************************
  ///                 Initialize page
  ///        --> Tab Controller length = # of Tabs
  /// ******************************************************

  @override
  void initState() {
    super.initState();

    setValues(widget.playerId, widget.teamId);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _title = _isSliverAppBarExpanded ? _player['DISPLAY_FIRST_LAST'] : '';
          _showImage = _isSliverAppBarExpanded ? true : false;
        });

        // Save the scroll position of the current tab
        _scrollPositions[_tabController.index] = _scrollController.offset;
      });
  }

  bool get _isSliverAppBarExpanded {
    return _scrollController.hasClients &&
        _scrollController.offset >= ((MediaQuery.of(context).size.height * 0.28) - 105.0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _notifier.addController('player', _scrollController);
  }

  /// ******************************************************
  ///    Dispose of Controllers with page to conserve
  ///    memory & improve performance.
  /// ******************************************************

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeController('player');
    _scrollController.dispose();
    super.dispose();
  }

  /// ******************************************************
  ///      Initialize each tab via anonymous function.
  /// ******************************************************

  /// ******************************************************
  ///                   Build the page.
  /// ******************************************************

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: _isLoading
          ? Center(
              child: SpinningIcon(
                color: kDarkPrimaryColors.contains(_team['ABBREVIATION'])
                    ? (kTeamColors[_team['ABBREVIATION']]?['secondaryColor'])
                    : (kTeamColors[_team['ABBREVIATION']]?['primaryColor']),
              ),
            )
          : ExtendedNestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor:
                        kTeamColors[_team['ABBREVIATION'] ?? 'FA']!['primaryColor']!,
                    pinned: true,
                    expandedHeight: MediaQuery.of(context).size.height * 0.28,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_showImage)
                          PlayerAvatar(
                            radius: 16.56.r,
                            backgroundColor: Colors.white70,
                            playerImageUrl:
                                'https://cdn.nba.com/headshots/nba/latest/1040x760/${_player['PERSON_ID']}.png',
                          ),
                        SizedBox(width: 15.0.r),
                        Flexible(
                          child: AutoSizeText(
                            _title,
                            style: kBebasBold.copyWith(fontSize: 22.0.r),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                    flexibleSpace: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'images/NBA_Logos/${_team['TEAM_ID']}_full.png',
                          fit: BoxFit.cover,
                        ),
                        // Gradient mask to fade out the image towards the bottom
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                kTeamColors[_team['ABBREVIATION'] ?? 'FA']!['primaryColor']!
                                    .withOpacity(kTeamColorOpacity[_team['ABBREVIATION']]![
                                        'opacity']!), // Transparent at the top
                                kTeamColors[_team['ABBREVIATION'] ?? 'FA']!['primaryColor']!
                                    .withOpacity(1.0), // Opaque at the bottom
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: FlexibleSpaceBar(
                            centerTitle: true,
                            background: PlayerInfo(team: _team, player: _player),
                            collapseMode: CollapseMode.pin,
                          ),
                        ),
                      ],
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor: kTeamColors[_team['ABBREVIATION']]!['secondaryColor']!,
                      indicatorWeight: 3.0,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      labelStyle: kBebasNormal.copyWith(fontSize: 19.0.r),
                      isScrollable: !_isHistoric && !isLandscape,
                      tabAlignment: !_isHistoric && !isLandscape ? TabAlignment.start : null,
                      tabs: _isHistoric
                          ? [
                              const Tab(text: 'Profile'),
                              const Tab(text: 'Career'),
                            ]
                          : [
                              const Tab(text: 'Profile'),
                              const Tab(text: 'Stats'),
                              const Tab(text: 'Game Logs'),
                              const Tab(text: 'Shot Chart'),
                              const Tab(text: 'Career'),
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
                      if (!_isHistoric)
                        CustomIconButton(
                          icon: Icons.people_alt_outlined,
                          size: 30.0.r,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerComparison(player: _player),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ];
              },
              pinnedHeaderSliverHeightBuilder: () {
                return 104.0 + MediaQuery.of(context).padding.top; // 56 + 49 = 105
              },
              onlyOneScrollInBody: true,
              body: TabBarView(
                controller: _tabController,
                children: _playerPages.map((page) {
                  return page(
                    team: _team,
                    player: _player,
                  ); // Pass team object to each page
                }).toList(),
              ),
            ),
    );
  }
}

class PlayerInfo extends StatelessWidget {
  const PlayerInfo({super.key, required this.team, required this.player});

  final Map<String, dynamic> team;
  final Map<String, dynamic> player;

  Widget playerNameAndStatus() {
    /*if (player.containsKey('PlayerRotowires')) {
      if (player['PlayerRotowires'][0]['Injured'] == 'YES') {
        return Row(
          children: [
            Text(
              player['FIRST_NAME'],
              style: kBebasBold.copyWith(fontSize: 28.0.r),
            ),
            SizedBox(width: 10.0.r),
            Icon(
              Icons.healing,
              size: 30.0.r,
              color: Colors.redAccent,
            ),
          ],
        );
      } else if (player['GREATEST_75_FLAG'] == 'Y') {
        return Row(
          children: [
            Text(
              player['FIRST_NAME'],
              style: kBebasBold.copyWith(fontSize: 28.0.r),
            ),
            SizedBox(width: 10.0.r),
            SvgPicture.asset(
              'images/NBA_75th_anniversary_logo.svg',
              width: 30.0.r,
              height: 30.0.r,
            ),
          ],
        );
      } else {
        return Text(
          player['FIRST_NAME'],
          style: kBebasBold.copyWith(fontSize: 28.0.r),
        );
      }
    } else */
    if (player['GREATEST_75_FLAG'] == 'Y') {
      return Row(
        children: [
          Text(
            player['FIRST_NAME'],
            style: kBebasBold.copyWith(fontSize: 28.0.r),
          ),
          SizedBox(width: 10.0.r),
          SvgPicture.asset(
            'images/NBA_75th_anniversary_logo.svg',
            width: 30.0.r,
            height: 30.0.r,
          ),
        ],
      );
    } else {
      return Text(
        player['FIRST_NAME'],
        style: kBebasBold.copyWith(fontSize: 28.0.r),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(35.0.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              PlayerAvatar(
                radius: 50.0.r,
                backgroundColor: Colors.white70,
                playerImageUrl:
                    'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PERSON_ID']}.png',
              ),
              SizedBox(width: 20.0.r),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  playerNameAndStatus(),
                  Text(
                    player['LAST_NAME'],
                    style: kBebasBold.copyWith(fontSize: 28.0.r),
                  ),
                  Text(
                    '${player['POSITION']} • #${player['JERSEY']}',
                    style: kBebasNormal.copyWith(fontSize: 17.0.r, color: Colors.white60),
                  ),
                  if (team['CITY'] != 'Free Agent')
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TeamHome(
                              teamId: team['TEAM_ID'].toString(),
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            '${team['CITY']} ${team['NICKNAME']}',
                            style:
                                kBebasNormal.copyWith(fontSize: 17.0.r, color: Colors.white60),
                          ),
                          SizedBox(width: 5.0.r),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 20.0.r),
                            child: Image.asset(
                              team['TEAM_ID'] == 1610612761
                                  ? 'images/NBA_Logos/${team['TEAM_ID']}_alt2.png'
                                  : 'images/NBA_Logos/${team['TEAM_ID']}.png',
                              fit: BoxFit.contain,
                              width: 20.0.r,
                              height: 20.0.r,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
