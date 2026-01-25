/// VideoSession entity for video call feature.
///
/// Represents a video call session stored in Supabase.
/// Contains Agora channel information and participant details.
library;

import 'package:flutter/foundation.dart';

/// Status of a video session in the database.
enum VideoSessionStatus {
  pending,
  ringing,
  connected,
  ended,
  missed,
  declined,
}

/// Video session entity.
///
/// Represents a video call session between two users.
/// Contains Agora SDK configuration (channel, token, uid) and
/// information about both participants.
@immutable
class VideoSession {
  /// Creates a video session.
  const VideoSession({
    required this.id,
    required this.channelName,
    required this.token,
    required this.uid,
    required this.callerProfileId,
    required this.receiverProfileId,
    required this.status,
    required this.createdAt,
    this.endedAt,
    this.callerName,
    this.receiverName,
    this.callerAvatarUrl,
    this.receiverAvatarUrl,
  });

  /// UUID of the session.
  final String id;

  /// Agora channel name for this session.
  final String channelName;

  /// Agora token for authentication.
  final String token;

  /// Agora user ID for the current user.
  final int uid;

  /// Profile ID of the caller.
  final String callerProfileId;

  /// Profile ID of the receiver.
  final String receiverProfileId;

  /// Current status of the session.
  final VideoSessionStatus status;

  /// When the session was created.
  final DateTime createdAt;

  /// When the session ended (null if still active).
  final DateTime? endedAt;

  /// Display name of the caller.
  final String? callerName;

  /// Display name of the receiver.
  final String? receiverName;

  /// Avatar URL of the caller.
  final String? callerAvatarUrl;

  /// Avatar URL of the receiver.
  final String? receiverAvatarUrl;

  /// Whether the session is pending.
  bool get isPending => status == VideoSessionStatus.pending;

  /// Whether the session is ringing.
  bool get isRinging => status == VideoSessionStatus.ringing;

  /// Whether the session is connected.
  bool get isConnected => status == VideoSessionStatus.connected;

  /// Whether the session has ended (ended, missed, or declined).
  bool get isEnded =>
      status == VideoSessionStatus.ended ||
      status == VideoSessionStatus.missed ||
      status == VideoSessionStatus.declined;

  /// Duration of the call (null if not ended).
  Duration? get duration {
    if (endedAt == null) return null;
    return endedAt!.difference(createdAt);
  }

  /// Creates a VideoSession from Supabase JSON.
  factory VideoSession.fromJson(Map<String, dynamic> json) {
    return VideoSession(
      id: json['id'] as String,
      channelName: json['channel_name'] as String,
      token: json['token'] as String,
      uid: json['uid'] as int,
      callerProfileId: json['caller_profile_id'] as String,
      receiverProfileId: json['receiver_profile_id'] as String,
      status: _parseStatus(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      callerName: json['caller_name'] as String?,
      receiverName: json['receiver_name'] as String?,
      callerAvatarUrl: json['caller_avatar_url'] as String?,
      receiverAvatarUrl: json['receiver_avatar_url'] as String?,
    );
  }

  static VideoSessionStatus _parseStatus(String? value) {
    switch (value) {
      case 'ringing':
        return VideoSessionStatus.ringing;
      case 'connected':
        return VideoSessionStatus.connected;
      case 'ended':
        return VideoSessionStatus.ended;
      case 'missed':
        return VideoSessionStatus.missed;
      case 'declined':
        return VideoSessionStatus.declined;
      default:
        return VideoSessionStatus.pending;
    }
  }

  /// Converts to JSON for Supabase.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'channel_name': channelName,
      'token': token,
      'uid': uid,
      'caller_profile_id': callerProfileId,
      'receiver_profile_id': receiverProfileId,
      'status': status.name,
    };

    if (endedAt != null) {
      json['ended_at'] = endedAt!.toIso8601String();
    }

    return json;
  }

  /// Creates a copy with updated values.
  VideoSession copyWith({
    String? id,
    String? channelName,
    String? token,
    int? uid,
    String? callerProfileId,
    String? receiverProfileId,
    VideoSessionStatus? status,
    DateTime? createdAt,
    DateTime? endedAt,
    String? callerName,
    String? receiverName,
    String? callerAvatarUrl,
    String? receiverAvatarUrl,
  }) {
    return VideoSession(
      id: id ?? this.id,
      channelName: channelName ?? this.channelName,
      token: token ?? this.token,
      uid: uid ?? this.uid,
      callerProfileId: callerProfileId ?? this.callerProfileId,
      receiverProfileId: receiverProfileId ?? this.receiverProfileId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      callerName: callerName ?? this.callerName,
      receiverName: receiverName ?? this.receiverName,
      callerAvatarUrl: callerAvatarUrl ?? this.callerAvatarUrl,
      receiverAvatarUrl: receiverAvatarUrl ?? this.receiverAvatarUrl,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoSession && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'VideoSession($id, $channelName, ${status.name})';
}
