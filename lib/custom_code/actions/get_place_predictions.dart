// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:uuid/uuid.dart';

Future<PlacePredictionsResultStruct> getPlacePredictions(
  String inputString,
  String? sessionToken,
  String? locale,
) async {
  // CORRECTION : Le code accède maintenant à la constante que tu viens de définir dans l'UI
  final String apiKey = FFAppConstants.googlePlacesApiKey;

  if (inputString.isEmpty) {
    return PlacePredictionsResultStruct(
        suggestions: [], newSessionToken: sessionToken);
  }

  final String lang =
      (locale ?? 'en').toLowerCase().startsWith('fr') ? 'fr' : 'en';
  final String currentSessionToken = sessionToken ?? const Uuid().v4();
  const String baseUrl =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  final String request =
      '$baseUrl?input=${Uri.encodeComponent(inputString)}&key=$apiKey&sessiontoken=$currentSessionToken&language=$lang';

  final List<PlaceSuggestionStruct> suggestions = [];
  try {
    final response = await http.get(Uri.parse(request));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final predictions = data['predictions'] as List;
        for (var p in predictions) {
          suggestions.add(PlaceSuggestionStruct(
            placeId: p['place_id'],
            primaryText: p['structured_formatting']['main_text'],
            secondaryText: p['structured_formatting']['secondary_text'] ?? '',
          ));
        }
      }
    } else {
      debugPrint('Google Places API error: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    debugPrint('getPlacePredictions error: $e');
  }
  return PlacePredictionsResultStruct(
      suggestions: suggestions, newSessionToken: currentSessionToken);
}
