import 'package:intl/intl.dart';

/// Email model matching backend schema
class Email {
  final int id;
  final String gmailId;
  final String threadId;
  final String subject;
  final String from;
  final String to;
  final String? cc;
  final String snippet;
  final String? bodyPlain;
  final String? bodyHtml;
  final DateTime date;
  final List<String> labels;
  final bool isUnread;
  final bool isStarred;
  final bool isImportant;
  final bool hasAttachments;
  final List<EmailAttachment> attachments;

  Email({
    required this.id,
    required this.gmailId,
    required this.threadId,
    required this.subject,
    required this.from,
    required this.to,
    this.cc,
    required this.snippet,
    this.bodyPlain,
    this.bodyHtml,
    required this.date,
    required this.labels,
    required this.isUnread,
    required this.isStarred,
    this.isImportant = false,
    this.hasAttachments = false,
    this.attachments = const [],
  });

  /// Factory constructor from JSON with performance optimization
  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      id: json['id'] as int,
      gmailId: json['gmail_id'] as String,
      threadId: json['thread_id'] as String,
      subject: json['subject'] as String? ?? '(No Subject)',
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
      cc: json['cc'] as String?,
      snippet: json['snippet'] as String? ?? '',
      bodyPlain: json['body_plain'] as String?,
      bodyHtml: json['body_html'] as String?,
      date: DateTime.parse(json['date'] as String),
      labels: (json['labels'] as List<dynamic>?)?.cast<String>() ?? [],
      isUnread: json['isUnread'] as bool? ?? false,
      isStarred: json['isStarred'] as bool? ?? false,
      isImportant: json['is_important'] as bool? ?? false,
      hasAttachments: json['has_attachments'] as bool? ?? false,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((a) => EmailAttachment.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gmail_id': gmailId,
      'thread_id': threadId,
      'subject': subject,
      'from': from,
      'to': to,
      'cc': cc,
      'snippet': snippet,
      'body_plain': bodyPlain,
      'body_html': bodyHtml,
      'date': date.toIso8601String(),
      'labels': labels,
      'isUnread': isUnread,
      'isStarred': isStarred,
      'is_important': isImportant,
      'has_attachments': hasAttachments,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  /// Get formatted date for display (performance optimized)
  String getFormattedDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final emailDate = DateTime(date.year, date.month, date.day);

    if (emailDate == today) {
      return DateFormat('HH:mm').format(date);
    } else if (emailDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return DateFormat('EEE').format(date); // Mon, Tue, etc.
    } else {
      return DateFormat('MMM d').format(date); // Jan 15
    }
  }

  /// Get sender name from email address
  String getSenderName() {
    // Extract name from "Name <email@example.com>" format
    final match = RegExp(r'^([^<]+)').firstMatch(from);
    if (match != null) {
      return match.group(1)!.trim();
    }
    return from;
  }

  /// Get sender initials for avatar
  String getSenderInitials() {
    final name = getSenderName();
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Copy with method for immutable updates
  Email copyWith({
    int? id,
    String? gmailId,
    String? threadId,
    String? subject,
    String? from,
    String? to,
    String? cc,
    String? snippet,
    String? bodyPlain,
    String? bodyHtml,
    DateTime? date,
    List<String>? labels,
    bool? isUnread,
    bool? isStarred,
    bool? isImportant,
    bool? hasAttachments,
    List<EmailAttachment>? attachments,
  }) {
    return Email(
      id: id ?? this.id,
      gmailId: gmailId ?? this.gmailId,
      threadId: threadId ?? this.threadId,
      subject: subject ?? this.subject,
      from: from ?? this.from,
      to: to ?? this.to,
      cc: cc ?? this.cc,
      snippet: snippet ?? this.snippet,
      bodyPlain: bodyPlain ?? this.bodyPlain,
      bodyHtml: bodyHtml ?? this.bodyHtml,
      date: date ?? this.date,
      labels: labels ?? this.labels,
      isUnread: isUnread ?? this.isUnread,
      isStarred: isStarred ?? this.isStarred,
      isImportant: isImportant ?? this.isImportant,
      hasAttachments: hasAttachments ?? this.hasAttachments,
      attachments: attachments ?? this.attachments,
    );
  }
}

/// Email attachment model
class EmailAttachment {
  final int id;
  final String filename;
  final String? mimeType;
  final int? size;
  final bool isDownloaded;

