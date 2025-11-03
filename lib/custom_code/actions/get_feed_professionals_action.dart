// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Ces helpers doivent être hors de la fonction principale pour être valides
Profession _professionFromString(String? s) {
  if (s == null) return Profession.PHOTOGRAPHER; // Fallback par défaut
  try {
    return Profession.values.firstWhere((e) => e.name == s.toUpperCase());
  } catch (_) {
    return Profession.PHOTOGRAPHER;
  }
}

SubscriptionTierType _tierFromString(String? s) {
  switch (s) {
    case 'premiumVisibility':
      return SubscriptionTierType.premiumVisibility;
    case 'ultimateAccess':
      return SubscriptionTierType.ultimateAccess;
    case 'earlyAccess':
      return SubscriptionTierType.earlyAccess;
    case 'trial':
      return SubscriptionTierType.trial;
    default:
      return SubscriptionTierType.inactive;
  }
}

Future<FeedResultStruct> getFeedProfessionalsAction(
  QueryFiltersStruct filters,
  String? cursor,
  int? pageSize,
) async {
  final client = SupaFlow.client;
  try {
    final double? budgetMaxClean =
        (filters.budgetMax != null && filters.budgetMax! >= 100000.0)
            ? null
            : filters.budgetMax;

    final filterParams = <String, dynamic>{
      // CORRECTION CRITIQUE : filters.professions est une List<String>, pas une List<Enum>
      'professions': filters.professions ?? [],
      'budgetMin': filters.budgetMin,
      'budgetMax': budgetMaxClean,
      'currency': (filters.currency == null || filters.currency!.isEmpty)
          ? null
          : filters.currency,
      if (filters.center != null)
        'center': {
          'longitude': filters.center!.longitude,
          'latitude': filters.center!.latitude,
        },
      'radiusKm': (filters.radiusKm == null || filters.radiusKm == 0.0)
          ? null
          : filters.radiusKm,
    };

    final data = await client.rpc('get_feed_professionals', params: {
      'p_filters': filterParams,
      'p_cursor': cursor,
      'p_page_size': pageSize ?? 24,
    });

    if (data is! Map<String, dynamic>)
      return FeedResultStruct(items: [], nextCursor: null);

    final items = <ProSummaryStruct>[];
    if (data['items'] is List) {
      for (final raw in (data['items'] as List)) {
        final m = raw as Map<String, dynamic>;
        items.add(ProSummaryStruct(
          proProfileId: m['proProfileId']?.toString() ?? '',
          fullName: m['fullName']?.toString() ?? '',
          avatarUrl: m['avatarUrl']?.toString() ?? '',
          businessName: m['businessName']?.toString() ?? '',
          profession: _professionFromString(m['profession']?.toString()),
          budgetMin: (m['budgetMin'] as num?)?.toInt(),
          budgetMax: (m['budgetMax'] as num?)?.toInt(),
          currency: m['currency']?.toString(),
          subscriptionTier: _tierFromString(m['subscriptionTier']?.toString()),
          distanceKm: (m['distanceKm'] as num?)?.toDouble(),
          locationLabel: m['locationLabel']?.toString() ?? '',
          coverImageUrl: m['coverImageUrl']?.toString() ?? '',
          isFavorited: m['isFavorited'] == true,
          isLive: m['isLive'] == true,
        ));
      }
    }

    return FeedResultStruct(
        items: items, nextCursor: data['nextCursor']?.toString());
  } catch (e) {
    print('getFeedProfessionalsAction error: $e');
    return FeedResultStruct(items: [], nextCursor: null);
  }
}
