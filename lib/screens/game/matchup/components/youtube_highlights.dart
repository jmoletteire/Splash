import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeHighlights extends StatefulWidget {
  final String videoId;
  const YoutubeHighlights({super.key, required this.videoId});

  @override
  State<YoutubeHighlights> createState() => _YoutubeHighlightsState();
}

class _YoutubeHighlightsState extends State<YoutubeHighlights> {
  late YoutubePlayerController _youtubePlayerController;

  @override
  void initState() {
    super.initState();

    // Initialize the YouTube player controller with the video ID
    _youtubePlayerController = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: true,
        forceHD: true,
      ),
    );
  }

  Future<void> _launchFullScreen(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url)); // Use the native iOS player
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    _youtubePlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0.r),
      child: Container(
        margin: EdgeInsets.fromLTRB(11.0.r, 11.0.r, 11.0.r, 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0), // Set your desired border radius
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge, // Ensure content is clipped smoothly
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: YoutubePlayer(
            controller: _youtubePlayerController,
            progressColors: ProgressBarColors(
              playedColor: Colors.deepOrange, // The played part of the video
              handleColor: Colors.deepOrange, // The draggable part of the progress bar
              bufferedColor: Colors.white70, // The buffered part of the video
              backgroundColor: Colors.grey.withOpacity(0.5), // The background color
            ),
          ),
        ),
      ),
    );
  }
}
