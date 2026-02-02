/// Wedding Group entity - Clean Architecture
///
/// Represents a wedding group chat room (public or private).
/// Default wedding_team is also represented as a WeddingGroup with isDefault=true.
library;

import 'package:flutter/foundation.dart';

/// Represents a wedding group (chat room linked to a wedding).
///
/// Groups can be:
/// - Default (wedding_team): Auto-created, cannot be deleted
/// - Public (wedding_group_public): Auto-join for all joined guests/pros
/// - Private (wedding_group_private): Manual invitation only
@immutable
class WeddingGroup {
  /// Creates a wedding group.
  const WeddingGroup({
    required this.roomId,
    required this.name,
    required this.isPublic,
    required this.isDefault,
    required this.memberCount,
    required this.createdAt,
  });

  /// Creates a WeddingGroup from a Supabase RPC response map.
  factory WeddingGroup.fromMap(Map<String, dynamic> map) {
    return WeddingGroup(
      roomId: map['room_id'] as String,
      name: map['name'] as String? ?? 'Wedding Team',
      isPublic: map['is_public'] as bool? ?? false,
      isDefault: map['is_default'] as bool? ?? false,
      memberCount: (map['member_count'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// The chat room ID.
  final String roomId;

  /// The display name of the group.
  final String name;

  /// Whether the group is public (auto-join for new members).
  final bool isPublic;

  /// Whether this is the default wedding team (cannot be deleted/renamed).
  final bool isDefault;

  /// Number of active members in the group.
  final int memberCount;

  /// When the group was created.
  final DateTime createdAt;

  /// Whether this group can be edited (not the default wedding team).
  bool get canEdit => !isDefault;

  /// Whether this group can be deleted (not the default wedding team).
  bool get canDelete => !isDefault;

  /// Creates a copy with updated values.
  WeddingGroup copyWith({
    String? roomId,
    String? name,
    bool? isPublic,
    bool? isDefault,
    int? memberCount,
    DateTime? createdAt,
  }) {
    return WeddingGroup(
      roomId: roomId ?? this.roomId,
      name: name ?? this.name,
      isPublic: isPublic ?? this.isPublic,
      isDefault: isDefault ?? this.isDefault,
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingGroup &&
        other.roomId == roomId &&
        other.name == name &&
        other.isPublic == isPublic &&
        other.isDefault == isDefault &&
        other.memberCount == memberCount &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(roomId, name, isPublic, isDefault, memberCount, createdAt);
  }

  @override
  String toString() {
    return 'WeddingGroup(roomId: $roomId, name: $name, isPublic: $isPublic, '
        'isDefault: $isDefault, memberCount: $memberCount)';
  }
}

/// Represents a member that can be added to a wedding group.
///
/// Used for member selection in private groups.
@immutable
class EligibleGroupMember {
  /// Creates an eligible group member.
  const EligibleGroupMember({
    required this.profileId,
    required this.fullName,
    required this.memberType,
    this.avatarUrl,
  });

  /// Creates from Supabase RPC response.
  factory EligibleGroupMember.fromMap(Map<String, dynamic> map) {
    return EligibleGroupMember(
      profileId: map['profile_id'] as String,
      fullName: map['full_name'] as String? ?? 'Unknown',
      avatarUrl: map['avatar_url'] as String?,
      memberType: GroupMemberType.fromString(map['member_type'] as String?),
    );
  }

  /// The profile ID.
  final String profileId;

  /// The display name.
  final String fullName;

  /// The avatar URL (optional).
  final String? avatarUrl;

  /// The type of member (guest or pro).
  final GroupMemberType memberType;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EligibleGroupMember && other.profileId == profileId;
  }

  @override
  int get hashCode => profileId.hashCode;
}

/// Represents a current member of a wedding group.
@immutable
class GroupMember {
  /// Creates a group member.
  const GroupMember({
    required this.profileId,
    required this.fullName,
    required this.memberType,
    required this.joinedAt,
    this.avatarUrl,
  });

  /// Creates from Supabase RPC response.
  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      profileId: map['profile_id'] as String,
      fullName: map['full_name'] as String? ?? 'Unknown',
      avatarUrl: map['avatar_url'] as String?,
      memberType: GroupMemberType.fromString(map['member_type'] as String?),
      joinedAt: map['joined_at'] != null
          ? DateTime.parse(map['joined_at'] as String)
          : DateTime.now(),
    );
  }

  /// The profile ID.
  final String profileId;

  /// The display name.
  final String fullName;

  /// The avatar URL (optional).
  final String? avatarUrl;

  /// The type of member.
  final GroupMemberType memberType;

  /// When the member joined the group.
  final DateTime joinedAt;

  /// Whether this member is the bride (cannot be removed).
  bool get isBride => memberType == GroupMemberType.bride;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupMember && other.profileId == profileId;
  }

  @override
  int get hashCode => profileId.hashCode;
}

/// Type of group member.
enum GroupMemberType {
  bride,
  pro,
  guest;

  static GroupMemberType fromString(String? value) {
    switch (value) {
      case 'bride':
        return GroupMemberType.bride;
      case 'pro':
        return GroupMemberType.pro;
      case 'guest':
      default:
        return GroupMemberType.guest;
    }
  }

  String get displayLabel {
    switch (this) {
      case GroupMemberType.bride:
        return 'Bride';
      case GroupMemberType.pro:
        return 'Pro';
      case GroupMemberType.guest:
        return 'Guest';
    }
  }
}
