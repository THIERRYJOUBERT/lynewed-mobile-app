/// MarketplaceOffer entity - An offer made by a buyer on a listing
///
/// Immutable data class representing an offer with expiration (48h).
library;

import 'package:flutter/foundation.dart';

/// Represents an offer made by a buyer on a marketplace listing.
///
/// Contains amount, optional message, status, and expiration timestamp.
@immutable
class MarketplaceOffer {
  /// Creates a marketplace offer.
  const MarketplaceOffer({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.amountCents,
    this.message,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    this.respondedAt,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Listing ID this offer is for.
  final String listingId;

  /// Buyer ID who made this offer.
  final String buyerId;

  /// Offer amount in cents (e.g., 20000 = $200.00).
  final int amountCents;

  /// Optional message from buyer to seller.
  final String? message;

  /// Status: 'pending', 'accepted', 'rejected', 'expired', 'withdrawn'.
  final String status;

  /// When this offer expires (default 48h from creation).
  final DateTime expiresAt;

  /// When the offer was created.
  final DateTime createdAt;

  /// When the seller responded (accepted/rejected).
  final DateTime? respondedAt;

  /// Amount formatted as dollars.
  double get amountInDollars => amountCents / 100;

  /// Whether this offer is still pending.
  bool get isPending => status == 'pending';

  /// Whether this offer was accepted.
  bool get isAccepted => status == 'accepted';

  /// Whether this offer is expired.
  bool get isExpired =>
      status == 'expired' ||
      (isPending && DateTime.now().isAfter(expiresAt));

  /// Creates a MarketplaceOffer from Supabase JSON row.
  factory MarketplaceOffer.fromJson(Map<String, dynamic> json) {
    return MarketplaceOffer(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      buyerId: json['buyer_id'] as String,
      amountCents: json['amount_cents'] as int,
      message: json['message'] as String?,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      respondedAt: json['responded_at'] != null
          ? DateTime.parse(json['responded_at'] as String)
          : null,
    );
  }

  /// Converts to JSON for database insert (excludes auto-generated fields).
  Map<String, dynamic> toJson() {
    return {
      'listing_id': listingId,
      'buyer_id': buyerId,
      'amount_cents': amountCents,
      'message': message,
      'status': status,
    };
  }

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceOffer &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() =>
      'MarketplaceOffer(id: $id, listingId: $listingId, '
      'amountCents: $amountCents, status: $status)';

  /// Creates a copy with updated fields.
  MarketplaceOffer copyWith({
    String? id,
    String? listingId,
    String? buyerId,
    int? amountCents,
    String? message,
    String? status,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return MarketplaceOffer(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      buyerId: buyerId ?? this.buyerId,
      amountCents: amountCents ?? this.amountCents,
      message: message ?? this.message,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
