/// Repository interface for marketplace offer operations.
///
/// Defines the contract for creating, managing, and querying offers
/// on marketplace listings.
library;

import '../entities/marketplace_offer.dart';
import '../entities/offer_display_model.dart';

/// Abstract repository for marketplace offers.
///
/// Implementations handle persistence (e.g., Supabase) while this
/// interface allows for testing with fakes.
abstract class MarketplaceOfferRepository {
  /// Create a new offer on a listing.
  ///
  /// Throws if buyer already has a pending offer on this listing.
  Future<MarketplaceOffer> createOffer({
    required String listingId,
    required int amountCents,
    String? message,
  });

  /// Accept an offer (seller action).
  ///
  /// Also rejects all other pending offers on the same listing.
  Future<void> acceptOffer(String offerId);

  /// Reject an offer (seller action).
  Future<void> rejectOffer(String offerId);

  /// Withdraw a pending offer (buyer action).
  Future<void> withdrawOffer(String offerId);

  /// Get a specific offer by its ID.
  Future<MarketplaceOffer> getOfferById(String offerId);

  /// Get all offers for a listing (seller view) with buyer profile info.
  ///
  /// Ordered by creation date, newest first.
  Future<List<OfferDisplayModel>> getOffersForListing(String listingId);

  /// Check if current user has a pending offer on a listing.
  ///
  /// Returns the pending offer or null if none exists.
  Future<MarketplaceOffer?> getPendingOfferForListing(String listingId);

  /// Get current user's offers across all listings (buyer view) with listing info.
  ///
  /// Includes both direct offers and counter-offers received from sellers.
  /// Ordered by creation date, newest first.
  Future<List<OfferDisplayModel>> getMyOffers();

  /// Get accepted offers awaiting payment by the current user.
  ///
  /// Returns offers where:
  /// - Status is 'accepted'
  /// - Current user is the buyer (direct offer or counter-offer receiver)
  /// - No transaction has been created yet for the offer
  Future<List<OfferDisplayModel>> getOffersAwaitingMyPayment();
}
