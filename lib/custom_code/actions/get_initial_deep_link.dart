// Automatic FlutterFlow imports
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:app_links/app_links.dart';

Future<String?> getInitialDeepLink() async {
  try {
    // Tente de récupérer le lien initial qui a lancé l'application.
    final appLinks = AppLinks();
    final Uri? initialUri = await appLinks.getInitialLink();
    return initialUri?.toString();
  } catch (e) {
    // Gère les erreurs si le plugin ne parvient pas à communiquer avec la plateforme.
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
