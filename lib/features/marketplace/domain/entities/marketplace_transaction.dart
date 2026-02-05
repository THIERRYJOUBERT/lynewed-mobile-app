/// MarketplaceTransaction entity - A completed purchase transaction
///
/// Immutable data class representing a transaction with payment, shipping,
/// and lifecycle.
library;

import 'package:flutter/foundation.dart';
import 'shipping_address.dart';

/// Represents a marketplace transaction.
///
/// Contains amounts, Stripe/FedEx references, addresses, and status lifecycle.
@immutable
class MarketplaceTransaction {
  /// Creates a marketplace transaction.
  const MarketplaceTransaction({
    required this.id,
    required this.listingId,
    this.offerId,
    required this.sellerId,
    required this.buyerId,
    required this.itemPriceCents,
    required this.shippingCostCents,
    required this.platformFeeCents,
    required this.sellerPayoutCents,
    required this.totalPaidCents,
    this.stripePaymentIntentId,
    this.stripeChargeId,
    this.stripeTransferId,
    this.fedexTrackingNumber,
    this.fedexLabelUrl,
    this.fedexRateId,
    required this.shippingFromAddress,
    required this.shippingToAddress,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.completedAt,
  });

  /// Unique identifier (UUID from database).
  final String id;

  /// Listing ID (FK to marketplace_listings).
  final String listingId;

  /// Optional offer ID (FK to marketplace_offers).
  final String? offerId;

  /// Seller profile ID.
  final String sellerId;

  /// Buyer profile ID.
  final String buyerId;

  /// Item price in cents.
  final int itemPriceCents;

  /// Shipping cost in cents.
  final int shippingCostCents;

  /// Platform fee in cents (10% of item price).
  final int platformFeeCents;

  /// Seller payout in cents (90% of item price).
  final int sellerPayoutCents;

  /// Total paid by buyer in cents (item + shipping).
  final int totalPaidCents;

  /// Stripe PaymentIntent ID.
  final String? stripePaymentIntentId;

  /// Stripe Charge ID.
  final String? stripeChargeId;

  /// Stripe Transfer ID (to seller).
  final String? stripeTransferId;

  /// FedEx tracking number.
  final String? fedexTrackingNumber;

  /// FedEx label URL (PDF).
  final String? fedexLabelUrl;

  /// FedEx rate ID used for this shipment.
  final String? fedexRateId;

  /// Shipping origin address (seller).
  final ShippingAddress shippingFromAddress;

  /// Shipping destination address (buyer).
  final ShippingAddress shippingToAddress;

  /// Transaction status lifecycle.
  final String status;

  /// When the transaction was created.
  final DateTime createdAt;

  /// When the transaction was last updated.
  final DateTime updatedAt;

  /// When payment was completed.
  final DateTime? paidAt;

  /// When the item was shipped.
  final DateTime? shippedAt;

  /// When the item was delivered.
  final DateTime? deliveredAt;

  /// When the transaction was completed (7 days after delivery).
  final DateTime? completedAt;

  /// Item price in dollars.
  double get itemPriceInDollars => itemPriceCents / 100;

  /// Total paid in dollars.
  double get totalPaidInDollars => totalPaidCents / 100;

  /// Shipping cost in dollars.
  double get shippingCostInDollars => shippingCostCents / 100;

  /// Platform fee in dollars.
  double get platformFeeInDollars => platformFeeCents / 100;

  /// Seller payout in dollars.
  double get sellerPayoutInDollars => sellerPayoutCents / 100;

  /// Whether the transaction is pending payment.
  bool get isPending => status == 'pending';

  /// Whether the transaction is paid.
  bool get isPaid => status == 'paid';

  /// Whether the transaction is completed.
  bool get isCompleted => status == 'completed';

