import 'package:flutter/material.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/email/models/email.dart';

/// Sync status banner widget showing sync progress
class SyncStatusBanner extends StatelessWidget {
  final SyncStatus syncStatus;
  final VoidCallback onDismiss;

  const SyncStatusBanner({
    super.key,
    required this.syncStatus,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!syncStatus.isSyncing) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.clay100,
        border: Border(
          bottom: BorderSide(
            color: AppColors.clay300,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.clay600),
              value: syncStatus.progressPercentage > 0
                  ? syncStatus.progressPercentage / 100
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Syncing emails...',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.neutralInk,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${syncStatus.syncedMessages} of ${syncStatus.totalMessages} messages (${syncStatus.progressPercentage.toStringAsFixed(0)}%)',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.sidebarTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDismiss,
            color: AppColors.sidebarText,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
