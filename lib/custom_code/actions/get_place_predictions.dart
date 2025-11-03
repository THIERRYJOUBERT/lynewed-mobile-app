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
  final String baseUrl =
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
      print('Google Places API error: ${response.statusCode} ${response.body}');
    }
  } catch (e) {
    print('getPlacePredictions error: $e');
  }
  return PlacePredictionsResultStruct(
      suggestions: suggestions, newSessionToken: currentSessionToken);
}
