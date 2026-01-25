/// Authenticated user entity from Supabase Auth.
///
/// Represents the authenticated user's identity without profile data.
/// This is the domain representation independent of Supabase implementation.
library;

import 'package:flutter/foundation.dart';

/// Represents an authenticated user from the auth system.
///
/// Contains only authentication-related data (not profile data).
/// Profile data is in [UserProfile].
@immutable
class AuthUser {
  /// Unique identifier (UUID from Supabase Auth).
  final String id;

  /// User's email address.
  final String email;

  /// User's phone number (optional).
  final String? phone;

  /// Whether the email has been confirmed.
  final bool emailConfirmed;

  /// Last sign-in timestamp.
  final DateTime? lastSignInAt;

  /// Account creation timestamp.
  final DateTime createdAt;

  /// Additional metadata stored with the user.
  final Map<String, dynamic>? userMetadata;

  /// Creates an authenticated user.
  const AuthUser({
    required this.id,
    required this.email,
    this.phone,
    this.emailConfirmed = false,
    this.lastSignInAt,
    required this.createdAt,
    this.userMetadata,
  });

  /// Creates a copy with updated fields.
  AuthUser copyWith({
    String? id,
    String? email,
    String? phone,
    bool? emailConfirmed,
    DateTime? lastSignInAt,
    DateTime? createdAt,
    Map<String, dynamic>? userMetadata,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      emailConfirmed: emailConfirmed ?? this.emailConfirmed,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
      createdAt: createdAt ?? this.createdAt,
      userMetadata: userMetadata ?? this.userMetadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser &&
        other.id == id &&
        other.email == email &&
        other.phone == phone &&
        other.emailConfirmed == emailConfirmed &&
        other.lastSignInAt == lastSignInAt &&
        other.createdAt == createdAt &&
        mapEquals(other.userMetadata, userMetadata);
  }

  @override
  int get hashCode => Object.hash(
        id,
        email,
        phone,
        emailConfirmed,
        lastSignInAt,
        createdAt,
        userMetadata != null ? Object.hashAll(userMetadata!.entries) : null,
      );

  @override
  String toString() => 'AuthUser($id, $email)';
}
