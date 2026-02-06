/// Use case for cancelling a FedEx shipment (voiding a shipping label).
///
/// Calls the repository to cancel the shipment via the FedEx Cancel API.
/// Only works when the transaction status is 'label_created'.
library;

import '../repositories/fedex_repository.dart';

/// Cancels a shipment for a marketplace transaction.
///
/// Usage:
/// ```dart
/// await cancelShipment(transactionId: transaction.id);
/// ```
class CancelShipmentUseCase {
  final FedExRepository _repository;

  /// Creates a use case with the given repository.
  CancelShipmentUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Throws if the Edge Function call fails or the transaction
  /// is not in 'label_created' status.
  Future<void> call({required String transactionId}) async {
    return _repository.cancelShipment(transactionId);
  }
}
