/// Blocked user entity - Clean Architecture
/// 
/// Represents a blocked user in the user_blocks table.
library;

import 'package:flutter/foundation.dart';
import 'chat_enums.dart';

/// Represents a blocked user
@immutable
class BlockedUser {
  const BlockedUser({
    required this.blockedProfileId,
    required this.createdAt,
    this.fullName,
    this.avatarUrl,
    this.role,
  });

  /// Blocked user's profile ID
  final String blockedProfileId;

  /// When the block was created
  final DateTime createdAt;

  /// Blocked user's full name (joined)
  final String? fullName;

  /// Blocked user's avatar URL (joined)
  final String? avatarUrl;

  /// Blocked user's role (joined)
  final UserRole? role;

  /// Factory from Supabase row with joined profile
  factory BlockedUser.fromMap(Map<String, dynamic> map) {
    return BlockedUser(
      blockedProfileId: map['blocked_profile_id'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      fullName: map['full_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      role: UserRole.fromString(map['role'] as String?),
    );
  }

  BlockedUser copyWith({
    String? blockedProfileId,
    DateTime? createdAt,
    String? fullName,
    String? avatarUrl,
    UserRole? role,
  }) {
    return BlockedUser(
      blockedProfileId: blockedProfileId ?? this.blockedProfileId,
      createdAt: createdAt ?? this.createdAt,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BlockedUser &&
        other.blockedProfileId == blockedProfileId &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode => Object.hash(blockedProfileId, createdAt);

  @override
  String toString() => 'BlockedUser($blockedProfileId, $fullName)';
}
