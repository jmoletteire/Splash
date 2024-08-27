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
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'images/NBA_Logos/$teamOne.png',
                width: 25.0,
                height: 25.0,
              ),
              Image.asset(
                'images/NBA_Logos/$teamTwo.png',
                width: 25.0,
                height: 25.0,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                series['TEAM_ONE_ABBR'].toString(),
                style: kBebasBold.copyWith(fontSize: 16.0),
              ),
              const Text(' '),
              Text(
                series['TEAM_TWO_ABBR'].toString(),
                style: kBebasBold.copyWith(fontSize: 16.0),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                series['TEAM_ONE_WINS'].toString(),
                style: kBebasNormal.copyWith(fontSize: 14.0),
              ),
              Text(
                '-',
                style: kBebasNormal.copyWith(fontSize: 14.0),
              ),
              Text(
                series['TEAM_TWO_WINS'].toString(),
                style: kBebasNormal.copyWith(fontSize: 14.0),
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
            painter: BracketPainter(),
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    // Draw lines between rounds
    /// EAST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.1), // Starting point
      Offset(size.width * 0.13, size.height * 0.135), // Ending point
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.1),
      Offset(size.width * 0.375, size.height * 0.135),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.135),
      Offset(size.width * 0.375, size.height * 0.135),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.135),
      Offset(size.width * 0.2525, size.height * 0.18),
      paint,
    );

    /// EAST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.1),
      Offset(size.width * 0.625, size.height * 0.135),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.1),
      Offset(size.width * 0.875, size.height * 0.135),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.135),
      Offset(size.width * 0.875, size.height * 0.135),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.135),
      Offset(size.width * 0.7525, size.height * 0.18),
      paint,
    );

    /// EAST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.265),
      Offset(size.width * 0.7525, size.height * 0.29),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.265),
      Offset(size.width * 0.2525, size.height * 0.29),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.29),
      Offset(size.width * 0.7525, size.height * 0.29),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.29),
      Offset(size.width * 0.5, size.height * 0.325),
      paint,
    );

    /// EAST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.42),
      Offset(size.width * 0.5, size.height * 0.465),
      paint,
    );

    /// WEST FINALS
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.56),
      Offset(size.width * 0.5, size.height * 0.6),
      paint,
    );

    /// WEST SEMIS
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.735),
      Offset(size.width * 0.7525, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.735),
      Offset(size.width * 0.2525, size.height * 0.8),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.735),
      Offset(size.width * 0.7525, size.height * 0.735),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.735),
      paint,
    );

    /// WEST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.89),
      Offset(size.width * 0.13, size.height * 0.925),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.375, size.height * 0.89),
      Offset(size.width * 0.375, size.height * 0.925),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.13, size.height * 0.89),
      Offset(size.width * 0.375, size.height * 0.89),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.2525, size.height * 0.8),
      Offset(size.width * 0.2525, size.height * 0.89),
      paint,
    );

    /// WEST FIRST ROUND
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.89),
      Offset(size.width * 0.625, size.height * 0.925),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.875, size.height * 0.89),
      Offset(size.width * 0.875, size.height * 0.925),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.625, size.height * 0.89),
      Offset(size.width * 0.875, size.height * 0.89),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.7525, size.height * 0.8),
      Offset(size.width * 0.7525, size.height * 0.89),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
