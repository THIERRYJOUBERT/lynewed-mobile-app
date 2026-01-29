/// Purchase entity representing a transaction.
///
/// Maps to the `purchases` table in Supabase.
/// Tracks all types of purchases: marketplace, magazines, albums, etc.
library;

import 'package:flutter/foundation.dart';

import 'product_type.dart';
import 'purchase_status.dart';

/// Represents a purchase transaction in the system.
///
/// Contains all payment information including amounts, status,
/// Stripe IDs, and timestamps for the complete purchase lifecycle.
@immutable
class Purchase {
  /// Unique purchase ID.
  final String id;

  /// Buyer user ID (references profiles.id).
  final String userId;

  /// Type of product being purchased.
  final ProductType productType;

  /// ID of the specific product.
  final String? productId;

  /// Seller user ID for marketplace items.
  final String? sellerId;

  /// Total amount in cents.
  final int amountCents;

  /// Currency code (USD, EUR, etc.).
  final String currency;

  /// Platform fee in cents (10% for marketplace).
  final int platformFeeCents;

  /// Amount going to seller in cents.
  final int? sellerAmountCents;

  /// Shipping cost in cents.
  final int shippingCents;

  /// Stripe PaymentIntent ID.
  final String? stripePaymentIntentId;

  /// Stripe Checkout Session ID.
  final String? stripeCheckoutSessionId;

  /// Stripe Transfer ID (for marketplace payouts).
  final String? stripeTransferId;

  /// Stripe Charge ID.
  final String? stripeChargeId;

  /// Current purchase status.
  final PurchaseStatus status;

  /// Additional metadata (JSONB).
  final Map<String, dynamic> metadata;

  /// Error message if payment failed.
  final String? errorMessage;

  /// Error code if payment failed.
  final String? errorCode;

  /// Purchase creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Payment completion timestamp.
  final DateTime? paidAt;

  /// Refund timestamp.
  final DateTime? refundedAt;

  /// Dispute timestamp.
  final DateTime? disputedAt;

  const Purchase({
    required this.id,
    required this.userId,
    required this.productType,
    this.productId,
    this.sellerId,
    required this.amountCents,
    this.currency = 'USD',
    this.platformFeeCents = 0,
    this.sellerAmountCents,
    this.shippingCents = 0,
    this.stripePaymentIntentId,
    this.stripeCheckoutSessionId,
    this.stripeTransferId,
    this.stripeChargeId,
    this.status = PurchaseStatus.pending,
    this.metadata = const {},
    this.errorMessage,
    this.errorCode,
    required this.createdAt,
    required this.updatedAt,
    this.paidAt,
    this.refundedAt,
    this.disputedAt,
  });

