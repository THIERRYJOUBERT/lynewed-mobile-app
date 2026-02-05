/// MarketplaceMessage entity - A chat message between buyer and seller
///
/// Immutable data class representing a message in marketplace conversation.
library;

import 'package:flutter/foundation.dart';

/// Represents a message in marketplace chat.
///
/// Contains sender/receiver, content, read status, and timestamps.
@immutable
class MarketplaceMessage {
  /// Creates a marketplace message.
  const MarketplaceMessage({
    required this.id,
    required this.listingId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Listing ID this conversation is about.
  final String listingId;

  /// Sender ID (who sent this message).
  final String senderId;

  /// Receiver ID (who receives this message).
  final String receiverId;

  /// Message content.
  final String content;

  /// Whether the receiver has read this message.
  final bool isRead;

  /// When the message was created.
  final DateTime createdAt;

  /// Whether this message is unread.
  bool get isUnread => !isRead;

  /// Creates a MarketplaceMessage from Supabase JSON row.
  factory MarketplaceMessage.fromJson(Map<String, dynamic> json) {
    return MarketplaceMessage(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String,
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts to JSON for database insert (excludes auto-generated fields).
  Map<String, dynamic> toJson() {
    return {
      'listing_id': listingId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
      'is_read': isRead,
    };
  }

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() =>
      'MarketplaceMessage(id: $id, senderId: $senderId, '
      'isRead: $isRead, content: ${content.length > 20 ? '${content.substring(0, 20)}...' : content})';

  /// Creates a copy with updated fields.
  MarketplaceMessage copyWith({
    String? id,
    String? listingId,
    String? senderId,
    String? receiverId,
    String? content,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return MarketplaceMessage(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
