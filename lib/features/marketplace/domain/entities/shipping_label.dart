/// ShippingLabel entity - A FedEx shipping label
///
/// Immutable data class representing a shipping label returned
/// by the fedex-create-shipment Edge Function.
library;

import 'package:flutter/foundation.dart';

/// Represents a FedEx shipping label with tracking number and PDF URL.
@immutable
class ShippingLabel {
  /// Creates a shipping label.
  const ShippingLabel({
    required this.trackingNumber,
    required this.labelUrl,
    required this.serviceType,
  });

  /// FedEx tracking number.
  final String trackingNumber;

  /// URL to download the label PDF.
  final String labelUrl;

  /// FedEx service type used (e.g., 'FEDEX_GROUND').
  final String serviceType;

  /// Creates from Edge Function response JSON.
  factory ShippingLabel.fromJson(Map<String, dynamic> json) {
    return ShippingLabel(
      trackingNumber: json['tracking_number'] as String,
      labelUrl: json['label_url'] as String,
      serviceType: json['service_type'] as String,
    );
  }

  /// Creates a copy with updated fields.
  ShippingLabel copyWith({
    String? trackingNumber,
    String? labelUrl,
    String? serviceType,
  }) {
    return ShippingLabel(
      trackingNumber: trackingNumber ?? this.trackingNumber,
      labelUrl: labelUrl ?? this.labelUrl,
      serviceType: serviceType ?? this.serviceType,
    );
  }

  /// Equality based on all fields.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingLabel &&
          runtimeType == other.runtimeType &&
          trackingNumber == other.trackingNumber &&
          labelUrl == other.labelUrl &&
          serviceType == other.serviceType;

  @override
  int get hashCode => Object.hash(trackingNumber, labelUrl, serviceType);

  @override
  String toString() =>
      'ShippingLabel(trackingNumber: $trackingNumber, '
      'serviceType: $serviceType)';
}
