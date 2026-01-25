/// Chat participant entity - Clean Architecture
///
/// Represents a participant in a chat room with their status and profile info.
library;

import 'package:flutter/foundation.dart';
import 'chat_enums.dart';

/// Represents a participant in a chat room
@immutable
class ChatParticipant {
  const ChatParticipant({
    required this.profileId,
    required this.roomId,
    required this.status,
    required this.joinedAt,
    this.fullName,
    this.avatarUrl,
    this.role,
    this.lastReadAt,
  });

  /// Participant's profile ID
  final String profileId;

  /// Room this participant belongs to
  final String roomId;

  /// Participant's conversation status
  final ConversationStatus status;

  /// When participant joined the room
  final DateTime joinedAt;

  /// Participant's full name (joined from profile)
  final String? fullName;

  /// Participant's avatar URL (joined from profile)
  final String? avatarUrl;

  /// Participant's role (joined from profile)
  final UserRole? role;

  /// When participant last read messages in this room
  final DateTime? lastReadAt;

  /// Whether participant is active in this room
  bool get isActive => status == ConversationStatus.active;

  /// Whether participant is pending
  bool get isPending => status == ConversationStatus.pending;

  /// Whether participant has archived the conversation
  bool get isArchived => status == ConversationStatus.archived;

  /// Display name for the participant
  String get displayName => fullName ?? 'Participant';

  /// Factory from Supabase row with joined profile
  /// Handles both snake_case (direct query) and camelCase (RPC) formats
  factory ChatParticipant.fromMap(Map<String, dynamic> map) {
    return ChatParticipant(
      profileId: map['profileId'] as String? ?? map['profile_id'] as String,
      roomId: map['roomId'] as String? ?? map['room_id'] as String,
      status: ConversationStatus.fromString(map['status'] as String?) ??
          ConversationStatus.active,
      joinedAt: _parseDateTime(map['joinedAt'] ?? map['joined_at'])!,
      fullName: map['fullName'] as String? ?? map['full_name'] as String?,
      avatarUrl: map['avatarUrl'] as String? ?? map['avatar_url'] as String?,
      role: UserRole.fromString(
          map['role'] as String? ?? map['user_role'] as String?),
      lastReadAt: _parseDateTime(map['lastReadAt'] ?? map['last_read_at']),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  ChatParticipant copyWith({
    String? profileId,
    String? roomId,
    ConversationStatus? status,
    DateTime? joinedAt,
    String? fullName,
    String? avatarUrl,
    UserRole? role,
    DateTime? lastReadAt,
  }) {
    return ChatParticipant(
      profileId: profileId ?? this.profileId,
      roomId: roomId ?? this.roomId,
      status: status ?? this.status,
      joinedAt: joinedAt ?? this.joinedAt,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      lastReadAt: lastReadAt ?? this.lastReadAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatParticipant &&
        other.profileId == profileId &&
        other.roomId == roomId &&
        other.status == status &&
        other.joinedAt == joinedAt &&
        other.fullName == fullName &&
        other.avatarUrl == avatarUrl &&
        other.role == role &&
        other.lastReadAt == lastReadAt;
  }

  @override
  int get hashCode => Object.hash(
        profileId,
        roomId,
        status,
        joinedAt,
        fullName,
        avatarUrl,
        role,
        lastReadAt,
      );

  @override
  String toString() =>
      'ChatParticipant($profileId, ${fullName ?? 'no name'}, $status)';
}
