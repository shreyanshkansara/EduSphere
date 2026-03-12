import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_model.dart';

class HistoryService {
  static const int _maxHistoryLength = 50;

  static String _historyKey(String userId) => 'history_$userId';

  /// Add a video to the user's local watch history
  static Future<void> addToHistory(String userId, Video video) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _historyKey(userId);
    
    // Get existing history
    final jsonString = prefs.getString(key);
    List<Video> history = [];
    
    if (jsonString != null) {
      try {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        history = jsonList.map((json) => Video.fromJson(json)).toList();
      } catch (e) {
        // If there's an error parsing old history, start fresh to prevent permanent breaking
        history = [];
      }
    }

    // Remove video if it already exists in the history (so it just moves to the top)
    history.removeWhere((v) => v.id == video.id);

    // Add to the front of the list
    history.insert(0, video);

    // Truncate to max length to save device storage
    if (history.length > _maxHistoryLength) {
      history = history.sublist(0, _maxHistoryLength);
    }

    // Save back to SharedPreferences
    final updatedJsonString = jsonEncode(history.map((v) => v.toJson()).toList());
    await prefs.setString(key, updatedJsonString);
  }

  /// Get the user's watch history
  static Future<List<Video>> getHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _historyKey(userId);
    
    final jsonString = prefs.getString(key);
    
    if (jsonString == null) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Video.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
  
  /// Clear the user's watch history
  static Future<void> clearHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _historyKey(userId);
    await prefs.remove(key);
  }
}
