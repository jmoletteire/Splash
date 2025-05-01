import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/utilities/constants.dart';

import 'column_options.dart';

class CustomBottomSheet extends StatefulWidget {
  final List<ColumnOption> selectedColumns;
  final Function(List<ColumnOption>) updateSelectedColumns;

  const CustomBottomSheet({
    super.key,
    required this.selectedColumns,
    required this.updateSelectedColumns,
  });

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  late List<ColumnOption> tempSelectedColumns;

  @override
  void initState() {
    super.initState();
    tempSelectedColumns = List.from(widget.selectedColumns);
  }

  void _updateSelection(bool? value, ColumnOption col) {
    setState(() {
      if (value == true) {
        tempSelectedColumns.add(col);
      } else {
        tempSelectedColumns.remove(col);
      }
      tempSelectedColumns
          .sort((a, b) => a.getIndex(kAllColumns).compareTo(b.getIndex(kAllColumns)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75, // Adjust height as needed
      decoration: const BoxDecoration(
        color: Color(0xFF111111),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 8.0.r), // Move the handle closer to the top
          Container(
            width: 50.0.r,
            height: 5.0.r,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          SizedBox(height: 12.0.r), // Space after the handle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select Columns',
                  style: kBebasBold.copyWith(
                    fontSize: 20.0.r,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        tempSelectedColumns.length == kAllColumns.length
                            ? setState(() {
                                tempSelectedColumns = List.from(kAllColumns.sublist(0, 4));
                              })
                            : setState(() {
                                tempSelectedColumns = List.from(kAllColumns);
                              });
                      },
                      child: Text(
                        tempSelectedColumns.length == kAllColumns.length
                            ? 'DESELECT ALL'
                            : 'SELECT ALL',
                        style: kBebasNormal.copyWith(
                          fontSize: 18.0.r,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.updateSelectedColumns(tempSelectedColumns);
                        Navigator.pop(context);
                      },
                      child: Text(
                        'DONE',
                        style: kBebasNormal.copyWith(
                          fontSize: 18.0.r,
                          color: Colors.deepOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 8.0.r),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade800),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: kAllColumns.sublist(4).map((col) {
                return CheckboxListTile(
                  shape: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade700,
                      width: 0.5,
                    ),
                  ),
                  title: Text(
                    col.selectorName,
                    style: kBebasNormal.copyWith(fontSize: 18.0.r),
                  ),
                  value: tempSelectedColumns.contains(col),
                  activeColor: Colors.deepOrange,
                  checkColor: Colors.black,
                  onChanged: (bool? value) {
                    _updateSelection(value, col);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
