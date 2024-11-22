import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/screens/team/team_home.dart';
import 'package:splash/utilities/constants.dart';

class LineScore extends StatefulWidget {
  final String homeTeam;
  final String awayTeam;
  final String homeAbbr;
  final String awayAbbr;
  final List<int> homeScores;
  final List<int> awayScores;

  LineScore({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeAbbr,
    required this.awayAbbr,
    required this.homeScores,
    required this.awayScores,
  });

  @override
  State<LineScore> createState() => _LineScoreState();
}

class _LineScoreState extends State<LineScore> with AutomaticKeepAliveClientMixin<LineScore> {
  late List<int> _homeScores;
  late List<int> _awayScores;
  int totalQuarters = 4;
  int totalPeriods = 4;
  int overtimes = 0;

  late final TextStyle headerTextStyle;
  late final TextStyle teamNameStyle;

  @override
  bool get wantKeepAlive => true; // Ensures widget state is kept alive

  @override
  void initState() {
    super.initState();
    // Initialize scores and styles
    _homeScores = List.from(widget.homeScores);
    _awayScores = List.from(widget.awayScores);
    totalPeriods = _homeScores.length;
    overtimes = totalPeriods > totalQuarters ? totalPeriods - totalQuarters : 0;

    // Memoize text styles
    headerTextStyle = kBebasBold.copyWith(fontSize: 14.0.r, color: Colors.grey.shade400);
    teamNameStyle = kBebasBold.copyWith(fontSize: 18.0.r);
  }

  @override
  void didUpdateWidget(covariant LineScore oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update scores only if they have changed
    if (!_areScoresEqual(oldWidget.homeScores, widget.homeScores) ||
        !_areScoresEqual(oldWidget.awayScores, widget.awayScores)) {
      setState(() {
        _homeScores = List.from(widget.homeScores);
        _awayScores = List.from(widget.awayScores);
        totalPeriods = _homeScores.length;
        overtimes = totalPeriods > totalQuarters ? totalPeriods - totalQuarters : 0;
      });
    }
  }

  bool _areScoresEqual(List<int> scores1, List<int> scores2) {
    if (scores1.length != scores2.length) return false;
    for (int i = 0; i < scores1.length; i++) {
      if (scores1[i] != scores2[i]) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // for AutomaticKeepAliveClientMixin

    return Container(
      color: Colors.grey.shade900,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: const Color(0xFF1B1B1B),
                  padding: EdgeInsets.symmetric(horizontal: 15.0.r),
                  child: Text('', style: headerTextStyle),
                ),
              ),
              for (int i = 1; i <= totalQuarters; i++)
                Expanded(
                  child: Container(
                    color: const Color(0xFF1B1B1B),
                    padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                    child: Text('Q$i', style: headerTextStyle, textAlign: TextAlign.end),
                  ),
                ),
              if (overtimes > 0)
                for (int i = 1; i <= overtimes; i++)
                  Expanded(
                    child: Container(
                      color: const Color(0xFF1B1B1B),
                      padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                      child: Text(i == 1 ? 'OT' : '${i}OT',
                          style: headerTextStyle, textAlign: TextAlign.end),
                    ),
                  ),
              Expanded(
                child: Container(
                  color: const Color(0xFF2A2A2A),
                  padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                  child: Text('F', style: headerTextStyle, textAlign: TextAlign.end),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0.r),
            child: LineScoreRow(
              teamId: widget.awayTeam,
              abbr: widget.awayAbbr,
              scores: _awayScores,
              teamNameStyle: teamNameStyle,
            ),
          ),
          Divider(height: 3.0.r, color: Colors.white12),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0.r),
            child: LineScoreRow(
              teamId: widget.homeTeam,
              abbr: widget.homeAbbr,
              scores: _homeScores,
              teamNameStyle: teamNameStyle,
            ),
          ),
        ],
      ),
    );
  }
}

class LineScoreRow extends StatefulWidget {
  final String teamId;
  final String abbr;
  final List<int> scores;
  final TextStyle teamNameStyle;

  LineScoreRow({
    required this.teamId,
    required this.abbr,
    required this.scores,
    required this.teamNameStyle,
  }) : super(key: ValueKey('$teamId-${scores.hashCode}'));

  @override
  _LineScoreRowState createState() => _LineScoreRowState();
}

class _LineScoreRowState extends State<LineScoreRow> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // This is required to ensure `wantKeepAlive` is respected.

    int totalScore = widget.scores.reduce((a, b) => a + b);

    return InkWell(
      onTap: () {
        if (widget.teamId != '0') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamHome(teamId: widget.teamId),
            ),
          );
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(left: 8.0.r),
              child: Row(
                children: [
                  if (widget.teamId == '0') SizedBox(width: 5.5.r),
                  Image.asset(
                    'images/NBA_Logos/${widget.teamId}.png',
                    width: widget.teamId == '0' ? 11.0.r : 22.0.r,
                    cacheWidth: widget.teamId == '0' ? 33 : 66,
                  ),
                  if (widget.teamId == '0') SizedBox(width: 5.5.r),
                  SizedBox(width: 5.0.r),
                  Text(widget.abbr, style: widget.teamNameStyle),
                ],
              ),
            ),
          ),
          for (int score in widget.scores)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0.r),
                child: Text(
                  score.toString(),
                  textAlign: TextAlign.end,
                  style: widget.teamNameStyle
                      .copyWith(fontSize: 18.0.r, color: Colors.grey.shade400),
                ),
              ),
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0.r),
              child: Text(
                totalScore.toString(),
                textAlign: TextAlign.end,
                style: widget.teamNameStyle.copyWith(fontSize: 18.0.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
