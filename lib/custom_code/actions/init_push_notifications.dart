// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Fichier : /custom_code/actions/init_push_notifications.dart
// VERSION FINALE AVEC LOGIQUE DE REDIRECTION

import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '/custom_code/push_background.dart';
import '/custom_code/firebase_options.dart';
import '/custom_code/actions/handle_notification_redirection.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/utils/secure_logger.dart';
// Pour appNavigatorKey

StreamSubscription<AuthState>? _authStateSubscription;

// Guard pour éviter la double navigation sur notification vidéo
bool _initialVideoNotificationHandled = false;

Future<void> initPushNotifications(BuildContext context) async {
  SecureLogger.functionStart('initPushNotifications');
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      SecureLogger.info('Firebase initialized');
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Check current permission status WITHOUT requesting
    // Permission will be requested during onboarding (step 5)
    final currentSettings = await FirebaseMessaging.instance.getNotificationSettings();
    SecureLogger.debug('FCM current permission status: ${currentSettings.authorizationStatus}');
    
    if (currentSettings.authorizationStatus != AuthorizationStatus.authorized &&
        currentSettings.authorizationStatus != AuthorizationStatus.provisional) {
      SecureLogger.info('FCM permission not yet granted, will be requested during onboarding');
      // Don't request here - it will be requested in onboarding step 5
      // Still setup listeners for when permission is granted later
    }

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Gestion du token de l'appareil
    _authStateSubscription?.cancel();
    _authStateSubscription =
        SupaFlow.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn ||
          event == AuthChangeEvent.tokenRefreshed) {
        final token = await FirebaseMessaging.instance.getToken();
        final platform =
            Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'web');
        if (currentUserUid.isNotEmpty && token != null && token.isNotEmpty) {
          // UPSERT du token avec le nouveau profile_id
          // Cela met à jour ou crée le token pour l'utilisateur actuel
          await SupaFlow.client.from('device_tokens').upsert({
            'token': token,
            'profile_id': currentUserUid,
            'platform': platform,
            'last_seen_at': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'token');
          SecureLogger.info('Device token registered for user');
        }
      } else if (event == AuthChangeEvent.signedOut) {
        // BACKUP : Suppression du token à la déconnexion
        // Note: Le token devrait déjà être supprimé par signOut() dans auth_manager
        // mais on garde ce code comme backup au cas où
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          try {
            await SupaFlow.client.rpc('delete_current_device_token', params: {
              'device_token': token,
            });
            SecureLogger.info('Device token deleted on signout (backup)');
          } catch (e) {
            SecureLogger.warning('Failed to delete device token on signout: $e');
          }
        }
      }
    });

    // Fonction pour rafraîchir le badge
    Future<void> refreshUnreadBadge() async {
      try {
        final resp =
            await SupaFlow.client.rpc('get_unread_notifications_count');
        final count = resp as int? ?? 0;
        FFAppState().update(() {
          FFAppState().unreadNotificationsCount = count;
          FFAppState().hasUnreadNotifications = count > 0;
        });
      } catch (e) {
        SecureLogger.error('Badge refresh error', error: e);
      }
    }

    // Écouteur pour les messages reçus quand l'app est OUVERTE (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      SecureLogger.debugSanitized(
        'onMessage (Foreground) received',
        sensitiveKeys: ['token', 'session_id', 'user_id', 'video_session_id']
      );
      final data = message.data;
      final type = data['type'] as String?;
      // Les notifications videoIncoming sont gérées par handleNotificationRedirection
      // Pas besoin de stocker dans AppState
      if (type != 'videoIncoming') {
        await refreshUnreadBadge();
      }
    });

    // Écouteur pour le TAP sur une notification quand l'app est en ARRIÈRE-PLAN
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      SecureLogger.debugSanitized(
        'onMessageOpenedApp (Background) notification tapped',
        sensitiveKeys: ['token', 'session_id', 'user_id', 'video_session_id']
      );
      final data = message.data;
      final type = data['type'] as String?;
      
      // Guard: si c'est une notif vidéo et qu'elle a déjà été traitée par getInitialMessage, ignorer
      if (type == 'videoIncoming' && _initialVideoNotificationHandled) {
        SecureLogger.info('⚠️ Video notification already handled by getInitialMessage - skipping');
        await refreshUnreadBadge();
        return;
      }
      
      // Utiliser le context du navigatorKey global
      final navContext = appNavigatorKey.currentContext;
      if (navContext != null && navContext.mounted) {
        await handleNotificationRedirection(navContext, data);
      } else {
        SecureLogger.error('Navigator context is null or not mounted');
      }
      await refreshUnreadBadge();
    });

    // Gestion de la notification qui a LANCÉ l'app (état terminé)
    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      SecureLogger.debugSanitized(
        'getInitialMessage (Terminated) app launched from notification',
        sensitiveKeys: ['token', 'session_id', 'user_id', 'video_session_id']
      );
      
      final type = initialMsg.data['type'] as String?;
      if (type == 'videoIncoming') {
        _initialVideoNotificationHandled = true;
        SecureLogger.info('✅ Marking video notification as handled (from getInitialMessage)');
      }
      
      // On attend un peu que l'UI soit prête
      Future.delayed(const Duration(milliseconds: 2000), () async {
        final navContext = appNavigatorKey.currentContext;
        if (navContext != null && navContext.mounted) {
          await handleNotificationRedirection(navContext, initialMsg.data);
        } else {
          SecureLogger.error('Navigator context is null or not mounted (initial message)');
        }
        await refreshUnreadBadge();
      });
    }

    // Upsert du token au démarrage si l'utilisateur est déjà connecté
    if (loggedIn) {
      final token = await FirebaseMessaging.instance.getToken();
      final platform =
          Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'web');
      if (currentUserUid.isNotEmpty && token != null && token.isNotEmpty) {
        await SupaFlow.client.from('device_tokens').upsert({
          'token': token,
          'profile_id': currentUserUid,
          'platform': platform,
          'last_seen_at': DateTime.now().toUtc().toIso8601String(),
        }, onConflict: 'token');
        SecureLogger.info('Device token registered at startup for logged-in user');
      }
    }

    // Rafraîchir le badge une première fois
    await refreshUnreadBadge();
  } catch (e) {
    SecureLogger.error('CRITICAL ERROR in initPushNotifications', error: e);
  }
  SecureLogger.functionEnd('initPushNotifications');
}
