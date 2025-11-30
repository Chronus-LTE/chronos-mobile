import 'package:chronus/features/chat/models/message.dart';
import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _service;

  ChatViewModel(this._service);

  final List<ChatMessage> _messages = [];
  final List<ChatConversation> _conversations = [];
  String? _currentConversationId;

  bool _isLoading = false;
  bool _isSending = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  List<ChatConversation> get conversations => List.unmodifiable(_conversations);
  String? get currentConversationId => _currentConversationId;

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get hasMessages => _messages.isNotEmpty;

  /// Start a new chat conversation
  void startNewChat() {
    _currentConversationId = null;
    _messages.clear();
    _isLoading = false;
    _isSending = false;
    notifyListeners();
  }

  /// Load all conversations for drawer
  Future<void> loadConversations() async {
    try {
      final data = await _service.getConversations();
      _conversations.clear();
      _conversations.addAll(
        data.map((json) => ChatConversation.fromJson(json)).toList(),
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading conversations: $e');
      }
    }
  }

  /// Load chat history for a specific conversation
  Future<void> loadChatHistory(String conversationId) async {
    _currentConversationId = conversationId;
    _isLoading = true;
    notifyListeners();

    try {
      final history = await _service.getChatHistory(conversationId);
      _messages.clear();
      _messages.addAll(history);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading history: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Deprecated: Use loadChatHistory instead
  Future<void> loadInitialMessages() async {
    await loadConversations();
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
      final reply = await _service.sendMessage(
        text.trim(),
        conversationId: _currentConversationId,
      );
      _messages.add(reply);

      // Reload conversations to update last message/title if needed
      // Optimization: Could update local list manually instead of fetching
      loadConversations();

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
