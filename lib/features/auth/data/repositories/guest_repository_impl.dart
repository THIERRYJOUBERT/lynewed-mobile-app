/// Guest repository implementation using Supabase.
///
/// Implements [GuestRepository] for guest account creation
/// and wedding joining operations.
library;

import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../../../core/core.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/guest_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of [GuestRepository] using Supabase.
class GuestRepositoryImpl implements GuestRepository {
  final supabase.SupabaseClient _supabaseClient;
  final AuthRemoteDatasource _authDatasource;

  /// Creates a guest repository with the given Supabase client.
  GuestRepositoryImpl(this._supabaseClient, this._authDatasource);

  /// Creates a guest repository with default Supabase instance.
  factory GuestRepositoryImpl.withDefaults() {
    final client = supabase.Supabase.instance.client;
    return GuestRepositoryImpl(client, AuthRemoteDatasourceImpl(client));
  }

  @override
  Future<Result<AuthUser>> signUpGuest({
    required String email,
    required String password,
    required String firstName,
    required String inviteCode,
  }) async {
    try {
      // 1. Create Supabase auth account with role='guest'
      final userModel = await _authDatasource.signUpWithEmail(
        email,
        password,
        metadata: {
          'first_name': firstName,
          'role': 'guest',
        },
      );

      // 2. Accept terms
      await _authDatasource.acceptTerms(userModel.id);

      // 3. Join wedding via RPC
      final joinResult = await _joinWeddingRpc(userModel.id, inviteCode);

      if (!joinResult.success) {
        // Signup succeeded but joining failed - user can retry joining
        return Failure(AuthFailure(joinResult.error ?? 'Failed to join wedding'));
      }

      return Success(userModel.toEntity());
    } on supabase.AuthException catch (e) {
      return Failure(AuthFailure(_translateAuthError(e.message)));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthUser>> signInWithOAuthAndJoinWedding({
    required String inviteCode,
  }) async {
    // OAuth flow is handled by the UI layer (Google/Apple sign-in buttons)
    // This method is called after OAuth completes to join the wedding
    try {
      final currentUser = _authDatasource.getCurrentUser();
      if (currentUser == null) {
        return const Failure(AuthFailure('No authenticated user'));
      }

      // Join wedding via RPC
      final joinResult = await _joinWeddingRpc(currentUser.id, inviteCode);

      if (!joinResult.success) {
        return Failure(AuthFailure(joinResult.error ?? 'Failed to join wedding'));
      }

      return Success(currentUser.toEntity());
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<JoinWeddingResult>> joinWedding({
    required String userId,
    required String inviteCode,
  }) async {
    try {
      final result = await _joinWeddingRpc(userId, inviteCode);

      if (!result.success) {
        return Failure(AuthFailure(result.error ?? 'Failed to join wedding'));
      }

      return Success(JoinWeddingResult(
        weddingId: result.weddingId!,
        brideName: result.brideName!,
        chatRoomId: result.chatRoomId,
        guestId: result.guestId!,
      ));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<JoinWeddingResult?>> getGuestWeddingInfo(String userId) async {
    try {
      final response = await _supabaseClient
          .from('wedding_guests')
          .select('''
            id,
            wedding_id,
            status,
            weddings!inner (
              id,
              bride_profile_id,
              profiles!weddings_bride_profile_id_fkey (
                first_name
              )
            )
          ''')
          .eq('user_id', userId)
          .eq('status', 'joined')
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      final wedding = response['weddings'] as Map<String, dynamic>;
      final brideProfile = wedding['profiles'] as Map<String, dynamic>?;

      // Get chat room ID
      final chatRoom = await _supabaseClient
          .from('chat_rooms')
          .select('id')
          .eq('wedding_id', wedding['id'])
          .eq('type', 'wedding_team')
          .maybeSingle();

      return Success(JoinWeddingResult(
        weddingId: wedding['id'] as String,
        brideName: brideProfile?['first_name'] as String? ?? 'La mariée',
        chatRoomId: chatRoom?['id'] as String?,
        guestId: response['id'] as String,
      ));
    } catch (e) {
      return Failure(UnknownFailure(e.toString()));
    }
  }

  /// Internal RPC call result.
  Future<_JoinWeddingRpcResult> _joinWeddingRpc(
    String userId,
    String inviteCode,
  ) async {
    final response = await _supabaseClient.rpc(
      'join_wedding_as_guest',
      params: {
        'p_user_id': userId,
        'p_invite_code': inviteCode.toUpperCase(),
      },
    );

    final data = response as Map<String, dynamic>;
    return _JoinWeddingRpcResult.fromJson(data);
  }

  /// Translates Supabase auth errors to user-friendly messages.
  String _translateAuthError(String message) {
    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'Cet email est déjà utilisé';
    }
    if (message.contains('Invalid email')) {
      return 'Email invalide';
    }
    if (message.contains('Password')) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return message;
  }
}

/// Internal class to parse RPC response.
class _JoinWeddingRpcResult {
  final bool success;
  final String? error;
  final String? weddingId;
  final String? brideName;
  final String? chatRoomId;
  final String? guestId;

  _JoinWeddingRpcResult({
    required this.success,
    this.error,
    this.weddingId,
    this.brideName,
    this.chatRoomId,
    this.guestId,
  });

  factory _JoinWeddingRpcResult.fromJson(Map<String, dynamic> json) {
    return _JoinWeddingRpcResult(
      success: json['success'] as bool,
      error: json['error'] as String?,
      weddingId: json['wedding_id'] as String?,
      brideName: json['bride_name'] as String?,
      chatRoomId: json['chat_room_id'] as String?,
      guestId: json['guest_id'] as String?,
    );
  }
}
