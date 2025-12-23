import 'dart:convert';
import 'package:chronus/features/email/models/email.dart';
import 'package:chronus/core/services/api_client.dart';

/// Email service for all Gmail API operations
/// Includes performance optimizations: connection pooling, response caching, error handling
class EmailService {
  final ApiClient _apiClient;

  // Cache for email list responses (TTL: 30 seconds)
  final Map<String, _CachedResponse> _cache = {};
  static const _cacheDuration = Duration(seconds: 30);

  EmailService(this._apiClient);

  /// Start Gmail sync (initial or incremental)
  Future<Map<String, dynamic>> startSync({
    bool forceFull = false,
    int maxMessages = 1000,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/gmail/sync',
      body: {
        'force_full': forceFull,
        'max_messages': maxMessages,
      },
    );

    if (response.statusCode == 202) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to start sync: ${response.body}');
    }
  }

  /// Get current sync status
  Future<SyncStatus> getSyncStatus() async {
    final response = await _apiClient.get('/api/v1/gmail/sync/status');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return SyncStatus.fromJson(data);
    } else {
      throw Exception('Failed to get sync status: ${response.body}');
    }
  }

  /// List emails with filters and pagination
  /// Includes caching for performance
  Future<EmailListResponse> getEmails({
    String? label,
    int limit = 20,
    int offset = 0,
    bool unreadOnly = false,
    bool starredOnly = false,
    bool useCache = true,
  }) async {
    // Generate cache key
    final cacheKey = 'emails_${label}_${limit}_${offset}_${unreadOnly}_$starredOnly';

    // Check cache
    if (useCache && _cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        return cached.response as EmailListResponse;
      } else {
        _cache.remove(cacheKey);
      }
    }

    // Build query parameters
    final queryParams = <String, String>{
      'limit': limit.toString(),
      'offset': offset.toString(),
    };

    if (label != null) queryParams['label'] = label;
    if (unreadOnly) queryParams['unread_only'] = 'true';
    if (starredOnly) queryParams['starred_only'] = 'true';

    final response = await _apiClient.get(
      '/api/v1/gmail/emails',
      queryParams: queryParams,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final emailListResponse = EmailListResponse.fromJson(data);

      // Cache the response
      if (useCache) {
        _cache[cacheKey] = _CachedResponse(
          response: emailListResponse,
          timestamp: DateTime.now(),
        );
      }

      return emailListResponse;
    } else {
      throw Exception('Failed to load emails: ${response.body}');
    }
  }

  /// Get single email by ID
  Future<Email> getEmail(int emailId) async {
    final response = await _apiClient.get('/api/v1/gmail/emails/$emailId');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return Email.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Email not found');
    } else {
      throw Exception('Failed to load email: ${response.body}');
    }
  }

  /// Search emails
  Future<List<Email>> searchEmails(String query, {int limit = 20}) async {
    final response = await _apiClient.get(
      '/api/v1/gmail/search',
      queryParams: {
        'q': query,
        'limit': limit.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final emails = (data['emails'] as List<dynamic>)
          .map((e) => Email.fromJson(e as Map<String, dynamic>))
          .toList();
      return emails;
    } else {
      throw Exception('Failed to search emails: ${response.body}');
    }
  }

  /// Send email
  Future<Map<String, dynamic>> sendEmail({
    required String to,
    required String subject,
    required String body,
  }) async {
    final response = await _apiClient.post(
      '/api/v1/gmail/send',
      body: {
        'to': to,
        'subject': subject,
        'body': body,
      },
    );

    if (response.statusCode == 201) {
      // Clear cache after sending
      _clearCache();
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to send email: ${response.body}');
    }
  }

  /// Delete email
  Future<void> deleteEmail(int emailId) async {
    final response = await _apiClient.delete('/api/v1/gmail/emails/$emailId');

    if (response.statusCode == 204) {
      // Clear cache after deletion
      _clearCache();
      return;
    } else {
      throw Exception('Failed to delete email: ${response.body}');
    }
  }

  // Mark email as read
  Future<void> markAsRead(int emailId) async {
    final response = await _apiClient.post('/api/v1/gmail/emails/$emailId/mark-read');

    if (response.statusCode == 200) {
      _clearCache();
      return;
    } else {
      throw Exception('Failed to mark as read: ${response.body}');
    }
  }

  /// Mark email as unread
  Future<void> markAsUnread(int emailId) async {
    final response = await _apiClient.post('/api/v1/gmail/emails/$emailId/mark-unread');

    if (response.statusCode == 200) {
      _clearCache();
      return;
    } else {
      throw Exception('Failed to mark as unread: ${response.body}');
    }
  }

  /// Star email
  Future<void> starEmail(int emailId) async {
    final response = await _apiClient.post('/api/v1/gmail/emails/$emailId/star');

    if (response.statusCode == 200) {
      _clearCache();
      return;
    } else {
      throw Exception('Failed to star email: ${response.body}');
    }
  }

  /// Unstar email
  Future<void> unstarEmail(int emailId) async {
    final response = await _apiClient.post('/api/v1/gmail/emails/$emailId/unstar');

    if (response.statusCode == 200) {
      _clearCache();
      return;
    } else {
      throw Exception('Failed to unstar email: ${response.body}');
    }
  }

  // METADATA

  /// Get unread count
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('/api/v1/gmail/unread-count');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data['unread_count'] as int;
    } else {
      throw Exception('Failed to get unread count: ${response.body}');
    }
  }
  /// Clear all cached responses
  void _clearCache() {
    _cache.clear();
  }

  /// Clear specific cache entry
  void clearCacheForKey(String key) {
    _cache.remove(key);
  }

  /// Clear expired cache entries
  void clearExpiredCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) {
      return now.difference(value.timestamp) >= _cacheDuration;
    });
  }
}

/// Internal class for caching responses
class _CachedResponse {
  final dynamic response;
  final DateTime timestamp;

  _CachedResponse({
    required this.response,
    required this.timestamp,
  });
}
