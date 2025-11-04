// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<String?> upsertUserPoi(
  String label, // Paramètre positionnel, non-nommé
  LatLng coords, // Paramètre positionnel, non-nommé
  int? radiusKm,
  List<String>? professions,
  int? budgetMin,
  int? budgetMax,
  String? currency,
  DateTime? eventStartDate,
  DateTime? eventEndDate,
  String? locationLabel,
) async {
  try {
    final client = SupaFlow.client;
    final params = {
      'p_label': label,
      'p_lat': coords.latitude,
      'p_lng': coords.longitude,
      'p_radius_km': radiusKm,
      'p_professions': (professions ?? []).map((e) => e.toUpperCase()).toList(),
      'p_budget_min': budgetMin,
      'p_budget_max': budgetMax,
      'p_currency': currency?.toUpperCase(),
      'p_event_start_date': eventStartDate?.toIso8601String().substring(0, 10),
      'p_event_end_date': eventEndDate?.toIso8601String().substring(0, 10),
      'p_location_label': locationLabel ?? '',
    };

    final res = await client.rpc('insert_user_poi', params: params);

    if (res == null) return null;

    return res.toString();
  } catch (e) {
    debugPrint('upsertUserPoi error: $e');
    return null;
  }
}
