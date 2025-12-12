/// Wedding Client entity - represents a wedding from the pro's perspective
///
/// Used in Weddings Hub Pro to display the list of weddings
/// where the professional is a participant.
library;

import 'package:flutter/foundation.dart';

@immutable
class WeddingClient {
  const WeddingClient({
    required this.weddingId,
    required this.participantId,
    required this.brideName,
    this.brideAvatarUrl,
    this.weddingName,
    this.eventDate,
    this.venueAddress,
    this.coverImageUrl,
    this.noteForPros,
    this.teamChatRoomId,
    this.isMuted = false,
    this.joinedAt,
    required this.brideProfileId,
  });

  final String weddingId;
  final String participantId;
  final String brideProfileId;
  final String brideName;
  final String? brideAvatarUrl;
  final String? weddingName;
  final DateTime? eventDate;
  final String? venueAddress;
  final String? coverImageUrl;
  final String? noteForPros;
  final String? teamChatRoomId;
  final bool isMuted;
  final DateTime? joinedAt;

  /// Days until wedding
  int? get daysUntilWedding {
    if (eventDate == null) return null;
    final now = DateTime.now();
    if (now.isAfter(eventDate!)) return 0;
    return eventDate!.difference(now).inDays;
  }

  /// Factory from Supabase JSON
  factory WeddingClient.fromJson(Map<String, dynamic> json) {
    final wedding = json['weddings'] as Map<String, dynamic>?;
    final brideProfile = wedding?['profiles'] as Map<String, dynamic>?;

    return WeddingClient(
      weddingId: json['wedding_id'] as String,
      participantId: json['id'] as String? ?? '',
      brideProfileId: wedding?['bride_profile_id'] as String? ?? '',
      brideName: brideProfile?['full_name'] as String? ?? 'Unknown',
      brideAvatarUrl: brideProfile?['avatar_url'] as String?,
      weddingName: wedding?['wedding_name'] as String?,
      eventDate: wedding?['event_date'] != null
          ? DateTime.parse(wedding!['event_date'] as String)
          : null,
      venueAddress: wedding?['venue_label'] as String?,
      coverImageUrl: wedding?['cover_image_url'] as String?,
      noteForPros: wedding?['note_for_pros'] as String?,
      teamChatRoomId: null, // Fetched separately
      isMuted: json['is_muted'] as bool? ?? false,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingClient && other.weddingId == weddingId;
  }

  @override
  int get hashCode => weddingId.hashCode;
}
