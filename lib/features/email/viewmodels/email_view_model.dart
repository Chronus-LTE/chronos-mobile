import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:chronus/features/email/models/email.dart';
import 'package:chronus/features/email/services/email_service.dart';

/// Email ViewModel with ChangeNotifier for state management
/// Includes performance optimizations: debouncing, caching, selective updates
class EmailViewModel extends ChangeNotifier {
  final EmailService _emailService;

  // State
  List<Email> _emails = [];
  Email? _selectedEmail;
  SyncStatus? _syncStatus;
  MailFolder _currentFolder = SystemFolders.inbox;
  int _unreadCount = 0;

  // Loading states
  bool _isLoading = false;
  bool _isSyncing = false;
  bool _isLoadingMore = false;
  bool _isSending = false;

  // Error state
  String? _error;

  // Pagination
  int _currentOffset = 0;
  final int _limit = 20;
  bool _hasMore = true;

  // Search
  String _searchQuery = '';
  Timer? _searchDebounce;
  List<Email>? _searchResults;

  // Filters
  bool _unreadOnly = false;
  bool _starredOnly = false;

  // Sync status polling
  Timer? _syncStatusTimer;

  EmailViewModel(this._emailService);

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<Email> get emails => _searchResults ?? _emails;
  Email? get selectedEmail => _selectedEmail;
  SyncStatus? get syncStatus => _syncStatus;
  MailFolder get currentFolder => _currentFolder;
  int get unreadCount => _unreadCount;

  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  bool get isLoadingMore => _isLoadingMore;
  bool get isSending => _isSending;
  bool get hasMore => _hasMore;
  bool get isSearching => _searchQuery.isNotEmpty;

  String? get error => _error;

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize and load initial data
  Future<void> initialize() async {
    await Future.wait([
      loadEmails(),
      fetchUnreadCount(),
      fetchSyncStatus(),
    ]);
  }

  // ============================================================================
  // EMAIL OPERATIONS
  // ============================================================================

