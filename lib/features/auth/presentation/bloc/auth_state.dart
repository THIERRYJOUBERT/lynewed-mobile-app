/// Authentication state for the AuthCubit.
///
/// Defines all possible authentication states in the application.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/entities.dart';

/// Base class for all authentication states.
///
/// Uses a sealed class hierarchy for exhaustive pattern matching.
@immutable
sealed class AuthState {
  /// Creates an auth state.
  const AuthState();
}

/// Initial state before authentication status is checked.
final class AuthInitial extends AuthState {
  /// Creates an initial auth state.
  const AuthInitial();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthInitial;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Loading state while authentication operation is in progress.
final class AuthLoading extends AuthState {
  /// Creates a loading auth state.
  const AuthLoading();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AuthLoading;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Authenticated state when user is signed in.
final class Authenticated extends AuthState {
  /// The authenticated user from Supabase Auth.
  final AuthUser user;

  /// The user's profile data (may be null if not loaded yet).
  final UserProfile? profile;

  /// Creates an authenticated state.
  const Authenticated({
    required this.user,
    this.profile,
  });

  /// Returns true if the user has a loaded profile.
  bool get hasProfile => profile != null;

  /// Returns true if the user needs to complete onboarding.
  ///
  /// Returns false if profile is null (assumes no onboarding needed).
  bool get needsOnboarding => profile?.isOnboardingComplete == false;

  /// Returns the user's role, defaulting to bride if profile is null.
  UserRole get role => profile?.role ?? UserRole.bride;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Authenticated &&
        other.user == user &&
        other.profile == profile;
  }

  @override
  int get hashCode => Object.hash(user, profile);
}

/// Unauthenticated state when no user is signed in.
final class Unauthenticated extends AuthState {
  /// Creates an unauthenticated state.
  const Unauthenticated();

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Unauthenticated;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Error state when authentication operation fails.
final class AuthError extends AuthState {
  /// The error message describing what went wrong.
  final String message;

  /// Creates an auth error state.
  const AuthError(this.message);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthError && other.message == message;
  }

  @override
  int get hashCode => message.hashCode;
}
