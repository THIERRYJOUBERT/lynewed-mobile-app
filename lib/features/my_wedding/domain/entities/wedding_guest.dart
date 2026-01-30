/// Wedding Guest entity for My Wedding Suite
///
/// Represents a guest invited to the wedding.
/// Anticipation for future features (album photos, unique links).
library;

import 'package:flutter/foundation.dart';

/// Guest role enum
enum GuestRole {
  guest,
  bridesmaid,
  bestMan,
  family,
  witness,
  other,
}

/// Guest invitation status
enum GuestStatus {
  pending,
  invited,
  joined,
}

/// Wedding Guest entity
@immutable
class WeddingGuest {
  const WeddingGuest({
    required this.id,
    required this.weddingId,
    this.name,
    this.email,
    this.phone,
    this.role = GuestRole.guest,
    this.notes,
    this.status = GuestStatus.pending,
    this.createdAt,
    this.invitedAt,
    this.joinedAt,
  });

  /// UUID of the guest
  final String id;

  /// UUID of the wedding
  final String weddingId;

  /// Guest name
  final String? name;

  /// Guest email
  final String? email;

  /// Guest phone
  final String? phone;

  /// Guest role in the wedding
  final GuestRole role;

  /// Private notes about the guest
  final String? notes;

  /// Invitation status (pending, invited, joined)
  final GuestStatus status;

  /// Creation date
  final DateTime? createdAt;

  /// When invitation was sent
  final DateTime? invitedAt;

  /// When guest joined the wedding
  final DateTime? joinedAt;

  /// Factory from Supabase JSON
  factory WeddingGuest.fromJson(Map<String, dynamic> json) {
    return WeddingGuest(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: _parseRole(json['role'] as String?),
      notes: json['notes'] as String?,
      status: _parseStatus(json['status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      invitedAt: json['invited_at'] != null
          ? DateTime.parse(json['invited_at'] as String)
          : null,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
    );
  }

  static GuestRole _parseRole(String? value) {
    switch (value) {
      case 'bridesmaid':
        return GuestRole.bridesmaid;
      case 'best_man':
        return GuestRole.bestMan;
      case 'family':
        return GuestRole.family;
      case 'witness':
        return GuestRole.witness;
      case 'other':
        return GuestRole.other;
      default:
        return GuestRole.guest;
    }
  }

  static GuestStatus _parseStatus(String? value) {
    switch (value) {
      case 'invited':
        return GuestStatus.invited;
      case 'joined':
        return GuestStatus.joined;
      default:
        return GuestStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'wedding_id': weddingId,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'notes': notes,
    };
  }

  WeddingGuest copyWith({
    String? id,
    String? weddingId,
    String? name,
    String? email,
    String? phone,
    GuestRole? role,
    String? notes,
    GuestStatus? status,
    DateTime? createdAt,
    DateTime? invitedAt,
    DateTime? joinedAt,
  }) {
    return WeddingGuest(
      id: id ?? this.id,
      weddingId: weddingId ?? this.weddingId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      invitedAt: invitedAt ?? this.invitedAt,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WeddingGuest && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WeddingGuest($id, $name)';
}
