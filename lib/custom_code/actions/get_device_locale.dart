// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
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
