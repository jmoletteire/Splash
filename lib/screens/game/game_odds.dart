import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utilities/constants.dart';

class Odds extends StatefulWidget {
  final Map<String, dynamic> odds;
  const Odds({super.key, required this.odds});

  @override
  State<Odds> createState() => _OddsState();
}

class _OddsState extends State<Odds> {
  Map<String, dynamic> fanDuel = {};
  Map<String, dynamic> draftKings = {};
  Map<String, dynamic> mgm = {};
  Map<String, dynamic> bet365 = {};

  int decimalToMoneyline(double decimalOdds) {
    if (decimalOdds <= 1.0) {
      throw ArgumentError('Decimal odds must be greater than 1.');
    }

    if (decimalOdds >= 2.0) {
      // Positive moneyline odds
      return ((decimalOdds - 1.0) * 100).round();
    } else {
      // Negative moneyline odds
      return (-100 / (decimalOdds - 1.0)).round();
    }
  }

  Map<String, dynamic> setOdds(String bookId) {
    String moneyLine = '';
    String spread = '';
    String overUnder = '';
    Map<String, dynamic> odds = {};

    try {
      odds = widget.odds[bookId];
    } catch (e) {
      odds = {};
      print('Book $bookId not found');
      return odds;
    }

    // MoneyLine
    String awayMLOdds = '';
    String homeMLOdds = '';
    try {
      int raw =
          decimalToMoneyline(double.parse(odds['oddstypes']['1']['outcomes']['2']['odds']));
      if (raw > 0) {
        awayMLOdds = '+${raw.toString()}';
      } else {
        awayMLOdds = raw.toString();
      }
    } catch (e) {
      awayMLOdds = '';
    }
    try {
      int raw =
          decimalToMoneyline(double.parse(odds['oddstypes']['1']['outcomes']['1']['odds']));
      if (raw > 0) {
        homeMLOdds = '+${raw.toString()}';
      } else {
        homeMLOdds = raw.toString();
      }
    } catch (e) {
      homeMLOdds = '';
    }

    // Spread
    String awaySpreadOdds = '';
    String homeSpreadOdds = '';
    try {
      double raw = double.parse(odds['oddstypes']['4']['hcp']['value']);
      if (raw > 0) {
        spread = '+${raw.toStringAsFixed(1)}';
      } else {
        spread = raw.toStringAsFixed(1);
      }
    } catch (e) {
      spread = '';
    }
    try {
      int raw =
          decimalToMoneyline(double.parse(odds['oddstypes']['4']['outcomes']['2']['odds']));
      if (raw > 0) {
        homeSpreadOdds = '+${raw.toString()}';
      } else {
        homeSpreadOdds = raw.toString();
      }
    } catch (e) {
      homeSpreadOdds = '';
    }
    try {
      int raw =
          decimalToMoneyline(double.parse(odds['oddstypes']['4']['outcomes']['4']['odds']));
      if (raw > 0) {
        awaySpreadOdds = '+${raw.toString()}';
      } else {
        awaySpreadOdds = raw.toString();
      }
    } catch (e) {
      awaySpreadOdds = '';
    }

    // Over/Under
    String overOdds = '';
    String underOdds = '';
    try {
      double raw = double.parse(odds['oddstypes']['3']['hcp']['value']);
      overUnder = raw.toStringAsFixed(1);
    } catch (e) {
      overUnder = '';
    }
    try {
      int raw =
          decimalToMoneyline(double.parse(odds['oddstypes']['3']['outcomes']['2']['odds']));
      if (raw > 0) {
        overOdds = '+${raw.toString()}';
      } else {
        overOdds = raw.toString();
      }
    } catch (e) {
      overOdds = '';
    }
    try {
      int raw =
          decimalToMoneyline(double.parse(odds['oddstypes']['3']['outcomes']['3']['odds']));
      if (raw > 0) {
        underOdds = '+${raw.toString()}';
      } else {
        underOdds = raw.toString();
      }
    } catch (e) {
      underOdds = '';
    }

    odds = {
      'MONEYLINE': {'VALUE': '', 'ODDS1': awayMLOdds, 'ODDS2': homeMLOdds},
      'SPREAD': {'VALUE': spread, 'ODDS1': awaySpreadOdds, 'ODDS2': homeSpreadOdds},
      'TOTAL': {'VALUE': overUnder, 'ODDS1': overOdds, 'ODDS2': underOdds},
    };

    return odds;
  }

