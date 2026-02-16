/// Magazine Order entity.
///
/// Represents a completed magazine order from the magazine_orders table.
/// Used for order tracking and display in the My Wedding section.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';

/// A magazine order placed through Stripe checkout.
class MagazineOrder {
  /// Creates a magazine order.
  const MagazineOrder({
    required this.id,
    required this.weddingId,
    required this.magazineFormat,
    required this.magazinePriceCents,
    required this.shippingCostCents,
    required this.totalPaidCents,
    required this.currency,
    required this.status,
    required this.photoCount,
    required this.magazineTitle,
    this.quantity = 1,
    required this.createdAt,
    this.paidAt,
    this.productionStartedAt,
    this.shippedAt,
    this.deliveredAt,
    this.shippingName,
    this.shippingAddressLine1,
    this.shippingAddressLine2,
    this.shippingCity,
    this.shippingZip,
    this.shippingCountry,
    this.shippingPhone,
    this.trackingNumber,
    this.trackingUrl,
  });

  /// Order ID.
  final String id;

  /// Wedding this order belongs to.
  final String weddingId;

  /// Magazine format key: 'guest_edition', 'iconic', 'memory', 'collector'.
  final String magazineFormat;

  /// Magazine price in cents.
  final int magazinePriceCents;

  /// Shipping cost in cents.
  final int shippingCostCents;

  /// Total paid in cents (magazine + shipping).
  final int totalPaidCents;

  /// Currency code (e.g. 'USD').
  final String currency;

  /// Order status: 'pending', 'paid', 'in_production', 'shipped', 'delivered', 'cancelled'.
  final String status;

  /// Number of copies ordered.
  final int quantity;

  /// Number of photos in the magazine.
  final int photoCount;

  /// Magazine title.
  final String magazineTitle;

  /// Order creation timestamp.
  final DateTime createdAt;

  /// Payment confirmation timestamp.
  final DateTime? paidAt;

  /// When production started.
  final DateTime? productionStartedAt;

  /// When order was shipped.
  final DateTime? shippedAt;

  /// When order was delivered.
  final DateTime? deliveredAt;

  /// Shipping recipient name.
  final String? shippingName;

  /// Shipping address line 1.
  final String? shippingAddressLine1;

  /// Shipping address line 2 (apartment, suite, etc.).
  final String? shippingAddressLine2;

  /// Shipping city.
  final String? shippingCity;

  /// Shipping postal/ZIP code.
  final String? shippingZip;

  /// Shipping country code (e.g. 'US', 'FR').
  final String? shippingCountry;

  /// Shipping phone number.
  final String? shippingPhone;

  /// Carrier tracking number.
  final String? trackingNumber;

  /// Carrier tracking URL.
  final String? trackingUrl;

  // ========== COMPUTED PROPERTIES ==========

  /// Display name for the format (e.g. 'ICONIC', 'GUEST EDITION').
  String get formatDisplayName {
    const names = {
      'guest_edition': 'GUEST EDITION',
      'iconic': 'ICONIC',
      'memory': 'MEMORY',
      'collector': 'COLLECTOR',
    };
    return names[magazineFormat] ?? magazineFormat.toUpperCase();
  }

  /// Format size string.
  String get formatSize {
    const sizes = {
      'guest_edition': '21x30cm',
      'iconic': '21x30cm',
      'memory': '21x30cm',
      'collector': '25x32cm',
    };
    return sizes[magazineFormat] ?? '21x30cm';
  }

  /// Human-readable status label.
  String get statusLabel {
    const labels = {
      'pending': 'Pending',
      'paid': 'Order Confirmed',
      'in_production': 'In Production',
      'shipped': 'Shipped',
      'delivered': 'Delivered',
      'cancelled': 'Cancelled',
    };
    return labels[status] ?? status;
  }

