// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<String?> createSignedUrlForChatMediaAction(
  String fullPath,
  int? expiresSeconds,
) async {
  try {
    final client = SupaFlow.client;
    if (fullPath.isEmpty) return null;

    // Le fullPath doit être au format "<bucket>/<chemin_objet>"
    // ex: "chat-audio/room_id/fichier.m4a"
    final firstSlash = fullPath.indexOf('/');
    if (firstSlash <= 0 || firstSlash >= fullPath.length - 1) {
      debugPrint('Error: fullPath format is invalid. Expected "<bucket>/<path>".');
      return null;
    }

    final bucket = fullPath.substring(0, firstSlash);
    final objectPath = fullPath.substring(firstSlash + 1);
    final expires = (expiresSeconds == null || expiresSeconds <= 0)
        ? 3600
        : expiresSeconds; // 1 heure par défaut

    final signedUrlResponse =
        await client.storage.from(bucket).createSignedUrl(objectPath, expires);

    return signedUrlResponse;
  } catch (e) {
    debugPrint('createSignedUrlForChatMediaAction error: $e');
    return null;
  }
}
