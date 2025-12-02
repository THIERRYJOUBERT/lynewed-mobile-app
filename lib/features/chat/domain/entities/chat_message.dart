/// Chat message entity - Clean Architecture
/// 
/// Immutable data class representing a chat message.
library;

import 'package:flutter/foundation.dart';
import 'chat_enums.dart';

/// Represents a single chat message
@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.profileId,
    required this.messageType,
    required this.createdAt,
    this.content,
    this.attachmentUrl,
    this.isDeleted = false,
  });

  /// Message ID (bigint from DB)
  final int id;

  /// Room this message belongs to
  final String roomId;

  /// Author profile ID
  final String profileId;

  /// Message content (text)
  final String? content;

  /// Type of message (text, image, audio)
  final MessageType messageType;

  /// URL for attachments (images, audio)
  final String? attachmentUrl;

  /// Whether message has been deleted/hidden
  final bool isDeleted;

  /// When message was created
  final DateTime createdAt;

  /// Factory from Supabase row
  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as int,
      roomId: map['room_id'] as String,
      profileId: map['profile_id'] as String? ?? '',
      content: map['content'] as String?,
      messageType: MessageType.fromString(map['message_type'] as String?) ?? MessageType.text,
      attachmentUrl: map['attachment_url'] as String?,
      isDeleted: map['is_deleted'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to map for insert
  Map<String, dynamic> toInsertMap() {
    return {
      'room_id': roomId,
      'profile_id': profileId,
      'content': content,
      'message_type': messageType.name,
      'attachment_url': attachmentUrl,
    };
  }

  ChatMessage copyWith({
    int? id,
    String? roomId,
    String? profileId,
    String? content,
    MessageType? messageType,
    String? attachmentUrl,
    bool? isDeleted,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      profileId: profileId ?? this.profileId,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.roomId == roomId &&
        other.profileId == profileId &&
        other.content == content &&
        other.messageType == messageType &&
        other.attachmentUrl == attachmentUrl &&
        other.isDeleted == isDeleted &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        roomId,
        profileId,
        content,
        messageType,
        attachmentUrl,
        isDeleted,
        createdAt,
      );

  @override
  String toString() => 'ChatMessage($id, $messageType, ${createdAt.toIso8601String()})';
}
