/// MarketplaceConversation entity - A conversation summary for chat list.
///
/// Aggregates information about a conversation between buyer and seller
/// for display in the chat list page.
library;

import 'package:flutter/foundation.dart';

/// Represents a conversation summary for the marketplace chat list.
///
/// Groups messages by listing and other user, providing last message preview,
/// unread count, and user/listing metadata.
@immutable
class MarketplaceConversation {
  /// Creates a marketplace conversation.
  const MarketplaceConversation({
    required this.listingId,
    required this.listingTitle,
    this.listingCoverUrl,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  /// Listing ID this conversation is about.
  final String listingId;

  /// Title of the listing.
  final String listingTitle;

  /// Cover photo URL of the listing.
  final String? listingCoverUrl;

  /// Other user ID (buyer or seller).
  final String otherUserId;

  /// Other user's display name.
  final String otherUserName;

  /// Other user's avatar URL.
  final String? otherUserAvatarUrl;

  /// Last message content preview.
  final String? lastMessage;

  /// Time of last message.
  final DateTime? lastMessageTime;

  /// Number of unread messages in this conversation.
  final int unreadCount;

  /// Whether there are unread messages.
  bool get hasUnread => unreadCount > 0;

  /// Creates a MarketplaceConversation from a JSON map.
  factory MarketplaceConversation.fromJson(Map<String, dynamic> json) {
    return MarketplaceConversation(
      listingId: json['listing_id'] as String,
      listingTitle: json['listing_title'] as String,
      listingCoverUrl: json['listing_cover_url'] as String?,
      otherUserId: json['other_user_id'] as String,
      otherUserName: json['other_user_name'] as String,
      otherUserAvatarUrl: json['other_user_avatar_url'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageTime: json['last_message_time'] != null
          ? DateTime.parse(json['last_message_time'] as String)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  /// Equality based on listingId and otherUserId (conversation identity).
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceConversation &&
          runtimeType == other.runtimeType &&
          listingId == other.listingId &&
          otherUserId == other.otherUserId;

  @override
  int get hashCode => Object.hash(listingId, otherUserId);

  /// String representation for debugging.
  @override
  String toString() =>
      'MarketplaceConversation(listingId: $listingId, '
      'otherUserId: $otherUserId, unread: $unreadCount)';

  /// Creates a copy with updated fields.
  MarketplaceConversation copyWith({
    String? listingId,
    String? listingTitle,
    String? listingCoverUrl,
    String? otherUserId,
    String? otherUserName,
    String? otherUserAvatarUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return MarketplaceConversation(
      listingId: listingId ?? this.listingId,
      listingTitle: listingTitle ?? this.listingTitle,
      listingCoverUrl: listingCoverUrl ?? this.listingCoverUrl,
      otherUserId: otherUserId ?? this.otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUserAvatarUrl: otherUserAvatarUrl ?? this.otherUserAvatarUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
