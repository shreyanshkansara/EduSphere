import 'video_model.dart';

class VideoResponse {
  final List<Video> videos;
  final String? nextPageToken;

  const VideoResponse({
    required this.videos,
    this.nextPageToken,
  });
}
