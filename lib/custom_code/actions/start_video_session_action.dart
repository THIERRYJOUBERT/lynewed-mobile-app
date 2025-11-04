// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import 'index.dart'; // Imports other custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Fichier: custom_code/actions/start_video_session_action.dart

import 'package:uuid/uuid.dart';

Future<VideoSessionsRow?> startVideoSessionAction(String receiverId) async {
  SecureLogger.functionStart('startVideoSessionAction', params: {
    'receiverId': '***REDACTED***'
  });
  
  final client = SupaFlow.client;
  final initiatorId = client.auth.currentUser?.id;
  if (initiatorId == null) {
    SecureLogger.warning('Video session start failed: User not authenticated');
    return null;
  }

  final channelName = const Uuid().v4();

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
    SecureLogger.info('Video session created successfully');

    // --- AJOUT : Déclenchement immédiat de la notification ---
    // Le trigger a déjà placé l'événement dans 'notifications_outbox'.
    // Nous forçons le traitement de la file d'attente maintenant.
    try {
      await client.functions.invoke('notifications_outbox_drain');
      SecureLogger.debug('Notification outbox drain invoked for immediate call');
    } catch (e) {
      // Cet échec n'est pas bloquant, le Cron Job prendra le relais.
      SecureLogger.error('Notification drain failed (will be processed by cron)', error: e);
    }

    // --- AJOUT : Démarrer un timeout de 30 secondes ---
    // Si la session n'est pas acceptée après 30 secondes, elle sera marquée comme 'missed'
    Future.delayed(const Duration(seconds: 30), () async {
      try {
        await handleVideoSessionTimeout(videoSession.id);
      } catch (e) {
        SecureLogger.error('Video session timeout handler failed', error: e);
      }
    });

    return videoSession;
  } catch (e) {
    SecureLogger.error('Video session start failed', error: e);
    return null;
  }
}
