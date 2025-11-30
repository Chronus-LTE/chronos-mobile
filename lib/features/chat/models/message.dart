class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class ChatConversation {
  final String id;
  final String title;
  final String? lastMessage;
  final DateTime? updatedAt;

  ChatConversation({
    required this.id,
    required this.title,
    this.lastMessage,
    this.updatedAt,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] ?? '',
      title: json['title'] ?? 'New Chat',
      lastMessage: json['last_message'],
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }
}
