import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chronus/core/theme/app_colors.dart';
import 'package:chronus/features/email/models/email.dart';
import 'package:chronus/features/email/viewmodels/email_view_model.dart';
import 'package:chronus/features/email/presentation/widgets/email_list_item.dart';
import 'package:chronus/features/email/presentation/widgets/sync_status_banner.dart';
import 'package:chronus/features/email/presentation/email_detail_screen.dart';
import 'package:chronus/features/email/presentation/compose_email_screen.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showSyncBanner = true;

  @override
  void initState() {
    super.initState();

    // Initialize email data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmailViewModel>().initialize();
    });

    // Setup scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      final vm = context.read<EmailViewModel>();
      if (vm.hasMore && !vm.isLoadingMore) {
        vm.loadMoreEmails();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EmailViewModel>();

    return Scaffold(
      backgroundColor: AppColors.neutralWhite,
      body: Column(
        children: [
          // Sync status banner
          if (vm.syncStatus != null && _showSyncBanner)
            SyncStatusBanner(
              syncStatus: vm.syncStatus!,
              onDismiss: () {
                setState(() {
                  _showSyncBanner = false;
                });
              },
            ),

          // Search bar
          _buildSearchBar(vm),

          const Divider(height: 1, color: AppColors.mainBorder),

          // Email list
          Expanded(
            child: _buildEmailList(vm),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showComposeScreen(context),
        backgroundColor: AppColors.clay600,
        child: const Icon(Icons.edit, color: AppColors.neutralWhite),
      ),
    );
  }

  Widget _buildSearchBar(EmailViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.contentBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.mainBorder,
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.neutralInk,
                ),
                decoration: InputDecoration(
                  hintText: 'Search emails...',
                  hintStyle: TextStyle(
                    color: AppColors.sidebarTextSecondary.withOpacity(0.5),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.sidebarTextSecondary,
                    size: 20,
                  ),
                  suffixIcon: vm.isSearching
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            vm.clearSearch();
                          },
                          color: AppColors.sidebarTextSecondary,
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (query) => vm.searchEmails(query),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Refresh button
          Container(
            decoration: BoxDecoration(
              color: AppColors.contentBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.mainBorder,
                width: 0.5,
              ),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh,
                color: vm.isSyncing ? AppColors.clay600 : AppColors.sidebarText,
              ),
              onPressed: vm.isSyncing
                  ? null
                  : () {
                      setState(() {
                        _showSyncBanner = true;
                      });
                      vm.startSync();
                    },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailList(EmailViewModel vm) {
    if (vm.isLoading && vm.emails.isEmpty) {
      return _buildLoadingState();
    }

    if (vm.error != null && vm.emails.isEmpty) {
      return _buildErrorState(vm.error!, () => vm.loadEmails(refresh: true));
    }

    if (vm.emails.isEmpty) {
      return _buildEmptyState(vm.isSearching);
    }

    return RefreshIndicator(
      onRefresh: () => vm.loadEmails(refresh: true),
      color: AppColors.clay600,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: vm.emails.length + (vm.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == vm.emails.length) {
            return _buildLoadingMoreIndicator();
          }

          final email = vm.emails[index];
          return EmailListItem(
            email: email,
            isSelected: vm.selectedEmail?.id == email.id,
            onTap: () => _openEmailDetail(context, email),
            onStar: () => vm.toggleStar(email.id, !email.isStarred),
            onDelete: () => _confirmDelete(context, vm, email),
            onMarkRead: email.isUnread
                ? () => vm.markAsRead(email.id)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.clay600),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading emails...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.sidebarTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.clay600),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.clay300, AppColors.clay400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isSearching ? Icons.search_off : Icons.inbox_outlined,
              size: 40,
              color: AppColors.neutralWhite,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isSearching ? 'No results found' : 'No emails',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.neutralInk,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isSearching
                ? 'Try a different search term'
                : 'Your inbox is empty',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.sidebarTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.clay400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.neutralInk,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.sidebarTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.clay600,
                foregroundColor: AppColors.neutralWhite,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _openEmailDetail(BuildContext context, Email email) {
    context.read<EmailViewModel>().selectEmail(email);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EmailDetailScreen(),
      ),
    );
  }

  void _showComposeScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ComposeEmailScreen(),
      ),
    );
  }

  void _confirmDelete(BuildContext context, EmailViewModel vm, Email email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Email'),
        content: const Text('Are you sure you want to delete this email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              vm.deleteEmail(email.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
