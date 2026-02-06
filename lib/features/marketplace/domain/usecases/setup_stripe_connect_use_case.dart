/// Use case for setting up a Stripe Connect account.
///
/// Calls the repository to create a Custom Connect account via Edge Function
/// and returns the onboarding URL. Does NOT launch the URL -- that is
/// the responsibility of the presentation layer.
library;

import '../repositories/stripe_connect_repository.dart';

/// Creates a Stripe Connect Custom account and returns the onboarding URL.
///
/// Pre-fills individual data (name, DOB, address, IBAN) so the Stripe
/// redirect only requires identity verification (KYC).
class SetupStripeConnectUseCase {
  final StripeConnectRepository _repository;

  /// Creates a use case with the given repository.
  SetupStripeConnectUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Returns a map with `url` (onboarding link) and `stripe_account_id`.
  /// Throws if the Edge Function call fails.
  Future<Map<String, dynamic>> call({
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
  }) async {
    return _repository.createConnectAccount(
      userId: userId,
      email: email,
      returnUrl: returnUrl,
      refreshUrl: refreshUrl,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      country: country,
      address: address,
      dateOfBirth: dateOfBirth,
      iban: iban,
      tosAccepted: tosAccepted,
    );
  }
}
