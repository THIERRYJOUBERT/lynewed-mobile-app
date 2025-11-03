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

// custom_code/actions/handle_video_session_timeout.dart

Future<void> handleVideoSessionTimeout(String sessionId) async {
  debugPrint(
      '[DEBUG] handleVideoSessionTimeout: Checking session $sessionId after 30 seconds');

  try {
    final client = SupaFlow.client;

    // Vérifier le statut actuel de la session
    final response = await client
        .from('video_sessions')
        .select('status')
        .eq('id', sessionId)
        .maybeSingle();

    if (response == null) {
      debugPrint(
          '[DEBUG] handleVideoSessionTimeout: Session not found (may have been deleted)');
      return;
    }

    final currentStatus = response['status'] as String?;

    // Si la session est toujours en pending après 30 secondes, la marquer comme missed
    if (currentStatus == 'pending') {
      debugPrint(
          '[DEBUG] handleVideoSessionTimeout: Session still pending, marking as missed');

      await client
          .from('video_sessions')
          .update({'status': 'missed'})
          .eq('id', sessionId)
          .select('id')
          .maybeSingle();

      debugPrint('[DEBUG] handleVideoSessionTimeout: Session marked as missed');
    } else {
      debugPrint(
          '[DEBUG] handleVideoSessionTimeout: Session status is $currentStatus, no action needed');
    }
  } catch (e) {
    debugPrint('[DEBUG] handleVideoSessionTimeout EXCEPTION: $e');
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
