import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

class MyDropdownSearch extends StatefulWidget {
  @override
  _MyDropdownSearchState createState() => _MyDropdownSearchState();
}

class _MyDropdownSearchState extends State<MyDropdownSearch> {
  String _field = '';
  final ValueNotifier<String?> _selectedItemNotifier =
      ValueNotifier<String?>(null);

  Map<String, List<String>> categorizedFields = {
    "Efficiency": [
      "GP",
      "MIN",
      "MPG",
      "POSS",
      "POSS PER GM",
      "PACE",
      "ORTG",
      "DRTG",
      "NRTG",
      "USAGE",
      "TOUCHES",
      "PTS PER TOUCH",
      "SEC PER TOUCH",
      "DRIB PER TOUCH",
      "% SHOOT",
      "% PASS",
      "% TOV",
      "% FOULED",
    ],
    "Scoring": [
      "PTS",
      "eFG%",
      "TS%",
      "FGM",
      "FGA",
      "FG%",
      "3PM",
      "3PA",
      "3PA Rate",
      "3P%",
      "FTM",
      "FTA",
      "FT%",
      "FTA Rate",
    ],
    "Shot Type": [
      "C&S Freq",
      "Pull Up Freq",
      "< 10ft Freq",
      "C&S FG%",
      "Pull Up FG%",
      "< 10ft FG%",
      "C&S 3P%",
      "Pull Up 3P%",
      "C&S eFG%",
      "Pull Up eFG%",
    ],
    'Closest Defender': [
      'Very Tight FREQ',
      'Very Tight FG%',
      'Very Tight 3P%',
      'Very Tight eFG%',
      'Tight FREQ',
      'Tight FG%',
      'Tight 3P%',
      'Tight eFG%',
      'Open FREQ',
      'Open FG%',
      'Open 3P%',
      'Open eFG%',
      'Wide Open FREQ',
      'Wide Open FG%',
      'Wide Open 3P%',
      'Wide Open eFG%'
    ],
    "Rebounding": [
      "REB",
      "OREB",
      "DREB",
      "OREB%",
      "DREB%",
      "BOX OUTS",
      "OFF BOX OUTS",
      "DEF BOX OUTS",
    ],
    "Passing": [
      "AST",
      "2nd AST",
      "FT AST",
      "ADJ AST",
      "POTENTIAL AST",
      "AST PTS",
      "AST%",
      "AST-PASS %",
      "ADJ AST-PASS %"
    ],
    "Defense": [
      "DRTG - ON",
      "STL",
      "DFLCT",
      "BLK",
      "CNTST",
    ],
    "Hustle": [
      "SCREEN AST",
      "SCREEN AST PTS",
      "CHARGES DRAWN",
      "FOULS",
      "FOULS DRAWN"
    ]
  };

  @override
  void initState() {
    super.initState();
    _selectedItemNotifier.addListener(() {
      if (_selectedItemNotifier.value != null) {
        (context as Element).markNeedsBuild();
      }
    });
  }

  @override
  void dispose() {
    _selectedItemNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      items: categorizedFields.values.expand((list) => list).toList(),
      popupProps: PopupProps.dialog(
        fit: FlexFit.loose,
        dialogProps: DialogProps(backgroundColor: Color(0xFF121212)),
        containerBuilder: (context, dialogState) {
          return Dialog(
            backgroundColor: Color(0xFF121212),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categorizedFields.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        entry.key,
                        style: kBebasNormal.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      GridView.count(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: entry.value.map((item) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                _field = item;
                              });
                              _selectedItemNotifier.value = item;
                              Navigator.pop(context, item);
                            },
                            child: GridTile(
                              child: Container(
                                margin: const EdgeInsets.all(5.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5.0, vertical: 0.0),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    border:
                                        Border.all(color: Colors.deepOrange),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Center(
                                  child: AutoSizeText(
                                    item,
                                    textAlign: TextAlign.center,
                                    style: kBebasOffWhite.copyWith(
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      onChanged: (String? selectedItem) {
        setState(() {
          _field = selectedItem ?? '';
        });
      },
      dropdownBuilder: (context, selectedItem) {
        return AutoSizeText(
          selectedItem ?? "ADD STAT",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: kBebasNormal.copyWith(
            color: selectedItem == null ? Colors.white70 : Colors.white,
            fontSize: 16.5,
          ),
        );
      },
      selectedItem: _field.isEmpty ? null : _field,
    );
  }
}