  EmailAttachment({
    required this.id,
    required this.filename,
    this.mimeType,
    this.size,
    this.isDownloaded = false,
  });

  factory EmailAttachment.fromJson(Map<String, dynamic> json) {
    return EmailAttachment(
      id: json['id'] as int,
      filename: json['filename'] as String,
      mimeType: json['mime_type'] as String?,
      size: json['size'] as int?,
      isDownloaded: json['is_downloaded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'mime_type': mimeType,
      'size': size,
      'is_downloaded': isDownloaded,
    };
  }

  /// Get formatted file size
  String getFormattedSize() {
    if (size == null) return 'Unknown size';
    final kb = size! / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

/// Sync status model
class SyncStatus {
  final String status; // pending, syncing, completed, failed
  final String? syncType; // initial, incremental
  final int totalMessages;
  final int syncedMessages;
  final int failedMessages;
  final double progressPercentage;
  final DateTime? lastSyncDate;
  final String? lastError;

  SyncStatus({
    required this.status,
    this.syncType,
    this.totalMessages = 0,
    this.syncedMessages = 0,
    this.failedMessages = 0,
    this.progressPercentage = 0.0,
    this.lastSyncDate,
    this.lastError,
  });

  factory SyncStatus.fromJson(Map<String, dynamic> json) {
    return SyncStatus(
      status: json['status'] as String,
      syncType: json['sync_type'] as String?,
      totalMessages: json['total_messages'] as int? ?? 0,
      syncedMessages: json['synced_messages'] as int? ?? 0,
      failedMessages: json['failed_messages'] as int? ?? 0,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      lastSyncDate: json['last_sync_date'] != null
          ? DateTime.parse(json['last_sync_date'] as String)
          : null,
      lastError: json['last_error'] as String?,
    );
  }

  bool get isSyncing => status == 'syncing';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isPending => status == 'pending';
}

/// Mail folder model for navigation
class MailFolder {
  final String id;
  final String name;
  final String icon;
  final FolderType type;
  final int? unreadCount;

  const MailFolder({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.unreadCount,
  });
}

/// Folder type enum
enum FolderType {
  inbox,
  sent,
  drafts,
  starred,
  trash,
  spam,
  important,
}

/// System folders constants
class SystemFolders {
  static const inbox = MailFolder(
    id: 'INBOX',
    name: 'Inbox',
    icon: 'inbox',
    type: FolderType.inbox,
  );

  static const sent = MailFolder(
    id: 'SENT',
    name: 'Sent',
    icon: 'send',
    type: FolderType.sent,
  );

  static const drafts = MailFolder(
    id: 'DRAFT',
    name: 'Drafts',
    icon: 'drafts',
    type: FolderType.drafts,
  );

  static const starred = MailFolder(
    id: 'STARRED',
    name: 'Starred',
    icon: 'star',
    type: FolderType.starred,
  );

  static const trash = MailFolder(
    id: 'TRASH',
    name: 'Trash',
    icon: 'delete',
    type: FolderType.trash,
  );

  static const spam = MailFolder(
    id: 'SPAM',
    name: 'Spam',
    icon: 'report',
    type: FolderType.spam,
  );

  static const important = MailFolder(
    id: 'IMPORTANT',
    name: 'Important',
    icon: 'flag',
    type: FolderType.important,
  );

  static const List<MailFolder> all = [
    inbox,
    sent,
    drafts,
    starred,
    important,
    spam,
    trash,
  ];
}

/// Email list response model
class EmailListResponse {
  final List<Email> emails;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  EmailListResponse({
    required this.emails,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  factory EmailListResponse.fromJson(Map<String, dynamic> json) {
    return EmailListResponse(
      emails: (json['emails'] as List<dynamic>)
          .map((e) => Email.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      hasMore: json['has_more'] as bool,
    );
  }
}
