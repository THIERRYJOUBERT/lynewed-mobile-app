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

import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart';

Future<String?> getInitialDeepLink() async {
  try {
    // Tente de récupérer le lien initial qui a lancé l'application.
    final String? initialLink = await getInitialLink();
    return initialLink;
  } on PlatformException {
    // Gère les erreurs si le plugin ne parvient pas à communiquer avec la plateforme.
    print("Failed to get initial link.");
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
