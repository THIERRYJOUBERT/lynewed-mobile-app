// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart' as functions; // Imports custom functions
import '/utils/secure_logger.dart';
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:uni_links/uni_links.dart';
import 'dart:async';
import '/index.dart';

StreamSubscription? _deeplinkSubscription;
StreamSubscription? _authStateSubscription;

Future<void> setupDeeplinkListener(BuildContext context) async {
  // Annuler les anciens listeners s'ils existent
  await _deeplinkSubscription?.cancel();
  await _authStateSubscription?.cancel();

  // Écouter les changements d'état d'authentification Supabase
  _authStateSubscription = SupaFlow.client.auth.onAuthStateChange.listen(
    (AuthState authState) {
      SecureLogger.debug('Auth state changed: ${authState.event}');
      
      // Si c'est un événement de récupération de mot de passe
      if (authState.event == AuthChangeEvent.passwordRecovery) {
        SecureLogger.debug('Password recovery event detected, redirecting to reset page');
        
        // Naviguer vers la page de reset password
        Future.delayed(const Duration(milliseconds: 100), () {
          context.goNamed(ResetPasswordNewPageWidget.routeName);
        });
      }
    },
  );

  // Créer un listener pour les deeplinks entrants (backup)
  _deeplinkSubscription = linkStream.listen(
    (String? link) {
      if (link != null && link.isNotEmpty) {
        SecureLogger.debugSanitized(
          'Deeplink received during app execution',
          sensitiveKeys: ['access_token', 'refresh_token', 'password', 'reset']
        );

        // ✅ Vérifier si le deeplink contient "reset-password" (path spécifique)
        if (link.contains('reset-password')) {
          SecureLogger.debug('Reset-password deeplink detected, redirecting to reset page');

          // Naviguer vers la page de reset password
          Future.delayed(const Duration(milliseconds: 100), () {
            context.goNamed(ResetPasswordNewPageWidget.routeName);
          });
          return;
        }

        // Backup: Vérifier aussi avec la fonction isRecoveryLink (type=recovery)
        if (functions.isRecoveryLink(link)) {
          SecureLogger.debug('Recovery link detected, redirecting to reset page');

          // Naviguer vers la page de reset password
          Future.delayed(const Duration(milliseconds: 100), () {
            context.goNamed(ResetPasswordNewPageWidget.routeName);
          });
        }
      }
    },
    onError: (err) {
      SecureLogger.error('Error listening to deeplinks', error: err);
    },
  );

  SecureLogger.info('Deeplink and auth state listeners configured successfully');
}

// Fonction pour nettoyer le listener (optionnel, à appeler lors de la déconnexion)
Future<void> cancelDeeplinkListener() async {
  await _deeplinkSubscription?.cancel();
  await _authStateSubscription?.cancel();
  _deeplinkSubscription = null;
  _authStateSubscription = null;
  SecureLogger.debug('Deeplink and auth state listeners cancelled');
}
// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
