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

// Fichier: custom_code/actions/start_video_session_action.dart

import 'package:uuid/uuid.dart';

Future<VideoSessionsRow?> startVideoSessionAction(String receiverId) async {
  final client = SupaFlow.client;
  final initiatorId = client.auth.currentUser?.id;
  if (initiatorId == null) {
    debugPrint('[DEBUG] startVideoSessionAction: User not authenticated.');
    return null;
  }

  final channelName = Uuid().v4();

  try {
    // Étape 1: Créer la session vidéo dans la base de données
    final data = await client
        .from('video_sessions')
        .insert({
          'initiator_id': initiatorId,
          'receiver_id': receiverId,
          'status': 'pending',
          'agora_channel_name': channelName,
        })
        .select()
        .single();

    final videoSession = VideoSessionsRow(data);
    debugPrint(
        '[DEBUG] startVideoSessionAction: Video session created with ID: ${videoSession.id}');

    // --- AJOUT : Déclenchement immédiat de la notification ---
    // Le trigger a déjà placé l'événement dans 'notifications_outbox'.
    // Nous forçons le traitement de la file d'attente maintenant.
    try {
      await client.functions.invoke('notifications_outbox_drain');
      debugPrint(
          '[DEBUG] startVideoSessionAction: "notifications_outbox_drain" invoked for immediate call notification.');
    } catch (e) {
      // Cet échec n'est pas bloquant, le Cron Job prendra le relais.
      debugPrint(
          '[DEBUG] startVideoSessionAction: Invoking drain function failed (will be processed by cron): $e');
    }

    // --- AJOUT : Démarrer un timeout de 30 secondes ---
    // Si la session n'est pas acceptée après 30 secondes, elle sera marquée comme 'missed'
    Future.delayed(Duration(seconds: 30), () async {
      try {
        await handleVideoSessionTimeout(videoSession.id);
      } catch (e) {
        debugPrint(
            '[DEBUG] startVideoSessionAction: Timeout handler failed: $e');
      }
    });

    return videoSession;
  } catch (e) {
    debugPrint('[DEBUG] startVideoSessionAction CRITICAL ERROR: $e');
    return null;
  }
}
