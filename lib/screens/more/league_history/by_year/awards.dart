import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:material_table_view/material_table_view.dart';
import 'package:material_table_view/sliver_table_view.dart';
import 'package:material_table_view/table_view_typedefs.dart';

import '../../../../components/player_avatar.dart';
import '../../../../utilities/constants.dart';
import '../../../player/player_home.dart';

class Awards extends StatefulWidget {
  final List<dynamic> awards;

  const Awards({
    super.key,
    required this.awards,
  });

  @override
  State<Awards> createState() => _AwardsState();
}

class _AwardsState extends State<Awards> {
  List columnNames = [
    'AWARD',
    'TEAM',
    'NAME',
  ];

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return SliverTableView.builder(
      style: const TableViewStyle(
        dividers: TableViewDividersStyle(
          vertical: TableViewVerticalDividersStyle.symmetric(
            TableViewVerticalDividerStyle(wigglesPerRow: 0),
          ),
        ),
        scrollbars: TableViewScrollbarsStyle.symmetric(
          TableViewScrollbarStyle(
            scrollPadding: false,
            enabled: TableViewScrollbarEnabled.never,
          ),
        ),
      ),
      headerHeight: MediaQuery.of(context).size.height * 0.045,
      rowCount: widget.awards.length,
      rowHeight: MediaQuery.of(context).size.height * 0.06,
      minScrollableWidth: MediaQuery.of(context).size.width * 0.01,
      columns: [
        /// AWARD
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.04
              : MediaQuery.of(context).size.width * 0.45,
          freezePriority: 1,
        ),

        /// TEAM
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.03
              : MediaQuery.of(context).size.width * 0.1,
          freezePriority: 1,
        ),

