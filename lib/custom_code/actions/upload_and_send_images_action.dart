// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<bool> uploadAndSendImagesAction(
  String roomId,
  List<FFUploadedFile> files,
  int? jpegQuality,
  int? maxSide,
  String? accompanyingText,
) async {
  final client = SupaFlow.client;
  final userId = client.auth.currentUser?.id;

  if (userId == null || roomId.isEmpty) return false;

  final bool hasImages = files.isNotEmpty;
  final bool hasText = (accompanyingText ?? '').trim().isNotEmpty;
  if (!hasImages && !hasText) return false;

  try {
    final messagesToInsert = <Map<String, dynamic>>[];

    // 1) Message texte optionnel
    if (hasText) {
      messagesToInsert.add({
        'room_id': roomId,
        'profile_id': userId,
        'message_type': 'text',
        'content': accompanyingText!.trim(),
      });
    }

    // 2) Upload(s) image(s) + préparation messages image
    if (hasImages) {
      final q = (jpegQuality == null || jpegQuality <= 0 || jpegQuality > 100)
          ? 80
          : jpegQuality;
      final maxDim = (maxSide == null || maxSide <= 0) ? 1440 : maxSide;
      const uuid = Uuid();

      Future<Uint8List> maybeCompress(
        Uint8List bytes,
        int? w,
        int? h,
      ) async {
        try {
          final largest = (w == null || h == null) ? 0 : max(w, h);
          if (largest <= maxDim) {
            return await FlutterImageCompress.compressWithList(
              bytes,
              quality: q,
              format: CompressFormat.jpeg,
            );
          }
          final scale = largest / maxDim;
          return await FlutterImageCompress.compressWithList(
            bytes,
            minWidth: (w! / scale).round(),
            minHeight: (h! / scale).round(),
            quality: q,
            format: CompressFormat.jpeg,
          );
        } catch (_) {
          // Si la compression échoue, on renvoie l'image d'origine
          return bytes;
        }
      }

      for (final file in files) {
        if (file.bytes == null || file.bytes!.isEmpty) continue;

        final compressed = await maybeCompress(
          file.bytes!,
          file.width?.round(),
          file.height?.round(),
        );

        final ts = DateTime.now().millisecondsSinceEpoch;
        final uniqueId = uuid.v4();
        final fileName = '${ts}_$uniqueId.jpg';
        final storagePath = '$roomId/$fileName';

        try {
          // Supabase v2: lève une exception si l’upload échoue
          await client.storage.from('chat-images').uploadBinary(
                storagePath,
                compressed,
                fileOptions: const FileOptions(
                  contentType: 'image/jpeg',
                  upsert: false,
                ),
              );

          messagesToInsert.add({
            'room_id': roomId,
            'profile_id': userId,
            'message_type': 'image',
            'attachment_url': 'chat-images/$storagePath',
          });
        } catch (e) {
          debugPrint('upload image failed: $e');
          // Si un upload échoue, on retourne false comme avant
          return false;
        }
      }
    }

    // 3) Insertion en base
    if (messagesToInsert.isNotEmpty) {
      // Supabase v2: insert lève une exception si échec. Pas de response.error.
      await client.from('chat_messages').insert(messagesToInsert);
    }

    return true;
  } catch (e) {
    debugPrint('uploadAndSendImagesAction error: $e');
    return false;
  }
}
