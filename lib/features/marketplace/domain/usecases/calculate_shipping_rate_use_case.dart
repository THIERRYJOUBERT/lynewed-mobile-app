/// Use case for calculating FedEx shipping rates.
///
/// Calls the repository to get available shipping rate options
/// between two addresses for a given item category.
library;

import '../entities/shipping_address.dart';
import '../entities/shipping_rate.dart';
import '../repositories/fedex_repository.dart';

/// Calculates available shipping rates for an item.
///
/// Usage:
/// ```dart
/// final rates = await calculateShippingRate(
///   fromAddress: sellerAddress,
///   toAddress: buyerAddress,
///   category: 'dress',
/// );
/// ```
class CalculateShippingRateUseCase {
  final FedExRepository _repository;

  /// Creates a use case with the given repository.
  CalculateShippingRateUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Returns a list of available [ShippingRate] options.
  /// Throws if the Edge Function call fails.
  Future<List<ShippingRate>> call({
    required ShippingAddress fromAddress,
    required ShippingAddress toAddress,
    required String category,
    double? weightKg,
  }) async {
    return _repository.calculateRates(
      fromAddress: fromAddress,
      toAddress: toAddress,
      category: category,
      weightKg: weightKg,
    );
  }
}
