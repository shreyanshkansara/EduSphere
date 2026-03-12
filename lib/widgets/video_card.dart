import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

import '../models/video_model.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final VoidCallback? onTap;

  const VideoCard({
    Key? key,
    required this.video,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 8.0,
                right: 8.0,
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  color: Colors.black,
                  child: Text(
                    video.duration,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white) ?? const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {},
                  child: CircleAvatar(
                    foregroundImage: CachedNetworkImageProvider(
                      video.channelAvatarUrl,
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          video.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontSize: 15.0) ?? const TextStyle(fontSize: 15.0),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '${video.channelTitle} • ${video.viewCount} views • ${timeago.format(video.publishedAt)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 13.0,
                                color: Colors.grey[300],
                              ) ?? TextStyle(fontSize: 13.0, color: Colors.grey[300]),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.more_vert, size: 20.0),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
