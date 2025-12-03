/// Contact request entity - Clean Architecture
/// 
/// Represents a pending contact request from Pro to Bride.
library;

import 'package:flutter/foundation.dart';
import 'chat_enums.dart';

/// Represents a contact request (Pro → Bride)
@immutable
class ContactRequest {
  const ContactRequest({
    required this.id,
    required this.proProfileId,
    required this.brideProfileId,
    required this.initiatorId,
    required this.source,
    required this.status,
    required this.createdAt,
    this.initialMessage,
    this.respondedAt,
    // Joined profile info
    this.otherFullName,
    this.otherAvatarUrl,
    this.otherRole,
  });

  /// Request UUID
  final String id;

  /// Pro's profile ID
  final String proProfileId;

  /// Bride's profile ID
  final String brideProfileId;

  /// Who initiated the request
  final String initiatorId;

  /// Source of the request
  final ContactRequestSource source;

  /// Initial message from Pro
  final String? initialMessage;

  /// Request status
  final ConnectionRequestStatus status;

  /// When request was created
  final DateTime createdAt;

  /// When request was responded to
  final DateTime? respondedAt;

  // Joined profile info (for display)
  final String? otherFullName;
  final String? otherAvatarUrl;
  final UserRole? otherRole;

  /// Whether this request is pending
  bool get isPending => status == ConnectionRequestStatus.pending;

  /// Factory from Supabase row
  /// Handles both direct table queries and RPC responses
  factory ContactRequest.fromMap(Map<String, dynamic> map) {
    // RPC uses camelCase, direct queries use snake_case
    final id = map['requestId'] as String? ?? map['id'] as String? ?? '';
    final initiatorId = map['initiatorId'] as String? ?? map['initiator_id'] as String? ?? '';
    
    // For RPC response, we may not have pro/bride IDs directly
    // but we have otherProfileId and can infer based on initiator
    final proProfileId = map['pro_profile_id'] as String? ?? map['proProfileId'] as String? ?? '';
    final brideProfileId = map['bride_profile_id'] as String? ?? map['brideProfileId'] as String? ?? '';
    
    return ContactRequest(
      id: id,
      proProfileId: proProfileId,
      brideProfileId: brideProfileId,
      initiatorId: initiatorId,
      source: ContactRequestSource.fromString(map['source'] as String?) ?? ContactRequestSource.fromProfile,
      initialMessage: map['initialMessage'] as String? ?? map['initial_message'] as String?,
      status: ConnectionRequestStatus.fromString(map['status'] as String?) ?? ConnectionRequestStatus.pending,
      createdAt: _parseDateTime(map['createdAt'] ?? map['created_at']) ?? DateTime.now(),
      respondedAt: _parseDateTime(map['respondedAt'] ?? map['responded_at']),
      // Joined profile info (from RPC)
      otherFullName: map['otherFullName'] as String? ?? map['other_full_name'] as String?,
      otherAvatarUrl: map['otherAvatarUrl'] as String? ?? map['other_avatar_url'] as String?,
      otherRole: UserRole.fromString(map['otherRole'] as String? ?? map['other_role'] as String?),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  ContactRequest copyWith({
    String? id,
    String? proProfileId,
    String? brideProfileId,
    String? initiatorId,
    ContactRequestSource? source,
    String? initialMessage,
    ConnectionRequestStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
    String? otherFullName,
    String? otherAvatarUrl,
    UserRole? otherRole,
  }) {
    return ContactRequest(
      id: id ?? this.id,
      proProfileId: proProfileId ?? this.proProfileId,
      brideProfileId: brideProfileId ?? this.brideProfileId,
      initiatorId: initiatorId ?? this.initiatorId,
      source: source ?? this.source,
      initialMessage: initialMessage ?? this.initialMessage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
      otherFullName: otherFullName ?? this.otherFullName,
      otherAvatarUrl: otherAvatarUrl ?? this.otherAvatarUrl,
      otherRole: otherRole ?? this.otherRole,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ContactRequest &&
        other.id == id &&
        other.proProfileId == proProfileId &&
        other.brideProfileId == brideProfileId &&
        other.initiatorId == initiatorId &&
        other.source == source &&
        other.initialMessage == initialMessage &&
        other.status == status &&
        other.createdAt == createdAt &&
        other.respondedAt == respondedAt;
  }

  @override
  int get hashCode => Object.hash(
        id,
        proProfileId,
        brideProfileId,
        initiatorId,
        source,
        initialMessage,
        status,
        createdAt,
        respondedAt,
      );

  @override
  String toString() => 'ContactRequest($id, $source, $status)';
}
