import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';

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
  late final String _viewId;

  @override
  void initState() {
    super.initState();
    _viewId = 'yt-iframe-${widget.videoId}-${DateTime.now().millisecondsSinceEpoch}';

    ui.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;
      iframe.src = 'https://www.youtube-nocookie.com/embed/${widget.videoId}'
          '?autoplay=1&rel=0&modestbranding=1';
      iframe.style.border = '0';
      iframe.style.width = '100%';
      iframe.style.height = '100%';
      iframe.allowFullscreen = true;
      iframe.setAttribute(
        'allow',
        'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share',
      );
      return iframe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: HtmlElementView(viewType: _viewId),
    );
  }
}