  /// Creates a MarketplaceTransaction from Supabase JSON row.
  factory MarketplaceTransaction.fromJson(Map<String, dynamic> json) {
    return MarketplaceTransaction(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      offerId: json['offer_id'] as String?,
      sellerId: json['seller_id'] as String,
      buyerId: json['buyer_id'] as String,
      itemPriceCents: json['item_price_cents'] as int,
      shippingCostCents: json['shipping_cost_cents'] as int,
      platformFeeCents: json['platform_fee_cents'] as int,
      sellerPayoutCents: json['seller_payout_cents'] as int,
      totalPaidCents: json['total_paid_cents'] as int,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      stripeChargeId: json['stripe_charge_id'] as String?,
      stripeTransferId: json['stripe_transfer_id'] as String?,
      fedexTrackingNumber: json['fedex_tracking_number'] as String?,
      fedexLabelUrl: json['fedex_label_url'] as String?,
      fedexRateId: json['fedex_rate_id'] as String?,
      shippingFromAddress: ShippingAddress.fromJson(
        json['shipping_from_address'] as Map<String, dynamic>,
      ),
      shippingToAddress: ShippingAddress.fromJson(
        json['shipping_to_address'] as Map<String, dynamic>,
      ),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  /// Converts to JSON for database insert (excludes auto-generated fields).
  Map<String, dynamic> toJson() {
    return {
      'listing_id': listingId,
      'offer_id': offerId,
      'seller_id': sellerId,
      'buyer_id': buyerId,
      'item_price_cents': itemPriceCents,
      'shipping_cost_cents': shippingCostCents,
      'platform_fee_cents': platformFeeCents,
      'seller_payout_cents': sellerPayoutCents,
      'total_paid_cents': totalPaidCents,
      'stripe_payment_intent_id': stripePaymentIntentId,
      'stripe_charge_id': stripeChargeId,
      'stripe_transfer_id': stripeTransferId,
      'fedex_tracking_number': fedexTrackingNumber,
      'fedex_label_url': fedexLabelUrl,
      'fedex_rate_id': fedexRateId,
      'shipping_from_address': shippingFromAddress.toJson(),
      'shipping_to_address': shippingToAddress.toJson(),
      'status': status,
    };
  }

  /// Equality based on id.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceTransaction &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// String representation for debugging.
  @override
  String toString() =>
      'MarketplaceTransaction(id: $id, status: $status, '
      'totalPaidCents: $totalPaidCents)';

  /// Creates a copy with updated fields.
  MarketplaceTransaction copyWith({
    String? id,
    String? listingId,
    String? offerId,
    String? sellerId,
    String? buyerId,
    int? itemPriceCents,
    int? shippingCostCents,
    int? platformFeeCents,
    int? sellerPayoutCents,
    int? totalPaidCents,
    String? stripePaymentIntentId,
    String? stripeChargeId,
    String? stripeTransferId,
    String? fedexTrackingNumber,
    String? fedexLabelUrl,
    String? fedexRateId,
    ShippingAddress? shippingFromAddress,
    ShippingAddress? shippingToAddress,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? completedAt,
  }) {
    return MarketplaceTransaction(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      offerId: offerId ?? this.offerId,
      sellerId: sellerId ?? this.sellerId,
      buyerId: buyerId ?? this.buyerId,
      itemPriceCents: itemPriceCents ?? this.itemPriceCents,
      shippingCostCents: shippingCostCents ?? this.shippingCostCents,
      platformFeeCents: platformFeeCents ?? this.platformFeeCents,
      sellerPayoutCents: sellerPayoutCents ?? this.sellerPayoutCents,
      totalPaidCents: totalPaidCents ?? this.totalPaidCents,
      stripePaymentIntentId:
          stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeChargeId: stripeChargeId ?? this.stripeChargeId,
      stripeTransferId: stripeTransferId ?? this.stripeTransferId,
      fedexTrackingNumber: fedexTrackingNumber ?? this.fedexTrackingNumber,
      fedexLabelUrl: fedexLabelUrl ?? this.fedexLabelUrl,
      fedexRateId: fedexRateId ?? this.fedexRateId,
      shippingFromAddress: shippingFromAddress ?? this.shippingFromAddress,
      shippingToAddress: shippingToAddress ?? this.shippingToAddress,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