  @override
  void initState() {
    super.initState();
    fanDuel = setOdds('18186');
    draftKings = setOdds('18149');
    mgm = setOdds('17324');
    bet365 = setOdds('28901');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          OddsCard(
            fanDuel: fanDuel,
            draftKings: draftKings,
            mgm: mgm,
            bet365: bet365,
            betType: 'SPREAD',
          ),
          OddsCard(
            fanDuel: fanDuel,
            draftKings: draftKings,
            mgm: mgm,
            bet365: bet365,
            betType: 'MONEYLINE',
          ),
          OddsCard(
            fanDuel: fanDuel,
            draftKings: draftKings,
            mgm: mgm,
            bet365: bet365,
            betType: 'TOTAL',
          ),
        ],
      ),
    );
  }
}

class OddsCard extends StatelessWidget {
  const OddsCard(
      {super.key,
      required this.fanDuel,
      required this.draftKings,
      required this.mgm,
      required this.bet365,
      required this.betType});

  final Map<String, dynamic> fanDuel;
  final Map<String, dynamic> draftKings;
  final Map<String, dynamic> mgm;
  final Map<String, dynamic> bet365;
  final String betType;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 11.0.r),
      color: Colors.grey.shade900,
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
                betType,
                style: kBebasBold.copyWith(fontSize: 18.0.r),
              ),
            ),
            SizedBox(height: 10.0.r),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        fanDuel[betType]['VALUE'],
                        textAlign: TextAlign.center,
                        style: kBebasNormal,
                      ),
                      Text(
                        betType == 'MONEYLINE' || fanDuel[betType]['ODDS1'] == ''
                            ? fanDuel[betType]['ODDS1']
                            : '  (${fanDuel[betType]['ODDS1']})',
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                            fontSize: betType == 'MONEYLINE' ? 20.0.r : 18.0.r,
                            color:
                                betType == 'MONEYLINE' ? Colors.white : Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 120.0.r, maxHeight: 40.0.r),
                    child: Image.asset(
                      'images/books/fanduel.png',
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        betType == 'SPREAD'
                            ? fanDuel[betType]['VALUE'].substring(0, 1) == '+'
                                ? '-${fanDuel[betType]['VALUE'].substring(1)}'
                                : '+${fanDuel[betType]['VALUE'].substring(1)}'
                            : fanDuel[betType]['VALUE'],
                        textAlign: TextAlign.center,
                        style: kBebasNormal,
                      ),
                      Text(
                        betType == 'MONEYLINE' || fanDuel[betType]['ODDS2'] == ''
                            ? fanDuel[betType]['ODDS2']
                            : '  (${fanDuel[betType]['ODDS2']})',
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                            fontSize: betType == 'MONEYLINE' ? 20.0.r : 18.0.r,
                            color:
                                betType == 'MONEYLINE' ? Colors.white : Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.0.r),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        draftKings[betType]['VALUE'],
                        textAlign: TextAlign.center,
                        style: kBebasNormal,
                      ),
                      Text(
                        betType == 'MONEYLINE' || draftKings[betType]['ODDS1'] == ''
                            ? draftKings[betType]['ODDS1']
                            : '  (${draftKings[betType]['ODDS1']})',
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                            fontSize: betType == 'MONEYLINE' ? 20.0.r : 18.0.r,
                            color:
                                betType == 'MONEYLINE' ? Colors.white : Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 120.0.r, maxHeight: 30.0.r),
                    child: Image.asset(
                      'images/books/draftkings.png',
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        betType == 'SPREAD'
                            ? draftKings[betType]['VALUE'].substring(0, 1) == '+'
                                ? '-${draftKings[betType]['VALUE'].substring(1)}'
                                : '+${draftKings[betType]['VALUE'].substring(1)}'
                            : draftKings[betType]['VALUE'],
                        textAlign: TextAlign.center,
                        style: kBebasNormal,
                      ),
                      Text(
                        betType == 'MONEYLINE' || draftKings[betType]['ODDS2'] == ''
                            ? draftKings[betType]['ODDS2']
                            : '  (${draftKings[betType]['ODDS2']})',
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                            fontSize: betType == 'MONEYLINE' ? 20.0.r : 18.0.r,
                            color:
                                betType == 'MONEYLINE' ? Colors.white : Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.0.r),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mgm[betType]['VALUE'],
                        textAlign: TextAlign.center,
                        style: kBebasNormal,
                      ),
                      Text(
                        betType == 'MONEYLINE' || mgm[betType]['ODDS1'] == ''
                            ? mgm[betType]['ODDS1']
                            : '  (${mgm[betType]['ODDS1']})',
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                            fontSize: betType == 'MONEYLINE' ? 20.0.r : 18.0.r,
                            color:
                                betType == 'MONEYLINE' ? Colors.white : Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 120.0.r, maxHeight: 25.0.r),
                    child: Image.asset(
                      'images/books/mgm.png',
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        betType == 'SPREAD'
                            ? mgm[betType]['VALUE'].substring(0, 1) == '+'
                                ? '-${mgm[betType]['VALUE'].substring(1)}'
                                : '+${mgm[betType]['VALUE'].substring(1)}'
                            : mgm[betType]['VALUE'],
                        textAlign: TextAlign.center,
                        style: kBebasNormal,
                      ),
                      Text(
                        betType == 'MONEYLINE' || mgm[betType]['ODDS2'] == ''
                            ? mgm[betType]['ODDS2']
                            : '  (${mgm[betType]['ODDS2']})',
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                            fontSize: betType == 'MONEYLINE' ? 20.0.r : 18.0.r,
                            color:
                                betType == 'MONEYLINE' ? Colors.white : Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30.0.r),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        bet365[betType]['VALUE'],
                        textAlign: TextAlign.center,
                        style: kBebasNormal,
                      ),
                      Text(
                        betType == 'MONEYLINE' || bet365[betType]['ODDS1'] == ''
                            ? bet365[betType]['ODDS1']
                            : '  (${bet365[betType]['ODDS1']})',
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                            fontSize: betType == 'MONEYLINE' ? 20.0.r : 18.0.r,
                            color:
                                betType == 'MONEYLINE' ? Colors.white : Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 120.0.r, maxHeight: 40.0.r),
                    child: Image.asset(
                      'images/books/bet365.png',
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        betType == 'SPREAD'
                            ? bet365[betType]['VALUE'].substring(0, 1) == '+'
                                ? '-${bet365[betType]['VALUE'].substring(1)}'
                                : '+${bet365[betType]['VALUE'].substring(1)}'
                            : bet365[betType]['VALUE'],
                        textAlign: TextAlign.center,
                        style: kBebasNormal,
                      ),
                      Text(
                        betType == 'MONEYLINE' || bet365[betType]['ODDS2'] == ''
                            ? bet365[betType]['ODDS2']
                            : '  (${bet365[betType]['ODDS2']})',
                        textAlign: TextAlign.center,
                        style: kBebasNormal.copyWith(
                            fontSize: betType == 'MONEYLINE' ? 20.0.r : 18.0.r,
                            color:
                                betType == 'MONEYLINE' ? Colors.white : Colors.grey.shade400),
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
  }
}
