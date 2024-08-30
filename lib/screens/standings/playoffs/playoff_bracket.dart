import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splash/utilities/constants.dart';

import '../../game/game_home.dart';

class PlayoffBracket extends StatefulWidget {
  final Map<String, dynamic> playoffData;

  const PlayoffBracket({super.key, required this.playoffData});

  @override
  State<PlayoffBracket> createState() => _PlayoffBracketState();
}

class _PlayoffBracketState extends State<PlayoffBracket> {
  List eastFirstRound = [];
  List eastConfSemis = [];
  Map<String, dynamic> eastConfFinals = {};
  Map<String, dynamic> nbaFinals = {};
  Map<String, dynamic> westConfFinals = {};
  List westConfSemis = [];
  List westFirstRound = [];

  void sortRounds() {
    /// FIRST ROUND
    for (var series in widget.playoffData['First Round'].entries) {
      if (kEastConfTeamIds.contains(series.value['TEAM_ONE'].toString()) ||
          kEastConfTeamIds.contains(series.value['TEAM_TWO'].toString())) {
        eastFirstRound.add(series);
      } else {
        westFirstRound.add(series);
      }
    }

    /// CONF SEMIS
    for (var series in widget.playoffData['Conf Semi-Finals'].entries) {
      if (kEastConfTeamIds.contains(series.value['TEAM_ONE'].toString())) {
        eastConfSemis.add(series);
      } else {
        westConfSemis.add(series);
      }
    }

    /// CONF FINALS
    for (var series in widget.playoffData['Conf Finals'].entries) {
      if (kEastConfTeamIds.contains(series.value['TEAM_ONE'].toString())) {
        eastConfFinals = series.value;
      } else {
        westConfFinals = series.value;
      }
    }

    /// NBA Finals
    for (var series in widget.playoffData['NBA Finals'].entries) {
      nbaFinals = series.value;
    }
  }

  @override
  void initState() {
    super.initState();
    sortRounds();
  }

  @override
  void didUpdateWidget(PlayoffBracket oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if playoffData has changed, and if so, sort the rounds again
    if (oldWidget.playoffData != widget.playoffData) {
      eastFirstRound = [];
      eastConfSemis = [];
      eastConfFinals = {};
      nbaFinals = {};
      westConfFinals = {};
      westConfSemis = [];
      westFirstRound = [];
      sortRounds();
    }
  }

  List<String> formatDate(String date) {
    // Parse the string to a DateTime object
    DateTime dateTime = DateTime.parse(date);

    // Create a DateFormat for the abbreviated day of the week
    DateFormat dayOfWeekFormat = DateFormat('E');
    String dayOfWeek = dayOfWeekFormat.format(dateTime);

    // Create a DateFormat for the month and date
    DateFormat monthDateFormat = DateFormat('M/d');
    String monthDate = monthDateFormat.format(dateTime);

    return [dayOfWeek, monthDate];
  }

