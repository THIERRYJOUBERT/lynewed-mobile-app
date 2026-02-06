/// ShippingRate entity - A FedEx shipping rate option
///
/// Immutable data class representing a shipping rate returned
/// by the fedex-calculate-rate Edge Function.
library;

import 'package:flutter/foundation.dart';

/// Represents a FedEx shipping rate option.
///
/// Contains service details, price in cents, and estimated delivery info.
@immutable
class ShippingRate {
  /// Creates a shipping rate.
  const ShippingRate({
    required this.serviceType,
    required this.serviceName,
    required this.rateCents,
    required this.currency,
    this.estimatedDelivery,
    this.estimatedDays,
    this.estimatedDaysLabel,
  });

  /// FedEx service type code (e.g., 'FEDEX_GROUND', 'FEDEX_EXPRESS').
  final String serviceType;

  /// Human-readable service name (e.g., 'FedEx Ground').
  final String serviceName;

  /// Rate in cents (e.g., 1250 = $12.50).
  final int rateCents;

  /// Currency code (e.g., 'USD').
  final String currency;

  /// Estimated delivery date (optional).
  final DateTime? estimatedDelivery;

  /// Estimated number of transit days (optional).
  final int? estimatedDays;

  /// Human-readable estimated delivery label (e.g., '3-5 business days').
  /// When provided, used instead of [estimatedDays] for display.
  final String? estimatedDaysLabel;

  /// Price formatted as dollars (e.g., 1250 -> 12.50).
  double get priceInDollars => rateCents / 100;

  /// Creates from Edge Function response JSON.
  factory ShippingRate.fromJson(Map<String, dynamic> json) {
    return ShippingRate(
      serviceType: json['service_type'] as String,
      serviceName: json['service_name'] as String,
      rateCents: json['rate_cents'] as int,
      currency: json['currency'] as String,
      estimatedDelivery: json['estimated_delivery'] != null
          ? DateTime.parse(json['estimated_delivery'] as String)
          : null,
      estimatedDays: json['estimated_days'] as int?,
    );
  }

  /// Creates a copy with updated fields.
  ShippingRate copyWith({
    String? serviceType,
    String? serviceName,
    int? rateCents,
    String? currency,
    DateTime? estimatedDelivery,
    int? estimatedDays,
    String? estimatedDaysLabel,
  }) {
    return ShippingRate(
      serviceType: serviceType ?? this.serviceType,
      serviceName: serviceName ?? this.serviceName,
      rateCents: rateCents ?? this.rateCents,
      currency: currency ?? this.currency,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      estimatedDays: estimatedDays ?? this.estimatedDays,
      estimatedDaysLabel: estimatedDaysLabel ?? this.estimatedDaysLabel,
    );
  }

  /// Equality based on all fields.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingRate &&
          runtimeType == other.runtimeType &&
          serviceType == other.serviceType &&
          serviceName == other.serviceName &&
          rateCents == other.rateCents &&
          currency == other.currency &&
          estimatedDelivery == other.estimatedDelivery &&
          estimatedDays == other.estimatedDays &&
          estimatedDaysLabel == other.estimatedDaysLabel;

  @override
  int get hashCode => Object.hash(
        serviceType,
        serviceName,
        rateCents,
        currency,
        estimatedDelivery,
        estimatedDays,
        estimatedDaysLabel,
      );

  @override
  String toString() =>
      'ShippingRate(serviceType: $serviceType, rateCents: $rateCents, '
      'currency: $currency)';
}
