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

    // Block new offers if an accepted offer already exists on this listing.
    if (await hasAcceptedOfferForListing(listingId)) {
      throw StateError('An offer has already been accepted on this listing');
    }

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
    return _getOffersForBuyer();
  }

  @override
  Future<List<OfferDisplayModel>> getOffersAwaitingMyPayment() async {
    final allOffers = await _getOffersForBuyer(statusFilter: 'accepted');

    if (allOffers.isEmpty) return [];

    // Exclude offers that already have a transaction.
    final offerIds = allOffers.map((m) => m.offer.id).toList();
    final existingTx = await _client
        .from('marketplace_transactions')
        .select('offer_id')
        .inFilter('offer_id', offerIds);

    final paidOfferIds = (existingTx as List)
        .map((row) => row['offer_id'] as String)
        .toSet();

    return allOffers
        .where((m) => !paidOfferIds.contains(m.offer.id))
        .toList();
  }

  /// Fetches all offers relevant to the current user as buyer.
  ///
  /// Includes direct offers (buyer_id = currentUser) and counter-offers
  /// received from sellers (found via marketplace_messages.receiver_id).
  /// Optionally filters by [statusFilter] (e.g. 'accepted').
  Future<List<OfferDisplayModel>> _getOffersForBuyer({
    String? statusFilter,
  }) async {
    final userId = _currentUserId;

    // Query 1: Direct offers by this user.
    var directQuery = _client
        .from('marketplace_offers')
        .select(
            '*, marketplace_listings!inner(id, title, price_cents, seller_id)')
        .eq('buyer_id', userId);
    if (statusFilter != null) {
      directQuery = directQuery.eq('status', statusFilter);
    }
    final directResponse =
        await directQuery.order('created_at', ascending: false);

    final directOfferIds =
        (directResponse as List).map((r) => r['id'] as String).toSet();

    // Query 2: Counter-offers received from sellers.
    // Find offer IDs from marketplace_messages where this user is the receiver.
    final counterOfferMsgs = await _client
        .from('marketplace_messages')
        .select('offer_id')
        .eq('receiver_id', userId)
        .eq('message_type', 'offer')
        .not('offer_id', 'is', null);

    final counterOfferIds = (counterOfferMsgs as List)
        .map((row) => row['offer_id'] as String)
        .toSet()
        .difference(directOfferIds) // Exclude already-fetched offers.
        .toList();

    List<dynamic> counterResponse = [];
    if (counterOfferIds.isNotEmpty) {
      var counterQuery = _client
          .from('marketplace_offers')
          .select(
              '*, marketplace_listings!inner(id, title, price_cents, seller_id)')
          .inFilter('id', counterOfferIds);
      if (statusFilter != null) {
        counterQuery = counterQuery.eq('status', statusFilter);
      }
      counterResponse =
          await counterQuery.order('created_at', ascending: false) as List;
    }

    // Merge both result sets.
    final allRows = [...directResponse, ...counterResponse];
    if (allRows.isEmpty) return [];

    // Identify counter-offers (where buyer_id == seller_id, meaning the seller
    // made a counter-offer stored as "buyer"). For these, the chat partner is
    // the actual buyer found via the offer message receiver_id.
    final counterOfferIdsForPartner = <String>[];
    for (final row in allRows) {
      final json = row as Map<String, dynamic>;
      final listing = json['marketplace_listings'] as Map<String, dynamic>?;
      final buyerId = json['buyer_id'] as String?;
      final sellerId = listing?['seller_id'] as String?;
      if (buyerId != null && buyerId == sellerId) {
        counterOfferIdsForPartner.add(json['id'] as String);
      }
    }

    // For counter-offers, find the actual chat partner (message receiver).
    final counterOfferPartnerMap = <String, String>{};
    if (counterOfferIdsForPartner.isNotEmpty) {
      final msgRows = await _client
          .from('marketplace_messages')
          .select('offer_id, receiver_id')
          .inFilter('offer_id', counterOfferIdsForPartner)
          .eq('message_type', 'offer');
      for (final row in msgRows as List) {
        final offerId = row['offer_id'] as String;
        final receiverId = row['receiver_id'] as String;
        counterOfferPartnerMap[offerId] = receiverId;
      }
    }

    // Collect all profile IDs needed (sellers + counter-offer partners).
    final profileIdsNeeded = <String>{};
    for (final row in allRows) {
      final listing = row['marketplace_listings'] as Map<String, dynamic>?;
      if (listing != null && listing['seller_id'] != null) {
        profileIdsNeeded.add(listing['seller_id'] as String);
      }
    }
    profileIdsNeeded.addAll(counterOfferPartnerMap.values);

    // Batch-fetch profiles.
    final profilesMap = <String, Map<String, dynamic>>{};
    if (profileIdsNeeded.isNotEmpty) {
      final profiles = await _client
          .from('profiles')
          .select('id, full_name, avatar_url')
          .inFilter('id', profileIdsNeeded.toList());
      for (final p in profiles as List) {
        final profile = p as Map<String, dynamic>;
        profilesMap[profile['id'] as String] = profile;
      }
    }

    final results = allRows.map((row) {
      final json = row as Map<String, dynamic>;
      final listing = json['marketplace_listings'] as Map<String, dynamic>?;
      final offer = MarketplaceOffer.fromJson(json);
      final sellerId = listing?['seller_id'] as String?;
      final sellerProfile = sellerId != null ? profilesMap[sellerId] : null;

      // Determine chat partner: for counter-offers use the actual buyer,
      // otherwise use the seller.
      final isCounterOffer = counterOfferPartnerMap.containsKey(offer.id);
      final partnerId = isCounterOffer
          ? counterOfferPartnerMap[offer.id]
          : sellerId;
      final partnerProfile = partnerId != null ? profilesMap[partnerId] : null;

      return OfferDisplayModel(
        offer: offer,
        listingTitle: listing?['title'] as String?,
        listingPriceCents: listing?['price_cents'] as int?,
        sellerId: sellerId,
        sellerName: sellerProfile?['full_name'] as String?,
        sellerAvatarUrl: sellerProfile?['avatar_url'] as String?,
        chatPartnerId: partnerId,
        chatPartnerName: partnerProfile?['full_name'] as String?,
        chatPartnerAvatarUrl: partnerProfile?['avatar_url'] as String?,
      );
    }).toList();

    // Sort by creation date descending (merged from two queries).
    results.sort((a, b) => b.offer.createdAt.compareTo(a.offer.createdAt));
    return results;
  }

  @override
  Future<bool> hasAcceptedOfferForListing(String listingId) async {
    final response = await _client
        .from('marketplace_offers')
        .select('id')
        .eq('listing_id', listingId)
        .eq('status', 'accepted')
        .limit(1)
        .maybeSingle();

    return response != null;
  }
}
