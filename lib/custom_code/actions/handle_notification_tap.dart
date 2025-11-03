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
import '/custom_code/actions/index.dart' as actions;

Future<void> handleNotificationTap(
  BuildContext context,
  AppNotificationStruct notificationItem,
) async {
  // --- Étape 1 : Marquer la notification comme lue ---
  // On exécute cette action en premier pour que l'UI se mette à jour rapidement.
  if (notificationItem.notificationId.isNotEmpty) {
    await actions.markNotificationAsRead(
      notificationItem.notificationId,
    );
  }

  // --- Étape 2 : Préparer les variables pour la navigation ---
  final type = notificationItem.notificationType;
  // Le referenceId contient l'ID pertinent (ex: room_id, alert_id)
  // grâce à la fonction `get_formatted_notifications`.
  final ref = notificationItem.referenceId;
  final userRole = FFAppState().currentUserRole;
  final router = GoRouter.of(context);

  // --- Étape 3 : Logique de navigation basée sur le type de notification ---
  switch (type) {
    // Cas groupés pour les notifications liées au Chat
    case NotificationType.chatMessage:
    case NotificationType.connectionRequest:
    case NotificationType.connectionRequestAccepted:
    case NotificationType.connectionRequestDeclined:
      if (ref != null && ref.isNotEmpty) {
        // Si on a un referenceId (qui sera le room_id), on va directement au chat.
        router.pushNamed(
          'ChatDetails',
          pathParameters: {'roomId': ref},
          extra: <String, dynamic>{
            kTransitionInfoKey: const TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.fade,
              duration: Duration(milliseconds: 0),
            ),
          },
        );
      } else {
        // Fallback: si pas de room_id, on va à la liste des messages du rôle.
        if (userRole == UserRole.professional) {
          router.pushNamed('MessagesPro');
        } else {
          router.pushNamed('MessagesBrides');
        }
      }
      break;

    // Cas groupés pour les notifications destinées au Dashboard Pro
    case NotificationType.wishlistAdd:
    case NotificationType.professionalAlertReminder24h:
    case NotificationType.professionalAlert: // Futur type
    case NotificationType.weddingPinMatch: // Futur type
      router.pushNamed('DashboardPro');
      break;

    // Cas pour le "Wedding of the Week"
    case NotificationType.wedPublished:
      router.pushNamed('WeddingOfTheWeek');
      break;

    // Cas pour l'appel vidéo entrant (ne fait rien, géré par l'AppState)
    case NotificationType.videoIncoming:
      // L'action est gérée par la BottomSheet, donc pas de navigation au tap.
      break;

    // Navigation par défaut pour tous les autres cas
    default:
      if (userRole == UserRole.professional) {
        router.pushNamed('DashboardPro');
      } else {
        router.pushNamed('HomeBrides');
      }
      break;
  }
}
