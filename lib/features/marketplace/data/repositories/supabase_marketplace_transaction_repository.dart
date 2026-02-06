/// Supabase implementation of MarketplaceTransactionRepository.
///
/// Uses Supabase Edge Functions for checkout session creation and
/// direct table queries for transaction lookups and CGVU management.
library;

import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/constants/cgvu_texts.dart';
import '../../domain/entities/marketplace_transaction.dart';
import '../../domain/entities/shipping_address.dart';
import '../../domain/entities/shipping_rate.dart';
import '../../domain/repositories/marketplace_transaction_repository.dart';

/// Supabase-backed implementation of [MarketplaceTransactionRepository].
class SupabaseMarketplaceTransactionRepository
    implements MarketplaceTransactionRepository {
  /// Creates the repository with a Supabase client.
  const SupabaseMarketplaceTransactionRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, dynamic>> createCheckoutSession({
    required String listingId,
    String? offerId,
    required ShippingAddress shippingToAddress,
    required ShippingRate shippingOption,
  }) async {
    final response = await _client.functions.invoke(
      'marketplace-create-payment',
      body: {
        'listing_id': listingId,
        if (offerId != null) 'offer_id': offerId,
        'shipping_to_address': shippingToAddress.toJson(),
        'shipping_option': {
          'service_type': shippingOption.serviceType,
          'service_name': shippingOption.serviceName,
          'rate_cents': shippingOption.rateCents,
          'currency': shippingOption.currency,
        },
      },
    );

    if (response.status != 200) {
      final errorBody = response.data;
      final errorMessage = errorBody is Map
          ? (errorBody['error'] as String? ?? 'Payment creation failed')
          : 'Payment creation failed';
      throw Exception(errorMessage);
    }

    final data = response.data is String
        ? jsonDecode(response.data as String) as Map<String, dynamic>
        : response.data as Map<String, dynamic>;

    return data;
  }

  @override
  Future<MarketplaceTransaction?> getTransaction(String transactionId) async {
    final response = await _client
        .from('marketplace_transactions')
        .select()
        .eq('id', transactionId)
        .maybeSingle();

    if (response == null) return null;
    return MarketplaceTransaction.fromJson(response);
  }

  @override
  Future<List<MarketplaceTransaction>> getMyPurchases() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('marketplace_transactions')
        .select()
        .eq('buyer_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) =>
            MarketplaceTransaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MarketplaceTransaction>> getMySales() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('marketplace_transactions')
        .select()
        .eq('seller_id', userId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) =>
            MarketplaceTransaction.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool> hasAcceptedBuyerCgvu() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final response = await _client
        .from('cgvu_acceptances')
        .select('id')
        .eq('user_id', userId)
        .eq('cgvu_type', marketplaceBuyerCgvuType)
        .maybeSingle();

    return response != null;
  }

  @override
  Future<void> acceptBuyerCgvu() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('cgvu_acceptances').insert({
      'user_id': userId,
      'cgvu_type': marketplaceBuyerCgvuType,
      'cgvu_version': marketplaceBuyerCgvuVersion,
    });
  }

  @override
  Future<void> requestRefund({
    required String transactionId,
    String? reason,
  }) async {
    final response = await _client.functions.invoke(
      'marketplace-refund',
      body: {
        'action': 'request',
        'transaction_id': transactionId,
        if (reason != null) 'reason': reason,
      },
    );
    _handleRefundResponse(response);
  }

  @override
  Future<void> approveRefund({required String transactionId}) async {
    final response = await _client.functions.invoke(
      'marketplace-refund',
      body: {
        'action': 'approve',
        'transaction_id': transactionId,
      },
    );
    _handleRefundResponse(response);
  }

  @override
  Future<void> rejectRefund({required String transactionId}) async {
    final response = await _client.functions.invoke(
      'marketplace-refund',
      body: {
        'action': 'reject',
        'transaction_id': transactionId,
      },
    );
    _handleRefundResponse(response);
  }

  void _handleRefundResponse(FunctionResponse response) {
    final data = response.data is String
        ? jsonDecode(response.data as String) as Map<String, dynamic>
        : response.data as Map<String, dynamic>;
    if (data['error'] != null) {
      throw Exception(data['error'] as String);
    }
  }
}
