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
import '/custom_code/actions/handle_notification_redirection.dart';
import '/custom_code/actions/mark_notification_as_read.dart';

Future handleInAppNotificationTap(
  BuildContext context,
  AppNotificationStruct notificationItem,
) async {
  // 1. Marquer comme lu
  if (notificationItem.notificationId.isNotEmpty) {
    // Appelle l'autre Custom Action directement
    await markNotificationAsRead(notificationItem.notificationId);
  }

  // 2. Préparer les données pour la redirection
  // On crée une Map qui ressemble au payload d'un push FCM
  if (notificationItem.notificationType == null) {
    debugPrint(
        'handleInAppNotificationTap: notificationType is null, cannot redirect.');
    return;
  }

  final Map<String, dynamic> dataForRedirection = {
    'type': notificationItem.notificationType!.name,
    // Le referenceId est la clé: il contient room_id, alert_id, etc.
    'room_id': notificationItem.referenceId,
  };

  // 3. Déléguer la navigation à l'action centralisée
  await handleNotificationRedirection(context, dataForRedirection);
}
