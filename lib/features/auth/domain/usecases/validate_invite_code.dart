/// Use case for validating wedding invitation codes.
///
/// Validates an 8-character invitation code against the database
/// and returns wedding details if valid.
library;

import '../../../map/domain/usecases/get_marker_details.dart' show UseCase;
import '../repositories/invite_code_repository.dart';

/// Result of validating an invitation code.
sealed class ValidateInviteCodeResult {
  const ValidateInviteCodeResult();
}

/// Code is valid, contains wedding details.
class ValidInviteCode extends ValidateInviteCodeResult {
  const ValidInviteCode({
    required this.weddingId,
    required this.brideName,
    this.guestEmail,
  });

  final String weddingId;
  final String brideName;
  final String? guestEmail;
}

/// Code is invalid or expired.
class InvalidInviteCode extends ValidateInviteCodeResult {
  const InvalidInviteCode();
}

/// Too many attempts, rate limited.
class RateLimitedInviteCode extends ValidateInviteCodeResult {
  const RateLimitedInviteCode();
}

/// Network or server error.
class InviteCodeError extends ValidateInviteCodeResult {
  const InviteCodeError(this.message);

  final String message;
}

/// Parameters for validating an invite code.
class ValidateInviteCodeParams {
  const ValidateInviteCodeParams({
    required this.code,
  });

  final String code;
}

/// Use case for validating invitation codes.
///
/// Calls the database RPC to validate the code and check
/// rate limiting on the server side.
class ValidateInviteCode
    implements UseCase<ValidateInviteCodeResult, ValidateInviteCodeParams> {
  ValidateInviteCode(this._repository);

  final InviteCodeRepository _repository;

  @override
  Future<ValidateInviteCodeResult> call(ValidateInviteCodeParams params) async {
    // Validate code format locally first
    if (params.code.length != 8) {
      return const InvalidInviteCode();
    }

    // Check with server
    try {
      return await _repository.validateCode(params.code);
    } catch (e) {
      return InviteCodeError(e.toString());
    }
  }
}
