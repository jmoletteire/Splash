import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:splash/utilities/constants.dart';

class MyDropdownSearch extends StatefulWidget {
  final ValueChanged<String> onChanged;

  MyDropdownSearch({required this.onChanged});

  @override
  _MyDropdownSearchState createState() => _MyDropdownSearchState();
}

class _MyDropdownSearchState extends State<MyDropdownSearch> {
  String _field = '';
  final ValueNotifier<String?> _selectedItemNotifier =
      ValueNotifier<String?>(null);

  Map<String, List<String>> categorizedFields = {
    "Efficiency": kPlayerStatLabelMap['EFFICIENCY']
        .keys
        .where((key) => !key.contains("fill"))
        .toList(),
    "Scoring": kPlayerStatLabelMap['SCORING']
        .keys
        .where((key) => !key.contains("fill"))
        .toList(),
    "Shot Type": kPlayerStatLabelMap['SHOT TYPE']
        .keys
        .where((key) => !key.contains("fill"))
        .toList(),
    'Closest Defender': kPlayerStatLabelMap['CLOSEST DEFENDER']
        .keys
        .where((key) => !key.contains("fill"))
        .toList(),
    "Rebounding": kPlayerStatLabelMap['REBOUNDING']
        .keys
        .where((key) => !key.contains("fill"))
        .toList(),
    "Passing": kPlayerStatLabelMap['PASSING']
        .keys
        .where((key) => !key.contains("fill"))
        .toList(),
    "Defense": kPlayerStatLabelMap['DEFENSE']
        .keys
        .where((key) => !key.contains("fill"))
        .toList(),
    "Hustle": kPlayerStatLabelMap['HUSTLE']
        .keys
        .where((key) => !key.contains("fill"))
        .toList(),
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
        dialogProps: const DialogProps(backgroundColor: Color(0xFF121212)),
        containerBuilder: (context, dialogState) {
          return Dialog(
            backgroundColor: const Color(0xFF121212),
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
                              widget.onChanged(item);
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
          widget.onChanged(selectedItem!);
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
