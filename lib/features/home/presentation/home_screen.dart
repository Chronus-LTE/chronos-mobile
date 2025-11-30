import 'package:chronus/features/chat/presentation/chat_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Mock danh sách các cuộc trò chuyện cũ
  final List<_ChatSession> _mockSessions = const [
    _ChatSession(
      title: 'Plan my study schedule',
      lastMessage: 'Review DSA & Flutter this week...',
      time: 'Yesterday',
    ),
    _ChatSession(
      title: 'Daily tasks',
      lastMessage: 'You have 3 tasks for today...',
      time: 'Today · 09:15',
    ),
    _ChatSession(
      title: 'Trip to Da Nang',
      lastMessage: 'Book flight and hotel by Friday.',
      time: '2 days ago',
    ),
  ];

  /// Hàm mở lịch sử chat (bottom sheet)
  void _openChatHistory() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const Text(
                'Chat history',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _mockSessions.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.black12),
                  itemBuilder: (context, index) {
                    final s = _mockSessions[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        s.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        s.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        s.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black45,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // sau này: load đoạn chat tương ứng
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Hàm tạo cuộc chat mới
  void _newChat() {
    setState(() {
      // khi tạo chat mới → chỉ cần clear ChatScreen bằng key mới
      _chatKey = UniqueKey();
    });
  }

  /// Key giúp rebuild lại ChatScreen từ đầu
  Key _chatKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: _openChatHistory,
        ),
        title: const Text('Chronos Assistant'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note), // icon sổ + bút ✍️
            onPressed: _newChat,
          ),
        ],
      ),

      // body ChatScreen, mỗi lần _chatKey đổi → reset UI
      body: ChatScreen(key: _chatKey),
    );
  }
}

class _ChatSession {
  final String title;
  final String lastMessage;
  final String time;

  const _ChatSession({
    required this.title,
    required this.lastMessage,
    required this.time,
  });
}
