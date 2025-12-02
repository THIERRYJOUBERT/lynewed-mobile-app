/// Conversation entity - Clean Architecture
/// 
/// Represents a conversation in the messages list.
/// Combines room info with participant info and last message.
library;

import 'package:flutter/foundation.dart';
import 'chat_enums.dart';

/// Represents a conversation item in the messages list
@immutable
class Conversation {
  const Conversation({
    required this.roomId,
    required this.roomType,
    required this.conversationStatus,
    required this.unreadCount,
    this.lastMessageType,
    this.lastMessageText,
    this.lastMessageAt,
    this.otherProfileId,
    this.otherFullName,
    this.otherAvatarUrl,
    this.otherRole,
    // Public room fields
    this.publicTitle,
    this.publicCoverUrl,
    this.audienceRole,
  });

  /// Room UUID
  final String roomId;

  /// Room type (private or public)
  final RoomType roomType;

  /// Current user's conversation status
  final ConversationStatus conversationStatus;

  /// Number of unread messages
  final int unreadCount;

  /// Last message type
  final MessageType? lastMessageType;

  /// Last message text (or preview)
  final String? lastMessageText;

  /// When last message was sent
  final DateTime? lastMessageAt;

  /// Other participant's profile ID (for private rooms)
  final String? otherProfileId;

  /// Other participant's full name
  final String? otherFullName;

  /// Other participant's avatar URL
  final String? otherAvatarUrl;

  /// Other participant's role
  final UserRole? otherRole;

  /// Public room title
  final String? publicTitle;

  /// Public room cover image URL
  final String? publicCoverUrl;

  /// Audience role for public room
  final UserRole? audienceRole;

  /// Whether this is a public room
  bool get isPublic => roomType == RoomType.public;

  /// Display name for the conversation
  String get displayName {
    if (isPublic) {
      return publicTitle ?? 'Salon public';
    }
    return otherFullName ?? 'Conversation';
  }

  /// Display avatar URL
  String? get displayAvatarUrl {
    if (isPublic) {
      return publicCoverUrl;
    }
    return otherAvatarUrl;
  }

  /// Last message preview text
  String get lastMessagePreview {
    if (lastMessageText != null && lastMessageText!.isNotEmpty) {
      return lastMessageText!;
    }
    switch (lastMessageType) {
      case MessageType.image:
        return '📷 Image';
      case MessageType.audio:
        return '🎵 Audio';
      default:
        return '';
    }
  }

  /// Factory from Supabase RPC result
  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      roomId: map['roomId'] as String? ?? map['room_id'] as String,
      roomType: RoomType.fromString(map['roomType'] as String? ?? map['room_type'] as String?) ?? RoomType.private,
      conversationStatus: ConversationStatus.fromString(
        map['conversationStatus'] as String? ?? map['conversation_status'] as String?
      ) ?? ConversationStatus.active,
      unreadCount: (map['unreadCount'] ?? map['unread_count'] ?? 0) as int,
      lastMessageType: MessageType.fromString(
        map['lastMessageType'] as String? ?? map['last_message_type'] as String?
      ),
      lastMessageText: map['lastMessageText'] as String? ?? map['last_message_text'] as String?,
      lastMessageAt: _parseDateTime(map['lastMessageAt'] ?? map['last_message_at']),
      otherProfileId: map['otherProfileId'] as String? ?? map['other_profile_id'] as String?,
      otherFullName: map['otherFullName'] as String? ?? map['other_full_name'] as String?,
      otherAvatarUrl: map['otherAvatarUrl'] as String? ?? map['other_avatar_url'] as String?,
      otherRole: UserRole.fromString(map['otherRole'] as String? ?? map['other_role'] as String?),
      publicTitle: map['publicTitle'] as String? ?? map['public_title'] as String?,
      publicCoverUrl: map['publicCoverUrl'] as String? ?? map['public_cover_url'] as String?,
      audienceRole: UserRole.fromString(map['audienceRole'] as String? ?? map['audience_role'] as String?),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Conversation copyWith({
    String? roomId,
    RoomType? roomType,
    ConversationStatus? conversationStatus,
    int? unreadCount,
    MessageType? lastMessageType,
    String? lastMessageText,
    DateTime? lastMessageAt,
    String? otherProfileId,
    String? otherFullName,
    String? otherAvatarUrl,
    UserRole? otherRole,
    String? publicTitle,
    String? publicCoverUrl,
    UserRole? audienceRole,
  }) {
    return Conversation(
      roomId: roomId ?? this.roomId,
      roomType: roomType ?? this.roomType,
      conversationStatus: conversationStatus ?? this.conversationStatus,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessageType: lastMessageType ?? this.lastMessageType,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      otherProfileId: otherProfileId ?? this.otherProfileId,
      otherFullName: otherFullName ?? this.otherFullName,
      otherAvatarUrl: otherAvatarUrl ?? this.otherAvatarUrl,
      otherRole: otherRole ?? this.otherRole,
      publicTitle: publicTitle ?? this.publicTitle,
      publicCoverUrl: publicCoverUrl ?? this.publicCoverUrl,
      audienceRole: audienceRole ?? this.audienceRole,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Conversation &&
        other.roomId == roomId &&
        other.roomType == roomType &&
        other.conversationStatus == conversationStatus &&
        other.unreadCount == unreadCount &&
        other.lastMessageType == lastMessageType &&
        other.lastMessageText == lastMessageText &&
        other.lastMessageAt == lastMessageAt &&
        other.otherProfileId == otherProfileId &&
        other.otherFullName == otherFullName &&
        other.otherAvatarUrl == otherAvatarUrl &&
        other.otherRole == otherRole &&
        other.publicTitle == publicTitle &&
        other.publicCoverUrl == publicCoverUrl &&
        other.audienceRole == audienceRole;
  }

  @override
  int get hashCode => Object.hash(
        roomId,
        roomType,
        conversationStatus,
        unreadCount,
        lastMessageType,
        lastMessageText,
        lastMessageAt,
        otherProfileId,
        otherFullName,
        otherAvatarUrl,
        otherRole,
        publicTitle,
        publicCoverUrl,
        audienceRole,
      );

  @override
  String toString() => 'Conversation($roomId, $displayName, unread: $unreadCount)';
}
