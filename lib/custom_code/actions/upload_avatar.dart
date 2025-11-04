// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import '/auth/supabase_auth/auth_util.dart';

Future<String?> uploadAvatar(String localPath) async {
  // Vérifie si l'utilisateur est connecté et si le chemin n'est pas vide
  if (currentUserUid.isEmpty || localPath.isEmpty) {
    return null;
  }

  try {
    // 1. Crée un objet Fichier à partir du chemin local
    final file = File(localPath);

    // 2. Lit les données binaires (Bytes) du fichier
    final fileBytes = await file.readAsBytes();

    // 3. Définit le chemin dans le bucket Supabase
    // On ajoute un timestamp pour forcer le rafraîchissement du cache si nécessaire
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final serverPath = '$currentUserUid/profile_$timestamp.jpg';

    // 4. Uploade les Bytes vers Supabase Storage
    await SupaFlow.client.storage.from('avatars').uploadBinary(
          serverPath,
          fileBytes,
        );

    // 5. Récupère l'URL publique de l'image qui vient d'être uploadée
    final publicUrl =
        SupaFlow.client.storage.from('avatars').getPublicUrl(serverPath);

    return publicUrl;
  } catch (e) {
    debugPrint('Error in uploadAvatar action: $e');
    return null;
  }
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
