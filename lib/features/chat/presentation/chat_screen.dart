import 'package:chronus/features/chat/models/message.dart';
import 'package:chronus/features/chat/viewmodels/chat_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data
    final vm = context.watch<ChatViewModel>();
    final List<ChatMessage> messages = vm.messages;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // List tin nhắn
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg.isUser;

                  return Row(
                    mainAxisAlignment:
                        isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black,
                          child: Text(
                            'C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.black : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12).copyWith(
                              bottomLeft: Radius.circular(isUser ? 12 : 2),
                              bottomRight: Radius.circular(isUser ? 2 : 12),
                            ),
                            border:
                                isUser
                                    ? null
                                    : Border.all(
                                      color: Colors.black12,
                                      width: 1,
                                    ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                isUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.text,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                msg.time,
                                style: TextStyle(
                                  color:
                                      isUser ? Colors.white54 : Colors.black38,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        const CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey,
                          child: Text(
                            'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),

            const Divider(height: 1),

            // Thanh nhập tin nhắn (giờ cho nhập + có nút +, voice, send)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // nút dấu +
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      // sau này mở bottom sheet: create task, note, calendar, ...
                    },
                  ),

                  // ô nhập
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // nút voice
                  IconButton(
                    icon: const Icon(Icons.mic_none),
                    onPressed: () {
                      // sau này gắn voice input
                    },
                  ),

                  // nút send
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      // sau này gắn logic gửi message
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
