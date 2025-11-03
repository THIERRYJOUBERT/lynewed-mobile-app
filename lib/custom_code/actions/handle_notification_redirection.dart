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

import '/index.dart';
import '/auth/supabase_auth/auth_util.dart';
import '/custom_code/actions/index.dart' as actions;

Future<void> handleNotificationRedirection(
  BuildContext context,
  dynamic data,
) async {
  if (data is! Map<String, dynamic>) {
    debugPrint('[DEBUG] handleNotificationRedirection: data is not a Map.');
    return;
  }

  final type = data['type'] as String?;
  if (type == null) {
    debugPrint(
        '[DEBUG] handleNotificationRedirection: "type" field is missing in data.');
    return;
  }

  final router = GoRouter.of(context);
  final userRole = FFAppState().currentUserRole;
  debugPrint(
      '--- [DEBUG] Redirecting for type=$type | role=$userRole | data=$data');

  switch (type) {
    case 'videoIncoming':
      {
        final sessionId = data['video_session_id'] as String?;
        final channelName = data['agora_channel_name'] as String?;
        if (sessionId == null || channelName == null) {
          debugPrint(
              '[DEBUG] videoIncoming redirection ERROR: missing session or channel name.');
          return;
        }

        await actions.updateVideoSessionStatusAction(
          sessionId,
          VideoSessionStatus.accepted,
        );

        // --- CORRECTION: On passe currentUserUid (String) directement ---
        final token =
            await actions.getAgoraTokenAction(channelName, currentUserUid);

        if (token == null || token.isEmpty) {
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

        router.pushNamed(
          'VideoCallPage',
          queryParameters: {
            'videoSessionId': sessionId,
            'channelName': channelName,
            'agoraToken': token,
            'isInitiator': 'false',
          },
        );
        break;
      }

    case 'chatMessage':
    case 'connectionRequest':
    case 'connectionRequestAccepted':
    case 'connectionRequestDeclined':
      {
        final roomId = (data['room_id'] as String?) ?? '';
        if (roomId.isNotEmpty) {
          router.pushNamed(
            'ChatDetails',
            queryParameters: {'roomId': roomId},
          );
        } else {
          if (userRole == UserRole.professional) {
            router.pushNamed('MessagesPro');
          } else {
            router.pushNamed('MessagesBrides');
          }
        }
        break;
      }

    default:
      {
        // Logique pour les autres cas
        if (userRole == UserRole.professional) {
          router.pushNamed('DashboardPro');
        } else {
          router.pushNamed('HomeBrides');
        }
        break;
      }
  }
}
