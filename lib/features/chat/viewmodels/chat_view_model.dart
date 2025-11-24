import 'package:fe_chronos/features/chat/models/message.dart';
import 'package:flutter/foundation.dart';
import '../services/chat_service.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatService _service;

  ChatViewModel(this._service);

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> loadInitialMessages() async {
    _isLoading = true;
    notifyListeners();

    final data = await _service.fetchInitialMessages();
    _messages.clear();
    _messages.addAll(data);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    // add user message
    _messages.add(
      ChatMessage(
        text: text,
        isUser: true,
        time: '09:32',
      ),
    );
    notifyListeners();

    // gọi mock service lấy AI reply
    final reply = await _service.sendMessage(text);
    _messages.add(reply);
    notifyListeners();
  }
}
