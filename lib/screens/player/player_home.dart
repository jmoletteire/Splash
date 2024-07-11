import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/custom_icon_button.dart';
import 'package:splash/screens/player/player_cache.dart';
import 'package:splash/screens/player/player_career.dart';
import 'package:splash/screens/player/player_comparison.dart';
import 'package:splash/screens/player/player_contract.dart';
import 'package:splash/screens/player/player_stats.dart';
import 'package:splash/screens/player/profile/player_profile.dart';
import 'package:splash/utilities/constants.dart';

import '../../utilities/player.dart';
import '../../utilities/team.dart';
import '../search_screen.dart';
import '../team/team_cache.dart';
import '../team/team_home.dart';

class PlayerHome extends StatefulWidget {
  static const String id = 'player_home';
  final String teamId;
  final String playerId;

  const PlayerHome({super.key, required this.teamId, required this.playerId});

  @override
  State<PlayerHome> createState() => _PlayerHomeState();
}

class _PlayerHomeState extends State<PlayerHome>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  Map<String, dynamic> player = {};
  Map<String, dynamic> team = {};
  String _title = '';
  bool _showImage = false;
  bool _isLoading = true;

  Map<int, double> _scrollPositions = {};

  Future<void> getTeam(String teamId) async {
    final teamCache = Provider.of<TeamCache>(context, listen: false);
    if (teamCache.containsTeam(teamId)) {
      setState(() {
        team = teamCache.getTeam(teamId)!;
      });
    } else {
      var fetchedTeam = await Team().getTeam(teamId);
      setState(() {
        team = fetchedTeam;
      });
      teamCache.addTeam(teamId, team);
    }
  }

  Future<void> getPlayer(String playerId) async {
    final playerCache = Provider.of<PlayerCache>(context, listen: false);
    if (playerCache.containsPlayer(playerId)) {
      setState(() {
        player = playerCache.getPlayer(playerId)!;
      });
    } else {
      var fetchedPlayer = await Player().getPlayer(playerId);
      setState(() {
        player = fetchedPlayer;
      });
      playerCache.addPlayer(playerId, player);
    }
  }

  Future<void> setValues(String player, String teamId) async {
    await Future.wait([
      getPlayer(player),
      getTeam(teamId),
    ]);
    setState(() {
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

    setValues(widget.playerId, widget.teamId);

    _tabController = TabController(length: _playerPages.length, vsync: this);

    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _title = _isSliverAppBarExpanded ? player['DISPLAY_FIRST_LAST'] : '';
          _showImage = _isSliverAppBarExpanded ? true : false;
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
    return _scrollController.hasClients &&
        _scrollController.offset > (200 - kToolbarHeight);
  }

  /// ******************************************************
  ///    Dispose of Controllers with page to conserve
  ///    memory & improve performance.
  /// ******************************************************

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ******************************************************
  ///      Initialize each tab via anonymous function.
  /// ******************************************************

  final List<
      Widget Function(
          {required Map<String, dynamic> team,
          required Map<String, dynamic> player})> _playerPages = [
    (
            {required Map<String, dynamic> team,
            required Map<String, dynamic> player}) =>
        PlayerProfile(team: team, player: player),
    (
            {required Map<String, dynamic> team,
            required Map<String, dynamic> player}) =>
        PlayerStats(team: team, player: player),
    (
            {required Map<String, dynamic> team,
            required Map<String, dynamic> player}) =>
        PlayerContract(team: team, player: player),
    (
            {required Map<String, dynamic> team,
            required Map<String, dynamic> player}) =>
        PlayerCareer(team: team, player: player),
  ];

  /// ******************************************************
  ///                   Build the page.
  /// ******************************************************

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: kDarkPrimaryColors.contains(team['ABBREVIATION'])
                    ? (kTeamColors[team['ABBREVIATION']]?['secondaryColor'])
                    : (kTeamColors[team['ABBREVIATION']]?['primaryColor']),
              ),
            )
          : NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor:
                        kTeamColors[team['ABBREVIATION']]!['primaryColor']!,
                    pinned: true,
                    expandedHeight: MediaQuery.of(context).size.height * 0.28,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_showImage)
                          CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.04,
                            backgroundColor: Colors.white70,
                            foregroundImage: NetworkImage(
                                'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PERSON_ID']}.png'),
                          ),
                        const SizedBox(width: 15.0),
                        Flexible(
                          child: AutoSizeText(
                            _title,
                            style: kBebasBold.copyWith(fontSize: 24.0),
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
                        SvgPicture.asset(
                          'images/NBA_Logos/${team['TEAM_ID']}.svg',
                          fit: BoxFit.cover,
                        ),
                        // Gradient mask to fade out the image towards the bottom
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                kTeamColors[team['ABBREVIATION']]![
                                        'primaryColor']!
                                    .withOpacity(kTeamColorOpacity[
                                            team['ABBREVIATION']]![
                                        'opacity']!), // Transparent at the top
                                kTeamColors[team['ABBREVIATION']]![
                                        'primaryColor']!
                                    .withOpacity(1.0), // Opaque at the bottom
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: FlexibleSpaceBar(
                            centerTitle: true,
                            background: PlayerInfo(team: team, player: player),
                            collapseMode: CollapseMode.pin,
                          ),
                        ),
                      ],
                    ),
                    bottom: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorColor:
                          kTeamColors[team['ABBREVIATION']]!['secondaryColor']!,
                      indicatorWeight: 3.0,
                      unselectedLabelColor: Colors.grey,
                      labelColor: Colors.white,
                      labelStyle: kBebasNormal,
                      tabs: const [
                        Tab(text: 'Profile'),
                        Tab(text: 'Stats'),
                        Tab(text: 'Contract'),
                        Tab(text: 'Career'),
                      ],
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
                        icon: Icons.compare_arrows,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PlayerComparison(player: player),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: _playerPages.map((page) {
                  return page(
                    team: team,
                    player: player,
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(35.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: MediaQuery.of(context).size.width * 0.125,
            backgroundColor: Colors.white70,
            foregroundImage: NetworkImage(
                'https://cdn.nba.com/headshots/nba/latest/1040x760/${player['PERSON_ID']}.png'),
          ),
          const SizedBox(
            width: 20.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              player['GREATEST_75_FLAG'] == 'Y'
                  ? Row(
                      children: [
                        Text(
                          player['FIRST_NAME'],
                          style: kBebasBold.copyWith(fontSize: 30.0),
                        ),
                        const SizedBox(width: 10.0),
                        SvgPicture.asset(
                          'images/NBA_75th_anniversary_logo.svg',
                          width: 30.0,
                          height: 30.0,
                        ),
                      ],
                    )
                  : Text(
                      player['FIRST_NAME'],
                      style: kBebasBold.copyWith(fontSize: 30.0),
                    ),
              Text(
                player['LAST_NAME'],
                style: kBebasBold.copyWith(fontSize: 30.0),
              ),
              Text(
                '${player['POSITION']} • #${player['JERSEY']}',
                style: kBebasNormal.copyWith(
                    fontSize: 19.0, color: Colors.white60),
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
                        style: kBebasNormal.copyWith(
                            fontSize: 19.0, color: Colors.white60),
                      ),
                      const SizedBox(width: 5.0),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 20.0),
                        child: Image.asset(
                          'images/NBA_Logos/${team['TEAM_ID']}.png',
                          fit: BoxFit.contain,
                          width: 20.0,
                          height: 20.0,
                        ),
                      ),
                      /*
                      SvgPicture.string(
                        team['LOGO'][0],
                        fit: BoxFit.contain,
                        width: 18.0,
                        height: 18.0,
                      ),

                       */
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
