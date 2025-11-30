import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';

class DrawerHeaderSection extends StatelessWidget {
  final VoidCallback onNewChat;

  const DrawerHeaderSection({
    super.key,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.clay700, AppColors.clay500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'C',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title
          const Expanded(
            child: Text(
              'Chronos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.neutralInk,
              ),
            ),
          ),

          // New chat button
          IconButton(
            icon: const Icon(Icons.edit_note, size: 22),
            color: AppColors.sidebarText,
            onPressed: onNewChat,
            tooltip: 'New Chat',
          ),
        ],
      ),
    );
  }
}
