// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Fichier: custom_code/widgets/agora_video_view.dart
// VERSION CORRIGÉE POUR AGORA 5.3.1 - API OFFICIELLE

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';
import '/utils/secure_logger.dart';

// Logique de contrôle statique pour être appelée depuis les Custom Actions
class _AgoraManager {
  static RtcEngine? _engine;

  static Future<void> agoraToggleMute(bool isMuted) async =>
      await _engine?.muteLocalAudioStream(isMuted);
  static Future<void> agoraToggleCamera(bool isCameraOff) async =>
      await _engine?.muteLocalVideoStream(isCameraOff);
  static Future<void> agoraSwitchCamera() async =>
      await _engine?.switchCamera();
  static Future<void> agoraEndCall() async {
    if (_engine != null) {
      try {
        await _engine!.leaveChannel();
        await _engine!.destroy();
        SecureLogger.info('Agora engine destroyed successfully');
      } catch (e) {
        SecureLogger.error('Error during agora end call', error: e);
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
  bool _isInitialized = false;

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
    SecureLogger.functionStart('initAgora', params: {
      'channelName': '***REDACTED***'
    });
    
    // Vérifier les permissions sans les redemander (déjà fait dans chat_details)
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    
    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      SecureLogger.warning('Agora permissions not granted - camera: $cameraStatus, mic: $micStatus');
      if (mounted) widget.onCallEnd();
      return;
    }

    try {
      // ✅ API OFFICIELLE AGORA 5.3.1 - CORRECTION CRITIQUE
      _AgoraManager._engine = await RtcEngine.create(widget.appId);
      
      SecureLogger.info('Agora engine created successfully');
      
      // Configuration pour appels 1-1
      await _AgoraManager._engine!.enableVideo();
      await _AgoraManager._engine!.setChannelProfile(ChannelProfile.Communication);
      await _AgoraManager._engine!.setClientRole(ClientRole.Broadcaster);
      
      // ✅ CORRECTION: T majuscule dans ToSpeakerphone
      await _AgoraManager._engine!.setDefaultAudioRouteToSpeakerphone(true);

      _AgoraManager._engine!.setEventHandler(
        RtcEngineEventHandler(
          joinChannelSuccess: (String channel, int uid, int elapsed) {
            SecureLogger.debugSanitized(
              'Agora join channel success',
              sensitiveKeys: ['channel', 'uid']
            );
            if (mounted) setState(() => _localUserJoined = true);
          },
          userJoined: (int uid, int elapsed) {
            SecureLogger.debugSanitized(
              'Agora remote user joined',
              sensitiveKeys: ['uid']
            );
            if (mounted) setState(() => _remoteUid = uid);
          },
          userOffline: (int uid, UserOfflineReason reason) {
            SecureLogger.debugSanitized(
              'Agora remote user offline',
              sensitiveKeys: ['uid']
            );
            if (mounted) {
              setState(() => _remoteUid = null);
              widget.onCallEnd();
            }
          },
          error: (ErrorCode err) {
            SecureLogger.error('Agora engine error', error: err);
            if (mounted) widget.onCallEnd();
          },
          leaveChannel: (RtcStats stats) {
            SecureLogger.performance('Agora leave channel completed');
          },
        ),
      );

      // Conversion userId (String) → UID Agora (Int)
      final localUidInt = widget.userId.hashCode & 0x7FFFFFFF;
      SecureLogger.debugSanitized(
        'Joining Agora channel',
        sensitiveKeys: ['channelName', 'uid', 'token']
      );

      await _AgoraManager._engine!.joinChannel(
        widget.token, 
        widget.channelName, 
        null,  // optionalInfo
        localUidInt
      );
      
      if (mounted) {
        setState(() => _isInitialized = true);
        SecureLogger.info('Agora initialization completed successfully');
      }
      
    } catch (e, stackTrace) {
      SecureLogger.error('Critical error in Agora initialization', error: e, stackTrace: stackTrace);
      if (mounted) widget.onCallEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              SizedBox(height: 20),
              Text(
                'Connecting to video call...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Remote video (full screen)
        Center(child: _remoteVideo()),
        
        // Local video (small window - bottom right)
        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: 100,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _localUserJoined
                      ? const RtcLocalView.SurfaceView()
                      : Container(
                          color: Colors.black87,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                ),
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
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.videocam_off,
                color: Colors.white54,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                'Waiting for the other person...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'They will join shortly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
