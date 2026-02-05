/// MarketplaceMessage entity - A chat message between buyer and seller
///
/// Immutable data class representing a message in marketplace conversation.
/// Supports text, image, audio, and document message types.
library;

import 'package:flutter/foundation.dart';

/// Represents a message in marketplace chat.
///
/// Contains sender/receiver, content, attachment info, read status, and timestamps.
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
    this.messageType = 'text',
    this.attachmentUrl,
    this.attachmentName,
    this.attachmentSize,
    this.attachmentMimeType,
    this.offerId,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Listing ID this conversation is about.
  final String listingId;

  /// Sender ID (who sent this message).
  final String senderId;

  /// Receiver ID (who receives this message).
  final String receiverId;

  /// Message content (text body, may be empty for attachment-only messages).
  final String content;

  /// Whether the receiver has read this message.
  final bool isRead;

  /// When the message was created.
  final DateTime createdAt;

  /// Message type: 'text', 'image', 'audio', or 'document'.
  final String messageType;

  /// Storage path for the attachment (used to generate signed URLs).
  final String? attachmentUrl;

  /// Original filename of the attachment.
  final String? attachmentName;

  /// File size in bytes.
  final int? attachmentSize;

  /// MIME type of the attachment (e.g., 'image/jpeg', 'audio/m4a').
  final String? attachmentMimeType;

  /// Linked offer ID for offer-type messages.
  final String? offerId;

  /// Whether this message is unread.
  bool get isUnread => !isRead;

  /// Whether this is a text message.
  bool get isText => messageType == 'text';

  /// Whether this is an image message.
  bool get isImage => messageType == 'image';

  /// Whether this is an audio message.
  bool get isAudio => messageType == 'audio';

  /// Whether this is a document message.
  bool get isDocument => messageType == 'document';

  /// Whether this is an offer message.
  bool get isOffer => messageType == 'offer';

  /// Whether this is a system message.
  bool get isSystem => messageType == 'system';

  /// Whether this message has an attachment.
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  /// Creates a MarketplaceMessage from Supabase JSON row.
  factory MarketplaceMessage.fromJson(Map<String, dynamic> json) {
    return MarketplaceMessage(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      messageType: json['message_type'] as String? ?? 'text',
      attachmentUrl: json['attachment_url'] as String?,
      attachmentName: json['attachment_name'] as String?,
      attachmentSize: json['attachment_size'] as int?,
      attachmentMimeType: json['attachment_mime_type'] as String?,
      offerId: json['offer_id'] as String?,
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
      'message_type': messageType,
      if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      if (attachmentName != null) 'attachment_name': attachmentName,
      if (attachmentSize != null) 'attachment_size': attachmentSize,
      if (attachmentMimeType != null) 'attachment_mime_type': attachmentMimeType,
      if (offerId != null) 'offer_id': offerId,
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
      'MarketplaceMessage(id: $id, type: $messageType, senderId: $senderId, '
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
    String? messageType,
    String? attachmentUrl,
    String? attachmentName,
    int? attachmentSize,
    String? attachmentMimeType,
    String? offerId,
  }) {
    return MarketplaceMessage(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      attachmentMimeType: attachmentMimeType ?? this.attachmentMimeType,
      offerId: offerId ?? this.offerId,
    );
  }
}
