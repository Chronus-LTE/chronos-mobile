import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/email/models/email.dart';

/// Email list item widget with swipe actions and performance optimizations
class EmailListItem extends StatelessWidget {
  final Email email;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onStar;
  final VoidCallback onDelete;
  final VoidCallback? onMarkRead;

  const EmailListItem({
    super.key,
    required this.email,
    required this.isSelected,
    required this.onTap,
    required this.onStar,
    required this.onDelete,
    this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(email.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: const Color(0xFFFEE2E2),
            foregroundColor: const Color(0xFFDC2626),
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: Material(
        color: _getBackgroundColor(),
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.mainBorder,
                  width: 0.5,
                ),
                left: isSelected
                    ? BorderSide(
                        color: AppColors.clay600,
                        width: 3,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _buildAvatar(),
                const SizedBox(width: 12),

                // Email content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row (sender, date, star)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              email.getSenderName(),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: email.isUnread ? FontWeight.w700 : FontWeight.w500,
                                color: AppColors.sidebarText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            email.getFormattedDate(),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.sidebarTextSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStarButton(),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Subject
                      Text(
                        email.subject,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: email.isUnread ? FontWeight.w700 : FontWeight.w400,
                          color: AppColors.sidebarText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),

                      // Snippet
                      Text(
                        email.snippet,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.sidebarTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      // Attachment indicator
                      if (email.hasAttachments) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.attach_file,
                              size: 12,
                              color: AppColors.sidebarTextSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${email.attachments.length} attachment${email.attachments.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.sidebarTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isSelected) {
      return AppColors.clay100.withOpacity(0.3);
    } else if (email.isUnread) {
      return AppColors.neutralWhite;
    } else {
      return AppColors.contentBg.withOpacity(0.7);
    }
  }

  Widget _buildAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.clay400, AppColors.clay500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          email.getSenderInitials(),
          style: const TextStyle(
            color: AppColors.neutralWhite,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStarButton() {
    return GestureDetector(
      onTap: onStar,
      child: Container(
        padding: const EdgeInsets.all(4),
        child: Icon(
          email.isStarred ? Icons.star : Icons.star_border,
          size: 18,
          color: email.isStarred ? const Color(0xFFF59E0B) : AppColors.sidebarTextSecondary,
        ),
      ),
    );
  }
}
