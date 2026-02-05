/// Supabase implementation of MarketplaceOfferRepository.
///
/// Handles CRUD operations for marketplace offers using Supabase Database.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/marketplace_offer.dart';
import '../../domain/repositories/marketplace_offer_repository.dart';

/// Supabase-backed implementation of [MarketplaceOfferRepository].
///
/// Uses the `marketplace_offers` table for all offer operations.
/// Current user is determined via `_client.auth.currentUser?.id`.
class SupabaseMarketplaceOfferRepository
    implements MarketplaceOfferRepository {
  /// Creates a repository with the given Supabase client.
  SupabaseMarketplaceOfferRepository(this._client);

  final SupabaseClient _client;

  String get _currentUserId {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('User must be authenticated');
    }
    return userId;
  }

  @override
  Future<MarketplaceOffer> createOffer({
    required String listingId,
    required int amountCents,
    String? message,
  }) async {
    final buyerId = _currentUserId;

    // Check for existing pending offer.
    final existing = await _client
        .from('marketplace_offers')
        .select()
        .eq('listing_id', listingId)
        .eq('buyer_id', buyerId)
        .eq('status', 'pending')
        .maybeSingle();

    if (existing != null) {
      throw StateError('You already have a pending offer on this listing');
    }

    // Validate amount.
    if (amountCents <= 0) {
      throw ArgumentError('Offer amount must be greater than 0');
    }

    final response = await _client
        .from('marketplace_offers')
        .insert({
          'listing_id': listingId,
          'buyer_id': buyerId,
          'amount_cents': amountCents,
          'message': message,
          'status': 'pending',
        })
        .select()
        .single();

    return MarketplaceOffer.fromJson(response);
  }

  @override
  Future<void> acceptOffer(String offerId) async {
    // Get the offer to find the listing_id.
    final offerRow = await _client
        .from('marketplace_offers')
        .select()
        .eq('id', offerId)
        .eq('status', 'pending')
        .single();

    final listingId = offerRow['listing_id'] as String;

    // Accept this offer.
    await _client
        .from('marketplace_offers')
        .update({
          'status': 'accepted',
          'responded_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId);

    // Reject all other pending offers on the same listing.
    await _client
        .from('marketplace_offers')
        .update({
          'status': 'rejected',
          'responded_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('listing_id', listingId)
        .eq('status', 'pending')
        .neq('id', offerId);
  }

  @override
  Future<void> rejectOffer(String offerId) async {
    await _client
        .from('marketplace_offers')
        .update({
          'status': 'rejected',
          'responded_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId)
        .eq('status', 'pending');
  }

  @override
  Future<void> withdrawOffer(String offerId) async {
    final buyerId = _currentUserId;

    await _client
        .from('marketplace_offers')
        .update({
          'status': 'withdrawn',
          'responded_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', offerId)
        .eq('buyer_id', buyerId)
        .eq('status', 'pending');
  }

  @override
  Future<List<MarketplaceOffer>> getOffersForListing(String listingId) async {
    final response = await _client
        .from('marketplace_offers')
        .select()
        .eq('listing_id', listingId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(MarketplaceOffer.fromJson)
        .toList();
  }

  @override
  Future<MarketplaceOffer?> getPendingOfferForListing(
      String listingId) async {
    final buyerId = _currentUserId;

    final response = await _client
        .from('marketplace_offers')
        .select()
        .eq('listing_id', listingId)
        .eq('buyer_id', buyerId)
        .eq('status', 'pending')
        .maybeSingle();

    if (response == null) return null;
    return MarketplaceOffer.fromJson(response);
  }

  @override
  Future<List<MarketplaceOffer>> getMyOffers() async {
    final buyerId = _currentUserId;

    final response = await _client
        .from('marketplace_offers')
        .select()
        .eq('buyer_id', buyerId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(MarketplaceOffer.fromJson)
        .toList();
  }
}
