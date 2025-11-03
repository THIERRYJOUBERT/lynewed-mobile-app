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

// Fichier : /custom_code/actions/init_push_notifications.dart
// VERSION FINALE AVEC LOGIQUE DE REDIRECTION

import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/custom_code/push_background.dart';
import '/custom_code/firebase_options.dart';
import '/custom_code/actions/handle_notification_redirection.dart';
import '/auth/supabase_auth/auth_util.dart';

StreamSubscription<AuthState>? _authStateSubscription;

Future<void> initPushNotifications(BuildContext context) async {
  debugPrint('--- [DEBUG] initPushNotifications: START');
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      debugPrint('--- [DEBUG] Firebase initialized');
    }

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final settings = await FirebaseMessaging.instance.requestPermission();
    debugPrint('--- [DEBUG] FCM permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      debugPrint('--- [DEBUG] Permission refused, stopping init.');
      return;
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
          await SupaFlow.client.from('device_tokens').upsert({
            'token': token,
            'profile_id': currentUserUid,
            'platform': platform,
            'last_seen_at': DateTime.now().toUtc().toIso8601String(),
          }, onConflict: 'token');
        }
      } else if (event == AuthChangeEvent.signedOut) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null && token.isNotEmpty) {
          await SupaFlow.client
              .from('device_tokens')
              .delete()
              .eq('token', token);
        }
      }
    });

    // Fonction pour rafraîchir le badge
    Future<void> _refreshUnreadBadge() async {
      try {
        final resp =
            await SupaFlow.client.rpc('get_unread_notifications_count');
        final count = resp as int? ?? 0;
        FFAppState()
            .update(() => FFAppState().hasUnreadNotifications = count > 0);
      } catch (e) {
        debugPrint('--- [DEBUG] Badge refresh error: $e');
      }
    }

    // Écouteur pour les messages reçus quand l'app est OUVERTE (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('--- [DEBUG] onMessage (Foreground) data=${message.data}');
      final data = message.data;
      final type = data['type'] as String?;
      if (type == 'videoIncoming') {
        FFAppState().update(() => FFAppState().incomingVideoCallData =
            Map<String, dynamic>.from(data));
      } else {
        await _refreshUnreadBadge();
      }
    });

    // Écouteur pour le TAP sur une notification quand l'app est en ARRIÈRE-PLAN
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint(
          '--- [DEBUG] onMessageOpenedApp (Background) data=${message.data}');
      final data = message.data;
      // IMPORTANT : On ne gère pas 'videoIncoming' ici car le widget listener va s'en charger.
      // On appelle directement la redirection pour tous les autres types.
      if (context.mounted) {
        await handleNotificationRedirection(context, data);
      }
      await _refreshUnreadBadge();
    });

    // Gestion de la notification qui a LANCÉ l'app (état terminé)
    final initialMsg = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMsg != null) {
      debugPrint(
          '--- [DEBUG] getInitialMessage (Terminated) data=${initialMsg.data}');
      // On attend un peu que l'UI soit prête
      Future.delayed(const Duration(milliseconds: 2000), () async {
        if (context.mounted) {
          await handleNotificationRedirection(context, initialMsg.data);
        }
        await _refreshUnreadBadge();
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
      }
    }

    // Rafraîchir le badge une première fois
    await _refreshUnreadBadge();
  } catch (e) {
    debugPrint('--- [DEBUG] CRITICAL ERROR in initPushNotifications: $e');
  }
  debugPrint('--- [DEBUG] initPushNotifications: END');
}
