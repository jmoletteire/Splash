import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:marquee/marquee.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/utilities/constants.dart';
import 'package:video_player/video_player.dart';

class PbpVideoPlayer extends StatefulWidget {
  final List pbpVideo;
  final String gameId;
  final String gameDate;
  final String homeAbbr;
  final String awayAbbr;

  PbpVideoPlayer({
    required this.pbpVideo,
    required this.gameId,
    required this.gameDate,
    required this.homeAbbr,
    required this.awayAbbr,
  });

  @override
  _PbpVideoPlayerState createState() => _PbpVideoPlayerState();
}

class _PbpVideoPlayerState extends State<PbpVideoPlayer> {
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  int currentIndex = 0;
  bool isMuted = true;
  double playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String formatDuration(String inputStr) {
    // Regular expression to match 'PT' followed by minutes and seconds with tenths of a second
    RegExp regex = RegExp(r'PT(\d+)M(\d+)\.(\d+)S');
    Match? match = regex.firstMatch(inputStr);

    if (match != null) {
      int minutes = int.parse(match.group(1)!); // Convert minutes to int
      int seconds = int.parse(match.group(2)!); // Convert seconds to int
      String tenths = match.group(3)![0]; // Take only the first digit for tenths

      if (minutes == 0) {
        // Less than a minute left, return seconds and tenths
        return ":$seconds.$tenths";
      } else {
        // Regular minutes and seconds format, with leading zero for seconds if necessary
        return "$minutes:${seconds.toString().padLeft(2, '0')}";
      }
    }

    // Return original string if no match is found
    return inputStr;
  }

