/// Abstract repository interface for Stripe Connect operations.
///
/// Provides methods for creating Connect accounts, checking account status,
/// and determining if a seller is ready to receive payments.
library;

import '../../../payments/domain/entities/stripe_account.dart';

/// Repository interface for Stripe Connect marketplace operations.
abstract class StripeConnectRepository {
  /// Creates a Stripe Connect Custom account and returns the onboarding URL.
  ///
  /// Pre-fills individual data (name, DOB, address, IBAN) so the Stripe
  /// onboarding redirect only requires identity verification.
  ///
  /// Returns a map with:
  /// - `url`: The Stripe onboarding URL to redirect the seller to.
  /// - `stripe_account_id`: The created Stripe account ID.
  Future<Map<String, dynamic>> createConnectAccount({
    required String userId,
    required String email,
    required String returnUrl,
    required String refreshUrl,
    String? firstName,
    String? lastName,
    String? phone,
    String? country,
    Map<String, String>? address,
    Map<String, int>? dateOfBirth,
    String? iban,
    bool tosAccepted = false,
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

  /// Syncs the Stripe account status from the Stripe API.
  ///
  /// Fetches fresh data from Stripe and updates the local DB record.
  Future<void> syncStripeAccount();
}
