import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chronus/features/chat/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://localhost:8000/api/v1';
  }

  // Helper to get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('WARNING: No auth token found in SharedPreferences');
    } else {
      print('DEBUG: Found auth token: ${token.substring(0, 10)}...');
    }

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get all conversations
  /// GET /chat/conversations
  Future<List<dynamic>> getConversations() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/conversations'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to load conversations: ${response.statusCode}');
      }
    } catch (e) {
      print('Get Conversations Error: $e');
      return [];
    }
  }

  /// Get chat history by conversation ID
  /// GET /chat/{conversationId}
  Future<List<ChatMessage>> getChatHistory(String conversationId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/chat/$conversationId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        // Map response to ChatMessage list
        // Assuming backend returns list of messages with 'content', 'role'/'is_user', 'created_at'
        return data.map((item) => _mapToChatMessage(item)).toList();
      } else {
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      print('Get History Error: $e');
      return [];
    }
  }

  /// Send message to AI
  /// POST /chat/
  Future<ChatMessage> sendMessage(String message, {String? conversationId}) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'message': message,
        if (conversationId != null) 'conversation_id': conversationId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/chat/'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        // Assuming backend returns the AI response
        return ChatMessage(
          text: data['response'] ?? data['message'] ?? 'No response',
          isUser: false,
          time: _getCurrentTime(),
        );
      } else {
        throw Exception('Failed to send message: ${response.statusCode}');
      }
    } catch (e) {
      print('ChatService Error: $e');
      return ChatMessage(
        text: 'Sorry, I\'m having trouble connecting. Please try again.',
        isUser: false,
        time: _getCurrentTime(),
      );
    }
  }

  // Helper to map backend data to ChatMessage
  ChatMessage _mapToChatMessage(dynamic item) {
    final isUser = item['role'] == 'user' || item['is_user'] == true;
    return ChatMessage(
      text: item['content'] ?? item['message'] ?? '',
      isUser: isUser,
      time: _formatTime(item['created_at'] ?? item['timestamp']),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return _getCurrentTime();
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return _getCurrentTime();
    }
  }

  // Deprecated: fetchInitialMessages is replaced by getChatHistory
  Future<List<ChatMessage>> fetchInitialMessages() async {
    return [];
  }
}
