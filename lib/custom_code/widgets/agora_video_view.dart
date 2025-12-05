// Automatic FlutterFlow imports
// Imports other custom widgets
// Imports custom actions
// Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Fichier: custom_code/widgets/agora_video_view.dart
// VERSION CORRIGÉE POUR AGORA 6.3.2 - API OFFICIELLE

import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '/utils/secure_logger.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import 'package:lynewed_beta/services/agora_engine_manager.dart';

// Import du widget Agora avec alias pour éviter le conflit de nom
import 'package:agora_rtc_engine/agora_rtc_engine.dart' as agora;

// Logique de contrôle statique pour être appelée depuis les Custom Actions
class _AgoraManager {
  static final AgoraEngineManager _engineManager = AgoraEngineManager.instance;
  static RtcEngine? _engine;
  static bool _initializing = false;
  static String? _currentChannel;

  static Future<RtcEngine> ensureEngineInitialized(String appId) async {
    final engine = await _engineManager.ensureInitialized(appId: appId);
    _engine = engine;
    return engine;
  }

  static Future<void> agoraToggleMute(bool isMuted) async =>
      await _engine?.muteLocalAudioStream(isMuted);
  static Future<void> agoraToggleCamera(bool isCameraOff) async =>
      await _engine?.muteLocalVideoStream(isCameraOff);
  static Future<void> agoraSwitchCamera() async =>
      await _engine?.switchCamera();
  static Future<void> agoraEndCall() async {
    SecureLogger.info('agoraEndCall called');
    final engine = _engine;
    if (engine != null) {
      try {
        await engine.stopPreview();
        await engine.leaveChannel();
      } catch (e) {
        SecureLogger.error('Error during agora end call', error: e);
      } finally {
        _currentChannel = null;
      }
    }
  }
}

class AgoraVideoViewWidget extends StatefulWidget {
  // Exposition des méthodes statiques pour les Custom Actions de FF
  static Future<void> agoraToggleMute(bool isMuted) =>
      _AgoraManager.agoraToggleMute(isMuted);
  static Future<void> agoraToggleCamera(bool isCameraOff) =>
      _AgoraManager.agoraToggleCamera(isCameraOff);
  static Future<void> agoraSwitchCamera() => _AgoraManager.agoraSwitchCamera();
  static Future<void> agoraEndCall() => _AgoraManager.agoraEndCall();

  const AgoraVideoViewWidget({
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
  State<AgoraVideoViewWidget> createState() => _AgoraVideoViewWidgetState();
}

class _AgoraVideoViewWidgetState extends State<AgoraVideoViewWidget> {
  int? _remoteUid;
  bool _localUserJoined = false;
  bool _isInitialized = false;
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;

  @override
  void initState() {
    super.initState();
    SecureLogger.info('AgoraVideoViewWidget initState called');
    _setupEventListener();
    initAgora();
  }

  @override
  void dispose() {
    SecureLogger.info('AgoraVideoViewWidget dispose called');
    _eventSubscription?.cancel();
    _AgoraManager.agoraEndCall();
    super.dispose();
  }
  
  void _setupEventListener() {
    _eventSubscription = AgoraEngineManager.instance.eventStream.listen((event) {
      final eventChannelId = event['channelId'] as String?;
      
      // Filter events for current channel only
      if (eventChannelId != null && eventChannelId != widget.channelName) {
        return; // Ignore events from other channels
      }
      
      switch (event['event']) {
        case 'joinChannelSuccess':
          SecureLogger.info('Local user joined channel successfully');
          if (mounted) {
            setState(() {
              _localUserJoined = true;
              _isInitialized = true;
            });
          }
          break;
          
        case 'userJoined':
          final remoteUid = event['remoteUid'] as int?;
          if (remoteUid != null) {
            SecureLogger.info('Remote user joined');
            if (mounted) {
              setState(() => _remoteUid = remoteUid);
            }
          }
          break;
          
        case 'userOffline':
          SecureLogger.info('Remote user left');
          if (mounted) {
            setState(() => _remoteUid = null);
            widget.onCallEnd();
          }
          break;
          
        case 'error':
          final errorCode = event['errorCode'] as String?;
          SecureLogger.error('Agora error', error: errorCode);
          
          // Check for critical errors
          if (errorCode?.contains('errInvalidAppId') == true ||
              errorCode?.contains('errInvalidToken') == true ||
              errorCode?.contains('errTokenExpired') == true) {
            if (mounted) widget.onCallEnd();
          }
          break;
          
        case 'connectionStateChanged':
          SecureLogger.debug('Connection state changed');
          break;
      }
    });
  }

  Future<void> initAgora() async {
    // GUARD: Vérifier si une initialisation est déjà en cours
    if (_AgoraManager._initializing) {
      if (mounted) widget.onCallEnd();
      return;
    }
    
    // GUARD: Vérifier si l'engine existe déjà pour ce canal
    if (_AgoraManager._engine != null && _AgoraManager._currentChannel == widget.channelName) {
      if (mounted) {
        setState(() {
          _localUserJoined = true;
          _isInitialized = true;
        });
      }
      return;
    }
    
    // GUARD: Si engine existe pour un autre canal, nettoyer d'abord
    if (_AgoraManager._engine != null && _AgoraManager._currentChannel != widget.channelName) {
      await _AgoraManager.agoraEndCall();
    }
    
    _AgoraManager._initializing = true;
    
    // Validation des paramètres
    if (widget.appId.isEmpty || widget.token.isEmpty) {
      _AgoraManager._initializing = false;
      if (mounted) widget.onCallEnd();
      return;
    }
    
    // Vérification des permissions
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    
    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      final cameraRequested = await Permission.camera.request();
      final micRequested = await Permission.microphone.request();
      
      if (!cameraRequested.isGranted || !micRequested.isGranted) {
        _AgoraManager._initializing = false;
        if (mounted) widget.onCallEnd();
        return;
      }
    }

    try {
      // Get pre-initialized engine
      final engine = await _AgoraManager.ensureEngineInitialized(widget.appId)
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Agora engine timeout');
        },
      );

      _AgoraManager._engine = engine;

      // Configure engine
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine.enableVideo();
      await engine.startPreview();
      await engine.setDefaultAudioRouteToSpeakerphone(true);
      
      // Calculate UID and join channel
      final localUidInt = functions.generateAgoraUid(widget.userId);
      
      await engine.joinChannel(
        token: widget.token,
        channelId: widget.channelName,
        uid: localUidInt,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
      
      _AgoraManager._currentChannel = widget.channelName;
      _AgoraManager._initializing = false;
      
    } catch (e) {
      SecureLogger.error('Agora initialization failed', error: e);
      _AgoraManager._initializing = false;
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
                      ? agora.AgoraVideoView(
                          controller: agora.VideoViewController(
                            rtcEngine: _AgoraManager._engine!,
                            canvas: const agora.VideoCanvas(uid: 0),
                          ),
                        )
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
      return agora.AgoraVideoView(
        controller: agora.VideoViewController.remote(
          rtcEngine: _AgoraManager._engine!,
          canvas: agora.VideoCanvas(uid: _remoteUid!),
          connection: agora.RtcConnection(channelId: widget.channelName),
        ),
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
