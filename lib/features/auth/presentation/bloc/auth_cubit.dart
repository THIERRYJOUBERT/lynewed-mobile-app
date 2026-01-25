/// Authentication Cubit for managing auth state.
///
/// Handles authentication operations and emits corresponding states.
library;

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/core.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit for managing authentication state.
///
/// Automatically watches the auth state stream and reacts to changes.
/// Provides methods for sign in, sign up, sign out, and checking auth status.
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;
  StreamSubscription<AuthUser?>? _authSubscription;

  /// Creates an AuthCubit with the given repository.
  ///
  /// Immediately starts watching the auth state stream.
  AuthCubit({required AuthRepository repository})
      : _repository = repository,
        super(const AuthInitial()) {
    _watchAuthState();
  }

  /// Watches the auth state stream and emits appropriate states.
  void _watchAuthState() {
    _authSubscription = _repository.watchAuthState().listen((user) async {
      if (user == null) {
        emit(const Unauthenticated());
      } else {
        await _loadProfile(user);
      }
    });
  }

  /// Loads the user's profile and emits Authenticated state.
  Future<void> _loadProfile(AuthUser user) async {
    final result = await _repository.getCurrentProfile();
    result.fold(
      onSuccess: (profile) {
        emit(Authenticated(user: user, profile: profile));
      },
      onFailure: (failure) {
        // User authenticated but profile error - emit with null profile
        emit(Authenticated(user: user, profile: null));
      },
    );
  }

  /// Signs in a user with email and password.
  ///
  /// Emits [AuthLoading] while signing in.
  /// Emits [Authenticated] on success.
  /// Emits [AuthError] on failure.
  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());

    final result = await _repository.signInWithEmail(email, password);
    switch (result) {
      case Success(:final data):
        await _loadProfile(data);
      case Failure(:final failure):
        emit(AuthError(failure.message));
    }
  }

  /// Signs up a new bride user.
  ///
  /// Emits [AuthLoading] while signing up.
  /// Emits [Authenticated] on success.
  /// Emits [AuthError] on failure.
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(const AuthLoading());

    final result = await _repository.signUpBride(
      email: email,
      password: password,
      displayName: displayName,
    );
    switch (result) {
      case Success(:final data):
        await _loadProfile(data);
      case Failure(:final failure):
        emit(AuthError(failure.message));
    }
  }

  /// Signs out the current user.
  ///
  /// Emits [Unauthenticated] after signing out.
  Future<void> signOut() async {
    await _repository.signOut();
    emit(const Unauthenticated());
  }

  /// Checks the current authentication status.
  ///
  /// Emits [AuthLoading] while checking.
  /// Emits [Authenticated] if user is signed in.
  /// Emits [Unauthenticated] if no user is signed in or on error.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final result = await _repository.getCurrentUser();
    switch (result) {
      case Success(:final data):
        if (data == null) {
          emit(const Unauthenticated());
        } else {
          await _loadProfile(data);
        }
      case Failure():
        emit(const Unauthenticated());
    }
  }

  /// Sends a password reset email.
  ///
  /// Returns a [Result] indicating success or failure.
  /// Does not change auth state.
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    return _repository.sendPasswordResetEmail(email);
  }

  /// Updates the current user's password.
  ///
  /// Returns a [Result] indicating success or failure.
  /// Does not change auth state.
  Future<Result<void>> updatePassword(String newPassword) async {
    return _repository.updatePassword(newPassword);
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
