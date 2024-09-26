import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/utilities/constants.dart';

import '../../game/game_home.dart';

class KnockoutBracket extends StatefulWidget {
  final List knockoutData;

  const KnockoutBracket({super.key, required this.knockoutData});

  @override
  State<KnockoutBracket> createState() => _KnockoutBracketState();
}

class _KnockoutBracketState extends State<KnockoutBracket> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(KnockoutBracket oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.knockoutData != widget.knockoutData) {
      setState(() {});
    }
  }

  Widget seriesCard(Map<String, dynamic> series, int round) {
    Widget getFinals(Map<String, dynamic> series, bool teamOneWins, bool teamTwoWins) {
      String teamOne = series['highSeedId'].toString();
      String teamTwo = series['lowSeedId'].toString();
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              teamTwoWins
                  ? GrayscaleImage(
                      imagePath: 'images/NBA_Logos/$teamOne.png',
                      size: 42.0.r,
                    )
                  : Image.asset(
                      'images/NBA_Logos/$teamOne.png',
                      width: 42.0.r,
                      height: 42.0.r,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${series['highSeedRank'].toString()} ',
                          style: kBebasBold.copyWith(
                            fontSize: 12.0.r,
                            color: teamTwoWins ? Colors.grey : Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: series['highSeedTricode'],
                          style: kBebasBold.copyWith(
                            fontSize: 20.0.r,
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
                    series['highSeedScore'].toString(),
                    style: kBebasBold.copyWith(
                      fontSize: 24.0.r,
                      color: teamTwoWins ? Colors.grey : Colors.white,
                    ),
                  ),
                  Text(
                    '    -    ',
                    style: kBebasNormal.copyWith(fontSize: 24.0.r),
                  ),
                  Text(
                    series['lowSeedScore'].toString(),
                    style: kBebasBold.copyWith(
                      fontSize: 24.0.r,
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
                      size: 42.0.r,
                    )
                  : Image.asset(
                      'images/NBA_Logos/$teamTwo.png',
                      width: 42.0.r,
                      height: 42.0.r,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${series['lowSeedRank'].toString()} ',
                          style: kBebasBold.copyWith(
                            fontSize: 12.0.r,
                            color: teamOneWins ? Colors.grey : Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: series['lowSeedTricode'],
                          style: kBebasBold.copyWith(
                            fontSize: 20.0.r,
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

    String teamOne = series['highSeedId'].toString();
    String teamTwo = series['lowSeedId'].toString();

    bool teamOneWinsSeries = series['seriesWinner'] == series['highSeedId'];
    bool teamTwoWinsSeries = series['seriesWinner'] == series['lowSeedId'];

    List<String> useSecondary = ['SAS'];

    Map<int, double> widthFactor = {1: 2.75.r, 2: 2.r, 3: 1.25.r};

    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameHome(
              gameId: series['nextGameId'].toString(),
              homeId: series['highSeedId'].toString(),
              awayId: series['lowSeedId'].toString(),
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.0.r),
        margin: EdgeInsets.all(8.0.r),
        height: MediaQuery.of(context).size.height / 10,
        width: MediaQuery.of(context).size.width / widthFactor[round]!,
        decoration: BoxDecoration(
          //color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10.0),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              teamTwoWinsSeries
                  ? Colors.grey.shade700
                  : useSecondary.contains(series['highSeedTricode'])
                      ? kTeamColors[series['highSeedTricode']]!['secondaryColor']!
                      : kTeamColors[series['highSeedTricode']]!['primaryColor']!,
              teamOneWinsSeries
                  ? Colors.grey.shade700
                  : useSecondary.contains(kTeamIdToName[series['lowSeedTricode']])
                      ? kTeamColors[series['lowSeedTricode']]!['secondaryColor']!
                      : kTeamColors[series['lowSeedTricode']]!['primaryColor']!,
            ],
          ),
        ),
        child: round == 3
            ? getFinals(series, teamOneWinsSeries, teamTwoWinsSeries)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      teamTwoWinsSeries
                          ? GrayscaleImage(
                              imagePath: 'images/NBA_Logos/$teamOne.png', size: 28.0.r)
                          : Image.asset(
                              'images/NBA_Logos/$teamOne.png',
                              width: 28.0.r,
                              height: 28.0.r,
                            ),
                      const Text(' '),
                      teamOneWinsSeries
                          ? GrayscaleImage(
                              imagePath: 'images/NBA_Logos/$teamTwo.png', size: 28.0.r)
                          : Image.asset(
                              'images/NBA_Logos/$teamTwo.png',
                              width: 28.0.r,
                              height: 28.0.r,
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
                              text: '${series['highSeedRank'].toString()} ',
                              style: kBebasBold.copyWith(
                                fontSize: 10.0.r, // smaller font size for TEAM_TWO_SEED
                                color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: series['highSeedTricode'],
                              style: kBebasBold.copyWith(
                                fontSize: 16.0.r, // keep the current styling for TEAM_TWO_ABBR
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
                              text: '${series['lowSeedRank'].toString()} ',
                              style: kBebasBold.copyWith(
                                fontSize: 10.0.r, // smaller font size for TEAM_TWO_SEED
                                color: teamOneWinsSeries ? Colors.grey : Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: series['lowSeedTricode'],
                              style: kBebasBold.copyWith(
                                fontSize: 16.0.r, // keep the current styling for TEAM_TWO_ABBR
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
                        series['highSeedScore'].toString(),
                        style: kBebasBold.copyWith(
                          fontSize: 16.0.r,
                          color: teamTwoWinsSeries ? Colors.grey : Colors.white,
                        ),
                      ),
                      Text(
                        '-',
                        style: kBebasNormal.copyWith(fontSize: 16.0.r),
                      ),
                      Text(
                        series['lowSeedScore'].toString(),
                        style: kBebasBold.copyWith(
                          fontSize: 16.0.r,
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
            painter: BracketPainter(widget.knockoutData),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  seriesCard(widget.knockoutData[0], widget.knockoutData[0]['roundNumber']),
                  seriesCard(widget.knockoutData[1], widget.knockoutData[1]['roundNumber']),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seriesCard(widget.knockoutData[4], widget.knockoutData[4]['roundNumber']),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seriesCard(widget.knockoutData[6], widget.knockoutData[6]['roundNumber']),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seriesCard(widget.knockoutData[5], widget.knockoutData[5]['roundNumber']),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 60),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  seriesCard(widget.knockoutData[2], widget.knockoutData[2]['roundNumber']),
                  seriesCard(widget.knockoutData[3], widget.knockoutData[3]['roundNumber']),
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
  final List knockoutData;

  BracketPainter(
    this.knockoutData,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2.0;

    Paint getPaint(String team) {
      List<String> useSecondary = ['BKN', 'SAS'];
      Color teamColor = useSecondary.contains(team)
          ? kTeamColors[team]!['secondaryColor']!
          : kTeamColors[team]!['primaryColor']!;
      return Paint()
        ..color = teamColor
        ..strokeWidth = 3;
    }

    Paint choosePaint(Map<String, dynamic> series, int round) {
      bool teamOneWinsSeries = series['seriesWinner'] == series['highSeedId'];

      bool teamTwoWinsSeries = series['seriesWinner'] == series['lowSeedId'];

      Paint result = series.isEmpty || (!teamOneWinsSeries && !teamTwoWinsSeries)
          ? paint
          : teamOneWinsSeries
              ? getPaint(series['highSeedTricode'].toString())
              : getPaint(series['lowSeedTricode'].toString());

      return result;
    }

    // Draw lines between rounds
    /// EAST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.05),
      Offset(size.width * 0.7525, size.height * 0.1275),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[1], 2),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.05),
      Offset(size.width * 0.2525, size.height * 0.1275),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[0], 2),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.1275),
      Offset(size.width * 0.5, size.height * 0.1275),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[0], 2),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.1275),
      Offset(size.width * 0.7525, size.height * 0.1275),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[1], 2),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.1275),
      Offset(size.width * 0.5, size.height * 0.195),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[4], 3),
    );

    /// EAST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.195),
      Offset(size.width * 0.5, size.height * 0.3325),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[4], 3),
    );

    /// WEST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.3325),
      Offset(size.width * 0.5, size.height * 0.47),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[6], 3),
    );

    /// WEST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.5375),
      Offset(size.width * 0.7525, size.height * 0.615),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[3], 2),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.5375),
      Offset(size.width * 0.2525, size.height * 0.615),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[2], 2),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.5375),
      Offset(size.width * 0.5, size.height * 0.5375),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[2], 2),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.5375),
      Offset(size.width * 0.7525, size.height * 0.5375),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[3], 2),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.47),
      Offset(size.width * 0.5, size.height * 0.5375),
      knockoutData.isEmpty ? paint : choosePaint(knockoutData[5], 2),
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
