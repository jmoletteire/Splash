import 'package:flutter/material.dart';
import 'package:splash/screens/player/career/career_stats.dart';

import '../../../utilities/constants.dart';

class PlayerCareer extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;
  const PlayerCareer({super.key, required this.team, required this.player});

  @override
  State<PlayerCareer> createState() => _PlayerCareerState();
}

class _PlayerCareerState extends State<PlayerCareer> {
  late Map<String, dynamic> seasons;
  late Map<String, dynamic> playoffSeasons;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.player.keys.contains('STATS')
        ? seasons = widget.player['STATS']
        : seasons = {};

    playoffSeasons = {};
    for (var season in seasons.keys) {
      if (seasons[season].containsKey('PLAYOFFS')) {
        playoffSeasons[season] = seasons[season];
      }
    }

    _scrollController.addListener(() {
      if (_scrollController.offset <=
              _scrollController.position.minScrollExtent &&
          !_scrollController.position.outOfRange) {}
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !widget.player.keys.contains('STATS') ||
            !widget.player['STATS'].isNotEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports_basketball,
                  color: Colors.white38,
                  size: 40.0,
                ),
                const SizedBox(height: 15.0),
                Text(
                  'No Stats Available',
                  style: kBebasNormal.copyWith(
                      fontSize: 20.0, color: Colors.white54),
                ),
              ],
            ),
          )
        : ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: CustomScrollView(
              slivers: [
                CareerStats(
                  player: widget.player,
                  seasons: seasons,
                  seasonType: 'REGULAR SEASON',
                ),
                if (playoffSeasons.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 8.0),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Playoffs',
                        style: kBebasNormal.copyWith(fontSize: 14.0),
                      ),
                    ),
                  ),
                if (playoffSeasons.isNotEmpty)
                  CareerStats(
                    player: widget.player,
                    seasons: playoffSeasons,
                    seasonType: 'PLAYOFFS',
                  )
              ],
            ),
          );
  }
}

class MyCustomScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const ClampingScrollPhysics();
  }
}
