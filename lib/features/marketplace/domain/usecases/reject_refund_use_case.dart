/// Use case for rejecting a refund on a marketplace transaction.
///
/// Called by the seller to reject a buyer's refund request.
/// Clears the refund request and notifies the buyer.
library;

import '../repositories/marketplace_transaction_repository.dart';

/// Rejects a refund for a marketplace transaction.
class RejectRefundUseCase {
  final MarketplaceTransactionRepository _repository;

  /// Creates a use case with the given repository.
  RejectRefundUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Throws if no refund request is pending or if the caller is not the seller.
  Future<void> call({required String transactionId}) async {
    return _repository.rejectRefund(transactionId: transactionId);
  }
}
