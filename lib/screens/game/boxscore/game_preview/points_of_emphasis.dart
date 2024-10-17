import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utilities/constants.dart';

class PointsOfEmphasis extends StatelessWidget {
  final String points;
  const PointsOfEmphasis({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Card(
        margin: EdgeInsets.fromLTRB(11.0.r, 0.0.r, 11.0.r, 11.0.r),
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
                  'Points of Emphasis',
                  style: kBebasBold.copyWith(fontSize: 16.0.r),
                ),
              ),
              SizedBox(height: 10.0.r),
              MarkdownBody(
                data: points,
                styleSheet: MarkdownStyleSheet(
                  h1: TextStyle(
                      fontFamily: 'Roboto', fontSize: 16.0.r, fontWeight: FontWeight.bold),
                  p: TextStyle(fontFamily: 'Roboto', letterSpacing: -1, fontSize: 16.0.r),
                  strong: TextStyle(
                      fontFamily: 'Roboto', letterSpacing: -1, fontWeight: FontWeight.bold),
                ),
                //style: kBebasNormal.copyWith(fontSize: 14.0.r),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
