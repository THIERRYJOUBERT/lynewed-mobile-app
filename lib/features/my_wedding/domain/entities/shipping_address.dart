/// Shipping Address entity for magazine orders.
///
/// Represents the shipping address for magazine delivery.
library;

import 'package:flutter/foundation.dart';

/// Shipping address for magazine delivery.
@immutable
class ShippingAddress {
  /// Creates a shipping address.
  const ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.zipCode,
    required this.country,
  });

  /// Full name of the recipient.
  final String fullName;

  /// Address line 1.
  final String addressLine1;

  /// Address line 2 (optional).
  final String? addressLine2;

  /// City.
  final String city;

  /// ZIP/Postal code.
  final String zipCode;

  /// Country code (e.g., 'US', 'FR', 'GB').
  final String country;

  /// Returns true if all required fields are filled.
  bool get isValid =>
      fullName.isNotEmpty &&
      addressLine1.isNotEmpty &&
      city.isNotEmpty &&
      zipCode.isNotEmpty &&
      country.isNotEmpty;

  /// Converts to JSON for API calls.
  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'address_line1': addressLine1,
        if (addressLine2 != null) 'address_line2': addressLine2,
        'city': city,
        'zip_code': zipCode,
        'country': country,
      };

  /// Creates from JSON.
  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['full_name'] as String? ?? '',
      addressLine1: json['address_line1'] as String? ?? '',
      addressLine2: json['address_line2'] as String?,
      city: json['city'] as String? ?? '',
      zipCode: json['zip_code'] as String? ?? '',
      country: json['country'] as String? ?? '',
    );
  }

  /// Creates an empty shipping address.
  factory ShippingAddress.empty() => const ShippingAddress(
        fullName: '',
        addressLine1: '',
        city: '',
        zipCode: '',
        country: 'US',
      );

  /// Creates a copy with updated values.
  ShippingAddress copyWith({
    String? fullName,
    String? addressLine1,
    String? addressLine2,
    bool clearAddressLine2 = false,
    String? city,
    String? zipCode,
    String? country,
  }) {
    return ShippingAddress(
      fullName: fullName ?? this.fullName,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2:
          clearAddressLine2 ? null : (addressLine2 ?? this.addressLine2),
      city: city ?? this.city,
      zipCode: zipCode ?? this.zipCode,
      country: country ?? this.country,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShippingAddress &&
        other.fullName == fullName &&
        other.addressLine1 == addressLine1 &&
        other.addressLine2 == addressLine2 &&
        other.city == city &&
        other.zipCode == zipCode &&
        other.country == country;
  }

  @override
  int get hashCode => Object.hash(
        fullName,
        addressLine1,
        addressLine2,
        city,
        zipCode,
        country,
      );

  @override
  String toString() =>
      'ShippingAddress($fullName, $addressLine1, $city, $zipCode, $country)';
}

/// Supported shipping countries with their display names.
class ShippingCountries {
  ShippingCountries._();

  /// List of supported countries for shipping.
  static const List<({String code, String name})> all = [
    (code: 'US', name: 'United States'),
    (code: 'CA', name: 'Canada'),
    (code: 'GB', name: 'United Kingdom'),
    (code: 'FR', name: 'France'),
    (code: 'DE', name: 'Germany'),
    (code: 'IT', name: 'Italy'),
    (code: 'ES', name: 'Spain'),
    (code: 'AU', name: 'Australia'),
  ];

  /// Gets the display name for a country code.
  static String getDisplayName(String code) {
    for (final country in all) {
      if (country.code == code) return country.name;
    }
    return code;
  }

  /// Gets the country code from display name.
  static String? getCode(String name) {
    for (final country in all) {
      if (country.name == name) return country.code;
    }
    return null;
  }
}

/// Shipping cost calculator.
class ShippingCosts {
  ShippingCosts._();

  /// Calculates shipping cost in cents based on country.
  ///
  /// V1 uses fixed rates:
  /// - USA: $15
  /// - Canada/Europe: $25
  /// - Others: $35
  static int calculateCents(String countryCode) {
    if (countryCode == 'US') return 1500;
    if (['CA', 'GB', 'FR', 'DE', 'IT', 'ES'].contains(countryCode)) return 2500;
    if (countryCode == 'AU') return 3500;
    return 3500; // Default for unsupported countries
  }

  /// Formats the shipping cost as a string.
  static String format(int cents) {
    final dollars = cents ~/ 100;
    final remainder = cents % 100;
    if (remainder == 0) {
      return '\$$dollars';
    }
    return '\$$dollars.${remainder.toString().padLeft(2, '0')}';
  }
}
