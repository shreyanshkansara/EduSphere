import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/video_model.dart';
import '../models/video_response.dart';

class ApiService {
  static const String _baseUrl = 'https://youtube.googleapis.com/youtube/v3';
  
  // Replace with your actual working free API key from Google Cloud Console
  static const String apiKey = 'AIzaSyBgNFEGDoK07Ks1b10slKLUij9XVKRE1GM';

  static const List<String> _educationalTopics = [
    'science experiments',
    'history documentary',
    'coding tutorial',
    'mathemathics explained',
    'astronomy',
    'technology explained',
    'biology lecture',
    'physics crash course',
    'financial literacy',
    'psychology basics',
    'language learning',
  ];

  static Future<VideoResponse> fetchVideos({String? query, String? pageToken}) async {
    // If no query is provided, pick a random educational topic for variety
    String activeQuery = query ?? _educationalTopics[Random().nextInt(_educationalTopics.length)];

    // Append "educational" to the search query to bias the results if it doesn't already contain it
    final String actualQuery = activeQuery.toLowerCase().contains('education') ? activeQuery : '$activeQuery educational';
    final encodedQuery = Uri.encodeComponent(actualQuery);
    
    // videoCategoryId=27 is the official YouTube category for Education (maxResults can be adjusted up to 50)
    String url = '$_baseUrl/search?part=snippet&maxResults=15&q=$encodedQuery&type=video&videoCategoryId=27&safeSearch=strict&key=$apiKey';
    
    // If a pageToken is provided for pagination, append it
    if (pageToken != null && pageToken.isNotEmpty) {
      url += '&pageToken=$pageToken';
    }
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Video> videos = [];
        for (var item in data['items']) {
          final snippet = item['snippet'];
          videos.add(Video(
            id: item['id']['videoId'],
            title: snippet['title'],
            thumbnailUrl: snippet['thumbnails']['high']['url'] ?? snippet['thumbnails']['default']['url'],
            channelTitle: snippet['channelTitle'],
            channelAvatarUrl: 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(snippet['channelTitle'])}&background=random',
            viewCount: '1K', // The search API doesn't return viewCount/duration
            publishedAt: DateTime.parse(snippet['publishedAt']),
            duration: '10:00', 
          ));
        }
        return VideoResponse(
          videos: videos,
          nextPageToken: data['nextPageToken'],
        );
      } else {
        throw Exception('Failed to load videos: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching videos: $e');
      throw Exception('Failed to load videos: $e');
    }
  }
}
