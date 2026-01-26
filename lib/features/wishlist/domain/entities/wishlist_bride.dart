/// WishlistBride entity - Clean Architecture
///
/// Represents a bride who has added a professional to their wishlist.
library;

import 'package:flutter/foundation.dart';
import 'contact_status.dart';

/// Represents a bride who saved a professional to their wishlist
@immutable
class WishlistBride {
  const WishlistBride({
    required this.profileId,
    required this.fullName,
    required this.addedAt,
    required this.contactStatus,
    this.avatarUrl,
  });

  /// Bride's profile ID
  final String profileId;

  /// Bride's full name
  final String fullName;

  /// Bride's avatar URL (optional)
  final String? avatarUrl;

  /// When the bride added the professional to their wishlist
  final DateTime addedAt;

  /// Contact status between professional and this bride
  final ContactStatus contactStatus;

  /// Display name for the bride
  String get displayName => fullName;

  /// Whether the bride has an avatar
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;

  /// Whether the professional can contact this bride
  bool get canContact => contactStatus.canContact;

  /// Whether a contact request is pending
  bool get isPending => contactStatus.isPending;

  /// Whether contact was accepted
  bool get isAccepted => contactStatus.isAccepted;

  /// Factory from Supabase RPC response
  /// Handles both snake_case (direct query) and camelCase (RPC) formats
  factory WishlistBride.fromMap(Map<String, dynamic> map) {
    return WishlistBride(
      profileId: map['brideProfileId'] as String? ??
          map['bride_profile_id'] as String? ??
          '',
      fullName: map['fullName'] as String? ??
          map['full_name'] as String? ??
          'Bride',
      avatarUrl: map['avatarUrl'] as String? ?? map['avatar_url'] as String?,
      addedAt: _parseDateTime(map['addedAt'] ?? map['added_at']) ?? DateTime.now(),
      contactStatus: ContactStatus.fromString(
        map['contactStatus'] as String? ?? map['contact_status'] as String?,
      ),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  WishlistBride copyWith({
    String? profileId,
    String? fullName,
    String? avatarUrl,
    DateTime? addedAt,
    ContactStatus? contactStatus,
  }) {
    return WishlistBride(
      profileId: profileId ?? this.profileId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      addedAt: addedAt ?? this.addedAt,
      contactStatus: contactStatus ?? this.contactStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WishlistBride &&
        other.profileId == profileId &&
        other.fullName == fullName &&
        other.avatarUrl == avatarUrl &&
        other.addedAt == addedAt &&
        other.contactStatus == contactStatus;
  }

  @override
  int get hashCode => Object.hash(
        profileId,
        fullName,
        avatarUrl,
        addedAt,
        contactStatus,
      );

  @override
  String toString() =>
      'WishlistBride($profileId, $fullName, ${contactStatus.toValue})';
}