  /// Creates a Purchase from a JSON map (Supabase row).
  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productType: ProductType.fromString(json['product_type'] as String),
      productId: json['product_id'] as String?,
      sellerId: json['seller_id'] as String?,
      amountCents: json['amount_cents'] as int,
      currency: json['currency'] as String? ?? 'USD',
      platformFeeCents: json['platform_fee_cents'] as int? ?? 0,
      sellerAmountCents: json['seller_amount_cents'] as int?,
      shippingCents: json['shipping_cents'] as int? ?? 0,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      stripeCheckoutSessionId: json['stripe_checkout_session_id'] as String?,
      stripeTransferId: json['stripe_transfer_id'] as String?,
      stripeChargeId: json['stripe_charge_id'] as String?,
      status:
          PurchaseStatus.fromString(json['status'] as String? ?? 'pending'),
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      errorMessage: json['error_message'] as String?,
      errorCode: json['error_code'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      refundedAt: json['refunded_at'] != null
          ? DateTime.parse(json['refunded_at'] as String)
          : null,
      disputedAt: json['disputed_at'] != null
          ? DateTime.parse(json['disputed_at'] as String)
          : null,
    );
  }

  /// Amount in currency units (dollars, euros, etc.).
  double get amountInCurrency => amountCents / 100;

  /// Platform fee in currency units.
  double get platformFeeInCurrency => platformFeeCents / 100;

  /// Seller amount in currency units.
  double? get sellerAmountInCurrency =>
      sellerAmountCents != null ? sellerAmountCents! / 100 : null;

  /// Shipping cost in currency units.
  double get shippingInCurrency => shippingCents / 100;

  /// Whether this is a marketplace purchase (has seller).
  bool get isMarketplace => sellerId != null;

  /// Whether the payment was successful.
  bool get isPaid => status == PurchaseStatus.succeeded;

  /// Whether the payment failed.
  bool get hasFailed => status == PurchaseStatus.failed;

  /// Whether the purchase was refunded (fully or partially).
  bool get isRefunded =>
      status == PurchaseStatus.refunded ||
      status == PurchaseStatus.partiallyRefunded;

  /// Creates a copy with optional field overrides.
  Purchase copyWith({
    String? id,
    String? userId,
    ProductType? productType,
    String? productId,
    String? sellerId,
    int? amountCents,
    String? currency,
    int? platformFeeCents,
    int? sellerAmountCents,
    int? shippingCents,
    String? stripePaymentIntentId,
    String? stripeCheckoutSessionId,
    String? stripeTransferId,
    String? stripeChargeId,
    PurchaseStatus? status,
    Map<String, dynamic>? metadata,
    String? errorMessage,
    String? errorCode,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? refundedAt,
    DateTime? disputedAt,
  }) {
    return Purchase(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productType: productType ?? this.productType,
      productId: productId ?? this.productId,
      sellerId: sellerId ?? this.sellerId,
      amountCents: amountCents ?? this.amountCents,
      currency: currency ?? this.currency,
      platformFeeCents: platformFeeCents ?? this.platformFeeCents,
      sellerAmountCents: sellerAmountCents ?? this.sellerAmountCents,
      shippingCents: shippingCents ?? this.shippingCents,
      stripePaymentIntentId:
          stripePaymentIntentId ?? this.stripePaymentIntentId,
      stripeCheckoutSessionId:
          stripeCheckoutSessionId ?? this.stripeCheckoutSessionId,
      stripeTransferId: stripeTransferId ?? this.stripeTransferId,
      stripeChargeId: stripeChargeId ?? this.stripeChargeId,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
      errorMessage: errorMessage ?? this.errorMessage,
      errorCode: errorCode ?? this.errorCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      refundedAt: refundedAt ?? this.refundedAt,
      disputedAt: disputedAt ?? this.disputedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Purchase &&
        other.id == id &&
        other.userId == userId &&
        other.productType == productType &&
        other.productId == productId &&
        other.sellerId == sellerId &&
        other.amountCents == amountCents &&
        other.currency == currency &&
        other.platformFeeCents == platformFeeCents &&
        other.sellerAmountCents == sellerAmountCents &&
        other.shippingCents == shippingCents &&
        other.stripePaymentIntentId == stripePaymentIntentId &&
        other.stripeCheckoutSessionId == stripeCheckoutSessionId &&
        other.stripeTransferId == stripeTransferId &&
        other.stripeChargeId == stripeChargeId &&
        other.status == status &&
        mapEquals(other.metadata, metadata) &&
        other.errorMessage == errorMessage &&
        other.errorCode == errorCode &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.paidAt == paidAt &&
        other.refundedAt == refundedAt &&
        other.disputedAt == disputedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      productType,
      productId,
      sellerId,
      amountCents,
      currency,
      platformFeeCents,
      sellerAmountCents,
      shippingCents,
      stripePaymentIntentId,
      stripeCheckoutSessionId,
      stripeTransferId,
      stripeChargeId,
      status,
      Object.hashAll(metadata.entries),
      errorMessage,
      errorCode,
      Object.hash(createdAt, updatedAt, paidAt, refundedAt, disputedAt),
    );
  }

  @override
  String toString() {
    return 'Purchase(id: $id, status: $status, amount: $amountInCurrency $currency)';
  }
}
