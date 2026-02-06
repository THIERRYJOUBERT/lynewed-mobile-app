/// Use case for requesting a refund on a marketplace transaction.
///
/// Called by the buyer to initiate a refund request.
/// The seller will be notified and can approve or reject.
library;

import '../repositories/marketplace_transaction_repository.dart';

/// Requests a refund for a marketplace transaction.
class RequestRefundUseCase {
  final MarketplaceTransactionRepository _repository;

  /// Creates a use case with the given repository.
  RequestRefundUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Throws if the transaction is not eligible for refund or if the
  /// caller is not the buyer.
  Future<void> call({
    required String transactionId,
    String? reason,
  }) async {
    return _repository.requestRefund(
      transactionId: transactionId,
      reason: reason,
    );
  }
}
