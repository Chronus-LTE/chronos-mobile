import 'dart:async';
import 'package:fe_chronos/features/chat/models/message.dart';

class ChatService {
  /// Lấy lịch sử chat mock
  Future<List<ChatMessage>> fetchInitialMessages() async {
    await Future.delayed(const Duration(milliseconds: 500)); // giả lập API

    return [
      ChatMessage(
        text: 'Hi Hoàng, I\'m Chronos. How can I help you today?',
        isUser: false,
        time: '09:30',
      ),
      ChatMessage(
        text: 'Remind me to study DSA at 8pm.',
        isUser: true,
        time: '09:31',
      ),
      ChatMessage(
        text: 'Yes Madam!', 
        isUser: false, 
        time: '09:31'),
    ];
  }

  /// Gửi tin nhắn mock – sau này sẽ gọi API thật
  Future<ChatMessage> sendMessage(String text) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // giả lập AI trả lời

    return ChatMessage(
      text: 'This is a mock AI reply to: $text',
      isUser: false,
      time: '09:32',
    );
  }
}
