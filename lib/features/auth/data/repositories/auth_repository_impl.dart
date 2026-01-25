/// Auth repository implementation using Supabase.
///
/// Implements [AuthRepository] using [AuthRemoteDatasource].
library;

import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/core.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [AuthRepository] using remote datasource.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  /// Creates an auth repository with the given datasource.
  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<Result<AuthUser>> signInWithEmail(
    String email,
    String password,
  ) async {
    try {
      final model = await _remoteDatasource.signInWithEmail(email, password);
      return Success(model.toEntity());
    } on supabase.AuthException catch (e) {
      return Failure(AuthFailure(e.message));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthUser>> signUpBride({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final metadata = <String, dynamic>{'role': 'bride'};
      if (displayName != null) {
        metadata['display_name'] = displayName;
      }

      final model = await _remoteDatasource.signUpWithEmail(
        email,
        password,
        metadata: metadata,
      );

      // Accept terms of service automatically for new bride sign-ups
      await _remoteDatasource.acceptTerms(model.id);

      return Success(model.toEntity());
    } on supabase.AuthException catch (e) {
      return Failure(AuthFailure(e.message));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDatasource.signOut();
      return const Success(null);
    } on supabase.AuthException catch (e) {
      return Failure(AuthFailure(e.message));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDatasource.sendPasswordResetEmail(email);
      return const Success(null);
    } on supabase.AuthException catch (e) {
      return Failure(AuthFailure(e.message));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await _remoteDatasource.updatePassword(newPassword);
      return const Success(null);
    } on supabase.AuthException catch (e) {
      return Failure(AuthFailure(e.message));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthUser?>> getCurrentUser() async {
    try {
      final model = _remoteDatasource.getCurrentUser();
      return Success(model?.toEntity());
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<AuthUser?> watchAuthState() {
    return _remoteDatasource.watchAuthState().map(
          (model) => model?.toEntity(),
        );
  }

  @override
  bool get isAuthenticated => _remoteDatasource.getCurrentUser() != null;

  @override
  Future<Result<UserProfile?>> getCurrentProfile() async {
    try {
      final currentUser = _remoteDatasource.getCurrentUser();
      if (currentUser == null) {
        return const Success(null);
      }

      final model = await _remoteDatasource.getProfile(currentUser.id);
      return Success(model?.toEntity());
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserProfile>> updateProfile(UpdateProfileParams params) async {
    try {
      final currentUser = _remoteDatasource.getCurrentUser();
      if (currentUser == null) {
        return const Failure(AuthFailure('Not authenticated'));
      }

      final data = <String, dynamic>{};
      if (params.displayName != null) {
        data['full_name'] = params.displayName;
      }
      if (params.avatarUrl != null) {
        data['avatar_url'] = params.avatarUrl;
      }
      if (params.bio != null) {
        data['bio'] = params.bio;
      }
      if (params.phone != null) {
        data['phone'] = params.phone;
      }
      if (params.profession != null) {
        data['profession'] = params.profession;
      }
      if (params.companyName != null) {
        data['company_name'] = params.companyName;
      }

      final model =
          await _remoteDatasource.updateProfile(currentUser.id, data);
      return Success(model.toEntity());
    } on supabase.AuthException catch (e) {
      return Failure(AuthFailure(e.message));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<String>> uploadAvatar(
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final currentUser = _remoteDatasource.getCurrentUser();
      if (currentUser == null) {
        return const Failure(AuthFailure('Not authenticated'));
      }

      final url = await _remoteDatasource.uploadAvatar(
        currentUser.id,
        imageBytes,
        fileName,
      );
      return Success(url);
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _remoteDatasource.deleteAccount();
      return const Success(null);
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> hasAcceptedTerms() async {
    try {
      final currentUser = _remoteDatasource.getCurrentUser();
      if (currentUser == null) {
        return const Failure(AuthFailure('Not authenticated'));
      }

      final accepted = await _remoteDatasource.hasAcceptedTerms(currentUser.id);
      return Success(accepted);
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> acceptTerms() async {
    try {
      final currentUser = _remoteDatasource.getCurrentUser();
      if (currentUser == null) {
        return const Failure(AuthFailure('Not authenticated'));
      }

      await _remoteDatasource.acceptTerms(currentUser.id);
      return const Success(null);
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }
}
