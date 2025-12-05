// Get user's market region from Supabase
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';

/// Get the current user's market region
/// Returns 'IN' for Indian users, 'GLOBAL' for everyone else
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
    debugPrint('Error getting user market region: $e');
    return 'GLOBAL';
  }
}
