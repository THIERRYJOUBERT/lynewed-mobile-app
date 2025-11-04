// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<UserPreferencesStruct?> saveUserPreferences(
  UserPreferencesStruct prefs,
  String? lastFiltersJsonOverride,
) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) {
      // Ne rien faire si l'utilisateur n'est pas connecté
      return null;
    }

    final mapToggles = {
      'showPros': prefs.mapToggles.showPros == true,
      'showProRecent': prefs.mapToggles.showProRecent == true,
      'showFixedLocations': prefs.mapToggles.showFixedLocations == true,
      'showBridePrivatePoi': prefs.mapToggles.showBridePrivatePoi == true,
      'showWeddingPins': prefs.mapToggles.showWeddingPins == true,
      'showProAlerts': prefs.mapToggles.showProAlerts == true,
      'showOnlyMyProfessionPins':
          prefs.mapToggles.showOnlyMyProfessionPins == true,
    };

    final String finalLastFiltersJson =
        lastFiltersJsonOverride ?? prefs.lastFiltersJson;

    await client.from('user_preferences').update({
      'distance_unit':
          prefs.distanceUnit == DistanceUnit.miles ? 'miles' : 'km',
      'currency': prefs.currency,
      'default_radius_km': prefs.defaultRadiusKm,
      'default_city': prefs.defaultCity,
      'default_country_code': prefs.defaultCountry,
      'default_locale': prefs.defaultLocale,
      'default_timezone': prefs.defaultTimezone,
      'map_toggles': mapToggles,
      'last_filters': finalLastFiltersJson,
    }).eq('profile_id', userId);

    // CORRECTION : FlutterFlow ne génère pas de méthode copyWith.
    // Nous reconstruisons manuellement une nouvelle instance du DataType
    // pour retourner la version la plus à jour, en incluant la modification de lastFiltersJson.
    return UserPreferencesStruct(
      distanceUnit: prefs.distanceUnit,
      currency: prefs.currency,
      defaultRadiusKm: prefs.defaultRadiusKm,
      defaultCity: prefs.defaultCity,
      defaultCountry: prefs.defaultCountry,
      defaultLocale: prefs.defaultLocale,
      defaultTimezone: prefs.defaultTimezone,
      mapToggles: prefs.mapToggles,
      lastFiltersJson: finalLastFiltersJson, // Utilise la valeur mise à jour
    );
  } catch (e) {
    debugPrint('saveUserPreferences error: $e');
    return null;
  }
}
