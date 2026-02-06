/// User profile model for data layer.
///
/// Maps between Supabase profiles table and domain UserProfile entity.
library;

import '../../../marketplace/domain/entities/shipping_address.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_role.dart';

/// Data model representing a user profile from the profiles table.
///
/// This model handles the mapping between Supabase's profiles table
/// and our domain [UserProfile] entity.
class UserProfileModel {
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

  /// Shipping address for marketplace sellers.
  final ShippingAddress? shippingAddress;

  /// Creates a user profile model.
  const UserProfileModel({
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

  /// Creates a UserProfileModel from a JSON map (Supabase row).
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      authUserId: json['auth_user_id'] as String? ?? json['id'] as String,
      displayName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: _parseRole(json['role'] as String?),
      profession: json['profession'] as String?,
      companyName: json['company_name'] as String?,
      bio: json['bio'] as String?,
      isOnboardingComplete: json['is_onboarding_complete'] as bool? ?? false,
      onboardingStep: json['onboarding_step'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(
              Map<String, dynamic>.from(json['shipping_address'] as Map))
          : null,
    );
  }

  /// Parses a role string to [UserRole].
  static UserRole _parseRole(String? roleStr) {
    switch (roleStr?.toLowerCase()) {
      case 'bride':
        return UserRole.bride;
      case 'professional':
        return UserRole.professional;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.bride;
    }
  }

  /// Converts this model to a domain [UserProfile] entity.
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      authUserId: authUserId,
      displayName: displayName,
      avatarUrl: avatarUrl,
      role: role,
      profession: profession,
      companyName: companyName,
      bio: bio,
      isOnboardingComplete: isOnboardingComplete,
      onboardingStep: onboardingStep,
      createdAt: createdAt,
      updatedAt: updatedAt,
      shippingAddress: shippingAddress,
    );
  }

  /// Converts this model to a JSON map for database updates.
  ///
  /// Only includes non-null values that can be updated.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (displayName != null) json['full_name'] = displayName;
    if (avatarUrl != null) json['avatar_url'] = avatarUrl;
    if (bio != null) json['bio'] = bio;
    if (profession != null) json['profession'] = profession;
    if (companyName != null) json['company_name'] = companyName;
    return json;
  }
}
