// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart' as places;
import 'dart:ui' show Locale;

Future<PlaceDetailsDataStruct?> getPlaceDetailsRich(
  String placeId,
  String sessionToken,
  String? locale,
) async {
  // Utilise SDK natif avec validation bundle ID
  final apiKey = FFAppConstants.googlePlacesApiKey;
  if (apiKey.isEmpty) {
    SecureLogger.warning('Google Places API Key is not configured');
    return null;
  }
  
  // Détermination de la locale
  final Locale sdkLocale = (locale ?? 'en').toLowerCase().startsWith('fr') 
      ? const Locale('fr') 
      : const Locale('en');
  
  // Création du SDK avec la clé API et locale
  final placesSdk = places.FlutterGooglePlacesSdk(apiKey, locale: sdkLocale);
  
  try {
    // Utilisation du SDK natif avec champs enrichis
    final result = await placesSdk.fetchPlace(
      placeId,
      fields: [
        places.PlaceField.Location,
        places.PlaceField.Address,
        places.PlaceField.AddressComponents
      ],
    );

    if (result.place != null && result.place!.latLng != null) {
      final place = result.place!;
      
      // Extraction des coordonnées avec null safety
      final placesLatLng = place.latLng!;
      // Conversion du type SDK vers FlutterFlow LatLng
      final coords = LatLng(placesLatLng.lat, placesLatLng.lng);
      
      // Extraction des composants d'adresse
      String city = '';
      String country = '';
      String countryCode = '';
      
      if (place.addressComponents != null) {
        for (var component in place.addressComponents!) {
          final types = component.types;
          
          // SDK 0.4.x: types est List<String>, pas List<AddressComponentType>
          if (types.contains('locality')) {
            city = component.name;
          } else if (city.isEmpty &&
              (types.contains('administrative_area_level_2') ||
                  types.contains('political'))) {
            // Fallbacks pour les cas où 'locality' n'est pas présent
            city = component.name;
          }
          
          if (types.contains('country')) {
            country = component.name;
            countryCode = component.shortName;
          }
        }
      }

      return PlaceDetailsDataStruct(
        coords: coords,
        formattedAddress: place.address ?? '',
        city: city,
        country: country,
        countryCode: countryCode,
      );
    }
    return null;
  } catch (e) {
    return null;
  }
}
