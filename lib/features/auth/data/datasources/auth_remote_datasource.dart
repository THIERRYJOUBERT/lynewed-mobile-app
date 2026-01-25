/// Auth remote datasource for Supabase operations.
///
/// Encapsulates all Supabase Auth, Storage, and Functions operations.
library;

import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/auth_user_model.dart';
import '../models/user_profile_model.dart';

/// Abstract interface for auth remote data source operations.
///
/// Defines the contract for all authentication-related remote operations.
abstract class AuthRemoteDatasource {
  /// Signs in a user with email and password.
  ///
  /// Throws [AuthException] if sign in fails.
  Future<AuthUserModel> signInWithEmail(String email, String password);

  /// Signs up a user with email and password.
  ///
  /// Optional [metadata] can include role and other user data.
  /// Throws [AuthException] if sign up fails.
  Future<AuthUserModel> signUpWithEmail(
    String email,
    String password, {
    Map<String, dynamic>? metadata,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email);

  /// Updates the current user's password.
  Future<void> updatePassword(String newPassword);

  /// Gets the currently authenticated user.
  ///
  /// Returns null if no user is signed in.
  AuthUserModel? getCurrentUser();

  /// Stream of auth state changes.
  Stream<AuthUserModel?> watchAuthState();

  /// Gets a user profile by user ID.
  Future<UserProfileModel?> getProfile(String userId);

  /// Updates a user profile.
  Future<UserProfileModel> updateProfile(
    String userId,
    Map<String, dynamic> data,
  );

  /// Uploads an avatar image.
  ///
  /// Returns the public URL of the uploaded image.
  Future<String> uploadAvatar(String userId, Uint8List bytes, String fileName);

  /// Deletes the current user's account via edge function.
  Future<void> deleteAccount();

  /// Checks if the user has accepted the current terms of service.
  Future<bool> hasAcceptedTerms(String userId);

  /// Records that the user has accepted the terms of service.
  Future<void> acceptTerms(String userId);

  /// Deletes device tokens for push notifications before sign out.
  Future<void> deleteDeviceTokens();
}

/// Implementation of [AuthRemoteDatasource] using Supabase.
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final SupabaseClient _supabase;

  /// Current TOS version - should match FFAppConstants.tosVersion.
  static const String tosVersion = 'v1.0.0';

  /// Current privacy policy version - should match FFAppConstants.privacyVersion.
  static const String privacyVersion = 'v1.0.0';

  /// Creates an auth remote datasource with the given Supabase client.
  AuthRemoteDatasourceImpl(this._supabase);

  @override
  Future<AuthUserModel> signInWithEmail(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw const AuthException('Sign in failed');
    }

    return AuthUserModel.fromSupabaseUser(response.user!);
  }

  @override
  Future<AuthUserModel> signUpWithEmail(
    String email,
    String password, {
    Map<String, dynamic>? metadata,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: metadata,
    );

    if (response.user == null) {
      throw const AuthException('Sign up failed');
    }

    return AuthUserModel.fromSupabaseUser(response.user!);
  }

  @override
  Future<void> signOut() async {
    // Delete device tokens before sign out (for push notifications)
    // This must happen while user is still authenticated
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser != null) {
        await deleteDeviceTokens();
      }
    } catch (_) {
      // Continue with sign out even if token deletion fails
    }

    await _supabase.auth.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _supabase.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  @override
  AuthUserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return AuthUserModel.fromSupabaseUser(user);
  }

  @override
  Stream<AuthUserModel?> watchAuthState() {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? AuthUserModel.fromSupabaseUser(user) : null;
    });
  }

  @override
  Future<UserProfileModel?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return UserProfileModel.fromJson(response);
  }

  @override
  Future<UserProfileModel> updateProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _supabase.from('profiles').update(data).eq('id', userId);

    // Fetch the updated profile
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfileModel.fromJson(response);
  }

  @override
  Future<String> uploadAvatar(
    String userId,
    Uint8List bytes,
    String fileName,
  ) async {
    // Add timestamp to force cache refresh
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final parts = fileName.split('.');
    final extension = parts.length > 1 ? parts.last : 'jpg';
    final serverPath = '$userId/profile_$timestamp.$extension';

    await _supabase.storage.from('avatars').uploadBinary(
          serverPath,
          bytes,
        );

    return _supabase.storage.from('avatars').getPublicUrl(serverPath);
  }

  @override
  Future<void> deleteAccount() async {
    final response = await _supabase.functions.invoke(
      'account_delete',
      headers: {'Content-Type': 'application/json'},
    );

    if (response.status != 200) {
      throw Exception('Failed to delete account: ${response.status}');
    }
  }

  @override
  Future<bool> hasAcceptedTerms(String userId) async {
    final rows = await _supabase
        .from('user_legal_acceptances')
        .select('id')
        .eq('profile_id', userId)
        .eq('tos_version', tosVersion)
        .eq('privacy_version', privacyVersion)
        .limit(1);

    return rows.isNotEmpty;
  }

  @override
  Future<void> acceptTerms(String userId) async {
    await _supabase.from('user_legal_acceptances').insert({
      'profile_id': userId,
      'tos_version': tosVersion,
      'privacy_version': privacyVersion,
      'accepted_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteDeviceTokens() async {
    await _supabase.rpc('delete_my_device_tokens');
  }
}
