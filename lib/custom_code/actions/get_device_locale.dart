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

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Future<String> getDeviceLocale(BuildContext context) async {
  // This action gets the device's locale and normalizes it to either 'fr' or 'en'.
  // This ensures that we only store and use supported language codes throughout the app.

  // Get the full language code from the device (e.g., 'fr-CA', 'en-US', 'de').
  final String deviceLanguageCode = FFLocalizations.of(context).languageCode;

  // Normalize the code.
  if (deviceLanguageCode.toLowerCase().startsWith('fr')) {
    // If the language is any variant of French, return 'fr'.
    return 'fr';
  } else {
    // For all other languages (including English variants), default to 'en'.
    return 'en';
  }
}
