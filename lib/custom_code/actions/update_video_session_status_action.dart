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

// custom_code/actions/update_video_session_status_action.dart

Future<bool> updateVideoSessionStatusAction(
  String sessionId,
  VideoSessionStatus newStatus,
) async {
  debugPrint(
      '[DEBUG] updateVideoSessionStatus: session=$sessionId, status=${newStatus.name}');
  try {
    final client = SupaFlow.client;

    // --- CORRECTION: Utilisation de .select() pour confirmer la mise à jour ---
    final response = await client
        .from('video_sessions')
        .update({'status': newStatus.name})
        .eq('id', sessionId)
        .select('id') // On demande de retourner l'ID si la mise à jour a réussi
        .maybeSingle();

    // Si la réponse n'est pas nulle, cela signifie que la ligne a été trouvée et mise à jour.
    if (response != null) {
      debugPrint('[DEBUG] updateVideoSessionStatus: Success.');
      return true;
    } else {
      debugPrint(
          '[DEBUG] updateVideoSessionStatus: Failed. Session ID not found or RLS issue.');
      return false;
    }
  } catch (e) {
    debugPrint('[DEBUG] updateVideoSessionStatus CRITICAL EXCEPTION: $e');
    return false;
  }
}
