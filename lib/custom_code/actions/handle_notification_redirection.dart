// Automatic FlutterFlow imports
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
import '/utils/secure_logger.dart';
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import '/backend/supabase/supabase.dart';
import '/backend/schema/structs/index.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart' show ProDetailsWidget;
import '/features/weddings_hub_pro/presentation/pages/weddings_hub_pro_page.dart';
import '/features/my_wedding/presentation/pages/my_wedding_page.dart';

// ignore_for_file: use_build_context_synchronously

Future<void> handleNotificationRedirection(
  BuildContext context,
  dynamic data,
) async {
  SecureLogger.functionStart('handleNotificationRedirection');
  
  if (data is! Map<String, dynamic>) {
    SecureLogger.warning('Notification redirection data is not a Map');
    return;
  }

  final type = data['type'] as String?;
  SecureLogger.info('Notification type: $type');
  
  if (type == null) {
    SecureLogger.warning('Notification redirection missing "type" field');
    return;
  }

  // Marquer la notification comme lue si notification_id est présent
  final notificationId = data['notification_id'] as String?;
  if (notificationId != null && notificationId.isNotEmpty) {
    try {
      await actions.markNotificationAsRead(notificationId);
      SecureLogger.debug('Notification marked as read: $notificationId');
    } catch (e) {
      SecureLogger.error('Failed to mark notification as read', error: e);
    }
  }

  if (!context.mounted) return;
  final router = GoRouter.of(context);
  final userRole = FFAppState().currentUserRole;
  SecureLogger.debugSanitized(
    'Processing notification redirection',
    sensitiveKeys: ['token', 'session_id', 'video_session_id', 'agora_channel_name', 'room_id', 'user_id']
  );

  switch (type) {
    case 'videoIncoming':
      {
        SecureLogger.info('🎥 videoIncoming case triggered!');
        
        // ⚠️ Logique robuste:
        // 1) Si un video_session_id est fourni dans le payload, tenter d'ouvrir CETTE session en priorité
        // 2) Sinon (ou si non valide), récupérer la dernière session récente du receveur
        try {
          final client = SupaFlow.client;
          final currentUserId = client.auth.currentUser?.id;
          
          if (currentUserId == null) {
            SecureLogger.error('User not authenticated');
            return;
          }
          // 1) Tentative par video_session_id exact (si présent dans le payload)
          String? selectedSessionId;
          String? selectedChannelName;
          String? selectedStatus;

          final requestedSessionId = (data['video_session_id'] as String?)?.trim();
          if (requestedSessionId != null && requestedSessionId.isNotEmpty) {
            SecureLogger.info('Trying requested session from payload: $requestedSessionId');
            final exact = await client
                .from('video_sessions')
                .select('id, agora_channel_name, status, created_at, receiver_id')
                .eq('id', requestedSessionId)
                .maybeSingle();

            if (exact != null) {
              // Vérifier que c'est bien pour l'utilisateur courant
              final receiverId = (exact['receiver_id'] as String?) ?? '';
              if (receiverId == currentUserId) {
                final createdAtStr = exact['created_at'] as String?;
                DateTime? createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
                final ageOk = createdAt == null
                    ? true
                    : DateTime.now().toUtc().difference(createdAt.toUtc()).inMinutes <= 5;

                final status = (exact['status'] as String?) ?? 'pending';
                if (ageOk && status != 'completed') {
                  selectedSessionId = exact['id'] as String?;
                  selectedChannelName = exact['agora_channel_name'] as String?;
                  selectedStatus = status;
                  SecureLogger.info('Using requested session: id=$selectedSessionId, status=$selectedStatus');
                } else {
                  SecureLogger.warning('Requested session not recent or already completed');
                }
              } else {
                SecureLogger.warning('Requested session does not belong to current receiver');
              }
            } else {
              SecureLogger.warning('Requested session not found');
            }
          }

          // 2) Fallback: dernière session du receveur (pending/accepted/missed), sans filtre de temps fragile
          if (selectedSessionId == null || selectedChannelName == null) {
            final fallback = await client
                .from('video_sessions')
                .select('id, agora_channel_name, status, created_at')
                .eq('receiver_id', currentUserId)
                .inFilter('status', ['pending', 'accepted', 'missed'])
                .order('created_at', ascending: false)
                .limit(1)
                .maybeSingle();

            if (fallback == null) {
              SecureLogger.warning('No active video session found (fallback)');
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Call expired or already ended'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }

            selectedSessionId = fallback['id'] as String?;
            selectedChannelName = fallback['agora_channel_name'] as String?;
            selectedStatus = fallback['status'] as String?;
            SecureLogger.info('Using fallback session: id=$selectedSessionId, status=$selectedStatus, channel=$selectedChannelName');
          }

          final sessionId = selectedSessionId!;
          final channelName = selectedChannelName!;
          final currentStatus = selectedStatus ?? 'pending';
          SecureLogger.info('Final session selected: $sessionId, status: $currentStatus, channel: $channelName');
          
          // Vérifier que la session n'est pas déjà "completed" (initiateur a raccroché)
          if (currentStatus == 'completed') {
            SecureLogger.warning('Session already completed by initiator');
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Call already ended by the other person'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          await actions.updateVideoSessionStatusAction(
            sessionId,
            VideoSessionStatus.accepted,
          );

          final token =
              await actions.getAgoraTokenAction(channelName, currentUserUid);

          if (token == null || token.isEmpty) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Unable to join the call. Please try again.',
                  style:
                      TextStyle(color: FlutterFlowTheme.of(context).primaryText),
                ),
                backgroundColor: FlutterFlowTheme.of(context).error,
              ),
            );
            return;
          }

          router.goNamed(
            'VideoCallPage',
            queryParameters: {
              'videoSessionId': serializeParam(
                sessionId,
                ParamType.String,
              ),
              'channelName': serializeParam(
                channelName,
                ParamType.String,
              ),
              'agoraToken': serializeParam(
                token,
                ParamType.String,
              ),
              'isInitiator': serializeParam(
                false,
                ParamType.bool,
              ),
            }.withoutNulls,
          );
        } catch (e) {
          SecureLogger.error('Error joining video call', error: e);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error joining call: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        break;
      }

    case 'chatMessage':
      {
        // chatMessage: Ouvrir la conversation directement
        final roomId = (data['room_id'] as String?) ?? '';
        final senderProfileId = (data['sender_profile_id'] as String?) ?? '';
        
        if (roomId.isNotEmpty) {
          SecureLogger.info('💬 chatMessage: Opening ChatDetailsPage with room_id=$roomId, sender=$senderProfileId');
          
          // Récupérer les infos du sender pour afficher dans le header
          String? senderFullName;
          String? senderAvatarUrl;
          
          if (senderProfileId.isNotEmpty) {
            try {
              final senderProfile = await Supabase.instance.client
                  .from('profiles')
                  .select('full_name, avatar_url')
                  .eq('id', senderProfileId)
                  .maybeSingle();
              
              if (senderProfile != null) {
                senderFullName = senderProfile['full_name'] as String?;
                senderAvatarUrl = senderProfile['avatar_url'] as String?;
                SecureLogger.info('💬 chatMessage: Sender info loaded: $senderFullName');
              }
            } catch (e) {
              SecureLogger.warning('chatMessage: Failed to load sender info: $e');
            }
          }
          
          // Marquer toutes les notifications non lues pour cette room comme lues
          await _markRoomNotificationsAsRead(roomId);
          
          router.pushNamed(
            'ChatDetailsPage',
            queryParameters: {
              'roomId': roomId,
              'otherProfileId': senderProfileId,
              if (senderFullName != null) 'otherFullName': senderFullName,
              if (senderAvatarUrl != null) 'otherAvatarUrl': senderAvatarUrl,
            },
            extra: <String, dynamic>{
              kTransitionInfoKey: const TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 0),
              ),
            },
          );
        } else {
          SecureLogger.warning('chatMessage: No room_id, falling back to Messages page');
          if (userRole == UserRole.professional) {
            router.pushNamed('MessagesProWidget');
          } else {
            router.pushNamed('MessagesBridesWidget');
          }
        }
        break;
      }

    case 'connectionRequest':
      {
        // connectionRequest: Pour les Brides - ouvrir ChatDetailsPage en mode demande de contact
        final requestId = (data['request_id'] as String?) ?? '';
        final senderProfileId = (data['sender_profile_id'] as String?) ?? '';
        SecureLogger.info('📩 connectionRequest: request_id=$requestId, sender=$senderProfileId');
        
        if (requestId.isEmpty) {
          SecureLogger.warning('connectionRequest: No request_id, falling back to Messages page');
          if (userRole == UserRole.professional) {
            router.pushNamed('MessagesProWidget');
          } else {
            router.pushNamed('MessagesBridesWidget');
          }
          break;
        }
        
        try {
          // Récupérer les détails de la demande et du Pro
          final requestData = await SupaFlow.client
              .from('connection_requests')
              .select('id, initial_message, pro_profile_id, status')
              .eq('id', requestId)
              .maybeSingle();
          
          if (requestData == null || requestData['status'] != 'pending') {
            SecureLogger.warning('connectionRequest: Request not found or not pending');
            if (userRole == UserRole.professional) {
              router.pushNamed('MessagesProWidget');
            } else {
              router.pushNamed('MessagesBridesWidget');
            }
            break;
          }
          
          final proProfileId = requestData['pro_profile_id'] as String?;
          final initialMessage = requestData['initial_message'] as String?;
          
          // Récupérer les infos du Pro
          String? proFullName;
          String? proAvatarUrl;
          if (proProfileId != null) {
            final proData = await SupaFlow.client
                .from('profiles')
                .select('full_name, avatar_url')
                .eq('id', proProfileId)
                .maybeSingle();
            proFullName = proData?['full_name'] as String?;
            proAvatarUrl = proData?['avatar_url'] as String?;
          }
          
          if (!context.mounted) return;
          
          // Naviguer vers ChatDetailsPage en mode demande de contact
          // roomId vide car pas encore de room, pendingRequestId pour le mode review
          router.pushNamed(
            'ChatDetailsPage',
            queryParameters: {
              'roomId': '', // Pas de room encore
              'pendingRequestId': requestId,
              'viewerIsReviewer': 'true',
              'otherProfileId': proProfileId ?? '',
              'otherFullName': proFullName ?? '',
              'otherAvatarUrl': proAvatarUrl ?? '',
            },
            extra: <String, dynamic>{
              'initialMessage': initialMessage,
              kTransitionInfoKey: const TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 0),
              ),
            },
          );
        } catch (e) {
          SecureLogger.error('connectionRequest: Error fetching request details', error: e);
          if (userRole == UserRole.professional) {
            router.pushNamed('MessagesProWidget');
          } else {
            router.pushNamed('MessagesBridesWidget');
          }
        }
        break;
      }

    case 'connectionRequestAccepted':
      {
        // connectionRequestAccepted: Pour les Pros - ouvrir la conversation si room_id disponible
        final roomId = (data['room_id'] as String?) ?? '';
        // Le payload contient sender_profile_id (la Bride qui a accepté)
        final senderProfileId = (data['sender_profile_id'] as String?) ?? '';
        SecureLogger.info('✅ connectionRequestAccepted: room_id=$roomId, sender=$senderProfileId');
        
        if (roomId.isNotEmpty) {
          // Récupérer les infos de la personne qui a accepté (Bride)
          String? senderFullName;
          String? senderAvatarUrl;
          
          if (senderProfileId.isNotEmpty) {
            try {
              final senderProfile = await Supabase.instance.client
                  .from('profiles')
                  .select('full_name, avatar_url')
                  .eq('id', senderProfileId)
                  .maybeSingle();
              
              if (senderProfile != null) {
                senderFullName = senderProfile['full_name'] as String?;
                senderAvatarUrl = senderProfile['avatar_url'] as String?;
                SecureLogger.info('✅ connectionRequestAccepted: Sender info loaded: $senderFullName');
              }
            } catch (e) {
              SecureLogger.warning('connectionRequestAccepted: Failed to load sender info: $e');
            }
          }
          
          // Marquer toutes les notifications non lues pour cette room comme lues
          await _markRoomNotificationsAsRead(roomId);
          
          router.pushNamed(
            'ChatDetailsPage',
            queryParameters: {
              'roomId': roomId,
              'otherProfileId': senderProfileId,
              if (senderFullName != null) 'otherFullName': senderFullName,
              if (senderAvatarUrl != null) 'otherAvatarUrl': senderAvatarUrl,
            },
            extra: <String, dynamic>{
              kTransitionInfoKey: const TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 0),
              ),
            },
          );
        } else {
          // Fallback vers la page Messages
          if (userRole == UserRole.professional) {
            router.pushNamed('MessagesProWidget');
          } else {
            router.pushNamed('MessagesBridesWidget');
          }
        }
        break;
      }

    case 'wishlistAdd':
      {
        // wishlistAdd: Pour les Pros Ultimate - aller vers le Dashboard Pro
        // Le bride_profile_id est dans le payload pour référence future (afficher la bride qui a ajouté)
        final brideProfileId = (data['bride_profile_id'] as String?) ?? '';
        SecureLogger.info('💖 wishlistAdd: bride_profile_id=$brideProfileId');
        
        // Naviguer vers le Dashboard Pro où la wishlist est visible
        router.pushNamed('DashboardPro');
        break;
      }

    case 'wedPublished':
      {
        // wedPublished: Nouveau Wedding of the Week - ouvrir la page dédiée
        final link = (data['link'] as String?) ?? '';
        final referenceId = (data['reference_id'] as String?) ?? '';
        SecureLogger.info('💒 wedPublished: reference_id=$referenceId, link=$link');
        
        // Naviguer vers la page Wedding of the Week
        router.pushNamed('WeddingOfTheWeek');
        break;
      }

    case 'replayPublished':
      {
        // replayPublished: Nouveau Replay disponible - ouvrir la page Replays
        final link = (data['link'] as String?) ?? '';
        final referenceId = (data['reference_id'] as String?) ?? '';
        SecureLogger.info('🎬 replayPublished: reference_id=$referenceId, link=$link');
        
        // Naviguer vers la page des Replays
        router.pushNamed('ContentReplay');
        break;
      }

    // connectionRequestDeclined: SUPPRIMÉ - Le backend ne notifie plus les refus
    // professionalAlert: CODE MORT - Jamais déclenché
    // professionalAlertReminder24h: CODE MORT - Jamais déclenché
    // weddingPinMatch: CODE MORT - Concept obsolète

    // === WEDDING EVENTS (Sprint 3.1) ===
    case 'weddingProAdded':
      {
        // Pro reçoit une notification qu'il a été ajouté à un mariage
        // Naviguer vers Weddings Hub Pro (la page de détail n'est pas accessible par route)
        final weddingId = (data['wedding_id'] as String?) ?? '';
        SecureLogger.info('💒 weddingProAdded: wedding_id=$weddingId');
        
        // Naviguer vers Weddings Hub + ouvrir automatiquement le bon mariage
        router.pushNamed(
          WeddingsHubProPage.routeName,
          queryParameters: {
            if (weddingId.isNotEmpty) 'weddingId': weddingId,
          },
        );
        break;
      }

    case 'weddingProExcluded':
      {
        // Pro reçoit une notification qu'il a été exclu d'un mariage
        // Pas d'action nécessaire, juste informer - naviguer vers Weddings Hub
        final weddingId = (data['wedding_id'] as String?) ?? '';
        SecureLogger.info('💒 weddingProExcluded: wedding_id=$weddingId');
        
        router.pushNamed(WeddingsHubProPage.routeName);
        break;
      }

    case 'weddingProLeft':
      {
        // Bride reçoit une notification qu'un pro a quitté son mariage
        // Naviguer vers ProDetails pour voir le profil du pro qui est parti
        final weddingId = (data['wedding_id'] as String?) ?? '';
        final proProfileId = (data['pro_profile_id'] as String?) ?? '';
        SecureLogger.info('💒 weddingProLeft: wedding_id=$weddingId, pro_profile_id=$proProfileId');
        
        if (proProfileId.isNotEmpty) {
          // Récupérer les infos du pro pour naviguer vers ProDetails
          try {
            final proData = await SupaFlow.client
                .from('profiles')
                .select('id, full_name, avatar_url, user_role')
                .eq('id', proProfileId)
                .maybeSingle();
            
            if (proData != null && context.mounted) {
              // Construire ProDetailsStruct minimal pour la navigation
              final proDetails = ProDetailsStruct(
                proProfileId: proData['id'] as String?,
                fullName: proData['full_name'] as String?,
                avatarUrl: proData['avatar_url'] as String?,
              );
              
              router.pushNamed(
                ProDetailsWidget.routeName,
                queryParameters: {
                  'proDetails': serializeParam(proDetails, ParamType.DataStruct),
                }.withoutNulls,
              );
              break;
            }
          } catch (e) {
            SecureLogger.error('weddingProLeft: Failed to load pro details', error: e);
          }
        }
        
        // Fallback: naviguer vers My Wedding page
        router.pushNamed(MyWeddingPage.routeName);
        break;
      }

    case 'weddingCancelled':
      {
        // Pro reçoit une notification qu'un mariage a été annulé
        // Naviguer vers Weddings Hub Pro
        final weddingId = (data['wedding_id'] as String?) ?? '';
        SecureLogger.info('💒 weddingCancelled: wedding_id=$weddingId');
        
        router.pushNamed(WeddingsHubProPage.routeName);
        break;
      }

    case 'broadcast':
      {
        // Broadcast générique depuis Admin Panel - utiliser le deep link
        // Pour les annonces qui ne sont pas wedPublished ou replayPublished
        final link = (data['link'] as String?) ?? '';
        SecureLogger.info('📢 broadcast: link=$link');
        
        if (link.isNotEmpty) {
          if (!context.mounted) return;
          _handleDeepLink(context, router, link, userRole);
        } else {
          // Fallback vers home si pas de deep link
          if (userRole == UserRole.professional) {
            router.pushNamed('DashboardProWidget');
          } else {
            router.pushNamed('HomeBridesWidget');
          }
        }
        break;
      }

    default:
      {
        SecureLogger.warning('Unknown notification type: $type');
        // Fallback vers la page d'accueil appropriée
        if (userRole == UserRole.professional) {
          router.pushNamed('DashboardProWidget');
        } else {
          router.pushNamed('HomeBridesWidget');
        }
        break;
      }
  }
}

