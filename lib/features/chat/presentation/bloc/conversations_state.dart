/// Conversations state - Clean Architecture
/// 
/// State classes for ConversationsCubit.
library;

import 'package:flutter/foundation.dart';
import '../../domain/entities/entities.dart';

/// Base state for conversations
@immutable
sealed class ConversationsState {
  const ConversationsState();
}

/// Initial state
class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

/// Loading state
class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

/// Loaded state with all data
class ConversationsLoaded extends ConversationsState {
  const ConversationsLoaded({
    required this.conversations,
    required this.pendingRequests,
    required this.blockedUsers,
    this.isRefreshing = false,
  });

  /// Active conversations (private rooms)
  final List<Conversation> conversations;

  /// Pending contact requests (for Brides)
  final List<ContactRequest> pendingRequests;

  /// Blocked users
  final List<BlockedUser> blockedUsers;

  /// Whether we're refreshing in background
  final bool isRefreshing;

  /// Filter conversations by status
  List<Conversation> get activeConversations => conversations
      .where((c) => c.conversationStatus == ConversationStatus.active)
      .toList();

  /// Get total unread count
  int get totalUnreadCount => conversations.fold(0, (sum, c) => sum + c.unreadCount);

  /// Has pending requests
  bool get hasPendingRequests => pendingRequests.isNotEmpty;

  /// Has blocked users
  bool get hasBlockedUsers => blockedUsers.isNotEmpty;

  ConversationsLoaded copyWith({
    List<Conversation>? conversations,
    List<ContactRequest>? pendingRequests,
    List<BlockedUser>? blockedUsers,
    bool? isRefreshing,
  }) {
    return ConversationsLoaded(
      conversations: conversations ?? this.conversations,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

/// Error state
class ConversationsError extends ConversationsState {
  const ConversationsError(this.message);

  final String message;
}
