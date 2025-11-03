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
import 'package:http/http.dart' as http;
import '/flutter_flow/lat_lng.dart';

Future<PlaceDetailsDataStruct?> getPlaceDetailsRich(
  String placeId,
  String sessionToken,
  String? locale,
) async {
  // CORRECTION : Utilise FFAppConstants au lieu de FFAppState pour la clé API.
  final apiKey = FFAppConstants.googlePlacesApiKey;
  if (apiKey.isEmpty) {
    print('Google Places API Key is not set in App Constants.');
    return null;
  }
  final lang = (locale ?? 'en').substring(0, 2);
  final url =
      'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&sessiontoken=$sessionToken&fields=geometry,formatted_address,address_component&language=$lang&key=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK' && data['result'] != null) {
      final result = data['result'];
      final location = result['geometry']['location'];
      final coords = LatLng(location['lat'], location['lng']);
      final addressComponents = result['address_components'] as List;

      String city = '';
      String country = '';
      String countryCode = '';

      for (var component in addressComponents) {
        final types = component['types'] as List;
        if (types.contains('locality')) {
          city = component['long_name'];
        } else if (city.isEmpty &&
            (types.contains('administrative_area_level_2') ||
                types.contains('political'))) {
          // Fallbacks pour les cas où 'locality' n'est pas présent
          city = component['long_name'];
        }

        if (types.contains('country')) {
          country = component['long_name'];
          countryCode = component['short_name'];
        }
      }

      return PlaceDetailsDataStruct(
        coords: coords,
        formattedAddress: result['formatted_address'],
        city: city,
        country: country,
        countryCode: countryCode,
      );
    }
    return null;
  } catch (e) {
    print('getPlaceDetailsRich error: $e');
    return null;
  }
}
