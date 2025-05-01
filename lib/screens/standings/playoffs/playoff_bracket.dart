import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    Map<String, dynamic> placeholder = {
      'TEAM_ONE': 0,
      'TEAM_TWO': 0,
      'TEAM_ONE_ABBR': '',
      'TEAM_TWO_ABBR': '',
      'TEAM_ONE_SEED': '',
      'TEAM_TWO_SEED': '',
      'TEAM_ONE_WINS': '',
      'TEAM_TWO_WINS': '',
      'GAMES': []
    };

    /// FIRST ROUND
    if (widget.playoffData.containsKey('First Round')) {
      for (var series in widget.playoffData['First Round'].entries) {
        if (kEastConfTeamIds.contains(series.value['TEAM_ONE'].toString()) ||
            kEastConfTeamIds.contains(series.value['TEAM_TWO'].toString())) {
          eastFirstRound.add(series.value);
        } else {
          westFirstRound.add(series.value);
        }
      }
    } else {
      eastFirstRound.add(placeholder);
      eastFirstRound.add(placeholder);
      eastFirstRound.add(placeholder);
      eastFirstRound.add(placeholder);

      westFirstRound.add(placeholder);
      westFirstRound.add(placeholder);
      westFirstRound.add(placeholder);
      westFirstRound.add(placeholder);
    }

    /// CONF SEMIS
    if (widget.playoffData.containsKey('Conf Semi-Finals')) {
      for (var series in (widget.playoffData['Conf Semi-Finals'] ?? {}).entries) {
        if (kEastConfTeamIds.contains(series.value['TEAM_ONE'].toString())) {
          eastConfSemis.add(series.value);
        } else {
          westConfSemis.add(series.value);
        }
      }
      if (eastConfSemis.length < 2) {
        eastConfSemis.add(placeholder);
        if (eastConfSemis.length == 1) {
          eastConfSemis.add(placeholder);
        }
      }
      if (westConfSemis.length < 2) {
        westConfSemis.add(placeholder);
        if (westConfSemis.length == 1) {
          westConfSemis.add(placeholder);
        }
      }
    } else {
      eastConfSemis.add(placeholder);
      eastConfSemis.add(placeholder);

      westConfSemis.add(placeholder);
      westConfSemis.add(placeholder);
    }

    /// CONF FINALS
    if (widget.playoffData.containsKey('Conf Finals')) {
      for (var series in (widget.playoffData['Conf Finals'] ?? {}).entries) {
        if (kEastConfTeamIds.contains(series.value['TEAM_ONE'].toString())) {
          eastConfFinals = series.value;
        } else {
          westConfFinals = series.value;
        }
      }
    } else {
      eastConfFinals = placeholder;
      westConfFinals = placeholder;
    }

    /// NBA Finals
    if (widget.playoffData.containsKey('NBA Finals')) {
      for (var series in (widget.playoffData['NBA Finals'] ?? {}).entries) {
        nbaFinals = series.value;
      }
    } else {
      nbaFinals = placeholder;
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

  void _showBottomSheet(Map<String, dynamic> selectedSeries, String round) {
    showModalBottomSheet(
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      backgroundColor: Colors.grey.shade900,
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0.r),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(11.0.r),
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
                        style: kBebasBold.copyWith(fontSize: 16.0.r),
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

                  return InkWell(
                    onTap: () {
                      if (int.parse(widget.playoffData['SEASON'].substring(0, 4)) >= 2017) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GameHome(
                              gameId: game['GAME_ID'],
                              homeId: homeTeam,
                              awayId: awayTeam,
                              gameDate: game['GAME_DATE'].substring(0, 10),
                            ),
                          ),
                        );
                      } else {
                        _showErrorSnackBar(context, 'GAMES ONLY AVAILABLE SINCE 2017-18');
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.0.r, vertical: 8.0.r),
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
                                          fontSize: 11.0.r, color: Colors.white70),
                                    ),
                                    Text(
                                      gameDate[1],
                                      style: kBebasNormal.copyWith(fontSize: 11.0.r),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(width: 15.0.r),
                                    SizedBox(
                                      width: 24.0.r,
                                      height: 24.0.r,
                                      child: awayTeam == ''
                                          ? const Text('')
                                          : Image.asset(
                                              'images/NBA_Logos/$awayTeam.png',
                                              fit: BoxFit.contain,
                                              width: 16.0.r,
                                              height: 16.0.r,
                                            ),
                                    ),
                                    if (game['AWAY_SCORE'] != null)
                                      Text(
                                        game['AWAY_SCORE'].toStringAsFixed(0),
                                        style: kBebasBold.copyWith(
                                          fontSize: 16.0.r,
                                          color: game['AWAY_SCORE'] < game['HOME_SCORE']
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                      ),
                                    if (game['AWAY_SCORE'] == null) const Text('  '),
                                    Text('@', style: kBebasBold.copyWith(fontSize: 12.0.r)),
                                    if (game['HOME_SCORE'] != null)
                                      Text(
                                        game['HOME_SCORE'].toStringAsFixed(0),
                                        style: kBebasBold.copyWith(
                                          fontSize: 16.0.r,
                                          color: game['HOME_SCORE'] < game['AWAY_SCORE']
                                              ? Colors.grey
                                              : Colors.white,
                                        ),
                                      ),
                                    if (game['HOME_SCORE'] == null) const Text('  '),
                                    SizedBox(
                                      width: 24.0.r,
                                      height: 24.0.r,
                                      child: homeTeam == ''
                                          ? const Text('')
                                          : Image.asset(
                                              'images/NBA_Logos/$homeTeam.png',
                                              fit: BoxFit.contain,
                                              width: 16.0.r,
                                              height: 16.0.r,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16.0.r,
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
    Widget getFinals(bool teamOneWins, bool teamTwoWins) {
      String teamOne = series['TEAM_ONE'].toString();
      String teamTwo = series['TEAM_TWO'].toString();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              teamTwoWins
                  ? GrayscaleImage(
                      imagePath: 'images/NBA_Logos/$teamOne.png',
                      size: round == 'NBA Finals'
                          ? 42.0.r
                          : round.substring(5) == 'Conference Finals'
                              ? 30.0.r
                              : 26.0.r,
                    )
                  : Image.asset(
                      'images/NBA_Logos/$teamOne.png',
                      width: round == 'NBA Finals'
                          ? 42.0.r
                          : round.substring(5) == 'Conference Finals'
                              ? 30.0.r
                              : 26.0.r,
                      height: round == 'NBA Finals'
                          ? 42.0.r
                          : round.substring(5) == 'Conference Finals'
                              ? 30.0.r
                              : 26.0.r,
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
                            fontSize: round == 'NBA Finals'
                                ? 14.0.r
                                : round.substring(5) == 'Conference Finals'
                                    ? 12.0.r
                                    : 10.0.r,
                            color: teamTwoWins ? Colors.grey : Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: series['TEAM_ONE_ABBR'],
                          style: kBebasBold.copyWith(
                            fontSize: round == 'NBA Finals'
                                ? 22.0.r
                                : round.substring(5) == 'Conference Finals'
                                    ? 16.0.r
                                    : 14.0.r,
                            color: teamTwoWins ? Colors.grey : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    series['TEAM_ONE_WINS'].toString(),
                    style: kBebasBold.copyWith(
                      fontSize: round == 'NBA Finals'
                          ? 26.0.r
                          : round.substring(5) == 'Conference Finals'
                              ? 22.0.r
                              : 18.0.r,
                      color: teamTwoWins ? Colors.grey : Colors.white,
                    ),
                  ),
                  Text(
                    round.substring(5) == 'Conf Semis' ? '  -  ' : '    -    ',
                    style: kBebasNormal.copyWith(
                      fontSize: round == 'NBA Finals'
                          ? 26.0.r
                          : round.substring(5) == 'Conference Finals'
                              ? 22.0.r
                              : 18.0.r,
                    ),
                  ),
                  Text(
                    series['TEAM_TWO_WINS'].toString(),
                    style: kBebasBold.copyWith(
                      fontSize: round == 'NBA Finals'
                          ? 26.0.r
                          : round.substring(5) == 'Conference Finals'
                              ? 22.0.r
                              : 18.0.r,
                      color: teamOneWins ? Colors.grey : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              teamOneWins
                  ? GrayscaleImage(
                      imagePath: 'images/NBA_Logos/$teamTwo.png',
                      size: round == 'NBA Finals'
                          ? 42.0.r
                          : round.substring(5) == 'Conference Finals'
                              ? 30.0.r
                              : 26.0.r,
                    )
                  : Image.asset(
                      'images/NBA_Logos/$teamTwo.png',
                      width: round == 'NBA Finals'
                          ? 42.0.r
                          : round.substring(5) == 'Conference Finals'
                              ? 30.0.r
                              : 26.0.r,
                      height: round == 'NBA Finals'
                          ? 42.0.r
                          : round.substring(5) == 'Conference Finals'
                              ? 30.0.r
                              : 26.0.r,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${series['TEAM_TWO_SEED'].toString()} ',
                          style: kBebasBold.copyWith(
                            fontSize: round == 'NBA Finals'
                                ? 14.0.r
                                : round.substring(5) == 'Conference Finals'
                                    ? 12.0.r
                                    : 10.0.r,
                            color: teamOneWins ? Colors.grey : Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: series['TEAM_TWO_ABBR'],
                          style: kBebasBold.copyWith(
                            fontSize: round == 'NBA Finals'
                                ? 22.0.r
                                : round.substring(5) == 'Conference Finals'
                                    ? 16.0.r
                                    : 14.0.r,
                            color: teamOneWins ? Colors.grey : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
    }

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

    Map<String, double> widthFactor = {
      'First Round': 5,
      'Conf Semis': 2.75,
      'Conference Finals': 2,
      'inals': 1.25
    };

    return GestureDetector(
      onTap: () {
        _showBottomSheet(series, round);
      },
      child: Container(
        padding: EdgeInsets.all(8.0.r),
        margin: EdgeInsets.all(8.0.r),
        height: round == 'NBA Finals'
            ? MediaQuery.of(context).size.height / 8
            : MediaQuery.of(context).size.height / 10,
        width: MediaQuery.of(context).size.width / widthFactor[round.substring(5)]!,
        decoration: BoxDecoration(
          //color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10.0),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              kTeamIdToName[series['TEAM_TWO'].toString()] == null
                  ? Colors.grey
                  : teamTwoWinsSeries
                      ? Colors.grey.shade700
                      : useSecondary.contains(kTeamIdToName[series['TEAM_ONE'].toString()][1])
                          ? kTeamColors[kTeamIdToName[series['TEAM_ONE'].toString()]?[1]]![
                              'secondaryColor']!
                          : kTeamColors[kTeamIdToName[series['TEAM_ONE'].toString()]?[1]]![
                              'primaryColor']!,
              teamOneWinsSeries
                  ? Colors.grey.shade700
                  : useSecondary.contains(kTeamIdToName[series['TEAM_TWO'].toString()][1])
                      ? kTeamColors[kTeamIdToName[series['TEAM_TWO'].toString()]?[1]]![
                          'secondaryColor']!
                      : kTeamColors[kTeamIdToName[series['TEAM_TWO'].toString()]?[1]]![
                          'primaryColor']!,
            ],
          ),
        ),
        child: round.substring(5) != 'First Round'
            ? getFinals(teamOneWinsSeries, teamTwoWinsSeries)
            : LayoutBuilder(builder: (context, constraints) {
                if (MediaQuery.of(context).orientation == Orientation.landscape) {
                  String teamOne = series['TEAM_ONE'].toString();
                  String teamTwo = series['TEAM_TWO'].toString();
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          teamTwoWinsSeries
                              ? GrayscaleImage(
                                  imagePath: 'images/NBA_Logos/$teamOne.png',
                                  size: round == 'NBA Finals'
                                      ? 42.0.r
                                      : round.substring(5) == 'Conference Finals'
                                          ? 30.0.r
                                          : 26.0.r,
                                )
                              : Image.asset(
                                  'images/NBA_Logos/$teamOne.png',
                                  width: round == 'NBA Finals'
                                      ? 42.0.r
                                      : round.substring(5) == 'Conference Finals'
                                          ? 30.0.r
                                          : 26.0.r,
                                  height: round == 'NBA Finals'
                                      ? 42.0.r
                                      : round.substring(5) == 'Conference Finals'
                                          ? 30.0.r
                                          : 26.0.r,
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
                                        fontSize: round == 'NBA Finals'
                                            ? 14.0.r
                                            : round.substring(5) == 'Conference Finals'
                                                ? 12.0.r
                                                : 10.0.r,
                                        color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: series['TEAM_ONE_ABBR'],
                                      style: kBebasBold.copyWith(
                                        fontSize: round == 'NBA Finals'
                                            ? 22.0.r
                                            : round.substring(5) == 'Conference Finals'
                                                ? 16.0.r
                                                : 14.0.r,
                                        color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                series['TEAM_ONE_WINS'].toString(),
                                style: kBebasBold.copyWith(
                                  fontSize: round == 'NBA Finals'
                                      ? 26.0.r
                                      : round.substring(5) == 'Conference Finals'
                                          ? 22.0.r
                                          : 18.0.r,
                                  color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                                ),
                              ),
                              Text(
                                round.substring(5) == 'Conf Semis' ? '  -  ' : '    -    ',
                                style: kBebasNormal.copyWith(
                                  fontSize: round == 'NBA Finals'
                                      ? 26.0.r
                                      : round.substring(5) == 'Conference Finals'
                                          ? 22.0.r
                                          : 18.0.r,
                                ),
                              ),
                              Text(
                                series['TEAM_TWO_WINS'].toString(),
                                style: kBebasBold.copyWith(
                                  fontSize: round == 'NBA Finals'
                                      ? 26.0.r
                                      : round.substring(5) == 'Conference Finals'
                                          ? 22.0.r
                                          : 18.0.r,
                                  color: teamOneWinsSeries ? Colors.grey : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          teamOneWinsSeries
                              ? GrayscaleImage(
                                  imagePath: 'images/NBA_Logos/$teamTwo.png',
                                  size: round == 'NBA Finals'
                                      ? 42.0.r
                                      : round.substring(5) == 'Conference Finals'
                                          ? 30.0.r
                                          : 26.0.r,
                                )
                              : Image.asset(
                                  'images/NBA_Logos/$teamTwo.png',
                                  width: round == 'NBA Finals'
                                      ? 42.0.r
                                      : round.substring(5) == 'Conference Finals'
                                          ? 30.0.r
                                          : 26.0.r,
                                  height: round == 'NBA Finals'
                                      ? 42.0.r
                                      : round.substring(5) == 'Conference Finals'
                                          ? 30.0.r
                                          : 26.0.r,
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${series['TEAM_TWO_SEED'].toString()} ',
                                      style: kBebasBold.copyWith(
                                        fontSize: round == 'NBA Finals'
                                            ? 14.0.r
                                            : round.substring(5) == 'Conference Finals'
                                                ? 12.0.r
                                                : 10.0.r,
                                        color: teamOneWinsSeries ? Colors.grey : Colors.white,
                                      ),
                                    ),
                                    TextSpan(
                                      text: series['TEAM_TWO_ABBR'],
                                      style: kBebasBold.copyWith(
                                        fontSize: round == 'NBA Finals'
                                            ? 22.0.r
                                            : round.substring(5) == 'Conference Finals'
                                                ? 16.0.r
                                                : 14.0.r,
                                        color: teamOneWinsSeries ? Colors.grey : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          teamTwoWinsSeries
                              ? GrayscaleImage(
                                  imagePath: 'images/NBA_Logos/$teamOne.png',
                                  size: 22.0.r,
                                )
                              : Image.asset(
                                  'images/NBA_Logos/$teamOne.png',
                                  width: 22.0.r,
                                  height: 22.0.r,
                                ),
                          const Text(' '),
                          teamOneWinsSeries
                              ? GrayscaleImage(
                                  imagePath: 'images/NBA_Logos/$teamTwo.png',
                                  size: 22.0.r,
                                )
                              : Image.asset(
                                  'images/NBA_Logos/$teamTwo.png',
                                  width: 22.0.r,
                                  height: 22.0.r,
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
                                    fontSize: 10.0.r, // smaller font size for TEAM_TWO_SEED
                                    color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: series['TEAM_ONE_ABBR'].toString(),
                                  style: kBebasBold.copyWith(
                                    fontSize:
                                        14.0.r, // keep the current styling for TEAM_TWO_ABBR
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
                                    fontSize: 10.0.r, // smaller font size for TEAM_TWO_SEED
                                    color: teamOneWinsSeries ? Colors.grey : Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: series['TEAM_TWO_ABBR'].toString(),
                                  style: kBebasBold.copyWith(
                                    fontSize:
                                        14.0.r, // keep the current styling for TEAM_TWO_ABBR
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
                              fontSize: 12.0.r,
                              color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                            ),
                          ),
                          Text(
                            '-',
                            style: kBebasNormal.copyWith(fontSize: 12.0.r),
                          ),
                          Text(
                            series['TEAM_TWO_WINS'].toString(),
                            style: kBebasBold.copyWith(
                              fontSize: 12.0.r,
                              color: teamOneWinsSeries ? Colors.grey : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              }),
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
                  seriesCard(eastFirstRound[0], 'East First Round'),
                  seriesCard(eastFirstRound[3], 'East First Round'),
                  seriesCard(eastFirstRound[2], 'East First Round'),
                  seriesCard(eastFirstRound[1], 'East First Round'),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  seriesCard(eastConfSemis[0], 'East Conf Semis'),
                  seriesCard(eastConfSemis[1], 'East Conf Semis'),
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
                  seriesCard(westConfSemis[0], 'West Conf Semis'),
                  seriesCard(westConfSemis[1], 'West Conf Semis'),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  seriesCard(westFirstRound[0], 'West First Round'),
                  seriesCard(westFirstRound[3], 'West First Round'),
                  seriesCard(westFirstRound[2], 'West First Round'),
                  seriesCard(westFirstRound[1], 'West First Round'),
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
      Color teamColor = useSecondary.contains(kTeamIdToName[teamId][1])
          ? kTeamColors[kTeamIdToName[teamId]?[1]]!['secondaryColor']!
          : kTeamColors[kTeamIdToName[teamId]?[1]]!['primaryColor']!;
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
      Offset(size.width * 0.13, size.height * 0.06),
      Offset(size.width * 0.13, size.height * 0.1375),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[0], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.06),
      Offset(size.width * 0.375, size.height * 0.1375),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[3], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.1375),
      Offset(size.width * 0.2525, size.height * 0.1375),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[0], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.1375),
      Offset(size.width * 0.375, size.height * 0.1375),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[3], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.1375),
      Offset(size.width * 0.2525, size.height * 0.215),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[0], 2, season),
    );

    /// EAST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.06),
      Offset(size.width * 0.625, size.height * 0.1375),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[2], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.06),
      Offset(size.width * 0.875, size.height * 0.1375),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[1], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.1375),
      Offset(size.width * 0.7525, size.height * 0.1375),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[2], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.1375),
      Offset(size.width * 0.875, size.height * 0.1375),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[1], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.1375),
      Offset(size.width * 0.7525, size.height * 0.215),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[1], 2, season),
    );

    /// EAST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.215),
      Offset(size.width * 0.7525, size.height * 0.295),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[1], 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.215),
      Offset(size.width * 0.2525, size.height * 0.295),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[0], 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.295),
      Offset(size.width * 0.5, size.height * 0.295),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[0], 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.295),
      Offset(size.width * 0.7525, size.height * 0.295),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[1], 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.295),
      Offset(size.width * 0.5, size.height * 0.375),
      eastConfFinals.isEmpty ? paint : choosePaint(eastConfFinals, 3, season),
    );

    /// EAST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.375),
      Offset(size.width * 0.5, size.height * 0.525),
      eastConfFinals.isEmpty ? paint : choosePaint(eastConfFinals, 3, season),
    );

    /// WEST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.525),
      Offset(size.width * 0.5, size.height * 0.675),
      westConfFinals.isEmpty ? paint : choosePaint(westConfFinals, 3, season),
    );

    /// WEST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.765),
      Offset(size.width * 0.7525, size.height * 0.835),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[1], 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.765),
      Offset(size.width * 0.2525, size.height * 0.835),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[0], 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.765),
      Offset(size.width * 0.5, size.height * 0.765),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[0], 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.765),
      Offset(size.width * 0.7525, size.height * 0.765),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[1], 2, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.675),
      Offset(size.width * 0.5, size.height * 0.765),
      westConfFinals.isEmpty ? paint : choosePaint(westConfFinals, 2, season),
    );

    /// WEST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.925),
      Offset(size.width * 0.13, size.height),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[0], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.925),
      Offset(size.width * 0.375, size.height),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[3], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.925),
      Offset(size.width * 0.2525, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[0], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.925),
      Offset(size.width * 0.375, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[3], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.835),
      Offset(size.width * 0.2525, size.height * 0.925),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[0], 2, season),
    );

    /// WEST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.925),
      Offset(size.width * 0.625, size.height),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[2], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.925),
      Offset(size.width * 0.875, size.height),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[1], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.925),
      Offset(size.width * 0.7525, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[2], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.925),
      Offset(size.width * 0.875, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[1], 1, season),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.835),
      Offset(size.width * 0.7525, size.height * 0.925),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[1], 2, season),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class GrayscaleImage extends StatelessWidget {
  final String imagePath;
  final double size;

  GrayscaleImage({required this.imagePath, required this.size});

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
        width: size,
        height: size,
      ),
    );
  }
}
