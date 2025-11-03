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

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'dart:convert';

String filtersToJsonString(QueryFiltersStruct filters) {
  final double? budgetMaxClean =
      (filters.budgetMax != null && filters.budgetMax! >= 100000.0)
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
    if (filters.budgetMin != null) 'budgetMin': filters.budgetMin,
    if (budgetMaxClean != null) 'budgetMax': budgetMaxClean,
    if (filters.currency != null && filters.currency!.isNotEmpty)
      'currency': filters.currency,
    if (centerJson != null) 'center': centerJson,
    if (filters.radiusKm != null) 'radiusKm': filters.radiusKm,
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
