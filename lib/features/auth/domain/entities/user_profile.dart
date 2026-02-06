/// User profile entity from the profiles table.
///
/// Contains profile data separate from authentication data.
/// This is the domain representation of the user's profile.
library;

import 'package:flutter/foundation.dart';

import '../../../marketplace/domain/entities/shipping_address.dart';
import 'user_role.dart';

/// Represents a user's profile data.
///
/// Contains profile information stored in the profiles table,
/// separate from authentication data in [AuthUser].
@immutable
class UserProfile {
  /// Unique profile identifier (UUID from profiles table).
  final String id;

  /// Reference to the auth user (foreign key to auth.users).
  final String authUserId;

  /// User's display name.
  final String? displayName;

  /// URL to the user's avatar image.
  final String? avatarUrl;

  /// The user's role in the application.
  final UserRole role;

  /// Profession (for professionals only).
  final String? profession;

  /// Company name (for professionals only).
  final String? companyName;

  /// User's biography.
  final String? bio;

  /// Whether the user has completed onboarding.
  final bool isOnboardingComplete;

  /// Current onboarding step (if not complete).
  final int? onboardingStep;

  /// Profile creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime? updatedAt;

  /// Shipping address for marketplace sellers (stored in profiles table).
  final ShippingAddress? shippingAddress;

  /// Creates a user profile.
  const UserProfile({
    required this.id,
    required this.authUserId,
    this.displayName,
    this.avatarUrl,
    required this.role,
    this.profession,
    this.companyName,
    this.bio,
    this.isOnboardingComplete = false,
    this.onboardingStep,
    required this.createdAt,
    this.updatedAt,
    this.shippingAddress,
  });

  /// Returns true if this user is a bride.
  bool get isBride => role == UserRole.bride;

  /// Returns true if this user is a professional.
  bool get isProfessional => role == UserRole.professional;

  /// Returns true if this user is an admin.
  bool get isAdmin => role == UserRole.admin;

  /// Creates a copy with updated fields.
  UserProfile copyWith({
    String? id,
    String? authUserId,
    String? displayName,
    String? avatarUrl,
    UserRole? role,
    String? profession,
    String? companyName,
    String? bio,
    bool? isOnboardingComplete,
    int? onboardingStep,
    DateTime? createdAt,
    DateTime? updatedAt,
    ShippingAddress? shippingAddress,
  }) {
    return UserProfile(
      id: id ?? this.id,
      authUserId: authUserId ?? this.authUserId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      profession: profession ?? this.profession,
      companyName: companyName ?? this.companyName,
      bio: bio ?? this.bio,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      onboardingStep: onboardingStep ?? this.onboardingStep,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippingAddress: shippingAddress ?? this.shippingAddress,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile &&
        other.id == id &&
        other.authUserId == authUserId &&
        other.displayName == displayName &&
        other.avatarUrl == avatarUrl &&
        other.role == role &&
        other.profession == profession &&
        other.companyName == companyName &&
        other.bio == bio &&
        other.isOnboardingComplete == isOnboardingComplete &&
        other.onboardingStep == onboardingStep &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.shippingAddress == shippingAddress;
  }

  @override
  int get hashCode => Object.hash(
        id,
        authUserId,
        displayName,
        avatarUrl,
        role,
        profession,
        companyName,
        bio,
        isOnboardingComplete,
        onboardingStep,
        createdAt,
        updatedAt,
        shippingAddress,
      );

  @override
  String toString() =>
      'UserProfile($id, ${displayName ?? 'unnamed'}, ${role.value})';
}
