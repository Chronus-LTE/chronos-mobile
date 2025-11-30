import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/chat/presentation/chat_screen.dart';
import 'package:chronus/features/calendar/presentation/calendar_screen.dart';
import 'package:chronus/features/email/presentation/email_screen.dart';
import 'package:chronus/features/chat/presentation/widgets/chat_drawer.dart';
import 'package:chronus/features/chat/presentation/widgets/drawer_conversation_list.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // Current active module
  AppModule _currentModule = AppModule.chat;

  // Key for chat screen to reset on new chat
  Key _chatKey = UniqueKey();

  void _switchModule(AppModule module) {
    setState(() {
      _currentModule = module;
    });
    Navigator.pop(context); // Close drawer
  }

  void _startNewChat() {
    setState(() {
      _chatKey = UniqueKey();
      _currentModule = AppModule.chat;
    });
  }

  String _getAppBarTitle() {
    switch (_currentModule) {
      case AppModule.chat:
        return 'Chronos';
      case AppModule.email:
        return 'Email';
      case AppModule.calendar:
        return 'Calendar';
    }
  }

  Widget _getCurrentScreen() {
    switch (_currentModule) {
      case AppModule.chat:
        return ChatScreen(key: _chatKey);
      case AppModule.email:
        return const EmailScreen();
      case AppModule.calendar:
        return const CalendarScreen();
    }
  }

  List<Widget> _getAppBarActions() {
    // Only show new chat button when in chat module
    if (_currentModule == AppModule.chat) {
      return [
        IconButton(
          icon: const Icon(Icons.edit_note, color: AppColors.neutralInk),
          onPressed: _startNewChat,
          tooltip: 'New Chat',
        ),
      ];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      drawer: _MainDrawer(
        currentModule: _currentModule,
        onModuleSelected: _switchModule,
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
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(
            color: AppColors.neutralInk,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: _getAppBarActions(),
      ),
      body: _getCurrentScreen(),
    );
  }
}

/// App modules enum
enum AppModule {
  chat,
  email,
  calendar,
}

/// Main Drawer - Navigation drawer for all modules
class _MainDrawer extends StatelessWidget {
  final AppModule currentModule;
  final Function(AppModule) onModuleSelected;
  final VoidCallback onNewChat;

  const _MainDrawer({
    required this.currentModule,
    required this.onModuleSelected,
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
            _DrawerHeader(onNewChat: onNewChat),

            const Divider(height: 1, color: AppColors.mainBorder),

            // Conversation history (always show)
            Expanded(
              child: DrawerConversationList(
                onConversationSelected: () => onModuleSelected(AppModule.chat),
              ),
            ),

            const Divider(height: 1, color: AppColors.mainBorder),

            // Navigation to other modules
            _NavigationSection(
              currentModule: currentModule,
              onModuleSelected: onModuleSelected,
            ),

            const Divider(height: 1, color: AppColors.mainBorder),

            // Profile section
            const _ProfileSection(),
          ],
        ),
      ),
    );
  }
}

/// Drawer Header
class _DrawerHeader extends StatelessWidget {
  final VoidCallback onNewChat;

  const _DrawerHeader({required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Chronos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.neutralInk,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.edit_note, color: AppColors.neutralInk),
            onPressed: onNewChat,
            tooltip: 'New Chat',
          ),
        ],
      ),
    );
  }
}

/// Navigation Section
class _NavigationSection extends StatelessWidget {
  final AppModule currentModule;
  final Function(AppModule) onModuleSelected;

  const _NavigationSection({
    required this.currentModule,
    required this.onModuleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _NavigationItem(
            icon: Icons.email_outlined,
            title: 'Email',
            isSelected: currentModule == AppModule.email,
            onTap: () => onModuleSelected(AppModule.email),
          ),
          _NavigationItem(
            icon: Icons.calendar_today_outlined,
            title: 'Calendar',
            isSelected: currentModule == AppModule.calendar,
            onTap: () => onModuleSelected(AppModule.calendar),
          ),
        ],
      ),
    );
  }
}

/// Navigation Item
class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.neutralInk : AppColors.sidebarText,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? AppColors.neutralInk : AppColors.sidebarText,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.clay100.withOpacity(0.3),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}

/// Profile Section
class _ProfileSection extends StatelessWidget {
  const _ProfileSection();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.clay300,
        child: Icon(Icons.person, color: AppColors.neutralWhite, size: 20),
      ),
      title: const Text(
        'Profile',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.sidebarText,
        ),
      ),
      onTap: () {
        // TODO: Navigate to profile
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    );
  }
}
