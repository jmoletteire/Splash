import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

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
      if (kEastConfTeamIds.contains(series.value['TEAM_ONE'].toString())) {
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

  Widget seriesCard(Map<String, dynamic> series) {
    String teamOne = series['TEAM_ONE'].toString();
    String teamTwo = series['TEAM_TWO'].toString();
    return Container(
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
                : series['TEAM_TWO_WINS'] == 4
                    ? Colors.grey.shade700
                    : kTeamColors[kTeamNames[series['TEAM_ONE'].toString()]![1]]![
                        'primaryColor']!, // Transparent at the top
            series['TEAM_ONE_WINS'] == 4
                ? Colors.grey.shade700
                : kTeamColors[kTeamNames[series['TEAM_TWO'].toString()]?[1]]![
                    'primaryColor']!, // Opaque at the bottom
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              series['TEAM_TWO_WINS'] == 4
                  ? GrayscaleImage(imagePath: 'images/NBA_Logos/$teamOne.png')
                  : Image.asset(
                      'images/NBA_Logos/$teamOne.png',
                      width: 24.0,
                      height: 24.0,
                    ),
              const Text(' '),
              series['TEAM_ONE_WINS'] == 4
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
                        color: series['TEAM_TWO_WINS'] == 4 ? Colors.grey : Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: series['TEAM_ONE_ABBR'].toString(),
                      style: kBebasBold.copyWith(
                        fontSize: 16.0, // keep the current styling for TEAM_TWO_ABBR
                        color: series['TEAM_TWO_WINS'] == 4 ? Colors.grey : Colors.white,
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
                        color: series['TEAM_ONE_WINS'] == 4 ? Colors.grey : Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: series['TEAM_TWO_ABBR'].toString(),
                      style: kBebasBold.copyWith(
                        fontSize: 16.0, // keep the current styling for TEAM_TWO_ABBR
                        color: series['TEAM_ONE_WINS'] == 4 ? Colors.grey : Colors.white,
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
                  color: series['TEAM_TWO_WINS'] == 4 ? Colors.grey : Colors.white,
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
                  color: series['TEAM_ONE_WINS'] == 4 ? Colors.grey : Colors.white,
                ),
              ),
            ],
          ),
        ],
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
            painter: BracketPainter(eastFirstRound, eastConfSemis, eastConfFinals, nbaFinals,
                westConfFinals, westConfSemis, westFirstRound),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  seriesCard(eastFirstRound[0].value),
                  seriesCard(eastFirstRound[3].value),
                  seriesCard(eastFirstRound[2].value),
                  seriesCard(eastFirstRound[1].value),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  seriesCard(eastConfSemis[0].value),
                  seriesCard(eastConfSemis[1].value),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seriesCard(eastConfFinals),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seriesCard(nbaFinals),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  seriesCard(westConfFinals),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  seriesCard(westConfSemis[0].value),
                  seriesCard(westConfSemis[1].value),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  seriesCard(westFirstRound[0].value),
                  seriesCard(westFirstRound[3].value),
                  seriesCard(westFirstRound[2].value),
                  seriesCard(westFirstRound[1].value),
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
  final List eastFirstRound;
  final List eastConfSemis;
  final Map<String, dynamic> eastConfFinals;
  final Map<String, dynamic> nbaFinals;
  final Map<String, dynamic> westConfFinals;
  final List westConfSemis;
  final List westFirstRound;

  BracketPainter(
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
      Color teamColor = kTeamColors[kTeamNames[teamId]?[1]]!['primaryColor']!;
      return Paint()
        ..color = teamColor
        ..strokeWidth = 3;
    }

    Paint choosePaint(Map<String, dynamic> round) {
      Paint result =
          round.isEmpty || (round['TEAM_ONE_WINS'] < 4 && round['TEAM_TWO_WINS'] < 4)
              ? paint
              : round['TEAM_ONE_WINS'] == 4
                  ? getPaint(round['TEAM_ONE'].toString())
                  : getPaint(round['TEAM_TWO'].toString());

      return result;
    }

    // Draw lines between rounds
    /// EAST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.1),
      Offset(size.width * 0.13, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[0].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.1),
      Offset(size.width * 0.375, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[3].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.135),
      Offset(size.width * 0.2525, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[0].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.135),
      Offset(size.width * 0.375, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[3].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.135),
      Offset(size.width * 0.2525, size.height * 0.18),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[0].value),
    );

    /// EAST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.1),
      Offset(size.width * 0.625, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[2].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.1),
      Offset(size.width * 0.875, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[1].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.135),
      Offset(size.width * 0.7525, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[2].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.135),
      Offset(size.width * 0.875, size.height * 0.135),
      eastFirstRound.isEmpty ? paint : choosePaint(eastFirstRound[1].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.135),
      Offset(size.width * 0.7525, size.height * 0.18),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[1].value),
    );

    /// EAST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.265),
      Offset(size.width * 0.7525, size.height * 0.29),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[1].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.265),
      Offset(size.width * 0.2525, size.height * 0.29),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[0].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.29),
      Offset(size.width * 0.5, size.height * 0.29),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[0].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.29),
      Offset(size.width * 0.7525, size.height * 0.29),
      eastConfSemis.isEmpty ? paint : choosePaint(eastConfSemis[1].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.29),
      Offset(size.width * 0.5, size.height * 0.325),
      eastConfFinals.isEmpty ? paint : choosePaint(eastConfFinals),
    );

    /// EAST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.42),
      Offset(size.width * 0.5, size.height * 0.465),
      eastConfFinals.isEmpty ? paint : choosePaint(eastConfFinals),
    );

    /// WEST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.56),
      Offset(size.width * 0.5, size.height * 0.6),
      westConfFinals.isEmpty ? paint : choosePaint(westConfFinals),
    );

    /// WEST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.735),
      Offset(size.width * 0.7525, size.height * 0.8),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[1].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.735),
      Offset(size.width * 0.2525, size.height * 0.8),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[0].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.735),
      Offset(size.width * 0.5, size.height * 0.735),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[0].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.735),
      Offset(size.width * 0.7525, size.height * 0.735),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[1].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.735),
      westConfFinals.isEmpty ? paint : choosePaint(westConfFinals),
    );

    /// WEST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.89),
      Offset(size.width * 0.13, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[0].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.89),
      Offset(size.width * 0.375, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[3].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.89),
      Offset(size.width * 0.2525, size.height * 0.89),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[0].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.89),
      Offset(size.width * 0.375, size.height * 0.89),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[3].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.8),
      Offset(size.width * 0.2525, size.height * 0.89),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[0].value),
    );

    /// WEST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.89),
      Offset(size.width * 0.625, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[2].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.89),
      Offset(size.width * 0.875, size.height * 0.925),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[1].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.89),
      Offset(size.width * 0.7525, size.height * 0.89),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[2].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.89),
      Offset(size.width * 0.875, size.height * 0.89),
      westFirstRound.isEmpty ? paint : choosePaint(westFirstRound[1].value),
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.8),
      Offset(size.width * 0.7525, size.height * 0.89),
      westConfSemis.isEmpty ? paint : choosePaint(westConfSemis[1].value),
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
