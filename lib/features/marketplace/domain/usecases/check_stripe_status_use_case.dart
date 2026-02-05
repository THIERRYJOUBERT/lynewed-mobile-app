/// Use case for checking a seller's Stripe Connect status.
///
/// Determines whether a seller has completed onboarding and can
/// receive payments via Stripe Connect.
library;

import '../../../payments/domain/entities/stripe_account.dart';
import '../repositories/stripe_connect_repository.dart';

/// Checks whether a seller's Stripe account is ready to receive payments.
///
/// Usage:
/// ```dart
/// final isReady = await checkStripeStatus('user-123');
/// if (!isReady) {
///   // Prompt user to complete Stripe setup
/// }
/// ```
class CheckStripeStatusUseCase {
  final StripeConnectRepository _repository;

  /// Creates a use case with the given repository.
  CheckStripeStatusUseCase(this._repository);

  /// Returns true if the seller's `charges_enabled` is true.
  Future<bool> call(String userId) async {
    return _repository.isSellerReady(userId);
  }

  /// Gets the full Stripe account details for a user.
  ///
  /// Returns null if no account exists.
  Future<StripeAccount?> getAccount(String userId) async {
    return _repository.getStripeAccount(userId);
  }
}
