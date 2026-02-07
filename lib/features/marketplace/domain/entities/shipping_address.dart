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
  ///
  /// Tolerates both snake_case (DB) and camelCase (FedEx) keys,
  /// with safe defaults for missing fields.
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      streetLines: _parseStreetLines(json['street_lines'] ?? json['streetLines']),
      city: (json['city'] as String?) ?? '',
      postalCode: (json['postal_code'] ?? json['postalCode'] as String?) ?? '',
      countryCode: (json['country_code'] ?? json['countryCode'] as String?) ?? '',
      stateOrProvinceCode:
          (json['state_or_province_code'] ?? json['stateOrProvinceCode']) as String?,
      personName: (json['person_name'] ?? json['personName']) as String?,
      phoneNumber: (json['phone_number'] ?? json['phoneNumber']) as String?,
    );
  }

  static List<String> _parseStreetLines(dynamic value) {
    if (value is List) return List<String>.from(value);
    return [];
  }

  /// Converts to JSON (snake_case keys for Supabase DB storage).
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

  /// Converts to camelCase JSON for FedEx Edge Functions.
  ///
  /// The Edge Function `fedex-calculate-rate` expects camelCase keys
  /// in address objects (e.g., `streetLines`, `postalCode`).
  Map<String, dynamic> toFedExJson() {
    return {
      'streetLines': streetLines,
      'city': city,
      'postalCode': postalCode,
      'countryCode': countryCode,
      if (stateOrProvinceCode != null)
        'stateOrProvinceCode': stateOrProvinceCode,
      if (personName != null) 'personName': personName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
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
