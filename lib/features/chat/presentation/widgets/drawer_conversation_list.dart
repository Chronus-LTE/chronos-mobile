import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/chat/viewmodels/chat_view_model.dart';
import 'package:provider/provider.dart';

class DrawerConversationList extends StatefulWidget {
  final VoidCallback? onConversationSelected;

  const DrawerConversationList({
    super.key,
    this.onConversationSelected,
  });

  @override
  State<DrawerConversationList> createState() => _DrawerConversationListState();
}

class _DrawerConversationListState extends State<DrawerConversationList> {
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load conversations when drawer opens (only once)
    if (!_hasLoaded) {
      _hasLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ChatViewModel>().loadConversations();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChatViewModel>();
    final conversations = vm.conversations;
    final currentId = vm.currentConversationId;

    if (conversations.isEmpty) {
      return Center(
        child: Text(
          'No conversations yet',
          style: TextStyle(
            color: AppColors.sidebarTextSecondary,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final conversation = conversations[index];
        final isActive = conversation.id == currentId;

        return _ConversationItem(
          title: conversation.title,
          lastMessage: conversation.lastMessage ?? 'No messages',
          time: _formatDate(conversation.updatedAt),
          isActive: isActive,
          onTap: () {
            vm.loadChatHistory(conversation.id);
            widget.onConversationSelected?.call();
            // Navigator.pop(context); // Removed: Parent handles closing drawer
          },
        );
      },
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}';
    }
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
