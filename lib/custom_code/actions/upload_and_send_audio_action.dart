// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import 'package:uuid/uuid.dart';

Future<bool> uploadAndSendAudioAction(
  String roomId,
  FFUploadedFile audioFile,
) async {
  try {
    final client = SupaFlow.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null || roomId.isEmpty) return false;

    final bytes = audioFile.bytes;
    if (bytes == null || bytes.isEmpty) return false;

    const uuid = Uuid();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final filename = 'audio_${ts}_${uuid.v4()}.m4a';
    final storagePath = '$roomId/$filename';

    // Upload binaire sur le bucket chat-audio
    await client.storage.from('chat-audio').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'audio/mp4', // Mime type pour m4a (AAC)
            cacheControl: '3600',
            upsert: false,
          ),
        );

    final fullPath = 'chat-audio/$storagePath';

    // Insert du message dans la table chat_messages
    await client.from('chat_messages').insert({
      'room_id': roomId,
      'profile_id': userId,
      'message_type': 'audio',
      'attachment_url': fullPath,
    });

    return true;
  } catch (e) {
    // Essayer un rollback si l'erreur n'est pas lors de l'insert
    // Note: une gestion d'erreur plus fine serait nécessaire en prod
    return false;
  }
}
