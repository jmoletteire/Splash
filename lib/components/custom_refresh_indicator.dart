import 'package:flutter/material.dart';

class CustomRefreshScoreboard extends StatefulWidget {
  @override
  _CustomRefreshScoreboardState createState() => _CustomRefreshScoreboardState();
}

class _CustomRefreshScoreboardState extends State<CustomRefreshScoreboard> {
  bool isRefreshing = false;
  double pullDistance = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Custom Refresh Indicator'),
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is OverscrollNotification) {
                // Capture the pull-to-refresh overscroll distance
                setState(() {
                  pullDistance +=
                      scrollNotification.overscroll / 2; // Adjust speed of animation
                });
              }

              if (scrollNotification is ScrollEndNotification && pullDistance >= 100.0) {
                // Trigger refresh when pull distance reaches a threshold
                setState(() {
                  isRefreshing = true;
                });
                _handleRefresh();
              }

              return false;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
          if (pullDistance > 0 && !isRefreshing)
            Positioned(
              top: 30, // Adjust position for the icon
              left: MediaQuery.of(context).size.width / 2 - 15,
              child: Icon(
                Icons.sports_basketball, // Your custom refresh icon
                color: Colors.deepOrange,
                size:
                    pullDistance.clamp(0.0, 50.0), // Dynamic icon size based on pull distance
              ),
            ),
          if (isRefreshing)
            Positioned(
              top: 30, // Adjust position for the refreshing indicator
              left: MediaQuery.of(context).size.width / 2 - 15,
              child: CircularProgressIndicator(
                color: Colors.deepOrange, // Custom refresh indicator color
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate fetch delay
    setState(() {
      isRefreshing = false;
      pullDistance = 0.0; // Reset pull distance after refresh
    });
  }
}
