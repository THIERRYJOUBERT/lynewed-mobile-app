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
    debugPrint(
        '[DEBUG] validateChatDetailsParams: roomId is NULL or EMPTY. Redirecting...');

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
  debugPrint('[DEBUG] validateChatDetailsParams: roomId is VALID.');
  return true;
}
