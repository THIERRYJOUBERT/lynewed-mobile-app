/// Use case for retrieving and validating seller shipping address.
///
/// Fetches the seller's profile and validates that the shipping address
/// contains all required fields for FedEx API calls.
library;

import '../../../auth/data/datasources/auth_remote_datasource.dart';
import '../entities/shipping_address.dart';

/// Retrieves and validates a seller's shipping address.
///
/// Throws [SellerAddressException] if the address is missing or incomplete.
///
/// Usage:
/// ```dart
/// final address = await getSellerShippingAddress('seller-id');
/// ```
class GetSellerShippingAddress {
  final AuthRemoteDatasource _authDatasource;

  /// Creates a use case with the given datasource.
  GetSellerShippingAddress(this._authDatasource);

  /// Executes the use case.
  ///
  /// Returns the seller's validated [ShippingAddress].
  /// Throws [SellerAddressException] if profile or address is invalid.
  Future<ShippingAddress> call(String sellerId) async {
    final profile = await _authDatasource.getProfile(sellerId);

    if (profile == null) {
      throw const SellerAddressException('Seller profile not found');
    }

    final address = profile.shippingAddress;

    if (address == null) {
      throw const SellerAddressException(
        'Seller shipping address not configured',
      );
    }

    if (address.countryCode.isEmpty) {
      throw const SellerAddressException(
        'Seller address missing country code',
      );
    }

    if (address.city.isEmpty) {
      throw const SellerAddressException('Seller address missing city');
    }

    if (address.postalCode.isEmpty) {
      throw const SellerAddressException(
        'Seller address missing postal code',
      );
    }

    return address;
  }
}

/// Exception thrown when seller address is missing or invalid.
class SellerAddressException implements Exception {
  /// The error message.
  final String message;

  /// Creates a seller address exception.
  const SellerAddressException(this.message);

  @override
  String toString() => 'SellerAddressException: $message';
}
