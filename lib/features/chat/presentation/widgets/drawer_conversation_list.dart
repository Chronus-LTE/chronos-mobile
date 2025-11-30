import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';

class DrawerConversationList extends StatelessWidget {
  final VoidCallback? onConversationSelected;

  const DrawerConversationList({
    super.key,
    this.onConversationSelected,
  });

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual conversation data from provider
    final conversations = _getMockConversations();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        return _ConversationItem(
          title: conversation.title,
          lastMessage: conversation.lastMessage,
          time: conversation.time,
          isActive: index == 0, // First one is active
          onTap: () {
            onConversationSelected?.call();
            Navigator.pop(context);
          },
        );
      },
    );
  }

  List<_Conversation> _getMockConversations() {
    return [
      _Conversation(
        title: 'Plan my study schedule',
        lastMessage: 'Review DSA & Flutter this week...',
        time: 'Today',
      ),
      _Conversation(
        title: 'Daily tasks',
        lastMessage: 'You have 3 tasks for today...',
        time: 'Yesterday',
      ),
      _Conversation(
        title: 'Trip to Da Nang',
        lastMessage: 'Book flight and hotel by Friday',
        time: '2 days ago',
      ),
      _Conversation(
        title: 'Project ideas',
        lastMessage: 'AI assistant for students...',
        time: '3 days ago',
      ),
    ];
  }
}

class _ConversationItem extends StatelessWidget {
  final String title;
  final String lastMessage;
  final String time;
  final bool isActive;
  final VoidCallback onTap;

  const _ConversationItem({
    required this.title,
    required this.lastMessage,
    required this.time,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? AppColors.clay50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? AppColors.clay700 : AppColors.sidebarText,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          lastMessage,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.sidebarTextSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          time,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.sidebarTextSecondary,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }
}

class _Conversation {
  final String title;
  final String lastMessage;
  final String time;

  _Conversation({
    required this.title,
    required this.lastMessage,
    required this.time,
  });
}
