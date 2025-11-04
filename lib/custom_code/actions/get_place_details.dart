// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<LatLng?> getPlaceDetails(
  String placeId,
  String sessionToken,
  String? locale,
) async {
  // CLÉ LUE DEPUIS LES VARIABLES D'ENVIRONNEMENT DE FLUTTERFLOW
  final String apiKey = FFAppConstants.googlePlacesApiKey;

  final String lang =
      (locale ?? 'en').toLowerCase().startsWith('fr') ? 'fr' : 'en';
  const String baseUrl =
      'https://maps.googleapis.com/maps/api/place/details/json';
  final String request =
      '$baseUrl?place_id=$placeId&fields=geometry&key=$apiKey&sessiontoken=$sessionToken&language=$lang';

  try {
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && data['result'] != null) {
        final location = data['result']['geometry']['location'];
        final double lat = (location['lat'] as num).toDouble();
        final double lng = (location['lng'] as num).toDouble();
        return LatLng(lat, lng);
      }
    } else {
      debugPrint('getPlaceDetails error: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    debugPrint('getPlaceDetails error: $e');
  }
  return null;
}
