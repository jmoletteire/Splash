import 'package:flutter/material.dart';

class PlayerAvatar extends StatefulWidget {
  final double radius;
  final Color backgroundColor;
  final String playerImageUrl;

  const PlayerAvatar(
      {Key? key,
      required this.radius,
      required this.backgroundColor,
      required this.playerImageUrl})
      : super(key: key);

  @override
  _PlayerAvatarState createState() => _PlayerAvatarState();
}

class _PlayerAvatarState extends State<PlayerAvatar> {
  bool networkImageFailed = false;

  @override
  void didUpdateWidget(covariant PlayerAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playerImageUrl != oldWidget.playerImageUrl) {
      setState(() {
        networkImageFailed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: widget.radius,
          backgroundColor: widget.backgroundColor,
          backgroundImage: networkImageFailed
              ? const AssetImage('images/default_player_image.png')
              : NetworkImage(widget.playerImageUrl),
        ),
        if (!networkImageFailed)
          CircleAvatar(
            radius: widget.radius,
            backgroundColor: Colors.transparent,
            backgroundImage: NetworkImage(widget.playerImageUrl),
            onBackgroundImageError: (exception, stackTrace) {
              setState(() {
                networkImageFailed = true;
              });
            },
          ),
      ],
    );
  }
}
