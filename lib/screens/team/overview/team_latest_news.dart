import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:splash/utilities/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TeamLatestNews extends StatefulWidget {
  final Map<String, dynamic> team;
  const TeamLatestNews({super.key, required this.team});

  @override
  State<TeamLatestNews> createState() => _TeamLatestNewsState();
}

class _TeamLatestNewsState extends State<TeamLatestNews> {
  late List<Map<String, String>> news;
  late final WebViewController _controller;
  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  String formatDate(String date) {
    DateTime dateTime = DateTime.parse(date);
    return DateFormat('MMM d').format(dateTime);
  }

  String timeAgo(String dateTimeString) {
    final inputFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
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
      final outputFormat = DateFormat('MMM d');
      return outputFormat.format(givenDateTime);
    }
  }

  List<Map<String, String>> getNews() {
    List<Map<String, String>> latest_news = [];

    if (widget.team.containsKey('NEWS')) {
      List rawNews = widget.team['NEWS'];

      // Convert Map<String, dynamic> to List<Map<String, String>>
      latest_news = rawNews.map((entry) {
        return {
          'date': entry['published'].toString(),
          'headline': entry['headline'].toString(),
          'provider': entry['provider'].toString(),
          'url': entry['url'].toString(),
          'image': entry['og_image'].toString()
        };
      }).toList();
    }
    return latest_news;
  }

  @override
  void initState() {
    super.initState();
    news = getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(11.0.r),
      color: Colors.grey.shade900,
      child: Padding(
        padding: EdgeInsets.all(15.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade700, width: 2.0),
                    ),
                  ),
                  child: Text(
                    //'Franchise',
                    'Latest',
                    style: kBebasBold.copyWith(fontSize: 18.0.r, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5.0.r),
            if (news.isEmpty)
              Padding(
                padding: EdgeInsets.all(15.0.r),
                child: Center(
                  child: Text(
                    'No News',
                    style: kBebasBold.copyWith(fontSize: 16.0.r, color: Colors.white70),
                  ),
                ),
              ),
            if (news.isNotEmpty)
              for (Map<String, String> item in news.take(3))
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        final WebViewController controller = WebViewController()
                          ..loadRequest(Uri.parse(item['url']!));
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius: BorderRadius.circular(20.0)),
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new),
                                    onPressed: () async {
                                      if (await controller.canGoBack()) {
                                        controller.goBack();
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    onPressed: () async {
                                      if (await controller.canGoForward()) {
                                        controller.goForward();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Expanded(
                                child: WebViewWidget(
                                  gestureRecognizers: gestureRecognizers,
                                  controller: controller,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0.r),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Add spacing between date and transaction text
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    children: [
                                      Text(item['headline']!,
                                          style: kBebasNormal.copyWith(fontSize: 14.0.r)),
                                    ],
                                  ),
                                  Row(
                                    textBaseline: TextBaseline.alphabetic,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    children: [
                                      Text(
                                        timeAgo(item['date']!),
                                        style: kBebasNormal.copyWith(
                                            fontSize: 12.0.r, color: Colors.white60),
                                      ),
                                      const Text(
                                          ' • '), // Add spacing between date and transaction text
                                      Text(
                                        item['provider']!,
                                        style: kBebasNormal.copyWith(
                                            fontSize: 12.0.r, color: Colors.white60),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (item['image'] != 'null') SizedBox(width: 10.0.r),
                            if (item['image'] != 'null')
                              Expanded(
                                flex: 3,
                                child: ConstrainedBox(
                                  constraints:
                                      BoxConstraints(maxHeight: 70.0.r, maxWidth: 70.0.r),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(item['image']!),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
