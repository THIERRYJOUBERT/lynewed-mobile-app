/// Repository interface for invitation code operations.
///
/// Defines the contract for validating wedding invitation codes.
library;

import '../usecases/validate_invite_code.dart';

/// Repository for invitation code operations.
///
/// This interface is implemented in the data layer
/// to communicate with the Supabase backend.
abstract class InviteCodeRepository {
  /// Validates an invitation code.
  ///
  /// Returns:
  /// - [ValidInviteCode] if code is valid with wedding details
  /// - [InvalidInviteCode] if code is invalid or expired
  /// - [RateLimitedInviteCode] if too many attempts
  /// - [InviteCodeError] if a server error occurred
  Future<ValidateInviteCodeResult> validateCode(String code);
}
