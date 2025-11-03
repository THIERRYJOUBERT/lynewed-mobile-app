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

// --- Début du Helper de parsing ROBUSTE ---
NotificationType _notificationTypeFromString(String? s) {
  if (s == null || s.isEmpty) {
    // Si la chaîne est vide, retournez un fallback par défaut.
    // Vous pouvez choisir le plus commun, comme chatMessage.
    return NotificationType.chatMessage;
  }
  // Convertit la chaîne reçue en minuscules pour une comparaison fiable.
  final lowerCaseS = s.toLowerCase();
  for (var val in NotificationType.values) {
    // Compare la version minuscule de la chaîne avec la version minuscule du nom de l'Enum.
    if (val.name.toLowerCase() == lowerCaseS) {
      return val;
    }
  }

  // Si aucune correspondance n'est trouvée après avoir tout vérifié,
  // loggez une alerte pour le débogage et retournez un fallback sûr pour éviter le crash.
  print('--- WARNING: Unmatched notificationType enum value from DB: "$s" ---');
  return NotificationType.chatMessage; // Fallback sûr
}
// --- Fin du Helper ---

Future<List<AppNotificationStruct>> getNotificationsAction() async {
  try {
    final response = await SupaFlow.client
        .rpc('get_formatted_notifications', params: {'p_limit': 100});

    if (response == null ||
        response is! Map<String, dynamic> ||
        response['items'] == null ||
        response['items'] is! List) {
      print('getNotificationsAction: Invalid RPC response format.');
      return [];
    }

    final List<dynamic> itemList = response['items'];
    final List<AppNotificationStruct> notifications = [];

    for (var itemData in itemList) {
      if (itemData is Map<String, dynamic>) {
        final createdAtStr = itemData['createdAt']?.toString();
        notifications.add(
          AppNotificationStruct(
            notificationId: itemData['notificationId']?.toString() ?? '',
            notificationType: _notificationTypeFromString(
                itemData['notificationType']?.toString()),
            title: itemData['title']?.toString() ?? 'Notification',
            message: itemData['message']?.toString() ?? '',
            createdAt:
                createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
            isRead: itemData['isRead'] as bool? ?? false,
            referenceId: itemData['referenceId']?.toString(),
            senderAvatarUrl: itemData['senderAvatarUrl']?.toString(),
          ),
        );
      }
    }

    return notifications;
  } catch (e) {
    print('getNotificationsAction error: $e');
    return [];
  }
}
