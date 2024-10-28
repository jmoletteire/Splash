import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:splash/utilities/constants.dart';

import '../../game/game_home.dart';

class PlayerFantasyStats extends StatefulWidget {
  final Map<String, dynamic> team;
  final Map<String, dynamic> player;
  const PlayerFantasyStats({super.key, required this.team, required this.player});

  @override
  State<PlayerFantasyStats> createState() => _PlayerFantasyStatsState();
}

class _PlayerFantasyStatsState extends State<PlayerFantasyStats> {
  List gamelogs = [];

  Map<String, dynamic> getGames() {
    Map<String, dynamic> seasons = widget.player['STATS'] ?? {};
    for (var season in seasons.entries) {
      Map<String, dynamic> seasonTypes = season.value['GAMELOGS'] ?? {};

      for (var seasonType in seasonTypes.entries) {
        for (var game in seasonType.value.entries) {
          gamelogs.add(game.value);
        }
      }
      // Sort the entries by the GAME_DATE value
      gamelogs.sort((a, b) => b['GAME_DATE'].compareTo(a['GAME_DATE']));
    }
    return {};
  }

  @override
  void initState() {
    super.initState();
    getGames();
  }

  @override
  Widget build(BuildContext context) {
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

    return SingleChildScrollView(
      child: Stack(children: [
        Column(
          children: [
            // Other content can go here
            SizedBox(height: 20.0.r),
            Text(
              'Recent Games',
              style: kBebasBold.copyWith(fontSize: 20.0.r),
            ),
            SizedBox(height: 10.0.r),
            Stack(children: [
              Positioned(
                  bottom: 50.0.r,
                  child: Opacity(
                    opacity: 0.2,
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.matrix(<double>[
                        0.2126, 0.7152, 0.0722, 0, 0, // Red channel
                        0.2126, 0.7152, 0.0722, 0, 0, // Green channel
                        0.2126, 0.7152, 0.0722, 0, 0, // Blue channel
                        0, 0, 0, 1, 0, // Alpha channel
                      ]),
                      child: Image.network(
                        'https://cdn.nba.com/silos/nba/latest/440x700/${widget.player['PERSON_ID']}.png',
                        width: MediaQuery.of(context).size.width,
                        height: 250.0.r,
                      ),
                    ),
                  )),
              SizedBox(
                height: 250.0.r,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: gamelogs.length,
                  itemBuilder: (context, index) {
                    String matchup = gamelogs[index]['MATCHUP'].toString();
                    String oppId = kTeamAbbrToId[matchup.substring(matchup.length - 3)] ?? '0';
                    String currentGameDate = gamelogs[index]['GAME_DATE'];
                    String currentMonth =
                        DateFormat('MMM').format(DateTime.parse(currentGameDate));
                    String currentYear =
                        DateFormat('yy').format(DateTime.parse(currentGameDate));

                    // Check if this is the first item or if the month has changed
                    bool isNewMonth = DateFormat('MMM')
                            .format(DateTime.parse(gamelogs[index + 1]['GAME_DATE'])) !=
                        currentMonth;

                    return Row(
                      children: [
                        if (isNewMonth)
                          Column(
                            children: [
                              Text(
                                '$currentMonth \'$currentYear',
                                style: kBebasNormal.copyWith(fontSize: 14.0.r),
                              ),
                              SizedBox(height: 5.0.r),
                              Container(
                                width: 2.0,
                                height: 180.0.r,
                                color: Colors.grey,
                              ),
                              SizedBox(width: 8.0.r), // Spacing between the line and the bar
                            ],
                          ),
                        Bar(
                          game: gamelogs[index],
                          playerName: widget.player['DISPLAY_FIRST_LAST'] ?? '',
                          date: formatDate(gamelogs[index]['GAME_DATE']),
                          opp: oppId, // Use your oppId here
                          homeAway: gamelogs[index]['MATCHUP'][4] != '@' ? 'vs' : '@',
                          value: gamelogs[index]?['NBA_FANTASY_PTS'] ?? 0,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ]),
            // More content below the bar chart
            SizedBox(height: 20.0.r),
            Text(
              'More Content Below the Bar Chart',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20.0.r),
            // Example of additional content that scrolls vertically
            Container(
              height: 300,
              color: Colors.blue[100],
              child: Center(child: Text('Scrollable Content')),
            ),
          ],
        ),
      ]),
    );
  }
}

class Bar extends StatelessWidget {
  final Map<String, dynamic> game;
  final String playerName;
  final List<String> date;
  final String opp;
  final String homeAway;
  final double value;

  const Bar({
    Key? key,
    required this.game,
    required this.playerName,
    required this.date,
    required this.opp,
    required this.homeAway,
    required this.value,
  }) : super(key: key);

  void showGameDetails(BuildContext context, Map<String, dynamic> gameData) {
    Color getColor(double value) {
      if (value > 35 && value <= 45) {
        return Color(0xFF70DAC7);
      } else if (value > 25 && value <= 35) {
        return Color(0xFFC2DB2F);
      } else if (value > 15 && value <= 25) {
        return Color(0xFFF0CE1D);
      } else if (value > 5 && value <= 15) {
        return Color(0xFFF7AA37);
      } else if (value <= 5) {
        return Color(0xFFFF999B);
      } else {
        return Color(0xFF32CE78);
      }
    }

    Widget fantasyStatRow(String statName, String abbr, int amount, double fpValue) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              "$statName: ",
              style: kBebasNormal.copyWith(fontSize: 14.0.r),
            ),
          ),
          Expanded(
            child: Text(
              "${(gameData[abbr] ?? '-') == 0 ? '-' : (gameData[abbr] ?? '-')}",
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(fontSize: 16.0.r),
            ),
          ),
          Expanded(
            child: Text(
              fpValue.toString(),
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(fontSize: 16.0.r, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              "${(gameData[abbr] * fpValue ?? '-') == 0 ? '-' : (gameData[abbr] * fpValue ?? '-').toStringAsFixed(1)}",
              textAlign: TextAlign.end,
              style: kBebasNormal.copyWith(fontSize: 16.0.r),
            ),
          ),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0.r),
          actionsPadding: EdgeInsets.symmetric(horizontal: 8.0.r, vertical: 4.0.r),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('M/d/yy').format(DateTime.parse(game['GAME_DATE'])),
                style: kBebasNormal.copyWith(fontSize: 19.0.r),
              ),
              SizedBox(width: 25.0.r),
              Row(
                children: [
                  Text(
                    homeAway,
                    style: kBebasNormal.copyWith(fontSize: 14.0.r),
                  ),
                  SizedBox(width: 3.0.r),
                  Text(
                    kTeamIdToName[opp][1],
                    style: kBebasNormal,
                  ),
                  SizedBox(width: 3.0.r),
                  SizedBox(
                      width: 20.0.r,
                      height: 20.0.r,
                      child: Image.asset('images/NBA_Logos/$opp.png')),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.0.r),
              Card(
                color: Colors.white10,
                child: Padding(
                  padding: EdgeInsets.all(8.0.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: Text("Total: ",
                                  style: kBebasBold.copyWith(fontSize: 20.0.r))),
                          Expanded(
                            child: Text(
                              "${gameData['NBA_FANTASY_PTS'] ?? '-'}",
                              textAlign: TextAlign.end,
                              style: kBebasBold.copyWith(
                                  fontSize: 20.0.r,
                                  color: getColor(gameData['NBA_FANTASY_PTS'])),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0.r),
                      fantasyStatRow('Points', 'PTS', gameData['PTS'] ?? 0, 1),
                      fantasyStatRow('Rebounds', 'REB', gameData['REB'] ?? 0, 1.2),
                      fantasyStatRow('Assists', 'AST', gameData['AST'] ?? 0, 1.5),
                      fantasyStatRow('Steals', 'STL', gameData['STL'] ?? 0, 3),
                      fantasyStatRow('Blocks', 'BLK', gameData['BLK'] ?? 0, 3),
                      fantasyStatRow('Turnovers', 'TOV', gameData['TOV'] ?? 0, -1),
                      SizedBox(height: 10.0.r),
                      Row(
                        children: [
                          Text(
                            'Minutes:  ',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade300),
                          ),
                          Text(
                            gameData['MIN_SEC'],
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Possessions:  ',
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade300),
                          ),
                          Text(
                            gameData['POSS'].toString(),
                            style: kBebasNormal.copyWith(fontSize: 14.0.r),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: kBebasNormal.copyWith(fontSize: 15.0.r, color: Colors.deepOrange),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Normalize the bar height based on a maximum value, e.g., 120
    double normalizedHeight = ((value / 100) * 200).clamp(30.0.r, 175.0.r);
    double valueContainerHeight = 30.0.r; // Height of the rounded container for the value

    Color getColor(double value) {
      if (value > 35 && value <= 45) {
        return Color(0xFF70DAC7);
      } else if (value > 25 && value <= 35) {
        return Color(0xFFC2DB2F);
      } else if (value > 15 && value <= 25) {
        return Color(0xFFF0CE1D);
      } else if (value > 5 && value <= 15) {
        return Color(0xFFF7AA37);
      } else if (value <= 5) {
        return Color(0xFFFF999B);
      } else {
        return Color(0xFF32CE78);
      }
    }

    // Choose colors based on the value, with lighter color for the value container
    Color barColor = getColor(value);
    Color valueContainerColor = barColor.withOpacity(0.8);

    return Container(
      width: 35.0.r, // Width of each bar
      margin: EdgeInsets.symmetric(horizontal: 8.0.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Main part of the bar with gradient
                InkWell(
                  onTap: () => showGameDetails(context, game),
                  child: Container(
                    height: normalizedHeight,
                    width: 40.0.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          barColor, // Lighter at the top
                          Colors.grey.shade800, // Darker at the bottom
                        ],
                      ),
                    ),
                  ),
                ),
                // Value container with rounded edges
                Positioned(
                  top: 215.0.r - normalizedHeight - valueContainerHeight,
                  child: InkWell(
                    onTap: () => showGameDetails(context, game),
                    child: Container(
                      height: valueContainerHeight,
                      width: 40.0.r,
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        color: valueContainerColor,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        value.toStringAsFixed(0),
                        style: kBebasNormal.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.0.r),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameHome(
                      gameId: game['GAME_ID'].toString(),
                      homeId: homeAway == '@' ? opp : game['TEAM_ID'].toString(),
                      awayId: homeAway == '@' ? game['TEAM_ID'].toString() : opp,
                      gameDate: game['GAME_DATE'].substring(0, 10),
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        homeAway,
                        style: kBebasBold.copyWith(fontSize: 10.0.r),
                      ),
                      SizedBox(width: 0.0.r),
                      SizedBox(
                        width: 18.0.r,
                        height: 18.0.r,
                        child: Image.asset(
                          'images/NBA_Logos/$opp.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          width: 18.0.r,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0.r),
                  Text(
                    date[0],
                    style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.white70),
                  ),
                  Text(
                    date[1],
                    style: kBebasNormal.copyWith(fontSize: 12.0.r),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
