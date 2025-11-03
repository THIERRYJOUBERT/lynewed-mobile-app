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
  final String baseUrl =
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
      print('getPlaceDetails error: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('getPlaceDetails error: $e');
  }
  return null;
}
