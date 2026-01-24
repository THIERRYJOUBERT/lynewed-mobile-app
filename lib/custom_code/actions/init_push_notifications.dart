// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Fichier : /custom_code/actions/init_push_notifications.dart
// VERSION 2.1 - Avec overlay d'appel entrant via Realtime + FCM

import 'dart:async';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '/custom_code/push_background.dart';
import '/custom_code/firebase_options.dart';
import '/custom_code/actions/handle_notification_redirection.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/utils/secure_logger.dart';
import '/core/services/app_badge_service.dart';
import '/core/services/incoming_call_service.dart';
// Pour appNavigatorKey

StreamSubscription<AuthState>? _authStateSubscription;
RealtimeChannel? _videoSessionsChannel;

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

    // Check current permission status WITHOUT requesting
    // Permission will be requested during onboarding (step 5)
    final currentSettings = await FirebaseMessaging.instance.getNotificationSettings();
    SecureLogger.debug('FCM current permission status: ${currentSettings.authorizationStatus}');
    
    // Only configure foreground presentation if permission is already granted
    // This avoids triggering the permission popup on app startup
    if (currentSettings.authorizationStatus == AuthorizationStatus.authorized ||
        currentSettings.authorizationStatus == AuthorizationStatus.provisional) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } else {
      SecureLogger.info('FCM permission not yet granted, will be requested during onboarding');
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
        FFAppState().unreadNotificationsCount = count;
        FFAppState().hasUnreadNotifications = count > 0;
        // Sync iOS app icon badge
        await AppBadgeService.instance.updateBadge();
      } catch (e) {
        SecureLogger.error('Badge refresh error', error: e);
      }
    }

    // Configurer les callbacks du service d'appel entrant
    _setupIncomingCallService();

    // ✅ REALTIME: Écouter les nouvelles video_sessions pour afficher l'overlay
    // Ceci fonctionne même sur simulateur (pas besoin de FCM push)
    _setupVideoSessionsRealtimeListener();

    // Écouteur pour les messages reçus quand l'app est OUVERTE (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      SecureLogger.debugSanitized(
        'onMessage (Foreground) received',
        sensitiveKeys: ['token', 'session_id', 'user_id', 'video_session_id']
      );
      final data = message.data;
      final type = data['type'] as String?;
      
      // Pour les appels vidéo en foreground, afficher l'overlay
      if (type == 'videoIncoming') {
        SecureLogger.info('Incoming video call in foreground - showing overlay');
        _showIncomingCallOverlay(data);
      } else {
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

/// Configure les callbacks du service d'appel entrant
void _setupIncomingCallService() {
  final callService = IncomingCallService.instance;

  // Callback quand l'utilisateur accepte l'appel
  callService.onAccept = (call) async {
    SecureLogger.info('User accepted incoming call');
    
    final navContext = appNavigatorKey.currentContext;
    if (navContext != null && navContext.mounted) {
      final data = {
        'type': 'videoIncoming',
        'video_session_id': call.videoSessionId,
        'agora_channel_name': call.channelName,
        'sender_profile_id': call.callerProfileId,
      };
      await handleNotificationRedirection(navContext, data);
    }
  };

  // Callback quand l'utilisateur decline l'appel
  callService.onDecline = (call) async {
    SecureLogger.info('User declined incoming call - session: ${call.videoSessionId}');
    
    try {
      // Utiliser 'declined' pour être explicite (l'enum supporte cette valeur)
      final response = await SupaFlow.client
          .from('video_sessions')
          .update({'status': 'declined'})
          .eq('id', call.videoSessionId)
          .select();
      SecureLogger.info('Video session marked as declined: $response');
    } catch (e) {
      SecureLogger.error('Failed to update video session status', error: e);
    }
  };

  // Callback quand l'appel expire (timeout 30s)
  callService.onTimeout = (call) async {
    SecureLogger.info('Incoming call timed out');
    
    try {
      final resp = await SupaFlow.client.rpc('get_unread_notifications_count');
      final count = resp as int? ?? 0;
      FFAppState().unreadNotificationsCount = count;
      FFAppState().hasUnreadNotifications = count > 0;
      await AppBadgeService.instance.updateBadge();
    } catch (e) {
      SecureLogger.error('Failed to update badge after missed call', error: e);
    }
  };
}

/// Affiche l'overlay d'appel entrant en foreground
void _showIncomingCallOverlay(Map<String, dynamic> data) {
  final callData = IncomingCallData.fromFcmPayload(data);
  
  if (callData.videoSessionId.isEmpty || callData.channelName.isEmpty) {
    SecureLogger.error('Invalid incoming call data - missing session or channel');
    return;
  }

  // Utilise le ValueNotifier - pas besoin de context!
  IncomingCallService.instance.showIncomingCall(callData);
}

/// Configure le listener Supabase Realtime pour les appels vidéo entrants
/// Ceci permet d'afficher l'overlay même sur simulateur (sans FCM push)
void _setupVideoSessionsRealtimeListener() {
  // Annuler l'ancien channel si existant
  _videoSessionsChannel?.unsubscribe();
  
  if (!loggedIn || currentUserUid.isEmpty) {
    SecureLogger.debug('Not logged in, skipping video sessions realtime listener');
    return;
  }

  final userId = currentUserUid;
  SecureLogger.info('Setting up video_sessions realtime listener for user: $userId');

  // Écouter TOUS les INSERT sur video_sessions et filtrer côté client
  // IMPORTANT: Utiliser la syntaxe cascade (..) comme dans chat_message_list.dart
  _videoSessionsChannel = SupaFlow.client
      .channel('video_sessions_incoming_$userId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'video_sessions',
        callback: (payload) async {
          SecureLogger.info('Realtime: video_sessions INSERT detected');
          
          final newRecord = payload.newRecord;
          if (newRecord.isEmpty) {
            SecureLogger.warning('Realtime: Empty payload received');
            return;
          }

          // Filtrer côté client: seulement les sessions où je suis le receiver
          final receiverId = newRecord['receiver_id'] as String?;
          if (receiverId != userId) {
            SecureLogger.debug('Realtime: Session not for current user, ignoring');
            return;
          }

          final status = newRecord['status'] as String?;
          if (status != 'pending') {
            SecureLogger.debug('Realtime: Session status is $status, ignoring');
            return;
          }

          SecureLogger.info('Realtime: Incoming call detected for current user!');

          // Récupérer les infos de l'appelant
          final initiatorId = newRecord['initiator_id'] as String?;
          final sessionId = newRecord['id'] as String?;
          final channelName = newRecord['agora_channel_name'] as String?;

          if (initiatorId == null || sessionId == null || channelName == null) {
            SecureLogger.error('Realtime: Missing required fields in payload');
            return;
          }

          // Récupérer le profil de l'appelant
          try {
            final initiatorProfile = await SupaFlow.client
                .from('profiles')
                .select('full_name, avatar_url')
                .eq('id', initiatorId)
                .maybeSingle();

            final callerName = initiatorProfile?['full_name'] as String? ?? 'Unknown';
            final callerAvatar = initiatorProfile?['avatar_url'] as String?;

            // Construire les données pour l'overlay
            final callData = IncomingCallData(
              videoSessionId: sessionId,
              channelName: channelName,
              callerProfileId: initiatorId,
              callerName: callerName,
              callerAvatarUrl: callerAvatar,
            );

            // Afficher l'overlay - utilise ValueNotifier, pas besoin de context!
            SecureLogger.info('Showing incoming call overlay from Realtime');
            IncomingCallService.instance.showIncomingCall(callData);
          } catch (e) {
            SecureLogger.error('Failed to fetch initiator profile', error: e);
          }
        },
      )
      ..subscribe((status, error) {
        SecureLogger.info('Realtime channel status: $status');
        if (error != null) {
          SecureLogger.error('Realtime channel error', error: error);
        }
      });

  SecureLogger.debug('Video sessions realtime channel subscription initiated');
}
