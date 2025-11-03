// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart' as functions; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:uni_links/uni_links.dart';
import 'dart:async';
import '/index.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

StreamSubscription? _deeplinkSubscription;
StreamSubscription? _authStateSubscription;

Future<void> setupDeeplinkListener(BuildContext context) async {
  // Annuler les anciens listeners s'ils existent
  await _deeplinkSubscription?.cancel();
  await _authStateSubscription?.cancel();

  // Écouter les changements d'état d'authentification Supabase
  _authStateSubscription = SupaFlow.client.auth.onAuthStateChange.listen(
    (AuthState authState) {
      print('🔐 Auth state changed: ${authState.event}');
      
      // Si c'est un événement de récupération de mot de passe
      if (authState.event == AuthChangeEvent.passwordRecovery) {
        print('🔑 Password recovery event détecté, redirection vers ResetPasswordNewPage');
        
        // Naviguer vers la page de reset password
        Future.delayed(Duration(milliseconds: 100), () {
          context.goNamed(ResetPasswordNewPageWidget.routeName);
        });
      }
    },
  );

  // Créer un listener pour les deeplinks entrants (backup)
  _deeplinkSubscription = linkStream.listen(
    (String? link) {
      if (link != null && link.isNotEmpty) {
        print('📱 Deeplink reçu pendant l\'exécution: $link');

        // ✅ Vérifier si le deeplink contient "reset-password" (path spécifique)
        if (link.contains('reset-password')) {
          print('🔑 Deeplink reset-password détecté, redirection vers ResetPasswordNewPage');

          // Naviguer vers la page de reset password
          Future.delayed(Duration(milliseconds: 100), () {
            context.goNamed(ResetPasswordNewPageWidget.routeName);
          });
          return;
        }

        // Backup: Vérifier aussi avec la fonction isRecoveryLink (type=recovery)
        if (functions.isRecoveryLink(link)) {
          print('🔑 Lien de récupération détecté (type=recovery), redirection vers ResetPasswordNewPage');

          // Naviguer vers la page de reset password
          Future.delayed(Duration(milliseconds: 100), () {
            context.goNamed(ResetPasswordNewPageWidget.routeName);
          });
        }
      }
    },
    onError: (err) {
      print('❌ Erreur lors de l\'écoute des deeplinks: $err');
    },
  );

  print('✅ Listeners de deeplinks et auth state configurés avec succès');
}

// Fonction pour nettoyer le listener (optionnel, à appeler lors de la déconnexion)
Future<void> cancelDeeplinkListener() async {
  await _deeplinkSubscription?.cancel();
  await _authStateSubscription?.cancel();
  _deeplinkSubscription = null;
  _authStateSubscription = null;
  print('🛑 Listeners de deeplinks et auth state annulés');
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
