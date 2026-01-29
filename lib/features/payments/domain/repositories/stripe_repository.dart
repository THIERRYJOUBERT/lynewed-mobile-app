import '../entities/purchase.dart';
import '../entities/stripe_account.dart';

/// Repository interface for Stripe-related data operations.
///
/// Provides access to stripe_accounts and purchases tables via Supabase.
/// All methods respect RLS policies (user sees own data, seller sees sales).
abstract class StripeRepository {
  /// Gets the Stripe Connect account for a user.
  ///
  /// Returns null if the user hasn't set up a Stripe account yet.
  Future<StripeAccount?> getStripeAccount(String userId);

  /// Gets all purchases made by a user.
  ///
  /// Returns purchases ordered by creation date (newest first).
  Future<List<Purchase>> getPurchases(String userId);

  /// Gets a specific purchase by ID.
  ///
  /// Returns null if the purchase doesn't exist or user doesn't have access.
  Future<Purchase?> getPurchase(String id);

  /// Gets all sales for a seller (marketplace).
  ///
  /// Returns purchases where the user is the seller, ordered by creation date.
  Future<List<Purchase>> getSales(String sellerId);
}
