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
    this.createdAt,
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

  /// Creation date
  final DateTime? createdAt;

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
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
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
    DateTime? createdAt,
  }) {
    return WeddingGuest(
      id: id ?? this.id,
      weddingId: weddingId ?? this.weddingId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
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
