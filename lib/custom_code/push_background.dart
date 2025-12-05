// Fichier : custom_code/push_background.dart

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '/custom_code/firebase_options.dart';

// Cette annotation est CRUCIALE. Elle permet à Flutter de trouver cette fonction
// même quand l'application est en arrière-plan.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ce code s'exécute lorsque l'application reçoit une notification en arrière-plan.

  // On s'assure que Firebase est initialisé dans ce contexte isolé.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    // Pour le débogage, vous pouvez décommenter la ligne suivante pour voir
    // les messages dans la console de votre appareil.
  } catch (e) {
  }
}