  void _showBottomSheet(Map<String, dynamic> selectedSeries, String round) {
    showModalBottomSheet(
      backgroundColor: Colors.grey.shade900,
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(11.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade700, width: 2),
                        ),
                      ),
                      child: Text(
                        '${int.parse(widget.playoffData['SEASON'].substring(0, 4)) + 1} $round',
                        style: kBebasBold.copyWith(fontSize: 18.0),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: selectedSeries['GAMES'].asMap().entries.map<Widget>((entry) {
                  int index = entry.key;
                  var game = entry.value;

                  // Determine home and away teams based on index
                  String homeTeam, awayTeam;
                  if (round == 'NBA Finals' &&
                      int.parse(widget.playoffData['SEASON'].substring(0, 4)) < 2013 &&
                      int.parse(widget.playoffData['SEASON'].substring(0, 4)) > 1983) {
                    if (index < 2 || index > 4) {
                      homeTeam = selectedSeries['TEAM_ONE'].toString();
                      awayTeam = selectedSeries['TEAM_TWO'].toString();
                    } else {
                      homeTeam = selectedSeries['TEAM_TWO'].toString();
                      awayTeam = selectedSeries['TEAM_ONE'].toString();
                    }
                  } else {
                    if (index == 0 || index == 1 || index == 4 || index == 6) {
                      homeTeam = selectedSeries['TEAM_ONE'].toString();
                      awayTeam = selectedSeries['TEAM_TWO'].toString();
                    } else {
                      homeTeam = selectedSeries['TEAM_TWO'].toString();
                      awayTeam = selectedSeries['TEAM_ONE'].toString();
                    }
                  }

                  List<String> gameDate = formatDate(game['GAME_DATE']);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameHome(
                            gameId: game['GAME_ID'],
                            homeId: homeTeam,
                            awayId: awayTeam,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gameDate[0],
                                      style: kBebasNormal.copyWith(
                                          fontSize: 13.0, color: Colors.white70),
                                    ),
                                    Text(
                                      gameDate[1],
                                      style: kBebasNormal.copyWith(fontSize: 13.0),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const SizedBox(width: 15.0),
                                    SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: awayTeam == ''
                                          ? const Text('')
                                          : Image.asset(
                                              'images/NBA_Logos/$awayTeam.png',
                                              fit: BoxFit.contain,
                                              width: 16.0,
                                              height: 16.0,
                                            ),
                                    ),
                                    Text(
                                      game['AWAY_SCORE'].toStringAsFixed(0),
                                      style: kBebasBold.copyWith(
                                        color: game['AWAY_SCORE'] < game['HOME_SCORE']
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                    Text('@', style: kBebasBold.copyWith(fontSize: 14.0)),
                                    Text(
                                      game['HOME_SCORE'].toStringAsFixed(0),
                                      style: kBebasBold.copyWith(
                                        color: game['HOME_SCORE'] < game['AWAY_SCORE']
                                            ? Colors.grey
                                            : Colors.white,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: homeTeam == ''
                                          ? const Text('')
                                          : Image.asset(
                                              'images/NBA_Logos/$homeTeam.png',
                                              fit: BoxFit.contain,
                                              width: 16.0,
                                              height: 16.0,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              const Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16.0,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget seriesCard(Map<String, dynamic> series, String round) {
    String teamOne = series['TEAM_ONE'].toString();
    String teamTwo = series['TEAM_TWO'].toString();

    bool teamOneWinsSeries = series['TEAM_ONE_WINS'] == 4 ||
        (series['TEAM_ONE_WINS'] == 3 &&
            int.parse(widget.playoffData['SEASON'].substring(0, 4)) < 2002 &&
            (round == 'East First Round' || round == 'West First Round'));

    bool teamTwoWinsSeries = series['TEAM_TWO_WINS'] == 4 ||
        (series['TEAM_TWO_WINS'] == 3 &&
            int.parse(widget.playoffData['SEASON'].substring(0, 4)) < 2002 &&
            (round == 'East First Round' || round == 'West First Round'));

    List<String> useSecondary = ['SAS'];

    return GestureDetector(
      onTap: () {
        _showBottomSheet(series, round);
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        margin: const EdgeInsets.all(8.0),
        height: MediaQuery.of(context).size.height / 10,
        width: MediaQuery.of(context).size.width / 5,
        decoration: BoxDecoration(
          //color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10.0),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              kTeamNames[series['TEAM_TWO'].toString()] == null
                  ? Colors.grey
                  : teamTwoWinsSeries
                      ? Colors.grey.shade700
                      : useSecondary.contains(kTeamNames[series['TEAM_ONE'].toString()][1])
                          ? kTeamColors[kTeamNames[series['TEAM_ONE'].toString()]?[1]]![
                              'secondaryColor']!
                          : kTeamColors[kTeamNames[series['TEAM_ONE'].toString()]?[1]]![
                              'primaryColor']!,
              teamOneWinsSeries
                  ? Colors.grey.shade700
                  : useSecondary.contains(kTeamNames[series['TEAM_TWO'].toString()][1])
                      ? kTeamColors[kTeamNames[series['TEAM_TWO'].toString()]?[1]]![
                          'secondaryColor']!
                      : kTeamColors[kTeamNames[series['TEAM_TWO'].toString()]?[1]]![
                          'primaryColor']!,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                teamTwoWinsSeries
                    ? GrayscaleImage(imagePath: 'images/NBA_Logos/$teamOne.png')
                    : Image.asset(
                        'images/NBA_Logos/$teamOne.png',
                        width: 24.0,
                        height: 24.0,
                      ),
                const Text(' '),
                teamOneWinsSeries
                    ? GrayscaleImage(imagePath: 'images/NBA_Logos/$teamTwo.png')
                    : Image.asset(
                        'images/NBA_Logos/$teamTwo.png',
                        width: 24.0,
                        height: 24.0,
                      ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${series['TEAM_ONE_SEED'].toString()} ',
                        style: kBebasBold.copyWith(
                          fontSize: 12.0, // smaller font size for TEAM_TWO_SEED
                          color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: series['TEAM_ONE_ABBR'].toString(),
                        style: kBebasBold.copyWith(
                          fontSize: 16.0, // keep the current styling for TEAM_TWO_ABBR
                          color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(' '),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${series['TEAM_TWO_SEED'].toString()} ',
                        style: kBebasBold.copyWith(
                          fontSize: 12.0, // smaller font size for TEAM_TWO_SEED
                          color: teamOneWinsSeries ? Colors.grey : Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: series['TEAM_TWO_ABBR'].toString(),
                        style: kBebasBold.copyWith(
                          fontSize: 16.0, // keep the current styling for TEAM_TWO_ABBR
                          color: teamOneWinsSeries ? Colors.grey : Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  series['TEAM_ONE_WINS'].toString(),
                  style: kBebasBold.copyWith(
                    fontSize: 15.0,
                    color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                  ),
                ),
                Text(
                  '-',
                  style: kBebasNormal.copyWith(fontSize: 15.0),
                ),
                Text(
                  series['TEAM_TWO_WINS'].toString(),
                  style: kBebasBold.copyWith(
                    fontSize: 15.0,
                    color: teamOneWinsSeries ? Colors.grey : Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Stack(
        children: [
          // CustomPaint for drawing lines
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
            painter: BracketPainter(
              int.parse(widget.playoffData['SEASON'].substring(0, 4)),
              eastFirstRound,
              eastConfSemis,
              eastConfFinals,
              nbaFinals,
              westConfFinals,
              westConfSemis,
              westFirstRound,
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  seriesCard(eastFirstRound[0].value, 'East First Round'),
                  seriesCard(eastFirstRound[3].value, 'East First Round'),
                  seriesCard(eastFirstRound[2].value, 'East First Round'),
                  seriesCard(eastFirstRound[1].value, 'East First Round'),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  seriesCard(eastConfSemis[0].value, 'East Conf Semis'),
                  seriesCard(eastConfSemis[1].value, 'East Conf Semis'),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seriesCard(eastConfFinals, 'East Conference Finals'),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seriesCard(nbaFinals, 'NBA Finals'),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seriesCard(westConfFinals, 'West Conference Finals'),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  seriesCard(westConfSemis[0].value, 'West Conf Semis'),
                  seriesCard(westConfSemis[1].value, 'West Conf Semis'),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  seriesCard(westFirstRound[0].value, 'West First Round'),
                  seriesCard(westFirstRound[3].value, 'West First Round'),
                  seriesCard(westFirstRound[2].value, 'West First Round'),
                  seriesCard(westFirstRound[1].value, 'West First Round'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BracketPainter extends CustomPainter {
  final int season;
  final List eastFirstRound;
  final List eastConfSemis;
  final Map<String, dynamic> eastConfFinals;
  final Map<String, dynamic> nbaFinals;
  final Map<String, dynamic> westConfFinals;
  final List westConfSemis;
  final List westFirstRound;

  BracketPainter(
    this.season,
    this.eastFirstRound,
    this.eastConfSemis,
    this.eastConfFinals,
    this.nbaFinals,
    this.westConfFinals,
    this.westConfSemis,
    this.westFirstRound,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2.0;

    Paint getPaint(String teamId) {
      List<String> useSecondary = ['BKN', 'SAS'];
      Color teamColor = useSecondary.contains(kTeamNames[teamId][1])
          ? kTeamColors[kTeamNames[teamId]?[1]]!['secondaryColor']!
          : kTeamColors[kTeamNames[teamId]?[1]]!['primaryColor']!;
      return Paint()
        ..color = teamColor
        ..strokeWidth = 3;
    }

    Paint choosePaint(Map<String, dynamic> series, int round, int season) {
      bool teamOneWinsSeries = series['TEAM_ONE_WINS'] == 4 ||
          (series['TEAM_ONE_WINS'] == 3 && season < 2002 && round == 1);

      bool teamTwoWinsSeries = series['TEAM_TWO_WINS'] == 4 ||
          (series['TEAM_TWO_WINS'] == 3 && season < 2002 && round == 1);

      Paint result = series.isEmpty || (!teamOneWinsSeries && !teamTwoWinsSeries)
          ? paint
          : teamOneWinsSeries
              ? getPaint(series['TEAM_ONE'].toString())
              : getPaint(series['TEAM_TWO'].toString());

      return result;
    }

    // Draw lines between rounds
    /// EAST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.1),
      Offset(size.width * 0.13, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[0].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.1),
      Offset(size.width * 0.375, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[3].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.135),
      Offset(size.width * 0.2525, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[0].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.135),
      Offset(size.width * 0.375, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[3].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.135),
      Offset(size.width * 0.2525, size.height * 0.18),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[0].value, 2, season),
    );

    /// EAST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.1),
      Offset(size.width * 0.625, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[2].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.1),
      Offset(size.width * 0.875, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[1].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.135),
      Offset(size.width * 0.7525, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[2].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.135),
      Offset(size.width * 0.875, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[1].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.135),
      Offset(size.width * 0.7525, size.height * 0.18),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[1].value, 2, season),
    );

    /// EAST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.265),
      Offset(size.width * 0.7525, size.height * 0.29),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[1].value, 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.265),
      Offset(size.width * 0.2525, size.height * 0.29),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[0].value, 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.29),
      Offset(size.width * 0.5, size.height * 0.29),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[0].value, 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.29),
      Offset(size.width * 0.7525, size.height * 0.29),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[1].value, 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.29),
      Offset(size.width * 0.5, size.height * 0.325),
      eastConfFinals.isEmpty ? paint : choosePaint(eastConfFinals, 3, season),
    );

    /// EAST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.42),
      Offset(size.width * 0.5, size.height * 0.465),
      eastConfFinals.isEmpty ? paint : choosePaint(eastConfFinals, 3, season),
    );

    /// WEST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.56),
      Offset(size.width * 0.5, size.height * 0.6),
      westConfFinals.isEmpty ? paint : choosePaint(westConfFinals, 3, season),
    );

    /// WEST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.735),
      Offset(size.width * 0.7525, size.height * 0.8),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[1].value, 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.735),
      Offset(size.width * 0.2525, size.height * 0.8),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[0].value, 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.735),
      Offset(size.width * 0.5, size.height * 0.735),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[0].value, 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.735),
      Offset(size.width * 0.7525, size.height * 0.735),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[1].value, 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.735),
      westConfFinals.isEmpty ? paint : choosePaint(westConfFinals, 2, season),
    );

    /// WEST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.89),
      Offset(size.width * 0.13, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[0].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.89),
      Offset(size.width * 0.375, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[3].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.89),
      Offset(size.width * 0.2525, size.height * 0.89),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[0].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.89),
      Offset(size.width * 0.375, size.height * 0.89),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[3].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.8),
      Offset(size.width * 0.2525, size.height * 0.89),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[0].value, 2, season),
    );

    /// WEST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.89),
      Offset(size.width * 0.625, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[2].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.89),
      Offset(size.width * 0.875, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[1].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.89),
      Offset(size.width * 0.7525, size.height * 0.89),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[2].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.89),
      Offset(size.width * 0.875, size.height * 0.89),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[1].value, 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.8),
      Offset(size.width * 0.7525, size.height * 0.89),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[1].value, 2, season),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class GrayscaleImage extends StatelessWidget {
  final String imagePath;

  GrayscaleImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0, // Red channel
        0.2126, 0.7152, 0.0722, 0, 0, // Green channel
        0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
        0, 0, 0, 1, 0, // Alpha channel
      ]),
      child: Image.asset(
        imagePath,
        width: 24.0,
        height: 24.0,
      ),
    );
  }
}
