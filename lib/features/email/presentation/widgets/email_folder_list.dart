import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/email/models/email.dart';

/// Email folder list widget for drawer navigation
class EmailFolderList extends StatelessWidget {
  final MailFolder currentFolder;
  final Function(MailFolder) onFolderSelected;
  final int unreadCount;

  const EmailFolderList({
    super.key,
    required this.currentFolder,
    required this.onFolderSelected,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Text(
            'FOLDERS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.sidebarTextSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        ...SystemFolders.all.map((folder) => _buildFolderItem(folder)),
      ],
    );
  }

  Widget _buildFolderItem(MailFolder folder) {
    final isSelected = currentFolder.id == folder.id;
    final showBadge = folder.id == 'INBOX' && unreadCount > 0;

    return ListTile(
      leading: Icon(
        _getFolderIcon(folder.type),
        color: isSelected ? AppColors.neutralInk : AppColors.sidebarText,
        size: 22,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              folder.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppColors.neutralInk : AppColors.sidebarText,
              ),
            ),
          ),
          if (showBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.clay600,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralWhite,
                ),
              ),
            ),
        ],
      ),
      selected: isSelected,
      selectedTileColor: AppColors.clay100.withOpacity(0.3),
      onTap: () => onFolderSelected(folder),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  IconData _getFolderIcon(FolderType type) {
    switch (type) {
      case FolderType.inbox:
        return Icons.inbox_outlined;
      case FolderType.sent:
        return Icons.send_outlined;
      case FolderType.drafts:
        return Icons.drafts_outlined;
      case FolderType.starred:
        return Icons.star_outline;
      case FolderType.trash:
        return Icons.delete_outline;
      case FolderType.spam:
        return Icons.report_outlined;
      case FolderType.important:
        return Icons.flag_outlined;
    }
  }
}
