/// Display model wrapping MarketplaceOffer with buyer profile info.
///
/// Since MarketplaceOffer does not contain buyer name or avatar,
/// this model combines the offer with profile data for UI display.
library;

import 'package:flutter/foundation.dart';

import 'marketplace_offer.dart';

/// Display model that wraps a [MarketplaceOffer] with additional UI data.
///
/// Used by OfferCard and offer list pages to display buyer information
/// alongside the offer details.
@immutable
class OfferDisplayModel {
  /// Creates an offer display model.
  const OfferDisplayModel({
    required this.offer,
    this.buyerName,
    this.buyerAvatarUrl,
    this.listingTitle,
    this.listingPriceCents,
    this.listingCoverUrl,
    this.sellerId,
    this.sellerName,
    this.sellerAvatarUrl,
  });

  /// The underlying marketplace offer.
  final MarketplaceOffer offer;

  /// Buyer display name (from profiles table).
  final String? buyerName;

  /// Buyer avatar URL (from profiles table).
  final String? buyerAvatarUrl;

  /// Listing title (for buyer's "My Offers" view).
  final String? listingTitle;

  /// Listing price in cents (for comparison with offer amount).
  final int? listingPriceCents;

  /// Listing cover photo URL.
  final String? listingCoverUrl;

  /// Seller user ID (for navigation to chat).
  final String? sellerId;

  /// Seller display name.
  final String? sellerName;

  /// Seller avatar URL.
  final String? sellerAvatarUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfferDisplayModel &&
          runtimeType == other.runtimeType &&
          offer == other.offer &&
          buyerName == other.buyerName &&
          buyerAvatarUrl == other.buyerAvatarUrl &&
          listingTitle == other.listingTitle &&
          listingPriceCents == other.listingPriceCents &&
          sellerId == other.sellerId;

  @override
  int get hashCode => Object.hash(
        offer,
        buyerName,
        buyerAvatarUrl,
        listingTitle,
        listingPriceCents,
        sellerId,
      );

  @override
  String toString() =>
      'OfferDisplayModel(offer: $offer, buyerName: $buyerName)';
}
