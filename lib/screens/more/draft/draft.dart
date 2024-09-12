import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/screens/more/draft/draftRound.dart';
import 'package:splash/screens/more/draft/draft_network_helper.dart';
import 'package:splash/utilities/constants.dart';

import '../../../components/custom_icon_button.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import '../../search_screen.dart';
import 'draft_cache.dart';

class Draft extends StatefulWidget {
  const Draft({super.key});

  @override
  State<Draft> createState() => _DraftState();
}

class _DraftState extends State<Draft> {
  late List<dynamic> draft;
  List<dynamic> firstRound = [];
  List<dynamic> secondRound = [];
  List<dynamic> thirdRound = [];
  List<dynamic> fourthRound = [];
  List<dynamic> fifthRound = [];
  List<dynamic> sixthRound = [];
  List<dynamic> seventhRound = [];
  List<dynamic> eighthRound = [];
  List<dynamic> ninthRound = [];
  List<dynamic> tenthRound = [];
  bool _isLoading = true;
  late String selectedSeason;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;

  List<String> seasons = [
    '2024-25',
    '2023-24',
    '2022-23',
    '2021-22',
    '2020-21',
    '2019-20',
    '2018-19',
    '2017-18',
    '2016-17',
    '2015-16',
    '2014-15',
    '2013-14',
    '2012-13',
    '2011-12',
    '2010-11',
    '2009-10',
    '2008-09',
    '2007-08',
    '2006-07',
    '2005-06',
    '2004-05',
    '2003-04',
    '2002-03',
    '2001-02',
    '2000-01',
    '1999-00',
    '1998-99',
    '1997-98',
    '1996-97',
    '1995-96',
    '1994-95',
    '1993-94',
    '1992-93',
    '1991-92',
    '1990-91',
    '1989-90',
    '1988-89',
    '1987-88',
    '1986-87',
    '1985-86',
    '1984-85',
    '1983-84',
    '1982-83',
    '1981-82',
    '1980-81',
  ];

  Future<void> getDraft(String draftYear) async {
    final draftCache = Provider.of<DraftCache>(context, listen: false);
    if (draftCache.containsDraft(draftYear)) {
      setState(() {
        draft = draftCache.getDraft(draftYear)!;
        setPicks();
        _isLoading = false;
      });
    } else {
      var fetchedDraft = await DraftNetworkHelper().getDraft(draftYear);
      setState(() {
        draft = fetchedDraft;
        setPicks();
        _isLoading = false;
      });
      draftCache.addDraft(draftYear, draft);
    }
  }

  void setPicks() {
    setState(() {
      firstRound = draft.where((d) => d['ROUND_NUMBER'] == 1).toList();
      secondRound = draft.where((d) => d['ROUND_NUMBER'] == 2).toList();

      // 7 rounds from 1985-86 to 1988-89
      if (int.parse(selectedSeason.substring(0, 4)) < 1989) {
        thirdRound = draft.where((d) => d['ROUND_NUMBER'] == 3).toList();
        fourthRound = draft.where((d) => d['ROUND_NUMBER'] == 4).toList();
        fifthRound = draft.where((d) => d['ROUND_NUMBER'] == 5).toList();
        sixthRound = draft.where((d) => d['ROUND_NUMBER'] == 6).toList();
        seventhRound = draft.where((d) => d['ROUND_NUMBER'] == 7).toList();
      }

      // 7 rounds from 1973-74 to 1984-85
      if (int.parse(selectedSeason.substring(0, 4)) < 1985) {
        eighthRound = draft.where((d) => d['ROUND_NUMBER'] == 8).toList();
        ninthRound = draft.where((d) => d['ROUND_NUMBER'] == 9).toList();
        tenthRound = draft.where((d) => d['ROUND_NUMBER'] == 10).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    selectedSeason = seasons.first;
    getDraft(selectedSeason.substring(0, 4));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _scrollController = ScrollController();
    _notifier.addController('draft', _scrollController);
  }

  @override
  void dispose() {
    _notifier.removeController('draft');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const SpinningIcon()
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.grey.shade900,
              surfaceTintColor: Colors.grey.shade900,
              title: Text(
                'Draft History',
                style: kBebasBold.copyWith(fontSize: 24.0),
              ),
              actions: [
                Container(
                  decoration: BoxDecoration(
                      color: Colors.grey.shade900,
                      border: Border.all(color: Colors.deepOrange),
                      borderRadius: BorderRadius.circular(10.0)),
                  margin: const EdgeInsets.fromLTRB(0.0, 11.0, 0.0, 11.0),
                  child: DropdownButton<String>(
                    menuMaxHeight: 300.0,
                    isExpanded: false,
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    borderRadius: BorderRadius.circular(10.0),
                    underline: Container(),
                    dropdownColor: Colors.grey.shade900,
                    value: selectedSeason.substring(0, 4),
                    items: seasons.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value.substring(0, 4),
                        child: Text(
                          value.substring(0, 4),
                          style: kBebasNormal,
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) async {
                      setState(() {
                        selectedSeason = newValue!.substring(0, 4);
                        _scrollController.jumpTo(0);
                      });
                      getDraft(selectedSeason);
                    },
                  ),
                ),
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
              ],
            ),
            body: CustomScrollView(
              controller: _scrollController,
              slivers: [
                DraftRound(round: firstRound, roundNum: '1'),
                DraftRound(round: secondRound, roundNum: '2'),
                if (thirdRound.isNotEmpty) DraftRound(round: thirdRound, roundNum: '3'),
                if (fourthRound.isNotEmpty) DraftRound(round: fourthRound, roundNum: '4'),
                if (fifthRound.isNotEmpty) DraftRound(round: fifthRound, roundNum: '5'),
                if (sixthRound.isNotEmpty) DraftRound(round: sixthRound, roundNum: '6'),
                if (seventhRound.isNotEmpty) DraftRound(round: seventhRound, roundNum: '7'),
                if (eighthRound.isNotEmpty) DraftRound(round: eighthRound, roundNum: '8'),
                if (ninthRound.isNotEmpty) DraftRound(round: ninthRound, roundNum: '9'),
                if (tenthRound.isNotEmpty) DraftRound(round: tenthRound, roundNum: '10'),
              ],
            ),
          );
  }
}
