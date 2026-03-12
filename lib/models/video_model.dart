class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String channelTitle;
  final String channelAvatarUrl;
  final String viewCount;
  final DateTime publishedAt;
  final String duration;

  const Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.channelTitle,
    required this.channelAvatarUrl,
    required this.viewCount,
    required this.publishedAt,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'thumbnailUrl': thumbnailUrl,
      'channelTitle': channelTitle,
      'channelAvatarUrl': channelAvatarUrl,
      'viewCount': viewCount,
      'publishedAt': publishedAt.toIso8601String(),
      'duration': duration,
    };
  }

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      title: json['title'],
      thumbnailUrl: json['thumbnailUrl'],
      channelTitle: json['channelTitle'],
      channelAvatarUrl: json['channelAvatarUrl'],
      viewCount: json['viewCount'],
      publishedAt: DateTime.parse(json['publishedAt']),
      duration: json['duration'],
    );
  }
}
