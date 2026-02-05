/// ShippingAddress entity - Address for FedEx shipping
///
/// Immutable data class representing a shipping address (from/to)
/// with fields compatible with FedEx API requirements.
library;

import 'package:flutter/foundation.dart';

/// Represents a shipping address for FedEx API.
///
/// Uses [streetLines] as a list to support multi-line addresses.
/// Optional fields [stateOrProvinceCode], [personName], and [phoneNumber]
/// provide additional FedEx-required data.
@immutable
class ShippingAddress {
  /// Creates a shipping address.
  const ShippingAddress({
    required this.streetLines,
    required this.city,
    required this.postalCode,
    required this.countryCode,
    this.stateOrProvinceCode,
    this.personName,
    this.phoneNumber,
  });

  /// Street address lines (FedEx supports up to 3 lines).
  final List<String> streetLines;

  /// City.
  final String city;

  /// Postal/ZIP code.
  final String postalCode;

  /// Country code (2 chars, e.g., "FR", "US").
  final String countryCode;

  /// State or province code (e.g., "NY", "CA").
  final String? stateOrProvinceCode;

  /// Contact person name.
  final String? personName;

  /// Contact phone number.
  final String? phoneNumber;

  /// Creates from JSON.
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      streetLines: List<String>.from(json['street_lines'] as List),
      city: json['city'] as String,
      postalCode: json['postal_code'] as String,
      countryCode: json['country_code'] as String,
      stateOrProvinceCode: json['state_or_province_code'] as String?,
      personName: json['person_name'] as String?,
      phoneNumber: json['phone_number'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    return {
      'street_lines': streetLines,
      'city': city,
      'postal_code': postalCode,
      'country_code': countryCode,
      'state_or_province_code': stateOrProvinceCode,
      'person_name': personName,
      'phone_number': phoneNumber,
    };
  }

  /// Creates a copy with updated fields.
  ShippingAddress copyWith({
    List<String>? streetLines,
    String? city,
    String? postalCode,
    String? countryCode,
    String? stateOrProvinceCode,
    String? personName,
    String? phoneNumber,
  }) {
    return ShippingAddress(
      streetLines: streetLines ?? this.streetLines,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      countryCode: countryCode ?? this.countryCode,
      stateOrProvinceCode: stateOrProvinceCode ?? this.stateOrProvinceCode,
      personName: personName ?? this.personName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  /// Equality based on all fields.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShippingAddress &&
          runtimeType == other.runtimeType &&
          listEquals(streetLines, other.streetLines) &&
          city == other.city &&
          postalCode == other.postalCode &&
          countryCode == other.countryCode &&
          stateOrProvinceCode == other.stateOrProvinceCode &&
          personName == other.personName &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(streetLines),
        city,
        postalCode,
        countryCode,
        stateOrProvinceCode,
        personName,
        phoneNumber,
      );

  @override
  String toString() =>
      'ShippingAddress(city: $city, countryCode: $countryCode)';
}
