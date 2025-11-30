import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/chat/presentation/chat_screen.dart';
import 'widgets/chat_drawer.dart';

/// Main Chat Screen - This is the home screen
/// Has a drawer with:
/// - Conversation history
/// - Navigation to Email, Calendar, Profile
class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  Key _chatKey = UniqueKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _startNewChat() {
    setState(() {
      _chatKey = UniqueKey();
    });
    // Close drawer after starting new chat
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.neutralWhite,
      drawer: ChatDrawer(
        onNewChat: _startNewChat,
      ),
      appBar: AppBar(
        backgroundColor: AppColors.neutralWhite,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.neutralInk),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Chronos',
          style: TextStyle(
            color: AppColors.neutralInk,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note, color: AppColors.neutralInk),
            onPressed: () {
              setState(() {
                _chatKey = UniqueKey();
              });
            },
            tooltip: 'New Chat',
          ),
        ],
      ),
      body: ChatScreen(key: _chatKey),
    );
  }
}