  // Function to show playlist bottom sheet
  void _showPlaylist() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the scroll happens after the bottom sheet is fully rendered
      _scrollController.jumpTo(
        currentIndex * 72.0.r, // Assuming each list item is 72 pixels tall
      );
    });

    String year = widget.gameDate.substring(0, 4);
    String month = widget.gameDate.substring(5, 7);
    String day = widget.gameDate.substring(8, 10);

    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      showDragHandle: true,
      backgroundColor: const Color(0xFF111111),
      builder: (context) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: widget.pbpVideo.length,
          itemBuilder: (context, index) {
            String thumbnail =
                'https://videos.nba.com/nba/pbp/media/$year/$month/$day/${widget.gameId}/${widget.pbpVideo[index]?['actionNumber']}/${widget.pbpVideo[index]?['videoId']}_960x540.jpg';
            String period = widget.pbpVideo[index]?['period'] > 4
                ? 'OT'
                : 'Q${widget.pbpVideo[index]?['period'] ?? ''}';
            String timePeriod =
                '$period ${formatDuration(widget.pbpVideo[index]?['clock'] ?? '')}';
            return ListTile(
              leading: widget.pbpVideo[index]?['videoId'] == null ||
                      widget.pbpVideo[index]?['description'] == 'Period Start'
                  ? SizedBox(
                      width: 50.r,
                      height: 50.r,
                    )
                  : Image.network(
                      thumbnail,
                      width: 50.r,
                      height: 50.r,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (BuildContext context, Object error, StackTrace? stackTrace) {
                        return SizedBox(
                          width: 50.r,
                          height: 50.r,
                        );
                      },
                    ),
              title: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 20.0.r, maxWidth: 20.0.r),
                    child: Image.asset(
                      'images/NBA_Logos/${kTeamAbbrToId[widget.awayAbbr]}.png',
                    ),
                  ),
                  SizedBox(width: 5.0.r),
                  Text(
                    '${widget.awayAbbr} @ ${widget.homeAbbr}',
                    style: kBebasNormal.copyWith(fontSize: 18.0.r),
                  ),
                  SizedBox(width: 5.0.r),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 20.0.r, maxWidth: 20.0.r),
                    child: Image.asset(
                      'images/NBA_Logos/${kTeamAbbrToId[widget.homeAbbr] ?? 0}.png',
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '$timePeriod - ${widget.pbpVideo[index]?['description'] ?? ''}',
                style: kBebasNormal.copyWith(fontSize: 16.0.r, color: Colors.white70),
              ),
              onTap: () {
                // Jump to the selected video page
                _pageController.jumpToPage(index);
                Navigator.pop(context); // Close the bottom sheet
              },
              selected: index == currentIndex, // Highlight current video
              selectedTileColor: Colors.grey.shade800,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    try {
      return PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.pbpVideo.length,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          String year = widget.gameDate.substring(0, 4);
          String month = widget.gameDate.substring(5, 7);
          String day = widget.gameDate.substring(8, 10);

          String video =
              'https://videos.nba.com/nba/pbp/media/$year/$month/$day/${widget.gameId}/${widget.pbpVideo[index]?['actionNumber']}/${widget.pbpVideo[index]?['videoId']}_960x540.mp4';
          String thumbnail =
              'https://videos.nba.com/nba/pbp/media/$year/$month/$day/${widget.gameId}/${widget.pbpVideo[index]?['actionNumber']}/${widget.pbpVideo[index]?['videoId']}_960x540.jpg';

          String period = widget.pbpVideo[index]?['period'] > 4
              ? 'OT'
              : 'Q${widget.pbpVideo[index]?['period'] ?? ''}';
          String timePeriod =
              '$period ${formatDuration(widget.pbpVideo[index]?['clock'] ?? '')}';

          return VideoPlayerScreen(
            videoUrl: widget.pbpVideo[index]?['videoId'] == null ? '' : video,
            thumbnailUrl: widget.pbpVideo[index]?['videoId'] == null ? '' : thumbnail,
            gameDate: widget.gameDate,
            matchup: '${widget.awayAbbr} @ ${widget.homeAbbr}',
            description: widget.pbpVideo[index]?['description'] ?? '',
            timePeriod: timePeriod,
            isMuted: isMuted,
            playbackSpeed: playbackSpeed,
            onMuteToggle: () {
              setState(() {
                isMuted = !isMuted;
              });
            },
            onSpeedChange: (newSpeed) {
              setState(() {
                playbackSpeed = newSpeed;
              });
            },
            onPlaylistPressed: _showPlaylist,
          );
        },
      );
    } catch (e) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_basketball,
              color: Colors.white38,
              size: 38.0.r,
            ),
            const SizedBox(height: 15.0),
            Text(
              'Video Unavailable',
              style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
            ),
          ],
        ),
      );
    }
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final String gameDate;
  final String matchup;
  final String timePeriod;
  final String description;
  final bool isMuted;
  final double playbackSpeed;
  final VoidCallback onMuteToggle;
  final Function(double) onSpeedChange;
  final VoidCallback onPlaylistPressed;

  const VideoPlayerScreen({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.gameDate,
    required this.matchup,
    required this.timePeriod,
    required this.description,
    required this.isMuted,
    required this.playbackSpeed,
    required this.onMuteToggle,
    required this.onSpeedChange,
    required this.onPlaylistPressed,
    Key? key,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  Future<void>? _initializeVideoPlayerFuture;
  Duration? videoDuration;
  Duration currentPosition = Duration.zero;
  bool shouldScroll = false;
  bool videoAvailable = true;

  @override
  void initState() {
    super.initState();
    _checkVideoUrl(); // Check if the video link is valid

    // Calculate if text needs to scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTextOverflow();
    });
  }

  Future<void> _checkVideoUrl() async {
    try {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );

      // Make a HEAD request to the video URL to check availability
      final response = await http.head(Uri.parse(widget.videoUrl));

      if (response.statusCode == 200) {
        // If available, initialize the video player
        _initializeVideoPlayerFuture = _videoPlayerController.initialize().then((_) {
          // Autoplay the video once it is initialized
          _videoPlayerController.play();
        });
        _videoPlayerController.setLooping(true);
        _videoPlayerController.setVolume(widget.isMuted ? 0.0 : 1.0);
        _videoPlayerController.setPlaybackSpeed(widget.playbackSpeed);
        _videoPlayerController.addListener(() {
          setState(() {
            currentPosition = _videoPlayerController.value.position;
            videoDuration = _videoPlayerController.value.duration;
          });
        });
      } else {
        setState(() {
          videoAvailable = false; // If not available, show the error message
        });
      }
    } catch (e) {
      // If an error occurs (e.g., network error), set video as unavailable
      setState(() {
        videoAvailable = false;
      });
    }
  }

  void _checkTextOverflow() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      double availableWidth = renderBox.size.width;

      // Use TextPainter to calculate the width of the text
      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: "${widget.timePeriod} | ${widget.description}",
          style: kBebasNormal.copyWith(fontSize: 14.0.r, color: Colors.grey.shade400),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(); // Perform the layout calculation

      setState(() {
        shouldScroll = textPainter.width > availableWidth;
      });
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isMuted != widget.isMuted) {
      _videoPlayerController.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
    if (oldWidget.playbackSpeed != widget.playbackSpeed) {
      _videoPlayerController.setPlaybackSpeed(widget.playbackSpeed);
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    return Stack(
      children: [
        if (widget.videoUrl == '' || !videoAvailable)
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.videocam_off,
                  color: Colors.white38,
                  size: 38.0.r,
                ),
                SizedBox(height: 15.0.r),
                Text(
                  'Video Unavailable',
                  style: kBebasNormal.copyWith(fontSize: 18.0.r, color: Colors.white54),
                ),
                SizedBox(height: 65.0.r),
              ],
            ),
          ),
        if (widget.videoUrl != '' && videoAvailable)
          FutureBuilder(
            future: _initializeVideoPlayerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_videoPlayerController.value.isPlaying) {
                        _videoPlayerController.pause();
                      } else {
                        _videoPlayerController.play();
                      }
                    });
                  },
                  child: isLandscape
                      ? AspectRatio(
                          aspectRatio: 16 / 9, child: VideoPlayer(_videoPlayerController))
                      : AspectRatio(
                          aspectRatio: 16 / 9, child: VideoPlayer(_videoPlayerController)),
                );
              } else {
                // Show a loading spinner while the video is loading
                return const Center(heightFactor: 5, child: SpinningIcon());
              }
            },
          ),
        // Bottom bar with playback controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: InkWell(
            onTap: widget.onPlaylistPressed,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10.0.r, horizontal: 15.0.r),
              color: Colors.black54,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Bottom bar with playlist and controls
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.video_collection, color: Colors.white),
                                  SizedBox(width: 8.0.r),
                                  Text(
                                    '${widget.gameDate.substring(0, 4)}-${widget.gameDate.substring(5, 7)}-${widget.gameDate.substring(8, 10)}',
                                    style: kBebasNormal.copyWith(
                                        fontSize: 16.0.r, color: Colors.grey.shade300),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxHeight: 20.0.r, maxWidth: 20.0.r),
                                    child: Image.asset(
                                      'images/NBA_Logos/${kTeamAbbrToId[widget.matchup.substring(0, 3)]}.png',
                                    ),
                                  ),
                                  Text(
                                    widget.matchup,
                                    style: kBebasNormal.copyWith(fontSize: 18.0.r),
                                  ),
                                  ConstrainedBox(
                                    constraints:
                                        BoxConstraints(maxHeight: 20.0.r, maxWidth: 20.0.r),
                                    child: Image.asset(
                                      'images/NBA_Logos/${kTeamAbbrToId[widget.matchup.substring(6)]}.png',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Mute button
                                  IconButton(
                                    icon: Icon(
                                      widget.isMuted ? Icons.volume_off : Icons.volume_up,
                                      color: Colors.white,
                                    ),
                                    onPressed: widget.onMuteToggle,
                                  ),
                                  // Playback speed button
                                  PopupMenuButton<double>(
                                    initialValue: widget.playbackSpeed,
                                    color: Colors.grey.shade900,
                                    icon: const Icon(Icons.speed, color: Colors.white),
                                    onSelected: (speed) {
                                      widget.onSpeedChange(speed);
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 0.25, child: Text("0.25x")),
                                      const PopupMenuItem(value: 0.5, child: Text("0.5x")),
                                      const PopupMenuItem(value: 1.0, child: Text("1.0x")),
                                      const PopupMenuItem(value: 2.0, child: Text("2.0x")),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Ticker for the current video title
                  SizedBox(
                    height: 20.0.r,
                    child: shouldScroll
                        ? Marquee(
                            text: "${widget.timePeriod} | ${widget.description}", // Title text
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                            scrollAxis: Axis.horizontal,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            blankSpace: 30.0,
                            velocity: 20.0,
                            pauseAfterRound: const Duration(seconds: 1),
                            startPadding: 0.0,
                            accelerationDuration: const Duration(seconds: 1),
                            accelerationCurve: Curves.linear,
                            decelerationDuration: const Duration(milliseconds: 500),
                            decelerationCurve: Curves.easeOut,
                          )
                        : Text(
                            "${widget.timePeriod} | ${widget.description}",
                            style: kBebasNormal.copyWith(
                                fontSize: 14.0.r, color: Colors.grey.shade400),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Playback progress bar
        // Thin slider resembling a top border
        Positioned(
          bottom: 75.r,
          left: -12.r,
          right: -12.r,
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 1.0, // Thin white line
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 0.0, // Thumb size when seeking
                disabledThumbRadius: 0.0, // Hide thumb when not seeking
              ),
              thumbColor: Colors.white, // Thumb color
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 12.0), // Thumb overlay
              showValueIndicator: ShowValueIndicator.never, // No value indicator
            ),
            child: Slider(
              value: currentPosition.inMicroseconds.toDouble(),
              min: 0,
              max: _videoPlayerController.value.duration.inMicroseconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _videoPlayerController.seekTo(Duration(microseconds: value.toInt()));
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