  /// Color for the status badge.
  Color get statusColor {
    switch (status) {
      case 'paid':
        return LynewedColors.success;
      case 'in_production':
        return LynewedColors.primary;
      case 'shipped':
        return const Color(0xFF2196F3); // Blue
      case 'delivered':
        return LynewedColors.success;
      case 'cancelled':
        return LynewedColors.error;
      default:
        return LynewedColors.textSecondary;
    }
  }

  /// Formatted total price (e.g. '$104.00').
  String get formattedTotal {
    final dollars = totalPaidCents ~/ 100;
    final cents = totalPaidCents % 100;
    return '\$$dollars.${cents.toString().padLeft(2, '0')}';
  }

  /// Formatted magazine price (e.g. '$59.00').
  String get formattedMagazinePrice {
    final dollars = magazinePriceCents ~/ 100;
    final cents = magazinePriceCents % 100;
    return '\$$dollars.${cents.toString().padLeft(2, '0')}';
  }

  /// Formatted shipping cost (e.g. '$15.00').
  String get formattedShippingCost {
    final dollars = shippingCostCents ~/ 100;
    final cents = shippingCostCents % 100;
    return '\$$dollars.${cents.toString().padLeft(2, '0')}';
  }

  /// Formatted multi-line shipping address.
  String get formattedShippingAddress {
    final lines = <String>[];
    if (shippingName != null) lines.add(shippingName!);
    if (shippingAddressLine1 != null) lines.add(shippingAddressLine1!);
    if (shippingAddressLine2 != null && shippingAddressLine2!.isNotEmpty) {
      lines.add(shippingAddressLine2!);
    }
    final cityLine = [
      if (shippingZip != null) shippingZip!,
      if (shippingCity != null) shippingCity!,
    ].join(' ');
    if (cityLine.isNotEmpty) {
      final withCountry = shippingCountry != null
          ? '$cityLine, $shippingCountry'
          : cityLine;
      lines.add(withCountry);
    }
    return lines.join('\n');
  }

  /// Status progression flags.
  bool get isPaid => status != 'pending' && status != 'cancelled';
  bool get isInProduction =>
      status == 'in_production' || status == 'shipped' || status == 'delivered';
  bool get isShipped => status == 'shipped' || status == 'delivered';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';

  /// Current step index for timeline display (0-3).
  int get currentStepIndex {
    if (isDelivered) return 3;
    if (isShipped) return 2;
    if (isInProduction) return 1;
    if (isPaid) return 0;
    return -1;
  }

  /// Creates from Supabase JSON row.
  factory MagazineOrder.fromJson(Map<String, dynamic> json) {
    return MagazineOrder(
      id: json['id'] as String,
      weddingId: json['wedding_id'] as String,
      magazineFormat: json['magazine_format'] as String,
      magazinePriceCents: json['magazine_price_cents'] as int,
      shippingCostCents: json['shipping_cost_cents'] as int,
      totalPaidCents: json['total_paid_cents'] as int,
      currency: json['currency'] as String? ?? 'USD',
      status: json['status'] as String,
      quantity: json['quantity'] as int? ?? 1,
      photoCount: json['photo_count'] as int,
      magazineTitle: json['magazine_title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      productionStartedAt: json['production_started_at'] != null
          ? DateTime.parse(json['production_started_at'] as String)
          : null,
      shippedAt: json['shipped_at'] != null
          ? DateTime.parse(json['shipped_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      shippingName: json['shipping_name'] as String?,
      shippingAddressLine1: json['shipping_address_line1'] as String?,
      shippingAddressLine2: json['shipping_address_line2'] as String?,
      shippingCity: json['shipping_city'] as String?,
      shippingZip: json['shipping_zip'] as String?,
      shippingCountry: json['shipping_country'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      trackingNumber: json['tracking_number'] as String?,
      trackingUrl: json['tracking_url'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MagazineOrder &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          status == other.status;

  @override
  int get hashCode => id.hashCode ^ status.hashCode;
}
