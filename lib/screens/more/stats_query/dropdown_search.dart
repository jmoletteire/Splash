import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/utilities/constants.dart';

class MyDropdownSearch extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueNotifier<String?> selectedItemNotifier;

  MyDropdownSearch({
    required this.onChanged,
    required this.onLocationChanged,
    required this.selectedItemNotifier,
  });

  @override
  _MyDropdownSearchState createState() => _MyDropdownSearchState();
}

class _MyDropdownSearchState extends State<MyDropdownSearch> {
  Map<String, List<String>> categorizedFields = {
    "Efficiency":
        kPlayerStatLabelMap['EFFICIENCY'].keys.where((key) => !key.contains("fill")).toList(),
    "Scoring":
        kPlayerStatLabelMap['SCORING'].keys.where((key) => !key.contains("fill")).toList(),
    "Shot Type":
        kPlayerStatLabelMap['SHOT TYPE'].keys.where((key) => !key.contains("fill")).toList(),
    'Closest Defender': kPlayerStatLabelMap['CLOSEST DEFENDER']
        .keys
        .where((key) => !key.contains("fill"))
        .toList(),
    'Drives':
        kPlayerStatLabelMap['DRIVES'].keys.where((key) => !key.contains("fill")).toList(),
    "Rebounding":
        kPlayerStatLabelMap['REBOUNDING'].keys.where((key) => !key.contains("fill")).toList(),
    "Passing":
        kPlayerStatLabelMap['PLAYMAKING'].keys.where((key) => !key.contains("fill")).toList(),
    "Defense":
        kPlayerStatLabelMap['DEFENSE'].keys.where((key) => !key.contains("fill")).toList(),
    "Hustle":
        kPlayerStatLabelMap['HUSTLE'].keys.where((key) => !key.contains("fill")).toList(),
  };

  @override
  void initState() {
    super.initState();
    widget.selectedItemNotifier.addListener(() {
      if (widget.selectedItemNotifier.value != null) {
        (context as Element).markNeedsBuild();
      }
    });
  }

  @override
  void dispose() {
    widget.selectedItemNotifier.dispose();
    super.dispose();
  }

  String _getLocation(String field) {
    for (var category in kPlayerStatLabelMap.entries) {
      if (category.value.containsKey(field)) {
        List<dynamic> locations = category.value[field]['location'];
        String loc = locations.join('.');
        loc += '.${category.value[field]['TOTAL']['nba_name']}';
        return loc;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return DropdownSearch<String>(
      items: (f, cs) => categorizedFields.values.expand((list) => list).toList(),
      popupProps: PopupProps.dialog(
        fit: FlexFit.loose,
        dialogProps: const DialogProps(backgroundColor: Color(0xFF121212)),
        containerBuilder: (context, dialogState) {
          return Dialog(
            backgroundColor: const Color(0xFF121212),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(10.0.r),
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
                          fontSize: 18.0.r,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      SizedBox(height: 8.0.r),
                      GridView.count(
                        padding: EdgeInsets.only(bottom: 10.0.r),
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // Disable GridView scrolling
                        crossAxisCount: 3.0.r.ceil(),
                        mainAxisSpacing: 10.0.r,
                        crossAxisSpacing: 10.0.r,
                        children: entry.value.map((item) {
                          return InkWell(
                            onTap: () {
                              widget.selectedItemNotifier.value = item;
                              widget.onChanged(item);
                              widget.onLocationChanged(_getLocation(item) ?? '');
                              Navigator.pop(context, item);
                            },
                            child: GridTile(
                              child: Container(
                                margin: EdgeInsets.all(5.0.r),
                                padding:
                                    EdgeInsets.symmetric(horizontal: 5.0.r, vertical: 0.0.r),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade900,
                                    border: Border.all(color: Colors.deepOrange),
                                    borderRadius: BorderRadius.circular(10.0)),
                                child: Center(
                                  child: AutoSizeText(
                                    item,
                                    textAlign: TextAlign.center,
                                    style: kBebasOffWhite.copyWith(
                                      fontSize: 12.0.r,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 30.0.r),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
      onChanged: (String? selectedItem) {
        widget.selectedItemNotifier.value = selectedItem;
        widget.onChanged(selectedItem!);
        widget.onLocationChanged(_getLocation(selectedItem) ?? '');
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
      selectedItem: widget.selectedItemNotifier.value,
    );
  }
}