        /// NAME
        TableColumn(
          width: isLandscape
              ? MediaQuery.of(context).size.width * 0.4
              : MediaQuery.of(context).size.width * 0.45,
        ),
      ],
      rowBuilder: _rowBuilder,
      headerBuilder: _headerBuilder,
    );
  }

  Widget _headerBuilder(BuildContext context, TableRowContentBuilder contentBuilder) =>
      contentBuilder(
        context,
        (context, column) {
          return Material(
            color: Colors.grey.shade800,
            child: Padding(
              padding:
                  column == 0 ? EdgeInsets.only(left: 8.0.r) : EdgeInsets.only(right: 8.0.r),
              child: Align(
                alignment: column <= 2 ? Alignment.centerLeft : Alignment.centerRight,
                child: Text(
                  columnNames[column],
                  style: kBebasNormal.copyWith(
                    fontSize: 14.0.r,
                  ),
                ),
              ),
            ),
          );
        },
      );

  /// This is used to wrap both regular and placeholder rows to achieve fade
  /// transition between them and to insert optional row divider.
  Widget _wrapRow(int index, Widget child) => KeyedSubtree(
        key: ValueKey(index),
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 0.125,
              ),
            ),
          ),
          child: child,
        ),
      );

  Widget? _rowBuilder(BuildContext context, int row, TableRowContentBuilder contentBuilder) {
    if (widget.awards[row].key == 'YEAR') {
      return Container();
    }
    return _wrapRow(
      row,
      Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlayerHome(
                    playerId: widget.awards[row].value['PLAYERS'][0]['PLAYER_ID'].toString(),
                  ),
                ),
              );
            }
          },
          splashColor: Colors.white,
          highlightColor: Colors.white,
          child: contentBuilder(context, (context, column) {
            return Padding(
              padding: EdgeInsets.only(right: column == 2 ? 0.0 : 8.0),
              child: getContent(row, column, context),
            );
          }),
        ),
      ),
    );
  }

  Widget getContent(int row, int column, BuildContext context) {
    Map<String, String> awardMap = {
      'NBA Most Valuable Player': 'Most Valuable Player',
      'NBA Defensive Player of the Year': 'Defensive Player of the Year',
      'NBA Sixth Man of the Year': 'Sixth Man of the Year',
      'NBA Most Improved Player': 'Most Improved Player',
      'NBA Rookie of the Year': 'Rookie of the Year',
      'NBA Clutch Player of the Year': 'Clutch Player of the Year',
      'NBA All-Star Most Valuable Player': 'All-Star Game MVP',
      'NBA Finals Most Valuable Player': 'Finals MVP',
      'NBA In-Season Tournament Most Valuable Player': 'NBA Cup MVP',
      'NBA In-Season Tournament All-Tournament': 'All-NBA Cup Team',
      'NBA Player of the Month': 'Player of the Month',
      'NBA Rookie of the Month': 'Player of the Rookie',
      'NBA Player of the Week': 'Player of the Week',
    };

    Map<String, String> teamMap = {
      'Atlanta Hawks': '1610612737',
      'Boston Celtics': '1610612738',
      'Cleveland Cavaliers': '1610612739',
      'New Orleans Pelicans': '1610612740',
      'Chicago Bulls': '1610612741',
      'Dallas Mavericks': '1610612742',
      'Denver Nuggets': '1610612743',
      'Golden State Warriors': '1610612744',
      'Houston Rockets': '1610612745',
      'Los Angeles Clippers': '1610612746',
      'Los Angeles Lakers': '1610612747',
      'Miami Heat': '1610612748',
      'Milwaukee Bucks': '1610612749',
      'Minnesota Timberwolves': '1610612750',
      'Brooklyn Nets': '1610612751',
      'New York Knicks': '1610612752',
      'Orlando Magic': '1610612753',
      'Indiana Pacers': '1610612754',
      'Philadelphia 76ers': '1610612755',
      'Phoenix Suns': '1610612756',
      'Portland Trail Blazers': '1610612757',
      'Sacramento Kings': '1610612758',
      'San Antonio Spurs': '1610612759',
      'Oklahoma City Thunder': '1610612760',
      'Toronto Raptors': '1610612761',
      'Utah Jazz': '1610612762',
      'Memphis Grizzlies': '1610612763',
      'Washington Wizards': '1610612764',
      'Detroit Pistons': '1610612765',
      'Charlotte Hornets': '1610612766',
    };

    String teamId = teamMap[widget.awards[row].value['PLAYERS'][0]['TEAM']] ?? '0';

    String awardName = awardMap.containsKey(widget.awards[row].value['DESCRIPTION'] ?? '-')
        ? awardMap[widget.awards[row].value['DESCRIPTION']]
        : widget.awards[row].value['DESCRIPTION'] ?? '-';

    switch (column) {
      case 0:
        return Container(
          padding: EdgeInsets.only(left: 8.0.r),
          alignment: Alignment.centerLeft,
          child: AutoSizeText(
            awardName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: kBebasNormal.copyWith(color: Colors.grey.shade400, fontSize: 15.0.r),
          ),
        );
      case 1:
        return Row(
          children: [
            if (teamId == '0') const Spacer(flex: 1),
            Expanded(
              flex: 4,
              child: Image.asset('images/NBA_Logos/$teamId.png'),
            ),
            Spacer(flex: teamId == '0' ? 3 : 1)
          ],
        );
      case 2:
        if (widget.awards[row].value['DESCRIPTION'] == 'NBA Champion') {
          return Container(
            padding: EdgeInsets.only(left: 8.0.r),
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              widget.awards[row].value['PLAYERS'][0]['TEAM'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: kBebasNormal.copyWith(fontSize: 17.5.r),
            ),
          );
        } else {
          return Padding(
            padding: EdgeInsets.fromLTRB(6.0.r, 8.0.r, 0.0, 8.0.r),
            child: Row(
              children: [
                PlayerAvatar(
                  radius: 12.0.r,
                  backgroundColor: Colors.white70,
                  playerImageUrl:
                      'https://cdn.nba.com/headshots/nba/latest/1040x760/${widget.awards[row].value['PLAYERS'][0]['PLAYER_ID']}.png',
                  //'https://www.basketball-reference.com/req/202106291/images/headshots/$lastSub${firstName.substring(0, 2).toLowerCase()}01.jpg'
                ),
                SizedBox(width: 8.0.r),
                Expanded(
                  flex: 7,
                  child: AutoSizeText(
                    '${widget.awards[row].value['PLAYERS'][0]['FIRST_NAME'] ?? ''} ${widget.awards[row].value['PLAYERS'][0]['LAST_NAME'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: kBebasNormal.copyWith(fontSize: 15.0.r),
                  ),
                ),
              ],
            ),
          );
        }
      default:
        return const Text('-');
    }
  }
}

class StandingsDataText extends StatelessWidget {
  const StandingsDataText(
      {super.key, required this.text, this.alignment, this.size, this.color});

  final Alignment? alignment;
  final double? size;
  final Color? color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment ?? Alignment.centerRight,
      child: Text(
        text,
        textAlign: TextAlign.end,
        style: kBebasNormal.copyWith(fontSize: size ?? 16.0.r, color: color),
      ),
    );
  }
}
