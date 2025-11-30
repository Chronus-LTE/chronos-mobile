import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'drawer_header_section.dart';
import 'drawer_conversation_list.dart';
import 'drawer_navigation_section.dart';
import 'drawer_profile_section.dart';

/// Chat Drawer - Contains:
/// 1. Header with logo
/// 2. Conversation history
/// 3. Navigation items (Email, Calendar)
/// 4. Profile section at bottom
class ChatDrawer extends StatelessWidget {
  final VoidCallback onNewChat;

  const ChatDrawer({
    super.key,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.neutralWhite,
      child: SafeArea(
        child: Column(
          children: [
            // Header with logo and new chat button
            DrawerHeaderSection(onNewChat: onNewChat),

            const Divider(height: 1, color: AppColors.mainBorder),

            // Conversation history (scrollable)
            const Expanded(
              child: DrawerConversationList(),
            ),

            const Divider(height: 1, color: AppColors.mainBorder),

            // Navigation to other screens
            const DrawerNavigationSection(),

            const Divider(height: 1, color: AppColors.mainBorder),

            // Profile section
            const DrawerProfileSection(),
          ],
        ),
      ),
    );
  }
}
