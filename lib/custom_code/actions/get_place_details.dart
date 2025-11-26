// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as places;
import 'dart:ui' show Locale;

Future<LatLng?> getPlaceDetails(
  String placeId,
  String sessionToken,
  String? locale,
) async {
  // Utilise SDK natif avec validation bundle ID
  final String apiKey = FFAppConstants.googlePlacesApiKey;

  // Détermination de la locale
  final Locale sdkLocale = (locale ?? 'en').toLowerCase().startsWith('fr') 
      ? const Locale('fr') 
      : const Locale('en');
  
  // Création du SDK avec la clé API et locale
  final placesSdk = places.FlutterGooglePlacesSdk(apiKey, locale: sdkLocale);
  
  try {
    // Utilisation du SDK natif pour récupérer les détails du lieu
    final result = await placesSdk.fetchPlace(
      placeId,
      fields: [places.PlaceField.Location],
    );
    
    if (result.place != null && result.place!.latLng != null) {
      final placesLatLng = result.place!.latLng!;
      // Conversion du type SDK vers FlutterFlow LatLng
      return LatLng(placesLatLng.lat, placesLatLng.lng);
    }
  } catch (e) {
    debugPrint('getPlaceDetails SDK error: $e');
  }
  return null;
}
