import 'package:flutter/material.dart';
import 'package:splash/components/custom_icon_button.dart';
import 'package:splash/utilities/constants.dart';

import '../screens/search_screen.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final AppBar appBar = AppBar();
  final Widget? title;
  final Color? color;
  final Widget? flexWidget;
  final TabBar? tabs;

  BaseAppBar({super.key, this.title, this.color, this.flexWidget, this.tabs});

  Future<void> _showYearPicker(BuildContext context) async {
    int selectedYear = DateTime.now().year;
    await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            'Season',
            style: kBebasBold.copyWith(fontSize: 18.0),
          ),
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Colors.deepOrange, // Selected item color
                  onPrimary: Colors.white, // Selected item text color
                  onSurface: Colors.white, // Unselected item text color
                ),
              ),
              child: YearPicker(
                firstDate: DateTime(1981),
                lastDate: DateTime.now(),
                selectedDate: DateTime(selectedYear),
                onChanged: (DateTime dateTime) {
                  Navigator.pop(context, dateTime.year);
                  selectedYear = dateTime.year;
                },
              ),
            ),
          ),
        );
      },
    );
    // Do something with the selected year
    print('Selected year: $selectedYear');
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: color ?? Colors.grey.shade900,
      surfaceTintColor: Colors.grey.shade900,
      title: title ?? kSplashText,
      flexibleSpace: flexWidget,
      bottom: tabs,
      actions: [
        CustomIconButton(
          icon: Icons.search,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(),
              ),
            );
          },
        ),
        CustomIconButton(
          icon: Icons.calendar_month,
          onPressed: () {
            _showYearPicker(context);
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(appBar.preferredSize.height);
}
