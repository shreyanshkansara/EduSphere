import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  // Get your FREE API key at: https://aistudio.google.com/app/apikey
  // Free tier: 15 requests/min, 1,500 requests/day — no credit card needed!
  static const String _apiKey = 'AIzaSyCxPHFvjoff9VUoCrWd46xAh-eFfFo-xWI';

  // Using the v1beta REST API — supports systemInstruction
  static const String _model = 'gemini-flash-latest';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const String _systemPrompt =
      'You are EduBot, an enthusiastic and friendly educational assistant built into the EduSphere learning app. '
      'Your role is to help students understand educational topics clearly and simply. '
      'Keep your answers concise but informative. Use simple language for complex topics. '
      'Do not answer questions unrelated to education or learning.';

  // Conversation history stored as raw JSON-compatible maps
  static final List<Map<String, dynamic>> _history = [];

  /// Sends [userMessage] to Gemini and returns the AI's text response.
  static Future<String> sendMessage(String userMessage) async {
    if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      return '⚠️ Please add your Gemini API key in `lib/services/gemini_service.dart`.\n\n'
          'Get a free key (no credit card) at:\nhttps://aistudio.google.com/app/apikey';
    }

    // Append user turn to history
    _history.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ],
    });

    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt}
        ]
      },
      'contents': _history,
    });

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text']
            as String? ?? 'Sorry, I got an empty response. Please try again.';

        // Append model reply to history for multi-turn context
        _history.add({
          'role': 'model',
          'parts': [
            {'text': text}
          ],
        });

        return text;
      } else {
        // Remove the user turn we added since it failed
        _history.removeLast();
        final error = jsonDecode(response.body);
        final msg = error['error']?['message'] ?? response.body;
        return '❌ Gemini error: $msg';
      }
    } catch (e) {
      _history.removeLast();
      debugPrint('GeminiService error: $e');
      return '❌ Something went wrong. Please check your internet connection and try again.';
    }
  }

  /// Clears conversation history and starts a fresh chat session.
  static void clearHistory() {
    _history.clear();
  }
}

