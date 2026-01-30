/// Use case for creating a guest account.
///
/// Creates a new user account with role='guest' and links
/// it to a wedding using the invitation code.
library;

import '../../../../core/core.dart';
import '../../../../core/error/failures.dart';
import '../../../map/domain/usecases/get_marker_details.dart' show UseCase;
import '../entities/entities.dart';
import '../repositories/guest_repository.dart';

/// Parameters for creating a guest account.
class CreateGuestAccountParams {
  /// Guest's first name.
  final String firstName;

  /// Guest's email address.
  final String email;

  /// Guest's password.
  final String password;

  /// Wedding invitation code (8 characters).
  final String inviteCode;

  /// Creates parameters for guest account creation.
  const CreateGuestAccountParams({
    required this.firstName,
    required this.email,
    required this.password,
    required this.inviteCode,
  });
}

/// Result of creating a guest account.
sealed class CreateGuestAccountResult {
  const CreateGuestAccountResult();
}

/// Account created successfully.
class GuestAccountCreated extends CreateGuestAccountResult {
  /// The created user.
  final AuthUser user;

  /// Creates a success result.
  const GuestAccountCreated(this.user);
}

/// Email is already registered.
class EmailAlreadyExists extends CreateGuestAccountResult {
  /// Creates an email exists result.
  const EmailAlreadyExists();
}

/// Invalid email format.
class InvalidEmailFormat extends CreateGuestAccountResult {
  /// Creates an invalid email result.
  const InvalidEmailFormat();
}

/// Password does not meet requirements.
class WeakPassword extends CreateGuestAccountResult {
  /// Creates a weak password result.
  const WeakPassword();
}

/// Invite code is invalid or expired.
class InvalidInviteCodeError extends CreateGuestAccountResult {
  /// Creates an invalid code result.
  const InvalidInviteCodeError();
}

/// Generic error.
class CreateGuestAccountError extends CreateGuestAccountResult {
  /// Error message.
  final String message;

  /// Creates an error result.
  const CreateGuestAccountError(this.message);
}

/// Use case for creating a guest account.
///
/// Validates input, creates the Supabase auth account,
/// and links the user to the wedding.
class CreateGuestAccount
    implements UseCase<CreateGuestAccountResult, CreateGuestAccountParams> {
  final GuestRepository _guestRepository;

  /// Creates the use case with the given repository.
  CreateGuestAccount(this._guestRepository);

  @override
  Future<CreateGuestAccountResult> call(CreateGuestAccountParams params) async {
    // Validate email format
    if (!_isValidEmail(params.email)) {
      return const InvalidEmailFormat();
    }

    // Validate password strength
    if (!_isValidPassword(params.password)) {
      return const WeakPassword();
    }

    // Validate invite code format
    if (params.inviteCode.length != 8) {
      return const InvalidInviteCodeError();
    }

    // Create account and join wedding
    final result = await _guestRepository.signUpGuest(
      email: params.email,
      password: params.password,
      firstName: params.firstName,
      inviteCode: params.inviteCode,
    );

    return result.fold(
      onFailure: (failure) => _mapFailureToResult(failure),
      onSuccess: (user) => GuestAccountCreated(user),
    );
  }

  /// Validates email format.
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }

  /// Validates password meets minimum requirements.
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  /// Maps a failure to a result type.
  CreateGuestAccountResult _mapFailureToResult(AppFailure failure) {
    final message = failure.message;

    if (message.contains('déjà utilisé') || message.contains('already')) {
      return const EmailAlreadyExists();
    }
    if (message.contains('Email invalide') || message.contains('Invalid email')) {
      return const InvalidEmailFormat();
    }
    if (message.contains('mot de passe') || message.contains('Password')) {
      return const WeakPassword();
    }
    if (message.contains('invalid_code') || message.contains('code')) {
      return const InvalidInviteCodeError();
    }

    return CreateGuestAccountError(message);
  }
}
