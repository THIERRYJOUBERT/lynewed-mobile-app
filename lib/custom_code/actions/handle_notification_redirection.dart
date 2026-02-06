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
import '/features/marketplace/presentation/pages/buyer_transaction_page.dart';
import '/features/marketplace/presentation/pages/listing_detail_page.dart';
import '/features/marketplace/presentation/pages/marketplace_chat_page.dart';
import '/features/marketplace/presentation/pages/received_offers_page.dart';
import '/features/marketplace/presentation/pages/transaction_detail_page.dart';

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

  // Mark the notification as read if notification_id is present
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
        
        // Robust logic:
        // 1) If a video_session_id is provided in the payload, try to open THAT session first
        // 2) Otherwise (or if not valid), fetch the most recent session for the receiver
        try {
          final client = SupaFlow.client;
          final currentUserId = client.auth.currentUser?.id;
          
          if (currentUserId == null) {
            SecureLogger.error('User not authenticated');
            return;
          }
          // 1) Attempt by exact video_session_id (if present in the payload)
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
              // Verify the session belongs to the current user
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

          // 2) Fallback: latest session for the receiver (pending/accepted/missed), without fragile time filter
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
          
          // Verify the session is not already "completed" (initiator hung up)
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
        // chatMessage: Open the conversation directly
        final roomId = (data['room_id'] as String?) ?? '';
        final senderProfileId = (data['sender_profile_id'] as String?) ?? '';
        
        if (roomId.isNotEmpty) {
          SecureLogger.info('💬 chatMessage: Opening ChatDetailsPage with room_id=$roomId, sender=$senderProfileId');
          
          // Fetch sender info for the header display
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

          // Mark all unread notifications for this room as read
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
            router.pushNamed('MessagesPro');
          } else {
            router.pushNamed('MessagesBrides');
          }
        }
        break;
      }

    case 'connectionRequest':
      {
        // connectionRequest: For Brides - open ChatDetailsPage in contact request review mode
        final requestId = (data['request_id'] as String?) ?? '';
        final senderProfileId = (data['sender_profile_id'] as String?) ?? '';
        SecureLogger.info('📩 connectionRequest: request_id=$requestId, sender=$senderProfileId');
        
        if (requestId.isEmpty) {
          SecureLogger.warning('connectionRequest: No request_id, falling back to Messages page');
          if (userRole == UserRole.professional) {
            router.pushNamed('MessagesPro');
          } else {
            router.pushNamed('MessagesBrides');
          }
          break;
        }
        
        try {
          // Fetch request details and Pro info
          final requestData = await SupaFlow.client
              .from('connection_requests')
              .select('id, initial_message, pro_profile_id, status')
              .eq('id', requestId)
              .maybeSingle();
          
          if (requestData == null || requestData['status'] != 'pending') {
            SecureLogger.warning('connectionRequest: Request not found or not pending');
            if (userRole == UserRole.professional) {
              router.pushNamed('MessagesPro');
            } else {
              router.pushNamed('MessagesBrides');
            }
            break;
          }
          
          final proProfileId = requestData['pro_profile_id'] as String?;
          final initialMessage = requestData['initial_message'] as String?;
          
          // Fetch Pro profile info
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
          
          // Navigate to ChatDetailsPage in contact request review mode
          // Empty roomId since no room exists yet, pendingRequestId enables review mode
          router.pushNamed(
            'ChatDetailsPage',
            queryParameters: {
              'roomId': '', // No room yet
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
            router.pushNamed('MessagesPro');
          } else {
            router.pushNamed('MessagesBrides');
          }
        }
        break;
      }

    case 'connectionRequestAccepted':
      {
        // connectionRequestAccepted: For Pros - open conversation if room_id is available
        final roomId = (data['room_id'] as String?) ?? '';
        // Payload contains sender_profile_id (the Bride who accepted)
        final senderProfileId = (data['sender_profile_id'] as String?) ?? '';
        SecureLogger.info('✅ connectionRequestAccepted: room_id=$roomId, sender=$senderProfileId');
        
        if (roomId.isNotEmpty) {
          // Fetch info about the person who accepted (Bride)
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

          // Mark all unread notifications for this room as read
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
          // Fallback to Messages page
          if (userRole == UserRole.professional) {
            router.pushNamed('MessagesPro');
          } else {
            router.pushNamed('MessagesBrides');
          }
        }
        break;
      }

    case 'wishlistAdd':
      {
        // wishlistAdd: For Ultimate Pros - navigate to Pro Dashboard
        // bride_profile_id is in payload for future reference (display the bride who added)
        final brideProfileId = (data['bride_profile_id'] as String?) ?? '';
        SecureLogger.info('💖 wishlistAdd: bride_profile_id=$brideProfileId');
        
        // Navigate to Pro Dashboard where the wishlist is visible
        router.pushNamed('DashboardPro');
        break;
      }

    case 'wedPublished':
      {
        // wedPublished: New Wedding of the Week - open the dedicated page
        final link = (data['link'] as String?) ?? '';
        final referenceId = (data['reference_id'] as String?) ?? '';
        SecureLogger.info('💒 wedPublished: reference_id=$referenceId, link=$link');
        
        // Navigate to the Wedding of the Week page
        router.pushNamed('WeddingOfTheWeek');
        break;
      }

    case 'replayPublished':
      {
        // replayPublished: New Replay available - open the Replays page
        final link = (data['link'] as String?) ?? '';
        final referenceId = (data['reference_id'] as String?) ?? '';
        SecureLogger.info('🎬 replayPublished: reference_id=$referenceId, link=$link');
        
        // Navigate to the Replays page
        router.pushNamed('ContentReplay');
        break;
      }

    // === MARKETPLACE NOTIFICATIONS (EPIC-14) ===
    case 'marketplaceNewOffer':
      {
        final listingId = data['listing_id'] as String?;
        if (listingId != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ReceivedOffersPage(listingId: listingId),
            ),
          );
        }
      }
      break;

    case 'marketplaceOfferAccepted':
    case 'marketplaceOfferRejected':
    case 'marketplaceOfferExpired':
      {
        final listingId = data['listing_id'] as String?;
        if (listingId != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ListingDetailPage(listingId: listingId),
            ),
          );
        }
      }
      break;

    case 'marketplaceOfferWithdrawn':
      {
        final listingId = data['listing_id'] as String?;
        if (listingId != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ReceivedOffersPage(listingId: listingId),
            ),
          );
        }
      }
      break;

    case 'marketplaceItemSold':
    case 'marketplacePaymentSucceeded':
      {
        final transactionId = data['transaction_id'] as String?;
        if (transactionId != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => TransactionDetailPage(
                transactionId: transactionId,
              ),
            ),
          );
        }
      }
      break;

    case 'marketplaceOrderConfirmed':
    case 'marketplaceLabelReady':
    case 'marketplaceTrackingUpdate':
    case 'marketplaceTransactionComplete':
      {
        final transactionId = data['transaction_id'] as String?;
        if (transactionId != null && context.mounted) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BuyerTransactionPage(
                transactionId: transactionId,
              ),
            ),
          );
        }
      }
      break;

    case 'marketplaceNewMessage':
      {
        final listingId = (data['listing_id'] as String?) ?? '';
        final senderId = (data['sender_profile_id'] as String?) ?? '';

        if (listingId.isNotEmpty && senderId.isNotEmpty) {
          SecureLogger.info('💬 marketplaceNewMessage: listing=$listingId, sender=$senderId');

          // Fetch sender info + listing title for display
          String? senderName;
          String? senderAvatar;
          String? listingTitle;

          try {
            final senderProfile = await Supabase.instance.client
                .from('profiles')
                .select('full_name, avatar_url')
                .eq('id', senderId)
                .maybeSingle();
            senderName = senderProfile?['full_name'] as String?;
            senderAvatar = senderProfile?['avatar_url'] as String?;

            final listing = await Supabase.instance.client
                .from('marketplace_listings')
                .select('title')
                .eq('id', listingId)
                .maybeSingle();
            listingTitle = listing?['title'] as String?;
          } catch (e) {
            SecureLogger.warning('marketplaceNewMessage: Failed to load context: $e');
          }

          if (!context.mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MarketplaceChatPage(
                listingId: listingId,
                otherUserId: senderId,
                listingTitle: listingTitle,
                otherUserName: senderName,
                otherUserAvatarUrl: senderAvatar,
              ),
            ),
          );
        }
        break;
      }

    // connectionRequestDeclined: REMOVED - Backend no longer notifies on rejections
    // professionalAlert: DEAD CODE - Never triggered
    // professionalAlertReminder24h: DEAD CODE - Never triggered
    // weddingPinMatch: DEAD CODE - Obsolete concept

    // === WEDDING EVENTS (Sprint 3.1) ===
    case 'weddingProAdded':
      {
        // Pro receives notification they were added to a wedding
        // Navigate to Weddings Hub Pro (detail page is not accessible by route)
        final weddingId = (data['wedding_id'] as String?) ?? '';
        SecureLogger.info('💒 weddingProAdded: wedding_id=$weddingId');
        
        // Navigate to Weddings Hub and auto-open the correct wedding
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
        // Pro receives notification they were excluded from a wedding
        // No action needed, just inform - navigate to Weddings Hub
        final weddingId = (data['wedding_id'] as String?) ?? '';
        SecureLogger.info('💒 weddingProExcluded: wedding_id=$weddingId');
        
        router.pushNamed(WeddingsHubProPage.routeName);
        break;
      }

    case 'weddingProLeft':
      {
        // Bride receives notification that a pro has left their wedding
        // Navigate to ProDetails to view the profile of the pro who left
        final weddingId = (data['wedding_id'] as String?) ?? '';
        final proProfileId = (data['pro_profile_id'] as String?) ?? '';
        SecureLogger.info('💒 weddingProLeft: wedding_id=$weddingId, pro_profile_id=$proProfileId');
        
        if (proProfileId.isNotEmpty) {
          // Fetch pro info to navigate to ProDetails
          try {
            final proData = await SupaFlow.client
                .from('profiles')
                .select('id, full_name, avatar_url, user_role')
                .eq('id', proProfileId)
                .maybeSingle();
            
            if (proData != null && context.mounted) {
              // Build minimal ProDetailsStruct for navigation
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
        
        // Fallback: navigate to My Wedding page
        router.pushNamed(MyWeddingPage.routeName);
        break;
      }

    case 'weddingCancelled':
      {
        // Pro receives notification that a wedding was cancelled
        // Navigate to Weddings Hub Pro
        final weddingId = (data['wedding_id'] as String?) ?? '';
        SecureLogger.info('💒 weddingCancelled: wedding_id=$weddingId');
        
        router.pushNamed(WeddingsHubProPage.routeName);
        break;
      }

    case 'broadcast':
      {
        // Generic broadcast from Admin Panel - use the deep link
        // For announcements that are not wedPublished or replayPublished
        final link = (data['link'] as String?) ?? '';
        SecureLogger.info('📢 broadcast: link=$link');
        
        if (link.isNotEmpty) {
          if (!context.mounted) return;
          _handleDeepLink(context, router, link, userRole);
        } else {
          // Fallback to home if no deep link
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
        // Fallback to the appropriate home page
        if (userRole == UserRole.professional) {
          router.pushNamed('DashboardProWidget');
        } else {
          router.pushNamed('HomeBridesWidget');
        }
        break;
      }
  }
}

/// Handles deep links in the format lynewed://[page]
/// Used by broadcast notifications from the Admin Panel

/// Marks all unread notifications for a room as read
Future<void> _markRoomNotificationsAsRead(String roomId) async {
  try {
    final client = SupaFlow.client;
    final currentUserId = client.auth.currentUser?.id;
    if (currentUserId == null) return;
    
    // Fetch unread notifications for this room
    final notifications = await client
        .from('notifications')
        .select('id')
        .eq('profile_id', currentUserId)
        .eq('is_read', false)
        .or('payload->>room_id.eq.$roomId,payload->>message_room_id.eq.$roomId');
    
    if ((notifications as List).isEmpty) return;
    
    // Mark each notification as read
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
  
  // Deep link to Flutter route mapping
  // Defined in the Admin Panel (see GUIDE_EQUIPE_APP_MOBILE.md)
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
        router.pushNamed('MessagesPro');
      } else {
        router.pushNamed('MessagesBrides');
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
