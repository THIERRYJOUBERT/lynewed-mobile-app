/// Implementation of [InviteCodeRepository].
///
/// Uses Supabase RPC to validate invitation codes.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/repositories/invite_code_repository.dart';
import '../../domain/usecases/validate_invite_code.dart';

/// Implementation of [InviteCodeRepository] using Supabase.
///
/// Calls the `validate_invite_code` RPC function which:
/// - Validates the code format and existence
/// - Checks expiration
/// - Enforces rate limiting (5 attempts per 15 minutes per IP)
/// - Returns wedding details if valid
class InviteCodeRepositoryImpl implements InviteCodeRepository {
  /// Creates the repository with an optional Supabase client.
  InviteCodeRepositoryImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<ValidateInviteCodeResult> validateCode(String code) async {
    try {
      final response = await _client.rpc(
        'validate_invite_code',
        params: {'p_code': code.toUpperCase()},
      );

      // Response is a map with success, wedding_id, bride_name, error
      final data = response as Map<String, dynamic>;

      if (data['success'] == true) {
        return ValidInviteCode(
          weddingId: data['wedding_id'] as String,
          brideName: data['bride_name'] as String,
          guestEmail: data['guest_email'] as String?,
        );
      }

      // Check for specific error types
      final error = data['error'] as String?;

      if (error == 'rate_limited') {
        return const RateLimitedInviteCode();
      }

      // Default to invalid code (invalid_code, code_expired)
      return const InvalidInviteCode();
    } on PostgrestException catch (e) {
      return InviteCodeError('Database error: ${e.message}');
    } catch (e) {
      return InviteCodeError('Unexpected error: $e');
    }
  }
}
