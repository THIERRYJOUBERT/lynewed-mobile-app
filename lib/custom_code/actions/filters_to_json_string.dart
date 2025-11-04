// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'dart:convert';

String filtersToJsonString(QueryFiltersStruct filters) {
  final double? budgetMaxClean =
      (filters.budgetMax >= 100000.0)
          ? null
          : filters.budgetMax;

  Map<String, dynamic>? centerJson;
  if (filters.center != null) {
    centerJson = {
      'longitude': filters.center!.longitude,
      'latitude': filters.center!.latitude,
    };
  }

  // PROFESSION TOKENS -> Supabase
  final List<String> professionsTokens =
      mapProfessionsToSupabaseTokens(filters.professions);

  final Map<String, dynamic> jsonMap = {
    if (professionsTokens.isNotEmpty) 'professions': professionsTokens,
    'budgetMin': filters.budgetMin,
    if (budgetMaxClean != null) 'budgetMax': budgetMaxClean,
    if (filters.currency.isNotEmpty)
      'currency': filters.currency,
    if (centerJson != null) 'center': centerJson,
    'radiusKm': filters.radiusKm,
    'showPros': filters.showPros,
    'showProRecent': filters.showProRecent,
    'showFixedLocations': filters.showFixedLocations,
    'showBridePrivatePoi': filters.showBridePrivatePoi,
    'showWeddingPins': filters.showWeddingPins,
    'showProAlerts': filters.showProAlerts,
    'showOnlyMyProfessionPins': filters.showOnlyMyProfessionPins,
  };

  return jsonEncode(jsonMap);
}
