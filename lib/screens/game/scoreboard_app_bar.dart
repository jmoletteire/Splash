import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../components/custom_icon_button.dart';
import '../../utilities/constants.dart';

class ScoreboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController tabController;
  final List<DateTime> dates;
  final Function(int) onTabTap;
  final VoidCallback onSearchPressed;
  final VoidCallback onCalendarPressed;

  const ScoreboardAppBar({
    Key? key,
    required this.tabController,
    required this.dates,
    required this.onTabTap,
    required this.onSearchPressed,
    required this.onCalendarPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(116.48.r);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey.shade900,
      title: Text(
        'Splash',
        style: TextStyle(color: Colors.white, fontFamily: 'Bebas_Neue', fontSize: 32.0.r),
      ),
      actions: [
        CustomIconButton(
          icon: Icons.search,
          size: 30.0.r,
          onPressed: onSearchPressed,
        ),
        CustomIconButton(
          icon: Icons.calendar_month,
          size: 30.0.r,
          onPressed: onCalendarPressed,
        ),
      ],
      bottom: TabBar(
        controller: tabController,
        isScrollable: true,
        onTap: onTabTap,
        tabAlignment: TabAlignment.center,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 3.0,
        indicatorColor: Colors.deepOrange,
        unselectedLabelColor: Colors.white70,
        labelColor: Colors.deepOrangeAccent,
        labelStyle: kBebasNormal.copyWith(fontSize: 20.0.r),
        labelPadding: EdgeInsets.symmetric(horizontal: 20.0.r),
        tabs: dates.map((date) {
          return Tab(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormat('E').format(date)),
                Text('${DateFormat.d().format(date)} ${DateFormat.MMM().format(date)}'),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
