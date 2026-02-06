/// Datasource for Stripe Connect operations via Supabase Edge Functions.
///
/// Handles communication with the `create-stripe-connect-account` Edge Function
/// to create Stripe Connect Custom accounts and generate onboarding links.
library;

import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract interface for Stripe Connect datasource operations.
abstract class StripeConnectDatasource {
  /// Creates a Stripe Connect account and returns the onboarding URL.
  ///
  /// Calls the `create-stripe-connect-account` Edge Function.
  /// Returns a map with `url` (onboarding link) and `stripe_account_id`.
  ///
  /// For Custom accounts, [dateOfBirth], [iban], and [tosAccepted] allow
  /// pre-filling most data in-app so the Stripe onboarding redirect only
  /// requires identity verification (KYC).
  ///
  /// Throws [FunctionException] if the Edge Function call fails.
  /// Throws [Exception] if the response is missing required fields.
  Future<Map<String, dynamic>> createStripeConnectAccount({
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

  /// Syncs the Stripe account status from the Stripe API.
  ///
  /// Calls the `sync-stripe-account` Edge Function which fetches fresh
  /// data from Stripe and updates the DB. Returns the sync result.
  Future<void> syncStripeAccount();
}

/// Supabase implementation of [StripeConnectDatasource].
///
/// Uses [SupabaseClient.functions] to invoke Edge Functions.
class SupabaseStripeConnectDatasource implements StripeConnectDatasource {
  final SupabaseClient _supabase;

  /// Creates a datasource with the given Supabase client.
  SupabaseStripeConnectDatasource(this._supabase);

  @override
  Future<Map<String, dynamic>> createStripeConnectAccount({
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
    final response = await _supabase.functions.invoke(
      'create-stripe-connect-account',
      body: {
        'user_id': userId,
        'email': email,
        'return_url': returnUrl,
        'refresh_url': refreshUrl,
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (phone != null) 'phone': phone,
        if (country != null) 'country': country,
        if (address != null) 'address': address,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (iban != null) 'iban': iban,
        'tos_accepted': tosAccepted,
      },
    );

    final data = response.data;
    Map<String, dynamic> parsed;

    if (data is String) {
      parsed = Map<String, dynamic>.from(
        jsonDecode(data) as Map,
      );
    } else if (data is Map) {
      parsed = Map<String, dynamic>.from(data);
    } else {
      throw Exception(
        'Unexpected response format from create-stripe-connect-account',
      );
    }

    if (parsed['url'] == null) {
      final error = parsed['error'] ?? 'Unknown error';
      throw Exception(
        'Failed to create Stripe Connect account: $error',
      );
    }

    return parsed;
  }

  @override
  Future<void> syncStripeAccount() async {
    final response = await _supabase.functions.invoke(
      'sync-stripe-account',
    );

    final data = response.data;
    if (data is Map && data['error'] != null) {
      throw Exception('Sync failed: ${data['error']}');
    }
  }
}
