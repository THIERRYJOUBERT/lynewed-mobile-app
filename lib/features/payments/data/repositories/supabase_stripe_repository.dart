import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/purchase.dart';
import '../../domain/entities/stripe_account.dart';
import '../../domain/repositories/stripe_repository.dart';

/// Supabase implementation of [StripeRepository].
///
/// Uses the Supabase client to fetch data from stripe_accounts and purchases.
/// All queries respect RLS policies defined on the tables.
class SupabaseStripeRepository implements StripeRepository {
  final SupabaseClient _supabase;

  SupabaseStripeRepository(this._supabase);

  @override
  Future<StripeAccount?> getStripeAccount(String userId) async {
    final response = await _supabase
        .from('stripe_accounts')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (response == null) return null;
    return StripeAccount.fromJson(response);
  }

  @override
  Future<List<Purchase>> getPurchases(String userId) async {
    final response = await _supabase
        .from('purchases')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Purchase.fromJson(json)).toList();
  }

  @override
  Future<Purchase?> getPurchase(String id) async {
    final response = await _supabase
        .from('purchases')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return Purchase.fromJson(response);
  }

  @override
  Future<List<Purchase>> getSales(String sellerId) async {
    final response = await _supabase
        .from('purchases')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Purchase.fromJson(json)).toList();
  }
}
