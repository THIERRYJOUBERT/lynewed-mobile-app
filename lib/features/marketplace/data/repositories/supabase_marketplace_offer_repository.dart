/// Supabase implementation of MarketplaceOfferRepository.
///
/// Handles CRUD operations for marketplace offers using Supabase Database.
library;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/marketplace_offer.dart';
import '../../domain/entities/offer_display_model.dart';
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
  Future<MarketplaceOffer> getOfferById(String offerId) async {
    final response = await _client
        .from('marketplace_offers')
        .select()
        .eq('id', offerId)
        .single();

    return MarketplaceOffer.fromJson(response);
  }

  @override
  Future<List<OfferDisplayModel>> getOffersForListing(String listingId) async {
    // Fetch offers with buyer profile info via join.
    final response = await _client
        .from('marketplace_offers')
        .select('*, profiles!marketplace_offers_buyer_id_fkey(full_name, avatar_url)')
        .eq('listing_id', listingId)
        .neq('buyer_id', _currentUserId) // Exclude seller's own counter-offers
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((row) {
      final json = row as Map<String, dynamic>;
      final profile = json['profiles'] as Map<String, dynamic>?;
      final offer = MarketplaceOffer.fromJson(json);
      return OfferDisplayModel(
        offer: offer,
        buyerName: profile?['full_name'] as String?,
        buyerAvatarUrl: profile?['avatar_url'] as String?,
      );
    }).toList();
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
  Future<List<OfferDisplayModel>> getMyOffers() async {
    final buyerId = _currentUserId;

    // Fetch offers with listing info via join.
    final response = await _client
        .from('marketplace_offers')
        .select('*, marketplace_listings!inner(id, title, price_cents, seller_id)')
        .eq('buyer_id', buyerId)
        .order('created_at', ascending: false);

    if ((response as List).isEmpty) return [];

    // Collect seller IDs for batch profile fetch.
    final sellerIds = <String>{};
    for (final row in response) {
      final listing = row['marketplace_listings'] as Map<String, dynamic>?;
      if (listing != null && listing['seller_id'] != null) {
        sellerIds.add(listing['seller_id'] as String);
      }
    }

    // Batch-fetch seller profiles.
    final profilesMap = <String, Map<String, dynamic>>{};
    if (sellerIds.isNotEmpty) {
      final profiles = await _client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .inFilter('id', sellerIds.toList());
      for (final p in profiles as List) {
        final profile = p as Map<String, dynamic>;
        profilesMap[profile['id'] as String] = profile;
      }
    }

    return response.map((row) {
      final json = row;
      final listing = json['marketplace_listings'] as Map<String, dynamic>?;
      final offer = MarketplaceOffer.fromJson(json);
      final sellerId = listing?['seller_id'] as String?;
      final sellerProfile = sellerId != null ? profilesMap[sellerId] : null;

      return OfferDisplayModel(
        offer: offer,
        listingTitle: listing?['title'] as String?,
        listingPriceCents: listing?['price_cents'] as int?,
        sellerId: sellerId,
        sellerName: sellerProfile?['full_name'] as String?,
        sellerAvatarUrl: sellerProfile?['avatar_url'] as String?,
      );
    }).toList();
  }
}
