/// Auth user model for data layer.
///
/// Maps between Supabase User and domain AuthUser entity.
library;

import 'package:supabase_flutter/supabase_flutter.dart' show User;

import '../../domain/entities/auth_user.dart';

/// Data model representing an authenticated user from Supabase.
///
/// This model handles the mapping between Supabase's [User] class
/// and our domain [AuthUser] entity.
class AuthUserModel {
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

  /// Creates an auth user model.
  const AuthUserModel({
    required this.id,
    required this.email,
    this.phone,
    this.emailConfirmed = false,
    this.lastSignInAt,
    required this.createdAt,
    this.userMetadata,
  });

  /// Creates an AuthUserModel from a Supabase [User].
  factory AuthUserModel.fromSupabaseUser(User user) {
    return AuthUserModel(
      id: user.id,
      email: user.email ?? '',
      phone: user.phone,
      emailConfirmed: user.emailConfirmedAt != null,
      lastSignInAt: user.lastSignInAt != null
          ? DateTime.parse(user.lastSignInAt!)
          : null,
      createdAt: DateTime.parse(user.createdAt),
      userMetadata: user.userMetadata,
    );
  }

  /// Converts this model to a domain [AuthUser] entity.
  AuthUser toEntity() {
    return AuthUser(
      id: id,
      email: email,
      phone: phone,
      emailConfirmed: emailConfirmed,
      lastSignInAt: lastSignInAt,
      createdAt: createdAt,
      userMetadata: userMetadata,
    );
  }
}
