/// Use case for generating a FedEx shipping label.
///
/// Calls the repository to create a shipment and generate a shipping label
/// with tracking number and downloadable PDF.
library;

import '../entities/shipping_label.dart';
import '../repositories/fedex_repository.dart';

/// Generates a shipping label for a marketplace transaction.
///
/// Usage:
/// ```dart
/// final label = await generateShippingLabel(
///   transactionId: transaction.id,
///   serviceType: 'FEDEX_GROUND',
/// );
/// print('Tracking: ${label.trackingNumber}');
/// print('Label PDF: ${label.labelUrl}');
/// ```
class GenerateShippingLabelUseCase {
  final FedExRepository _repository;

  /// Creates a use case with the given repository.
  GenerateShippingLabelUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Returns a [ShippingLabel] with tracking number and PDF URL.
  /// Throws if the Edge Function call fails.
  Future<ShippingLabel> call({
    required String transactionId,
    required String serviceType,
  }) async {
    return _repository.createShipment(
      transactionId: transactionId,
      serviceType: serviceType,
    );
  }
}
