// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Fichier: custom_code/widgets/agora_video_view.dart
// VERSION FINALE ET STABILISÉE POUR AGORA 5.3.1

import 'package:agora_rtc_engine/rtc_engine.dart' as rtc_engine;
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';

// Logique de contrôle statique pour être appelée depuis les Custom Actions
class _AgoraManager {
  static rtc_engine.RtcEngine? _engine;

  static Future<void> agoraToggleMute(bool isMuted) async =>
      await _engine?.muteLocalAudioStream(isMuted);
  static Future<void> agoraToggleCamera(bool isCameraOff) async =>
      await _engine?.enableLocalVideo(!isCameraOff);
  static Future<void> agoraSwitchCamera() async =>
      await _engine?.switchCamera();
  static Future<void> agoraEndCall() async {
    if (_engine != null) {
      try {
        await _engine!.leaveChannel();
        await _engine!.destroy();
      } catch (e) {
        debugPrint('[AGORA 5.3] Error during agoraEndCall: $e');
      } finally {
        _engine = null;
      }
    }
  }
}

class AgoraVideoView extends StatefulWidget {
  // Exposition des méthodes statiques pour les Custom Actions de FF
  static Future<void> agoraToggleMute(bool isMuted) =>
      _AgoraManager.agoraToggleMute(isMuted);
  static Future<void> agoraToggleCamera(bool isCameraOff) =>
      _AgoraManager.agoraToggleCamera(isCameraOff);
  static Future<void> agoraSwitchCamera() => _AgoraManager.agoraSwitchCamera();
  static Future<void> agoraEndCall() => _AgoraManager.agoraEndCall();

  const AgoraVideoView({
    super.key,
    this.width,
    this.height,
    required this.appId,
    required this.channelName,
    required this.token,
    required this.userId,
    required this.onCallEnd,
  });

  final double? width;
  final double? height;
  final String appId;
  final String channelName;
  final String token;
  final String userId;
  final Future<dynamic> Function() onCallEnd;

  @override
  State<AgoraVideoView> createState() => _AgoraVideoViewState();
}

class _AgoraVideoViewState extends State<AgoraVideoView> {
  int? _remoteUid;
  bool _localUserJoined = false;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  @override
  void dispose() {
    _AgoraManager.agoraEndCall();
    super.dispose();
  }

  Future<void> initAgora() async {
    debugPrint('[AGORA 5.3] Initializing Agora...');
    await [Permission.microphone, Permission.camera].request();

    try {
      // Version recommandée pour 5.3.x : createWithContext
      _AgoraManager._engine = await rtc_engine.RtcEngine.createWithContext(
        rtc_engine.RtcEngineContext(widget.appId),
      );

      // Profil Communication pour les appels 1-1 (plus simple et fiable)
      await _AgoraManager._engine!
          .setChannelProfile(rtc_engine.ChannelProfile.Communication);
      await _AgoraManager._engine!.enableVideo();
      await _AgoraManager._engine!.setDefaultAudioRouteToSpeakerphone(true);

      _AgoraManager._engine!.setEventHandler(
        rtc_engine.RtcEngineEventHandler(
          joinChannelSuccess: (String channel, int uid, int elapsed) {
            debugPrint(
                '[AGORA 5.3] ✅ joinChannelSuccess: channel=$channel, uid=$uid');
            if (mounted) setState(() => _localUserJoined = true);
          },
          userJoined: (int uid, int elapsed) {
            debugPrint('[AGORA 5.3] 🤝 userJoined: remoteUid=$uid');
            if (mounted) setState(() => _remoteUid = uid);
          },
          userOffline: (int uid, rtc_engine.UserOfflineReason reason) {
            debugPrint('[AGORA 5.3] 👋 userOffline: uid=$uid, reason=$reason');
            if (mounted) setState(() => _remoteUid = null);
            widget.onCallEnd();
          },
          error: (rtc_engine.ErrorCode err) {
            debugPrint('[AGORA 5.3] 🛑 onError: code=$err');
            widget.onCallEnd();
          },
        ),
      );

      final localUidInt = widget.userId.hashCode & 0x7FFFFFFF;
      debugPrint(
          '[AGORA 5.3] Joining channel "${widget.channelName}" with uid $localUidInt');

      await _AgoraManager._engine!
          .joinChannel(widget.token, widget.channelName, null, localUidInt);
    } catch (e) {
      debugPrint('[AGORA 5.3] 🛑 CRITICAL in initAgora: $e');
      widget.onCallEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(child: _remoteVideo()),
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 100,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: _localUserJoined
                    ? RtcLocalView.SurfaceView()
                    : Container(
                        color: Colors.black54,
                        child: Center(
                            child: Text('Connecting...',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10)))),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid!,
        channelId: widget.channelName,
      );
    } else {
      return const Text('Waiting for the other person...',
          textAlign: TextAlign.center, style: TextStyle(color: Colors.white));
    }
  }
}
