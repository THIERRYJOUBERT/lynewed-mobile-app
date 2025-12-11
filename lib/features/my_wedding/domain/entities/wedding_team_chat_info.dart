/// Wedding Team Chat Info entity
///
/// Contains information about the wedding team chat room for display in My Wedding Page.
library;

import 'package:flutter/foundation.dart';

/// Wedding Team Chat Info - Data for the wedding team chat item
@immutable
class WeddingTeamChatInfo {
  const WeddingTeamChatInfo({
    required this.roomId,
    required this.weddingId,
    this.participantsCount = 0,
    this.unreadCount = 0,
    this.participantAvatars = const [],
  });

  /// Chat room ID
  final String roomId;

  /// Wedding ID
  final String weddingId;

  /// Number of participants in the chat
  final int participantsCount;

  /// Number of unread messages
  final int unreadCount;

  /// List of participant avatar URLs (max 4 for display)
  final List<String> participantAvatars;

  /// Factory from Supabase JSON
  factory WeddingTeamChatInfo.fromJson(Map<String, dynamic> json) {
    final participants = json['chat_room_participants'] as List<dynamic>? ?? [];
    final avatars = <String>[];
    
    for (final p in participants) {
      final profile = p['profiles'] as Map<String, dynamic>?;
      final avatarUrl = profile?['avatar_url'] as String?;
      if (avatarUrl != null && avatarUrl.isNotEmpty && avatars.length < 4) {
        avatars.add(avatarUrl);
      }
    }

    return WeddingTeamChatInfo(
      roomId: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      participantsCount: participants.length,
      unreadCount: json['unread_count'] as int? ?? 0,
      participantAvatars: avatars,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingTeamChatInfo && other.roomId == roomId;
  }

  @override
  int get hashCode => roomId.hashCode;

  @override
  String toString() => 'WeddingTeamChatInfo($roomId, $participantsCount participants)';
}
