/// Weddings Hub Repository Interface
///
/// Defines the contract for pro-side wedding operations.
library;

import '../entities/wedding_client.dart';

/// Result wrapper for repository operations
class WeddingsHubResult<T> {
  const WeddingsHubResult.success(this.data) : error = null;
  const WeddingsHubResult.failure(this.error) : data = null;

  final T? data;
  final String? error;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}

/// Weddings Hub Repository Interface
abstract class WeddingsHubRepository {
  /// Get all weddings where the pro is an active participant
  Future<WeddingsHubResult<List<WeddingClient>>> getMyWeddingsAsPro();

  /// Get a single wedding client detail
  Future<WeddingsHubResult<WeddingClient?>> getWeddingClient({
    required String weddingId,
  });

  /// Leave a wedding (pro quits)
  Future<WeddingsHubResult<void>> leaveWedding({
    required String weddingId,
    required String reason,
  });

  /// Toggle mute status for a wedding
  Future<WeddingsHubResult<void>> toggleMuteWedding({
    required String weddingId,
    required bool isMuted,
  });

  /// Get wedding team chat room ID
  Future<WeddingsHubResult<String?>> getWeddingTeamChatId({
    required String weddingId,
  });

  /// Get wedding team chat info with participants and unread count
  Future<WeddingsHubResult<TeamChatInfo?>> getWeddingTeamChatInfo({
    required String weddingId,
  });

  /// Ensure pro is added as participant to wedding team chat
  Future<WeddingsHubResult<void>> ensureProInWeddingTeamChat({
    required String weddingId,
  });
}

/// Team Chat Info for pro side
class TeamChatInfo {
  const TeamChatInfo({
    required this.roomId,
    required this.weddingId,
    this.participantsCount = 0,
    this.unreadCount = 0,
    this.participantAvatars = const [],
  });

  final String roomId;
  final String weddingId;
  final int participantsCount;
  final int unreadCount;
  final List<String> participantAvatars;

  factory TeamChatInfo.fromJson(Map<String, dynamic> json) {
    final participants = json['chat_room_participants'] as List<dynamic>? ?? [];
    final avatars = <String>[];
    
    for (final p in participants) {
      final profile = p['profiles'] as Map<String, dynamic>?;
      final avatarUrl = profile?['avatar_url'] as String?;
      if (avatarUrl != null && avatarUrl.isNotEmpty && avatars.length < 5) {
        avatars.add(avatarUrl);
      }
    }

    return TeamChatInfo(
      roomId: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      participantsCount: participants.length,
      unreadCount: json['unread_count'] as int? ?? 0,
      participantAvatars: avatars,
    );
  }
}
