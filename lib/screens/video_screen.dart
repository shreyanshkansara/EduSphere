import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/api_service.dart';
import '../services/history_service.dart';
import '../widgets/video_card.dart';
import '../widgets/platform_youtube_player.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VideoScreen extends StatefulWidget {
  final Video video;
  final void Function(Video)? onVideoTap;

  const VideoScreen({super.key, required this.video, this.onVideoTap});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  List<Video>? _relatedVideos;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRelatedVideos();
    _recordHistory();
  }

  Future<void> _recordHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      HistoryService.addToHistory(user.uid, widget.video);
    }
  }

  Future<void> _fetchRelatedVideos() async {
    try {
      final response = await ApiService.fetchVideos();
      if (mounted) {
        setState(() {
          _relatedVideos = response.videos;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: PlatformYoutubePlayer(
                    videoId: widget.video.id,
                    aspectRatio: 16 / 9,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 18.0) ??
                          const TextStyle(fontSize: 18.0),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Text(
                          '${widget.video.viewCount} views • ${widget.video.publishedAt.year}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontSize: 14.0, color: Colors.grey) ??
                              const TextStyle(
                                  fontSize: 14.0, color: Colors.grey),
                        ),
                      ],
                    ),
                    const Divider(height: 24.0, color: Colors.grey),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                              widget.video.channelAvatarUrl),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.video.channelTitle,
                                style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold) ??
                                    const TextStyle(
                                        fontWeight: FontWeight.bold),
                              ),
                              const Text('1M subscribers',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24.0, color: Colors.grey),
                  ],
                ),
              ),
            ),
            if (_error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Error loading related videos.\nCheck API Key in api_service.dart.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              )
            else if (_relatedVideos == null)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = _relatedVideos?[index];
                    if (video == null) return const SizedBox.shrink();
                    if (video.id == widget.video.id) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: VideoCard(
                        video: video,
                        onTap: () {
                          widget.onVideoTap?.call(video);
                        },
                      ),
                    );
                  },
                  childCount: _relatedVideos?.length ?? 0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
