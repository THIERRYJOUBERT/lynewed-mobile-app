/// PurchaseStatus enum for payment state management.
///
/// Represents the current state of a purchase transaction.
/// Maps directly to the `status` column in the `purchases` table.
library;

/// Current status of a purchase in the system.
enum PurchaseStatus {
  /// Payment initiated but not yet processed.
  pending,

  /// Payment is being processed by Stripe.
  processing,

  /// Additional authentication required (3DS, etc.).
  requiresAction,

  /// Payment completed successfully.
  succeeded,

  /// Payment failed.
  failed,

  /// Payment was canceled by user or system.
  canceled,

  /// Payment was fully refunded.
  refunded,

  /// Payment was partially refunded.
  partiallyRefunded,

  /// Payment is under dispute.
  disputed;

  /// Creates a PurchaseStatus from a database string value.
  static PurchaseStatus fromString(String value) {
    switch (value) {
      case 'pending':
        return PurchaseStatus.pending;
      case 'processing':
        return PurchaseStatus.processing;
      case 'requires_action':
        return PurchaseStatus.requiresAction;
      case 'succeeded':
        return PurchaseStatus.succeeded;
      case 'failed':
        return PurchaseStatus.failed;
      case 'canceled':
        return PurchaseStatus.canceled;
      case 'refunded':
        return PurchaseStatus.refunded;
      case 'partially_refunded':
        return PurchaseStatus.partiallyRefunded;
      case 'disputed':
        return PurchaseStatus.disputed;
      default:
        return PurchaseStatus.pending;
    }
  }

  /// Converts to database string value.
  String toJson() {
    switch (this) {
      case PurchaseStatus.pending:
        return 'pending';
      case PurchaseStatus.processing:
        return 'processing';
      case PurchaseStatus.requiresAction:
        return 'requires_action';
      case PurchaseStatus.succeeded:
        return 'succeeded';
      case PurchaseStatus.failed:
        return 'failed';
      case PurchaseStatus.canceled:
        return 'canceled';
      case PurchaseStatus.refunded:
        return 'refunded';
      case PurchaseStatus.partiallyRefunded:
        return 'partially_refunded';
      case PurchaseStatus.disputed:
        return 'disputed';
    }
  }
}

/// Extension to add computed properties to PurchaseStatus.
extension PurchaseStatusExtension on PurchaseStatus {
  /// Whether the status is a terminal state (no more transitions expected).
  bool get isTerminal => [
        PurchaseStatus.succeeded,
        PurchaseStatus.failed,
        PurchaseStatus.canceled,
        PurchaseStatus.refunded,
      ].contains(this);

  /// Whether the payment was successful.
  bool get isSuccessful => this == PurchaseStatus.succeeded;

  /// Whether the payment requires user action.
  bool get requiresUserAction => this == PurchaseStatus.requiresAction;

  /// Whether the payment can still be processed.
  bool get isPending =>
      this == PurchaseStatus.pending || this == PurchaseStatus.processing;
}