/// Gère les deep links au format lynewed://[page]
/// Utilisé par les notifications broadcast de l'Admin Panel
/// Marque toutes les notifications non lues pour une room comme lues
Future<void> _markRoomNotificationsAsRead(String roomId) async {
  try {
    final client = SupaFlow.client;
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null) return;
    
    // Récupérer les notifications non lues pour cette room
    final notifications = await client
        .from('notifications')
        .select('id')
        .eq('profile_id', currentUserId)
        .eq('is_read', false)
        .or('payload->>room_id.eq.$roomId,payload->>message_room_id.eq.$roomId');
    
    if ((notifications as List).isEmpty) return;
    
    // Marquer chaque notification comme lue
    for (final notif in notifications) {
      final notifId = notif['id'] as String?;
      if (notifId != null) {
        await actions.markNotificationAsRead(notifId);
      }
    }
    
    SecureLogger.debug('Marked ${notifications.length} room notifications as read for room: $roomId');
  } catch (e) {
    SecureLogger.error('Failed to mark room notifications as read', error: e);
  }
}

void _handleDeepLink(
  BuildContext context,
  GoRouter router,
  String link,
  UserRole? userRole,
) {
  final uri = Uri.tryParse(link);
  if (uri == null || uri.scheme != 'lynewed') {
    SecureLogger.warning('Invalid deep link format: $link');
    return;
  }
  
  final page = uri.host.toLowerCase();
  SecureLogger.info('🔗 Deep link page: $page');
  
  // Mapping des deep links vers les routes Flutter
  // Définis dans l'Admin Panel (voir GUIDE_EQUIPE_APP_MOBILE.md)
  switch (page) {
    case 'home':
      if (userRole == UserRole.professional) {
        router.pushNamed('DashboardProWidget');
      } else {
        router.pushNamed('HomeBridesWidget');
      }
      break;
    case 'wedding':
      router.pushNamed('WeddingOfTheWeekWidget');
      break;
    case 'replays':
      router.pushNamed('ContentReplayWidget');
      break;
    case 'feed':
      router.pushNamed('FeedBridesWidget');
      break;
    case 'profile':
      router.pushNamed('ProfileBridesAndProWidget');
      break;
    case 'settings':
      router.pushNamed('PreferenceWidget');
      break;
    case 'chat':
      if (userRole == UserRole.professional) {
        router.pushNamed('MessagesProWidget');
      } else {
        router.pushNamed('MessagesBridesWidget');
      }
      break;
    case 'notifications':
      router.pushNamed('NotificationsPage');
      break;
    default:
      SecureLogger.warning('Unknown deep link page: $page');
      if (userRole == UserRole.professional) {
        router.pushNamed('DashboardProWidget');
      } else {
        router.pushNamed('HomeBridesWidget');
      }
  }
}
