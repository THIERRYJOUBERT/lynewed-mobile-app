/// Chat room state - Clean Architecture
/// 
/// State classes for ChatRoomNotifier.
library;

import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';

/// Base state for chat room
@immutable
sealed class ChatRoomState {
  const ChatRoomState();
}

/// Initial state - no data loaded yet
class ChatRoomInitial extends ChatRoomState {
  const ChatRoomInitial();
}

/// Loading state - fetching messages
class ChatRoomLoading extends ChatRoomState {
  const ChatRoomLoading();
}

/// Author info for public room messages
class AuthorInfo {
  const AuthorInfo({
    required this.profileId,
    required this.fullName,
    this.avatarUrl,
  });

  final String profileId;
  final String fullName;
  final String? avatarUrl;
}

/// Loaded state with messages and room info
class ChatRoomLoaded extends ChatRoomState {
  const ChatRoomLoaded({
    required this.messages,
    required this.roomId,
    this.otherProfileId,
    this.otherFullName,
    this.otherAvatarUrl,
    this.otherRole,
    this.isPublicRoom = false,
    this.publicRoomTitle,
    this.hasMoreMessages = true,
    this.isLoadingMore = false,
    this.isSending = false,
    this.pendingRequestId,
    this.viewerIsReviewer = false,
    this.authors = const {},
  });

  /// List of messages (newest first)
  final List<ChatMessage> messages;

  /// Room ID
  final String roomId;

  /// Other participant's profile ID (for private rooms)
  final String? otherProfileId;

  /// Other participant's full name
  final String? otherFullName;

  /// Other participant's avatar URL
  final String? otherAvatarUrl;

  /// Other participant's role
  final UserRole? otherRole;

  /// Whether this is a public room
  final bool isPublicRoom;

  /// Public room title (if public)
  final String? publicRoomTitle;

  /// Whether there are more messages to load (pagination)
  final bool hasMoreMessages;

  /// Whether we're loading more messages
  final bool isLoadingMore;

  /// Whether we're sending a message
  final bool isSending;

  /// Pending contact request ID (for Pro→Bride flow)
  final String? pendingRequestId;

  /// Whether current user is the reviewer (Bride reviewing Pro request)
  final bool viewerIsReviewer;

  /// Authors cache for public rooms (profileId -> AuthorInfo)
  final Map<String, AuthorInfo> authors;

  /// Get author info for a profile ID (public rooms)
  AuthorInfo? getAuthor(String profileId) => authors[profileId];

  /// Get oldest message ID for pagination
  int? get oldestMessageId => messages.isNotEmpty ? messages.last.id : null;

  /// Check if room is empty (no messages yet)
  bool get isEmpty => messages.isEmpty;

  /// Check if this is a pending contact request
  bool get isPendingRequest => pendingRequestId != null;

  ChatRoomLoaded copyWith({
    List<ChatMessage>? messages,
    String? roomId,
    String? otherProfileId,
    String? otherFullName,
    String? otherAvatarUrl,
    UserRole? otherRole,
    bool? isPublicRoom,
    String? publicRoomTitle,
    bool? hasMoreMessages,
    bool? isLoadingMore,
    bool? isSending,
    String? pendingRequestId,
    bool clearPendingRequestId = false, // Flag to explicitly clear pendingRequestId
    bool? viewerIsReviewer,
    Map<String, AuthorInfo>? authors,
  }) {
    return ChatRoomLoaded(
      messages: messages ?? this.messages,
      roomId: roomId ?? this.roomId,
      otherProfileId: otherProfileId ?? this.otherProfileId,
      otherFullName: otherFullName ?? this.otherFullName,
      otherAvatarUrl: otherAvatarUrl ?? this.otherAvatarUrl,
      otherRole: otherRole ?? this.otherRole,
      isPublicRoom: isPublicRoom ?? this.isPublicRoom,
      publicRoomTitle: publicRoomTitle ?? this.publicRoomTitle,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSending: isSending ?? this.isSending,
      pendingRequestId: clearPendingRequestId ? null : (pendingRequestId ?? this.pendingRequestId),
      viewerIsReviewer: viewerIsReviewer ?? this.viewerIsReviewer,
      authors: authors ?? this.authors,
    );
  }

  /// Create a copy with cleared pending request (after accept/decline)
  ChatRoomLoaded clearPendingRequest() {
    return copyWith(
      clearPendingRequestId: true,
      viewerIsReviewer: false,
    );
  }
}

/// Error state
class ChatRoomError extends ChatRoomState {
  const ChatRoomError(this.message);

  final String message;
}
