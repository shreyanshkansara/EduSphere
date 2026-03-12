import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class PlatformYoutubePlayer extends StatefulWidget {
  final String videoId;
  final double aspectRatio;

  const PlatformYoutubePlayer({
    super.key,
    required this.videoId,
    this.aspectRatio = 16 / 9,
  });

  @override
  State<PlatformYoutubePlayer> createState() => _PlatformYoutubePlayerState();
}

class _PlatformYoutubePlayerState extends State<PlatformYoutubePlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        mute: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      aspectRatio: widget.aspectRatio,
    );
  }
}