  /// Load emails for current folder
  Future<void> loadEmails({bool refresh = false}) async {
    if (refresh) {
      _currentOffset = 0;
      _hasMore = true;
      _emails.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _emailService.getEmails(
        label: _currentFolder.id,
        limit: _limit,
        offset: _currentOffset,
        unreadOnly: _unreadOnly,
        starredOnly: _starredOnly,
        useCache: !refresh,
      );

      if (refresh) {
        _emails = response.emails;
      } else {
        _emails.addAll(response.emails);
      }

      _hasMore = response.hasMore;
      _currentOffset = response.offset + response.emails.length;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading emails: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more emails (pagination)
  Future<void> loadMoreEmails() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final response = await _emailService.getEmails(
        label: _currentFolder.id,
        limit: _limit,
        offset: _currentOffset,
        unreadOnly: _unreadOnly,
        starredOnly: _starredOnly,
      );

      _emails.addAll(response.emails);
      _hasMore = response.hasMore;
      _currentOffset = response.offset + response.emails.length;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading more emails: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Select an email
  Future<void> selectEmail(Email email) async {
    _selectedEmail = email;
    notifyListeners();

    // Load full email details if needed
    if (email.bodyHtml == null && email.bodyPlain == null) {
      try {
        final fullEmail = await _emailService.getEmail(email.id);
        _selectedEmail = fullEmail;

        // Update in list as well
        final index = _emails.indexWhere((e) => e.id == email.id);
        if (index != -1) {
          _emails[index] = fullEmail;
        }

        notifyListeners();
      } catch (e) {
        debugPrint('Error loading email details: $e');
      }
    }
  }

  /// Search emails with debouncing (300ms)
  void searchEmails(String query) {
    _searchQuery = query;

    // Cancel previous debounce timer
    _searchDebounce?.cancel();

    if (query.isEmpty) {
      _searchResults = null;
      notifyListeners();
      return;
    }

    // Debounce search
    _searchDebounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await _emailService.searchEmails(query);
        _searchResults = results;
        notifyListeners();
      } catch (e) {
        _error = e.toString();
        debugPrint('Error searching emails: $e');
        notifyListeners();
      }
    });
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _searchResults = null;
    _searchDebounce?.cancel();
    notifyListeners();
  }

  // ============================================================================
  // EMAIL ACTIONS
  // ============================================================================

  /// Send email
  Future<bool> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      await _emailService.sendEmail(
        to: to,
        subject: subject,
        body: body,
      );

      // Refresh emails after sending
      await loadEmails(refresh: true);

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      debugPrint('Error sending email: $e');
      return false;
    }
  }

  /// Delete email
  Future<void> deleteEmail(int emailId) async {
    try {
      await _emailService.deleteEmail(emailId);

      // Remove from local list
      _emails.removeWhere((e) => e.id == emailId);

      if (_selectedEmail?.id == emailId) {
        _selectedEmail = null;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting email: $e');
      notifyListeners();
    }
  }

  /// Mark email as read
  Future<void> markAsRead(int emailId) async {
    try {
      await _emailService.markAsRead(emailId);

      // Update local state
      _updateEmailInList(emailId, (email) => email.copyWith(isUnread: false));
      await fetchUnreadCount();
    } catch (e) {
      debugPrint('Error marking as read: $e');
    }
  }

  /// Mark email as unread
  Future<void> markAsUnread(int emailId) async {
    try {
      await _emailService.markAsUnread(emailId);

      // Update local state
      _updateEmailInList(emailId, (email) => email.copyWith(isUnread: true));
      await fetchUnreadCount();
    } catch (e) {
      debugPrint('Error marking as unread: $e');
    }
  }

  /// Toggle star
  Future<void> toggleStar(int emailId, bool starred) async {
    try {
      if (starred) {
        await _emailService.starEmail(emailId);
      } else {
        await _emailService.unstarEmail(emailId);
      }

      // Update local state
      _updateEmailInList(emailId, (email) => email.copyWith(isStarred: starred));
    } catch (e) {
      debugPrint('Error toggling star: $e');
    }
  }

  // ============================================================================
  // FOLDER NAVIGATION
  // ============================================================================

  /// Switch to a different folder
  Future<void> switchFolder(MailFolder folder) async {
    if (_currentFolder.id == folder.id) return;

    _currentFolder = folder;
    _currentOffset = 0;
    _hasMore = true;
    _emails.clear();
    _selectedEmail = null;

    notifyListeners();

    await loadEmails();
  }

  // ============================================================================
  // FILTERS
  // ============================================================================

  /// Toggle unread filter
  Future<void> toggleUnreadFilter() async {
    _unreadOnly = !_unreadOnly;
    await loadEmails(refresh: true);
  }

  /// Toggle starred filter
  Future<void> toggleStarredFilter() async {
    _starredOnly = !_starredOnly;
    await loadEmails(refresh: true);
  }

  // ============================================================================
  // SYNC OPERATIONS
  // ============================================================================

  /// Start sync
  Future<void> startSync({bool forceFull = false}) async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _emailService.startSync(forceFull: forceFull);

      // Start polling sync status
      _startSyncStatusPolling();
    } catch (e) {
      _error = e.toString();
      _isSyncing = false;
      debugPrint('Error starting sync: $e');
      notifyListeners();
    }
  }

  /// Fetch sync status
  Future<void> fetchSyncStatus() async {
    try {
      _syncStatus = await _emailService.getSyncStatus();
      _isSyncing = _syncStatus?.isSyncing ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching sync status: $e');
    }
  }

  /// Start polling sync status
  void _startSyncStatusPolling() {
    _syncStatusTimer?.cancel();
    _syncStatusTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      await fetchSyncStatus();

      // Stop polling when sync is complete
      if (_syncStatus?.isCompleted == true || _syncStatus?.isFailed == true) {
        timer.cancel();
        _isSyncing = false;

        // Refresh emails after sync completes
        if (_syncStatus?.isCompleted == true) {
          await loadEmails(refresh: true);
        }

        notifyListeners();
      }
    });
  }

  // ============================================================================
  // METADATA
  // ============================================================================

  /// Fetch unread count
  Future<void> fetchUnreadCount() async {
    try {
      _unreadCount = await _emailService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Update email in list
  void _updateEmailInList(int emailId, Email Function(Email) updater) {
    final index = _emails.indexWhere((e) => e.id == emailId);
    if (index != -1) {
      _emails[index] = updater(_emails[index]);

      if (_selectedEmail?.id == emailId) {
        _selectedEmail = _emails[index];
      }

      notifyListeners();
    }
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _syncStatusTimer?.cancel();
    super.dispose();
  }
}
