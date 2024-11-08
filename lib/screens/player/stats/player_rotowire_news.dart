import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:splash/utilities/constants.dart';

class PlayerRotowireNews extends StatefulWidget {
  final Map<String, dynamic> playerNews;
  final String teamAbbr;
  const PlayerRotowireNews({super.key, required this.playerNews, required this.teamAbbr});

  @override
  State<PlayerRotowireNews> createState() => _PlayerRotowireNewsState();
}

class _PlayerRotowireNewsState extends State<PlayerRotowireNews> {
  String timeAgo(String dateTimeString) {
    final inputFormat = DateFormat('MM/dd/yyyy HH:mm:ss');
    final DateTime givenDateTime = inputFormat.parse(dateTimeString);
    // Convert current time to GST (GMT+4)
    final DateTime now = DateTime.now().toUtc().add(const Duration(hours: 7));
    final Duration difference = now.difference(givenDateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 2) {
      return '${difference.inDays} day ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final String formattedDate = (givenDateTime.year == now.year)
          ? DateFormat('MMM d').format(givenDateTime)
          : DateFormat('MMM d, yyyy').format(givenDateTime);
      return formattedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(15.0.r),
      margin: EdgeInsets.fromLTRB(11.0.r, 0.0, 11.0.r, 11.0.r),
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: AutoSizeText(
                  '${widget.playerNews['FirstName']} ${widget.playerNews['LastName']} - ${widget.playerNews['ListItemCaption']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: kBebasBold,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.0.r),
          RichText(
              text: TextSpan(
            children: [
              TextSpan(
                text: widget.playerNews['ListItemShort'] ?? '',
                style: TextStyle(
                  color: const Color(0xFFEEEEEE),
                  letterSpacing: -0.8,
                  fontSize: 13.0.r,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          )),
          SizedBox(height: 5.0.r),
          Row(
            children: [
              SvgPicture.asset(
                'images/rotowire.svg',
                height: 17.0.r,
                width: 20.0.r,
              ),
              SizedBox(width: 5.0.r),
              Text(
                timeAgo(widget.playerNews['ListItemPubDate']),
                style: kBebasNormal.copyWith(fontSize: 11.0.r, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 8.0.r),
          Stack(
            children: [
              // Colored bar extending to the height of RichText
              Positioned.fill(
                left: 0, // Position the bar on the left side
                child: Row(
                  children: [
                    Container(
                      width: 3.0.r, // Width of the colored bar
                      color: kTeamColors.containsKey(widget.teamAbbr)
                          ? kDarkPrimaryColors.contains(widget.teamAbbr)
                              ? kTeamColors[widget.teamAbbr]!['secondaryColor']
                              : kTeamColors[widget.teamAbbr]!['primaryColor']
                          : Colors.blue,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0.r), // Space between bar and RichText
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Analysis: ',
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: -0.8,
                          fontSize: 12.0.r,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: widget.playerNews['ListItemDescription'],
                        style: TextStyle(
                          color: const Color(0xFFCCCCCC),
                          letterSpacing: -0.8,
                          fontSize: 12.0.r,
                          fontFamily: 'Roboto',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
