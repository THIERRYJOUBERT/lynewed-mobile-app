/// Abstract repository interface for Stripe Connect operations.
///
/// Provides methods for creating Connect accounts, checking account status,
/// and determining if a seller is ready to receive payments.
library;

import '../../../payments/domain/entities/stripe_account.dart';

/// Repository interface for Stripe Connect marketplace operations.
abstract class StripeConnectRepository {
  /// Creates a Stripe Connect Express account and returns the onboarding URL.
  ///
  /// Returns a map with:
  /// - `url`: The Stripe onboarding URL to redirect the seller to.
  /// - `stripe_account_id`: The created Stripe account ID.
  Future<Map<String, dynamic>> createConnectAccount({
    required String userId,
    required String email,
    required String returnUrl,
    required String refreshUrl,
  });

  /// Gets the Stripe account for a user.
  ///
  /// Returns null if the user has not set up a Stripe account.
  Future<StripeAccount?> getStripeAccount(String userId);

  /// Checks whether a seller has completed Stripe onboarding
  /// and can receive charges.
  ///
  /// Returns true only if the account exists and `charges_enabled` is true.
  Future<bool> isSellerReady(String userId);
}
