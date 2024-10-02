import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:splash/components/spinning_ball_loading.dart';
import 'package:splash/utilities/constants.dart';
import 'package:video_player/video_player.dart';

class TikTokVideoPlayer extends StatefulWidget {
  final List shotChart;

  TikTokVideoPlayer({required this.shotChart});

  @override
  _TikTokVideoPlayerState createState() => _TikTokVideoPlayerState();
}

class _TikTokVideoPlayerState extends State<TikTokVideoPlayer> {
  PageController _pageController = PageController();
  ScrollController _scrollController = ScrollController();
  int currentIndex = 0;
  bool isMuted = true;
  double playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    // Sort shots by date
    widget.shotChart.sort(
        (a, b) => DateTime.parse(a['GAME_DATE']).compareTo(DateTime.parse(b['GAME_DATE'])));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Function to show playlist bottom sheet
  void _showPlaylist() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure the scroll happens after the bottom sheet is fully rendered
      _scrollController.jumpTo(
        currentIndex * 72.0.r, // Assuming each list item is 72 pixels tall
      );
    });

    showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
      backgroundColor: const Color(0xFF111111),
      builder: (context) {
        return ListView.builder(
          controller: _scrollController,
          itemCount: widget.shotChart.length,
          itemBuilder: (context, index) {
            return ListTile(
              leading: Image.network(
                widget.shotChart[index]['THUMBNAIL']!,
                width: 50.r,
                height: 50.r,
                fit: BoxFit.cover,
              ),
              title: Row(
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 20.0.r, maxWidth: 20.0.r),
                    child: Image.asset(
                      'images/NBA_Logos/${kTeamAbbrToId[widget.shotChart[index]['VTM']]}.png',
                    ),
                  ),
                  SizedBox(width: 5.0.r),
                  Text(
                    '${widget.shotChart[index]['VTM']} @ ${widget.shotChart[index]['HTM']}',
                    style: kBebasNormal.copyWith(fontSize: 18.0.r),
                  ),
                  SizedBox(width: 5.0.r),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 20.0.r, maxWidth: 20.0.r),
                    child: Image.asset(
                      'images/NBA_Logos/${kTeamAbbrToId[widget.shotChart[index]['HTM']]}.png',
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                widget.shotChart[index]['SHOT_TYPE']!,
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
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      itemCount: widget.shotChart.length,
      onPageChanged: (index) {
        setState(() {
          currentIndex = index;
        });
      },
      itemBuilder: (context, index) {
        return VideoPlayerScreen(
          videoUrl: widget.shotChart[index]['VIDEO']!,
          thumbnailUrl: widget.shotChart[index]['THUMBNAIL']!,
          gameDate:
              '${widget.shotChart[index]['GAME_DATE']!.substring(0, 4)}-${widget.shotChart[index]['GAME_DATE']!.substring(4, 6)}-${widget.shotChart[index]['GAME_DATE']!.substring(6)}',
          matchup: '${widget.shotChart[index]['VTM']!} @ ${widget.shotChart[index]['HTM']!}',
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
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final String gameDate;
  final String matchup;
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

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
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

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
                child: Center(
                  child: AspectRatio(
                      aspectRatio: 16 / 9, child: VideoPlayer(_videoPlayerController)),
                ),
              );
            } else {
              // Show a loading spinner while the video is loading
              return const Center(child: SpinningIcon());
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
                                    widget.gameDate,
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
                                      PopupMenuItem(value: 0.25, child: Text("0.25x")),
                                      PopupMenuItem(value: 0.5, child: Text("0.5x")),
                                      PopupMenuItem(value: 1.0, child: Text("1.0x")),
                                      PopupMenuItem(value: 2.0, child: Text("2.0x")),
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
                ],
              ),
            ),
          ),
        ),
        // Playback progress bar
        // Thin slider resembling a top border
        Positioned(
          bottom: 55.r,
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
              value: currentPosition.inSeconds.toDouble(),
              min: 0,
              max: _videoPlayerController.value.duration.inSeconds.toDouble(),
              onChanged: (value) {
                setState(() {
                  _videoPlayerController.seekTo(Duration(seconds: value.toInt()));
                });
              },
            ),
          ),
        ),
      ],
    );
  }
}
