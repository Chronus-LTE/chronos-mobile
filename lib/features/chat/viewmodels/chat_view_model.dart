import 'package:chronus/features/chat/models/message.dart';
import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _service;

  ChatViewModel(this._service);

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get hasMessages => _messages.isNotEmpty;

  /// Start a new chat conversation
  void startNewChat() {
    _messages.clear();
    _isLoading = false;
    _isSending = false;
    notifyListeners();
  }

  /// Load initial messages (if any)
  Future<void> loadInitialMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await _service.fetchInitialMessages();
      _messages.clear();
      _messages.addAll(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading messages: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send user message and get AI response
  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (_isSending) return; // Prevent duplicate sends

    final userMessage = ChatMessage(
      text: text.trim(),
      isUser: true,
      time: _getCurrentTime(),
    );

    _messages.add(userMessage);
    _isSending = true;
    notifyListeners();

    try {
      // Call service to get AI reply
      final reply = await _service.sendMessage(text.trim());
      _messages.add(reply);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending message: $e');
      }
      // Add error message
      _messages.add(
        ChatMessage(
          text: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
          time: _getCurrentTime(),
        ),
      );
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  /// Get current time in HH:mm format
  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
