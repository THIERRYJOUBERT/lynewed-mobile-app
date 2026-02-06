/// Use case for approving a refund on a marketplace transaction.
///
/// Called by the seller to approve a buyer's refund request.
/// Triggers Stripe refund, updates transaction status, and notifies buyer.
library;

import '../repositories/marketplace_transaction_repository.dart';

/// Approves a refund for a marketplace transaction.
class ApproveRefundUseCase {
  final MarketplaceTransactionRepository _repository;

  /// Creates a use case with the given repository.
  ApproveRefundUseCase(this._repository);

  /// Executes the use case.
  ///
  /// Throws if no refund request is pending or if the caller is not the seller.
  Future<void> call({required String transactionId}) async {
    return _repository.approveRefund(transactionId: transactionId);
  }
}
