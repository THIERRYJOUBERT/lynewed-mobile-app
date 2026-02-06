/// Implementation of [StripeConnectRepository].
///
/// Delegates Edge Function calls to [StripeConnectDatasource] and
/// account queries to the existing [StripeRepository].
library;

import '../../../payments/domain/entities/stripe_account.dart';
import '../../../payments/domain/repositories/stripe_repository.dart';
import '../../domain/repositories/stripe_connect_repository.dart';
import '../datasources/stripe_connect_datasource.dart';

/// Supabase implementation of [StripeConnectRepository].
///
/// Combines the Edge Function datasource for account creation with
/// the existing Stripe repository for account queries.
class StripeConnectRepositoryImpl implements StripeConnectRepository {
  final StripeConnectDatasource _datasource;
  final StripeRepository _stripeRepository;

  /// Creates a repository with the given datasource and Stripe repository.
  StripeConnectRepositoryImpl({
    required StripeConnectDatasource datasource,
    required StripeRepository stripeRepository,
  })  : _datasource = datasource,
        _stripeRepository = stripeRepository;

  @override
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
  }) async {
    return _datasource.createStripeConnectAccount(
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

  @override
  Future<StripeAccount?> getStripeAccount(String userId) async {
    return _stripeRepository.getStripeAccount(userId);
  }

  @override
  Future<bool> isSellerReady(String userId) async {
    final account = await _stripeRepository.getStripeAccount(userId);
    return account?.chargesEnabled ?? false;
  }

  @override
  Future<void> syncStripeAccount() async {
    return _datasource.syncStripeAccount();
  }
}
