/// Auth repository interface for Clean Architecture.
///
/// Defines the contract for authentication operations.
/// Implementation will be in the data layer.
library;

import 'dart:typed_data';

import 'package:lynewed_beta/core/core.dart';

import '../entities/entities.dart';

/// Parameters for updating a user profile.
class UpdateProfileParams {
  /// New display name.
  final String? displayName;

  /// New avatar URL.
  final String? avatarUrl;

  /// New biography.
  final String? bio;

  /// New phone number.
  final String? phone;

  /// New profession (professionals only).
  final String? profession;

  /// New company name (professionals only).
  final String? companyName;

  /// Creates update profile parameters.
  const UpdateProfileParams({
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.phone,
    this.profession,
    this.companyName,
  });

  /// Returns true if at least one field is set.
  bool get hasChanges =>
      displayName != null ||
      avatarUrl != null ||
      bio != null ||
      phone != null ||
      profession != null ||
      companyName != null;

  @override
  String toString() =>
      'UpdateProfileParams(displayName: $displayName, avatarUrl: $avatarUrl, '
      'bio: $bio, phone: $phone, profession: $profession, companyName: $companyName)';
}

/// Repository interface for authentication operations.
///
/// This is the contract that the data layer must implement.
/// All methods use [Result] for explicit error handling.
abstract class AuthRepository {
  // ============================================================
  // AUTHENTICATION
  // ============================================================

  /// Signs in a user with email and password.
  ///
  /// Returns [AuthUser] on success, [AuthFailure] on error.
  Future<Result<AuthUser>> signInWithEmail(String email, String password);

  /// Creates a new bride account.
  ///
  /// Returns [AuthUser] on success, [AuthFailure] on error.
  Future<Result<AuthUser>> signUpBride({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs out the current user.
  ///
  /// Returns void on success, [AuthFailure] on error.
  Future<Result<void>> signOut();

  /// Sends a password reset email.
  ///
  /// Returns void on success, [AuthFailure] on error.
  Future<Result<void>> sendPasswordResetEmail(String email);

  /// Updates the current user's password.
  ///
  /// Returns void on success, [AuthFailure] on error.
  Future<Result<void>> updatePassword(String newPassword);

  // ============================================================
  // SESSION
  // ============================================================

  /// Gets the currently authenticated user.
  ///
  /// Returns null if no user is signed in.
  Future<Result<AuthUser?>> getCurrentUser();

  /// Stream of auth state changes.
  ///
  /// Emits the current user on sign in/out.
  Stream<AuthUser?> watchAuthState();

  /// Returns true if a user is currently authenticated.
  bool get isAuthenticated;

  // ============================================================
  // PROFILE
  // ============================================================

  /// Gets the current user's profile.
  ///
  /// Returns null if no profile exists.
  Future<Result<UserProfile?>> getCurrentProfile();

  /// Updates the current user's profile.
  ///
  /// Returns the updated [UserProfile] on success.
  Future<Result<UserProfile>> updateProfile(UpdateProfileParams params);

  /// Uploads an avatar image.
  ///
  /// Returns the URL of the uploaded image.
  Future<Result<String>> uploadAvatar(Uint8List imageBytes, String fileName);

  /// Deletes the current user's account.
  ///
  /// This is a destructive operation.
  Future<Result<void>> deleteAccount();

  // ============================================================
  // TERMS & LEGAL
  // ============================================================

  /// Checks if the user has accepted the terms of service.
  Future<Result<bool>> hasAcceptedTerms();

  /// Records that the user has accepted the terms of service.
  Future<Result<void>> acceptTerms();
}
