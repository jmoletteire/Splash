import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utilities/constants.dart';

class TeamRecord extends StatefulWidget {
  final String season;
  final Map<String, dynamic> homeTeam;
  final Map<String, dynamic> awayTeam;
  const TeamRecord({
    super.key,
    required this.season,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  State<TeamRecord> createState() => _TeamRecordState();
}

class _TeamRecordState extends State<TeamRecord> {
  String getStanding(int confRank) {
    switch (confRank) {
      case 1:
        return '${confRank}st';
      case 2:
        return '${confRank}nd';
      case 3:
        return '${confRank}rd';
      case 21:
        return '${confRank}st';
      case 22:
        return '${confRank}nd';
      case 23:
        return '${confRank}rd';
      default:
        return '${confRank}th';
    }
  }

  @override
  Widget build(BuildContext context) {
    Color teamOneColor = kDarkPrimaryColors.contains(widget.awayTeam['ABBREVIATION'])
        ? (kTeamColors[widget.awayTeam['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.awayTeam['ABBREVIATION']]!['primaryColor']!);

    Color teamTwoColor = kDarkPrimaryColors.contains(widget.homeTeam['ABBREVIATION'])
        ? (kTeamColors[widget.homeTeam['ABBREVIATION']]!['secondaryColor']!)
        : (kTeamColors[widget.homeTeam['ABBREVIATION']]!['primaryColor']!);

    var homeStandings = widget.homeTeam['seasons'][widget.season]['STANDINGS'];
    var awayStandings = widget.awayTeam['seasons'][widget.season]['STANDINGS'];

    return SliverToBoxAdapter(
      child: Card(
        color: Colors.grey.shade900,
        margin: EdgeInsets.symmetric(horizontal: 11.0.r, vertical: 5.0.r),
        child: Padding(
          padding: EdgeInsets.all(15.0.r),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
                  ),
                ),
                child: Text(
                  'Standings',
                  style: kBebasBold.copyWith(fontSize: 16.0.r),
                ),
              ),
              SizedBox(height: 15.0.r),
              NonComparisonRow(
                statName: 'RECORD',
                teamOne: awayStandings['Record'],
                teamTwo: homeStandings['Record'],
              ),
              SizedBox(height: 5.0.r),
              NonComparisonRow(
                statName: 'WIN %',
                teamOne: awayStandings['WinPCT'].toStringAsFixed(3),
                teamTwo: homeStandings['WinPCT'].toStringAsFixed(3),
              ),
              SizedBox(height: 5.0.r),
              NonComparisonRow(
                statName: 'STANDINGS',
                teamOne: getStanding(awayStandings['PlayoffRank']),
                teamTwo: getStanding(homeStandings['PlayoffRank']),
              ),
              SizedBox(height: 5.0.r),
              NonComparisonRow(
                statName: 'CONF',
                teamOne: awayStandings['Conference'],
                teamTwo: homeStandings['Conference'],
              ),
              SizedBox(height: 15.0.r),
              ComparisonRow(
                statName: 'vs ${awayStandings['Conference']}',
                teamOne: awayStandings['vs${awayStandings['Conference']}'],
                teamTwo: homeStandings['vs${awayStandings['Conference']}'],
                teamOneColor: teamOneColor,
                teamTwoColor: teamTwoColor,
              ),
              if (homeStandings['Conference'] != awayStandings['Conference'])
                SizedBox(height: 5.0.r),
              if (homeStandings['Conference'] != awayStandings['Conference'])
                ComparisonRow(
                  statName: 'vs ${homeStandings['Conference']}',
                  teamOne: awayStandings['vs${homeStandings['Conference']}'],
                  teamTwo: homeStandings['vs${homeStandings['Conference']}'],
                  teamOneColor: teamOneColor,
                  teamTwoColor: teamTwoColor,
                ),
              SizedBox(height: 5.0.r),
              ComparisonRow(
                statName: 'vs ${awayStandings['Division']}',
                teamOne: awayStandings['vs${awayStandings['Division']}'],
                teamTwo: homeStandings['vs${awayStandings['Division']}'],
                teamOneColor: teamOneColor,
                teamTwoColor: teamTwoColor,
              ),
              if (homeStandings['Division'] != awayStandings['Division'])
                SizedBox(height: 5.0.r),
              if (homeStandings['Division'] != awayStandings['Division'])
                ComparisonRow(
                  statName: 'vs ${homeStandings['Division']}',
                  teamOne: awayStandings['vs${homeStandings['Division']}'],
                  teamTwo: homeStandings['vs${homeStandings['Division']}'],
                  teamOneColor: teamOneColor,
                  teamTwoColor: teamTwoColor,
                ),
              SizedBox(height: 15.0.r),
              ComparisonRow(
                statName: 'HOME',
                teamOne: awayStandings['HOME'].trimRight(),
                teamTwo: homeStandings['HOME'].trimRight(),
                teamOneColor: teamOneColor,
                teamTwoColor: teamTwoColor,
              ),
              SizedBox(height: 5.0.r),
              ComparisonRow(
                statName: 'ROAD',
                teamOne: awayStandings['ROAD'].trimRight(),
                teamTwo: homeStandings['ROAD'].trimRight(),
                teamOneColor: teamOneColor,
                teamTwoColor: teamTwoColor,
              ),
              SizedBox(height: 5.0.r),
              ComparisonRow(
                statName: 'LAST 10',
                teamOne: awayStandings['L10'].trimRight(),
                teamTwo: homeStandings['L10'].trimRight(),
                teamOneColor: teamOneColor,
                teamTwoColor: teamTwoColor,
              ),
              SizedBox(height: 5.0.r),
              NonComparisonRow(
                statName: 'STREAK',
                teamOne: awayStandings['strCurrentStreak'],
                teamTwo: homeStandings['strCurrentStreak'],
              ),
              SizedBox(height: 15.0.r),
              ComparisonRow(
                statName: 'OT',
                teamOne: awayStandings['OT'].trimRight(),
                teamTwo: homeStandings['OT'].trimRight(),
                teamOneColor: teamOneColor,
                teamTwoColor: teamTwoColor,
              ),
              SizedBox(height: 5.0.r),
              ComparisonRow(
                statName: '3 PTS OR LESS',
                teamOne: awayStandings['ThreePTSOrLess'].trimRight(),
                teamTwo: homeStandings['ThreePTSOrLess'].trimRight(),
                teamOneColor: teamOneColor,
                teamTwoColor: teamTwoColor,
              ),
              SizedBox(height: 5.0.r),
              ComparisonRow(
                statName: '10+ PTS',
                teamOne: awayStandings['TenPTSOrMore'].trimRight(),
                teamTwo: homeStandings['TenPTSOrMore'].trimRight(),
                teamOneColor: teamOneColor,
                teamTwoColor: teamTwoColor,
              ),
              SizedBox(height: 5.0.r),
              ComparisonRow(
                statName: 'Opp Over .500',
                teamOne: awayStandings['OppOver500'].trimRight(),
                teamTwo: homeStandings['OppOver500'].trimRight(),
                teamOneColor: teamOneColor,
                teamTwoColor: teamTwoColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NonComparisonRow extends StatelessWidget {
  const NonComparisonRow({
    super.key,
    required this.statName,
    required this.teamOne,
    required this.teamTwo,
  });

  final String statName;
  final dynamic teamOne;
  final dynamic teamTwo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                child: AutoSizeText(
                  teamOne,
                  style: kBebasNormal.copyWith(
                      fontSize: 18.0.r,
                      color: statName == 'STREAK'
                          ? teamOne.contains('W')
                              ? const Color(0xFF55F86F)
                              : const Color(0xFFFC3126)
                          : Colors.white),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            statName,
            textAlign: TextAlign.center,
            style: kBebasNormal.copyWith(fontSize: 16.0.r),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                child: AutoSizeText(
                  teamTwo,
                  style: kBebasNormal.copyWith(
                      fontSize: 18.0.r,
                      color: statName == 'STREAK'
                          ? teamTwo.contains('W')
                              ? const Color(0xFF55F86F)
                              : const Color(0xFFFC3126)
                          : Colors.white),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ComparisonRow extends StatelessWidget {
  const ComparisonRow({
    super.key,
    required this.statName,
    required this.teamOne,
    required this.teamTwo,
    this.teamOneColor = Colors.transparent,
    this.teamTwoColor = Colors.transparent,
  });

  final String statName;
  final dynamic teamOne;
  final dynamic teamTwo;
  final Color teamOneColor;
  final Color teamTwoColor;

  @override
  Widget build(BuildContext context) {
    int teamOneWins = int.parse(teamOne.split('-')[0]);
    int teamOneLosses = int.parse(teamOne.split('-')[1]);
    int teamTwoWins = int.parse(teamTwo.split('-')[0]);
    int teamTwoLosses = int.parse(teamTwo.split('-')[1]);

    double teamOneWinPct = 0.0;
    double teamTwoWinPct = 0.0;

    try {
      teamOneWinPct = teamOneWins / (teamOneWins + teamOneLosses);
    } catch (e) {
      teamOneWinPct = 0.0;
    }

    try {
      teamTwoWinPct = teamTwoWins / (teamTwoWins + teamTwoLosses);
    } catch (e) {
      teamTwoWinPct = 0.0;
    }

    bool oneIsBetter = teamOneWinPct > teamTwoWinPct;
    bool twoIsBetter = teamTwoWinPct > teamOneWinPct;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              StatValue(
                value: teamOne,
                isHighlighted: oneIsBetter ? true : false,
                color: teamOneColor,
                isPercentage: statName.contains('%'),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            statName,
            textAlign: TextAlign.center,
            style: kBebasNormal.copyWith(fontSize: 16.0.r),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              StatValue(
                value: teamTwo,
                isHighlighted: twoIsBetter ? true : false,
                color: teamTwoColor,
                isPercentage: statName.contains('%'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class StatValue extends StatelessWidget {
  final dynamic value;
  final bool isHighlighted;
  final Color color;
  final bool isPercentage;

  StatValue(
      {required this.value,
      this.isHighlighted = false,
      required this.color,
      required this.isPercentage});

  @override
  Widget build(BuildContext context) {
    Map<Color, Color> lightColors = {
      const Color(0xFFFFFFFF): Color(0xFF000000),
      const Color(0xFFFEC524): Color(0xFF0E2240),
      const Color(0xFFFDBB30): Color(0xFF002D62),
      const Color(0xFFED184D): Color(0xFF0B2240),
      const Color(0xFF78BE20): Color(0xFF0B233F),
      const Color(0xFF85714D): Color(0xFF0C2340),
      const Color(0xFFE56020): Color(0xFF1D1160),
      const Color(0xFFC4CED4): Color(0xFF000000),
      const Color(0xFFFCA200): Color(0xFF002B5C),
      const Color(0xFFE31837): Color(0xFF002B5C),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0.r),
      decoration: BoxDecoration(
        color: isHighlighted ? color : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Text(
        isPercentage ? '$value%' : '$value',
        style: isHighlighted && lightColors.containsKey(color)
            ? kBebasNormal.copyWith(fontSize: 18.0.r, color: lightColors[color])
            : kBebasNormal.copyWith(fontSize: 18.0.r),
      ),
    );
  }
}
