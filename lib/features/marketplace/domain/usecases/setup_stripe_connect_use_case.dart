/// Use case for setting up a Stripe Connect account.
///
/// Calls the repository to create a Connect account via Edge Function
/// and returns the onboarding URL. Does NOT launch the URL -- that is
/// the responsibility of the presentation layer.
library;

import '../repositories/stripe_connect_repository.dart';

/// Creates a Stripe Connect Express account and returns the onboarding URL.
///
/// Usage:
/// ```dart
/// final result = await setupStripeConnect(
///   userId: currentUser.id,
///   email: currentUser.email,
///   returnUrl: 'lynewed://stripe-connect-return?success=true',
///   refreshUrl: 'lynewed://stripe-connect-return?error=refresh_required',
/// );
/// final onboardingUrl = result['url'] as String;
/// ```
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
    );
  }
}
