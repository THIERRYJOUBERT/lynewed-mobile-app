// Get user's market region from Supabase
import '/backend/supabase/supabase.dart';

/// Gets the current user's market region.
///
/// Returns 'IN' for Indian users, 'GLOBAL' for everyone else.
///
/// TODO: Migrate to Core locale service in Clean Architecture.
/// This function should be part of a locale/region service.
///
/// Target migration: lib/core/services/locale_service.dart
Future<String> getUserMarketRegion() async {
  try {
    final client = SupaFlow.client;
    final response = await client.rpc('get_my_market_region');
    
    if (response == null) {
      return 'GLOBAL';
    }
    
    final market = response as String?;
    return market ?? 'GLOBAL';
  } catch (e) {
    return 'GLOBAL';
  }
}
