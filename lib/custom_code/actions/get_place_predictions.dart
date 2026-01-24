// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as places;
import 'dart:ui' show Locale;

Future<PlacePredictionsResultStruct> getPlacePredictions(
  String inputString,
  String? sessionToken,
  String? locale,
) async {
  // Utilise SDK natif avec validation bundle ID
  final String apiKey = FFAppConstants.googlePlacesApiKey;

  if (inputString.isEmpty) {
    return PlacePredictionsResultStruct(
        suggestions: [], newSessionToken: sessionToken);
  }

  // Détermination de la locale
  final Locale sdkLocale = (locale ?? 'en').toLowerCase().startsWith('fr') 
      ? const Locale('fr') 
      : const Locale('en');
  
  // Création du SDK avec la clé API et locale
  final placesSdk = places.FlutterGooglePlacesSdk(apiKey, locale: sdkLocale);
  
  final List<PlaceSuggestionStruct> suggestions = [];
  try {
    // Utilisation du SDK natif
    final result = await placesSdk.findAutocompletePredictions(
      inputString,
      newSessionToken: sessionToken == null, // Nouveau token si non fourni
    );
    
    for (var prediction in result.predictions) {
      suggestions.add(PlaceSuggestionStruct(
        placeId: prediction.placeId,
        primaryText: prediction.primaryText,
        secondaryText: prediction.secondaryText ?? '',
      ));
    }
  } catch (e) {
    debugPrint('[getPlacePredictions] Error: $e');
  }

  // Note: Le SDK 0.4.x gère automatiquement les session tokens
  return PlacePredictionsResultStruct(
      suggestions: suggestions, newSessionToken: sessionToken);
}
