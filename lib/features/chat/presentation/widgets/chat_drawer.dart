import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'drawer_header_section.dart';
import 'drawer_conversation_list.dart';
import 'drawer_navigation_section.dart';
import 'drawer_profile_section.dart';

class ChatDrawer extends StatelessWidget {
  final VoidCallback onNewChat;

  const ChatDrawer({
    super.key,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBg,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            DrawerHeaderSection(
              onNewChat: onNewChat,
            ),
            const SizedBox(height: 16),

            // Conversation List
            Expanded(
              child: DrawerConversationList(),
            ),

            const Divider(color: AppColors.sidebarBorder, height: 1),

            // Navigation Section
            DrawerNavigationSection(),

            const Divider(color: AppColors.sidebarBorder, height: 1),

            // Profile Section
            DrawerProfileSection(),
          ],
        ),
      ),
    );
  }
}
