import 'package:flutter/material.dart';

class PlayerAvatar extends StatefulWidget {
  final String playerImageUrl;

  const PlayerAvatar({Key? key, required this.playerImageUrl})
      : super(key: key);

  @override
  _PlayerAvatarState createState() => _PlayerAvatarState();
}

class _PlayerAvatarState extends State<PlayerAvatar> {
  bool networkImageFailed = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20.0,
          backgroundColor: Colors.white12,
          backgroundImage: networkImageFailed
              ? const AssetImage('images/default_player_image.png')
              : NetworkImage(widget.playerImageUrl),
        ),
        if (!networkImageFailed)
          CircleAvatar(
            radius: 20.0,
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
