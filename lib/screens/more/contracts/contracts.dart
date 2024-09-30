import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../components/custom_icon_button.dart';
import '../../../components/spinning_ball_loading.dart';
import '../../../utilities/constants.dart';
import '../../../utilities/scroll/scroll_controller_notifier.dart';
import '../../../utilities/scroll/scroll_controller_provider.dart';
import '../../search_screen.dart';

class Contracts extends StatefulWidget {
  const Contracts({super.key});

  @override
  State<Contracts> createState() => _ContractsState();
}

class _ContractsState extends State<Contracts> with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  late ScrollControllerNotifier _notifier;
  bool _isLoading = false;

  /// ******************************************************
  ///                 Initialize page
  ///        --> Tab Controller length = # of Tabs
  /// ******************************************************

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notifier = ScrollControllerProvider.of(context)!.notifier;
    _notifier.addController('player', _scrollController);
  }

  /// ******************************************************
  ///    Dispose of Controllers with page to conserve
  ///    memory & improve performance.
  /// ******************************************************

  @override
  void dispose() {
    _tabController.dispose();
    _notifier.removeController('player');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Scaffold(
      body: _isLoading
          ? Center(child: SpinningIcon())
          : ExtendedNestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: Colors.grey.shade900,
                    surfaceTintColor: Colors.grey.shade900,
                    pinned: true,
                    expandedHeight: MediaQuery.of(context).size.height * 0.28,
                    title: Text(
                      'Contracts',
                      style: kBebasBold.copyWith(fontSize: 24.0.r),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                    ),
                    bottom: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicatorColor: Colors.deepOrange,
                        indicatorWeight: 3.0,
                        unselectedLabelColor: Colors.grey,
                        labelColor: Colors.white,
                        labelStyle: kBebasNormal.copyWith(fontSize: 19.0.r),
                        isScrollable: false,
                        //tabAlignment: TabAlignment.start,
                        tabs: const [
                          Tab(text: 'Teams'),
                          Tab(text: 'Players'),
                          Tab(text: 'Free Agents'),
                        ]),
                    actions: [
                      CustomIconButton(
                        icon: Icons.search,
                        size: 30.0.r,
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
                ];
              },
              pinnedHeaderSliverHeightBuilder: () {
                return 104.0 + MediaQuery.of(context).padding.top; // 56 + 49 = 105
              },
              onlyOneScrollInBody: true,
              body: TabBarView(controller: _tabController, children: []),
            ),
    );
  }
}
