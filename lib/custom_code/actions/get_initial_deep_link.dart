// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
// Imports other custom actions
// Imports custom functions
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
    debugPrint("Failed to get initial link.");
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
