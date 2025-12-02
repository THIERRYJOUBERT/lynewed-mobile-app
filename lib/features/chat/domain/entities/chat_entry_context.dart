/// Chat entry context entity - Clean Architecture
/// 
/// Result of open_or_prepare_contact_context RPC.
/// Determines how to handle contact initiation.
library;

import 'package:flutter/foundation.dart';
import 'chat_enums.dart';

/// Context returned when attempting to open/create a chat
@immutable
class ChatEntryContext {
  const ChatEntryContext({
    required this.status,
    this.roomId,
    this.requestId,
    this.otherProfileId,
    this.otherFullName,
    this.otherAvatarUrl,
    this.otherRole,
    this.isPublic = false,
    this.isRoomEmpty = true,
    this.firstMessageTextOnly = false,
    this.limitToSingleInitialMessage = false,
    this.viewerIsReviewer = false,
    this.conversationStatus,
    this.reason,
  });

  /// Status of the contact attempt
  final ChatEntryStatus status;

  /// Room ID if room exists
  final String? roomId;

  /// Request ID if there's a pending request
  final String? requestId;

  /// Other participant's profile ID
  final String? otherProfileId;

  /// Other participant's full name
  final String? otherFullName;

  /// Other participant's avatar URL
  final String? otherAvatarUrl;

  /// Other participant's role
  final UserRole? otherRole;

  /// Whether this is a public room
  final bool isPublic;

  /// Whether the room has no messages yet
  final bool isRoomEmpty;

  /// Whether first message must be text only
  final bool firstMessageTextOnly;

  /// Whether Pro is limited to single initial message (deprecated with new flow)
  final bool limitToSingleInitialMessage;

  /// Whether current user can accept/decline request
  final bool viewerIsReviewer;

  /// Current conversation status
  final ConversationStatus? conversationStatus;

  /// Error reason if status is error/notAllowed
  final String? reason;

  /// Whether we can navigate to chat directly
  bool get canNavigateToChat => 
      status == ChatEntryStatus.roomReady || 
      status == ChatEntryStatus.requestPending;

  /// Whether we need to show ContactRequestSheet first
  bool get requiresContactRequest => status == ChatEntryStatus.requiresRequest;

  /// Whether contact is blocked
  bool get isBlocked => status == ChatEntryStatus.blocked;

  /// Whether there's an error
  bool get hasError => status == ChatEntryStatus.error || status == ChatEntryStatus.notAllowed;

  /// Factory from Supabase RPC result
  factory ChatEntryContext.fromMap(Map<String, dynamic> map) {
    return ChatEntryContext(
      status: ChatEntryStatus.fromString(map['status'] as String?) ?? ChatEntryStatus.error,
      roomId: map['roomId'] as String?,
      requestId: map['requestId'] as String?,
      otherProfileId: map['otherProfileId'] as String?,
      otherFullName: map['otherFullName'] as String?,
      otherAvatarUrl: map['otherAvatarUrl'] as String?,
      otherRole: UserRole.fromString(map['otherRole'] as String?),
      isPublic: map['isPublic'] as bool? ?? false,
      isRoomEmpty: map['isRoomEmpty'] as bool? ?? true,
      firstMessageTextOnly: map['firstMessageTextOnly'] as bool? ?? false,
      limitToSingleInitialMessage: map['limitToSingleInitialMessage'] as bool? ?? false,
      viewerIsReviewer: map['viewerIsReviewer'] as bool? ?? false,
      conversationStatus: ConversationStatus.fromString(map['conversationStatus'] as String?),
      reason: map['reason'] as String?,
    );
  }

  /// Create error context
  factory ChatEntryContext.error(String reason) {
    return ChatEntryContext(
      status: ChatEntryStatus.error,
      reason: reason,
    );
  }

  ChatEntryContext copyWith({
    ChatEntryStatus? status,
    String? roomId,
    String? requestId,
    String? otherProfileId,
    String? otherFullName,
    String? otherAvatarUrl,
    UserRole? otherRole,
    bool? isPublic,
    bool? isRoomEmpty,
    bool? firstMessageTextOnly,
    bool? limitToSingleInitialMessage,
    bool? viewerIsReviewer,
    ConversationStatus? conversationStatus,
    String? reason,
  }) {
    return ChatEntryContext(
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      requestId: requestId ?? this.requestId,
      otherProfileId: otherProfileId ?? this.otherProfileId,
      otherFullName: otherFullName ?? this.otherFullName,
      otherAvatarUrl: otherAvatarUrl ?? this.otherAvatarUrl,
      otherRole: otherRole ?? this.otherRole,
      isPublic: isPublic ?? this.isPublic,
      isRoomEmpty: isRoomEmpty ?? this.isRoomEmpty,
      firstMessageTextOnly: firstMessageTextOnly ?? this.firstMessageTextOnly,
      limitToSingleInitialMessage: limitToSingleInitialMessage ?? this.limitToSingleInitialMessage,
      viewerIsReviewer: viewerIsReviewer ?? this.viewerIsReviewer,
      conversationStatus: conversationStatus ?? this.conversationStatus,
      reason: reason ?? this.reason,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatEntryContext &&
        other.status == status &&
        other.roomId == roomId &&
        other.requestId == requestId &&
        other.otherProfileId == otherProfileId &&
        other.otherFullName == otherFullName &&
        other.otherAvatarUrl == otherAvatarUrl &&
        other.otherRole == otherRole &&
        other.isPublic == isPublic &&
        other.isRoomEmpty == isRoomEmpty &&
        other.firstMessageTextOnly == firstMessageTextOnly &&
        other.limitToSingleInitialMessage == limitToSingleInitialMessage &&
        other.viewerIsReviewer == viewerIsReviewer &&
        other.conversationStatus == conversationStatus &&
        other.reason == reason;
  }

  @override
  int get hashCode => Object.hash(
        status,
        roomId,
        requestId,
        otherProfileId,
        otherFullName,
        otherAvatarUrl,
        otherRole,
        isPublic,
        isRoomEmpty,
        firstMessageTextOnly,
        limitToSingleInitialMessage,
        viewerIsReviewer,
        conversationStatus,
        reason,
      );

  @override
  String toString() => 'ChatEntryContext($status, room: $roomId, request: $requestId)';
}
