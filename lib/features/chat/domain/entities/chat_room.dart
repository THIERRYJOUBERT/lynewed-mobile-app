/// Chat room entity - Clean Architecture
/// 
/// Immutable data class representing a chat room.
library;

import 'package:flutter/foundation.dart';
import 'chat_enums.dart';

/// Represents a chat room
@immutable
class ChatRoom {
  const ChatRoom({
    required this.id,
    required this.type,
    required this.isActive,
    required this.createdAt,
    this.name,
  });

  /// Room UUID
  final String id;

  /// Room type (private or public)
  final RoomType type;

  /// Room name (for public rooms)
  final String? name;

  /// Whether room is active
  final bool isActive;

  /// When room was created
  final DateTime createdAt;

  /// Factory from Supabase row
  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] as String,
      type: map['type'] == 'public' ? RoomType.public : RoomType.private,
      name: map['name'] as String?,
      isActive: map['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  bool get isPublic => type == RoomType.public;
  bool get isPrivate => type == RoomType.private;

  ChatRoom copyWith({
    String? id,
    RoomType? type,
    String? name,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatRoom &&
        other.id == id &&
        other.type == type &&
        other.name == name &&
        other.isActive == isActive &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(id, type, name, isActive, createdAt);

  @override
  String toString() => 'ChatRoom($id, $type)';
}
