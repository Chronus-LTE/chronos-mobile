import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chronus/features/chat/models/message.dart';
import 'package:http/http.dart' as http;

class ChatService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }

  String? _authToken;

  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Fetch initial messages (empty for new chat)
  Future<List<ChatMessage>> fetchInitialMessages() async {
    // For now, return empty list for new chats
    // In the future, this could load conversation history
    await Future.delayed(const Duration(milliseconds: 100));
    return [];
  }

  /// Send message to AI and get response
  Future<ChatMessage> sendMessage(String text) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: headers,
        body: jsonEncode({
          'message': text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatMessage(
          text: data['response'] ?? 'No response from AI',
          isUser: false,
          time: _getCurrentTime(),
        );
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('ChatService Error: $e');
      // Return a fallback message
      return ChatMessage(
        text: 'Sorry, I\'m having trouble connecting. Please try again.',
        isUser: false,
        time: _getCurrentTime(),
      );
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
