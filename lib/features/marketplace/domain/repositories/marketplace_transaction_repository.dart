/// Abstract repository interface for marketplace purchase transactions.
///
/// Provides methods for creating checkout sessions, querying transactions,
/// and managing CGVU (terms) acceptance for marketplace buyers.
library;

import '../entities/marketplace_transaction.dart';
import '../entities/shipping_address.dart';
import '../entities/shipping_rate.dart';

/// Repository interface for marketplace purchase transactions.
abstract class MarketplaceTransactionRepository {
  /// Creates a Stripe Checkout Session for marketplace purchase.
  ///
  /// Calls the `marketplace-create-payment` Edge Function.
  /// Returns checkout URL and pricing breakdown as a map with keys:
  /// - `checkout_url` (String)
  /// - `session_id` (String)
  /// - `item_price_cents` (int)
  /// - `shipping_cents` (int)
  /// - `platform_fee_cents` (int)
  /// - `seller_payout_cents` (int)
  /// - `total_cents` (int)
  Future<Map<String, dynamic>> createCheckoutSession({
    required String listingId,
    String? offerId,
    required ShippingAddress shippingToAddress,
    required ShippingRate shippingOption,
  });

  /// Gets a transaction by ID.
  Future<MarketplaceTransaction?> getTransaction(String transactionId);

  /// Gets buyer's purchase transactions.
  Future<List<MarketplaceTransaction>> getMyPurchases();

  /// Gets seller's sale transactions.
  Future<List<MarketplaceTransaction>> getMySales();

  /// Checks if current user has accepted marketplace buyer CGVU.
  Future<bool> hasAcceptedBuyerCgvu();

  /// Records CGVU acceptance for marketplace buyer.
  Future<void> acceptBuyerCgvu();

  /// Gets seller's transactions that are paid but not yet shipped.
  ///
  /// Returns transactions where the current user is the seller,
  /// status is 'paid', and no shipping label has been generated yet.
  Future<List<MarketplaceTransaction>> getTransactionsAwaitingShipment();

  /// Requests a refund for a transaction (buyer action).
  Future<void> requestRefund({
    required String transactionId,
    String? reason,
  });

  /// Approves a refund request (seller action).
  Future<void> approveRefund({required String transactionId});

  /// Rejects a refund request (seller action).
  Future<void> rejectRefund({required String transactionId});
}
