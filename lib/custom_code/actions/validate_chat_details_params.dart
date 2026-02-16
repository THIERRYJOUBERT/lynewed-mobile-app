// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
// Fichier: custom_code/actions/validate_chat_details_params.dart

Future<bool> validateChatDetailsParams(
  BuildContext context,
  String? roomId,
  UserRole? userRole,
) async {
  // Cette action vérifie si le roomId, qui est essentiel pour la page,
  // est bien présent. Si non, elle redirige l'utilisateur et retourne 'false'.

  if (roomId == null || roomId.isEmpty) {
    SecureLogger.warning('Chat details validation failed: roomId is null or empty, redirecting...');

    // Redirection de secours vers la liste des messages appropriée
    if (userRole == UserRole.professional) {
      context.goNamed('MessagesPro', extra: {'replace': true});
    } else {
      context.goNamed('MessagesBrides', extra: {'replace': true});
    }

    // Indique que la validation a échoué et que le reste des actions On Page Load ne doit pas s'exécuter
    return false;
  }

  // Si le roomId est valide, on indique que tout va bien
  SecureLogger.debug('Chat details validation: roomId is valid');
  return true;
}
