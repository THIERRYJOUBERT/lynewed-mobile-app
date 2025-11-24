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
import 'dart:math';
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
    SecureLogger.info('🔴 agoraEndCall called - Engine status: ${_engine != null ? "ACTIVE" : "NULL"}');
    print('🎥 [AGORA] === CLEANUP: agoraEndCall() ===');
    print('🎥 [AGORA] Engine status: ${_engine != null ? "ACTIVE" : "NULL"}');
    final engine = _engine;
    if (engine != null) {
      try {
        SecureLogger.info('Stopping preview...');
        print('🎥 [AGORA] Stopping preview...');
        await engine.stopPreview();
        print('🎥 [AGORA] ✅ Preview stopped');
        SecureLogger.info('Leaving Agora channel...');
        print('🎥 [AGORA] Leaving channel...');
        await engine.leaveChannel();
        print('🎥 [AGORA] ✅ Channel left');
      } catch (e) {
        SecureLogger.error('❌ Error during agora end call', error: e);
        print('🎥 [AGORA] ❌ Error during cleanup: $e');
      } finally {
        _currentChannel = null;
        SecureLogger.info('Current channel cleared');
        print('🎥 [AGORA] Current channel cleared');
      }
    } else {
      SecureLogger.warning('⚠️ agoraEndCall called but engine is NULL');
      print('🎥 [AGORA] ⚠️ agoraEndCall called but engine is NULL');
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
          debugPrint('');
          debugPrint('🎊🎊🎊 LOCAL USER JOINED SUCCESSFULLY 🎊🎊🎊');
          print('🎥 [AGORA] 🎊🎊🎊 onJoinChannelSuccess FIRED 🎊🎊🎊');
          final channelId = event['channelId'] as String? ?? '';
          debugPrint('Channel: ${channelId.substring(0, min(8, channelId.length))}***');
          print('🎥 [AGORA] Channel ID: ${channelId.substring(0, min(8, channelId.length))}***');
          debugPrint('Local UID: ${event['uid']}');
          print('🎥 [AGORA] Local UID: ${event['uid']}');
          debugPrint('Elapsed: ${event['elapsed']}ms');
          print('🎥 [AGORA] Elapsed time: ${event['elapsed']}ms');
          if (mounted) {
            setState(() {
              _localUserJoined = true;
              _isInitialized = true;
            });
            debugPrint('✅ UI state updated');
          }
          break;
          
        case 'userJoined':
          final remoteUid = event['remoteUid'] as int?;
          if (remoteUid != null) {
            debugPrint('');
            debugPrint('👤 REMOTE USER JOINED: $remoteUid');
            print('🎥 [AGORA] 👤 onUserJoined FIRED - Remote UID: $remoteUid');
            debugPrint('Elapsed: ${event['elapsed']}ms');
            print('🎥 [AGORA] Remote user elapsed: ${event['elapsed']}ms');
            if (mounted) {
              setState(() => _remoteUid = remoteUid);
              debugPrint('✅ Remote UID set to: $remoteUid');
            }
          }
          break;
          
        case 'userOffline':
          final remoteUid = event['remoteUid'] as int?;
          debugPrint('');
          debugPrint('👋 REMOTE USER LEFT: $remoteUid');
          print('🎥 [AGORA] 👋 onUserOffline FIRED - Remote UID: $remoteUid');
          debugPrint('Reason: ${event['reason']}');
          print('🎥 [AGORA] Offline reason: ${event['reason']}');
          if (mounted) {
            setState(() => _remoteUid = null);
            widget.onCallEnd();
          }
          break;
          
        case 'error':
          final errorCode = event['errorCode'] as String?;
          final message = event['message'] as String?;
          debugPrint('');
          debugPrint('⚠️ AGORA ERROR');
          print('🎥 [AGORA] ⚠️⚠️⚠️ onError FIRED ⚠️⚠️⚠️');
          debugPrint('Code: $errorCode');
          print('🎥 [AGORA] Error code: $errorCode');
          debugPrint('Message: $message');
          print('🎥 [AGORA] Error message: $message');
          
          // Check for critical errors
          if (errorCode?.contains('errInvalidAppId') == true ||
              errorCode?.contains('errInvalidToken') == true ||
              errorCode?.contains('errTokenExpired') == true) {
            debugPrint('🚨 CRITICAL ERROR - Closing call');
            print('🎥 [AGORA] 🚨 CRITICAL ERROR DETECTED - Closing call');
            if (mounted) widget.onCallEnd();
          }
          break;
          
        case 'connectionStateChanged':
          debugPrint('🔗 Connection state: ${event['state']}, reason: ${event['reason']}');
          print('🎥 [AGORA] 🔗 Connection: ${event['state']} (${event['reason']})');
          break;
      }
    });
  }

  Future<void> initAgora() async {
    debugPrint('');
    debugPrint('═══════════════════════════════════════════');
    debugPrint('🚀 AGORA INITIALIZATION START');
    debugPrint('═══════════════════════════════════════════');
    
    // GUARD: Vérifier si une initialisation est déjà en cours
    if (_AgoraManager._initializing) {
      debugPrint('⚠️ Another initialization is in progress - aborting');
      if (mounted) widget.onCallEnd();
      return;
    }
    
    // GUARD: Vérifier si l\'engine existe déjà pour ce canal
    if (_AgoraManager._engine != null && _AgoraManager._currentChannel == widget.channelName) {
      debugPrint('⚠️ Engine already exists for this channel - reusing');
      if (mounted) {
        setState(() {
          _localUserJoined = true;
          _isInitialized = true;
        });
      }
      return;
    }
    
    // GUARD: Si engine existe pour un autre canal, nettoyer d\'abord
    if (_AgoraManager._engine != null && _AgoraManager._currentChannel != widget.channelName) {
      debugPrint('⚠️ Engine exists for different channel - cleaning up first');
      await _AgoraManager.agoraEndCall();
    }
    
    _AgoraManager._initializing = true;
    
    // STEP 1 : Validation
    debugPrint('📋 STEP 1: Validating parameters...');
    print('🎥 [AGORA] === STEP 1: VALIDATION ===');
    print('🎥 [AGORA] App ID length: ${widget.appId.length}');
    print('🎥 [AGORA] App ID value: ${widget.appId.substring(0, min(8, widget.appId.length))}***');
    print('🎥 [AGORA] App ID isEmpty: ${widget.appId.isEmpty}');
    
    if (widget.appId.isEmpty) {
      debugPrint('❌ ERROR: App ID is empty');
      print('🎥 [AGORA] ❌ CRITICAL: App ID is EMPTY - aborting');
      if (mounted) widget.onCallEnd();
      return;
    }
    debugPrint('✅ App ID: OK');
    print('🎥 [AGORA] ✅ App ID validated');
    
    print('🎥 [AGORA] Token length: ${widget.token.length}');
    print('🎥 [AGORA] Token isEmpty: ${widget.token.isEmpty}');
    if (widget.token.isNotEmpty) {
      print('🎥 [AGORA] Token starts with: ${widget.token.substring(0, min(10, widget.token.length))}');
    }
    
    if (widget.token.isEmpty) {
      debugPrint('❌ ERROR: Token is empty');
      print('🎥 [AGORA] ❌ CRITICAL: Token is EMPTY - aborting');
      if (mounted) widget.onCallEnd();
      return;
    }
    debugPrint('✅ Token: OK');
    print('🎥 [AGORA] ✅ Token validated');
    debugPrint('✅ Channel: ${widget.channelName.substring(0, min(8, widget.channelName.length))}***');
    print('🎥 [AGORA] Channel name: ${widget.channelName.substring(0, min(8, widget.channelName.length))}***');
    debugPrint('✅ User ID: ${widget.userId.substring(0, min(8, widget.userId.length))}***');
    print('🎥 [AGORA] User ID: ${widget.userId.substring(0, min(8, widget.userId.length))}***');
    
    // STEP 2 : Permissions
    debugPrint('');
    debugPrint('📋 STEP 2: Checking permissions...');
    print('🎥 [AGORA] === STEP 2: PERMISSIONS ===');
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;
    debugPrint('Camera: $cameraStatus | Mic: $micStatus');
    print('🎥 [AGORA] Camera permission: $cameraStatus');
    print('🎥 [AGORA] Microphone permission: $micStatus');
    
    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      debugPrint('⚠️ Requesting permissions...');
      final cameraRequested = await Permission.camera.request();
      final micRequested = await Permission.microphone.request();
      
      if (!cameraRequested.isGranted || !micRequested.isGranted) {
        debugPrint('❌ ERROR: Permissions denied');
        if (mounted) widget.onCallEnd();
        return;
      }
      debugPrint('✅ Permissions granted');
    } else {
      debugPrint('✅ Permissions already granted');
    }

    try {
        // STEP 3 : Get pre-initialized engine (already initialized at app startup)
      debugPrint('');
      debugPrint('📋 STEP 3: Getting Agora engine instance...');
      print('🎥 [AGORA] === STEP 3: ENGINE RETRIEVAL ===');
      print('🎥 [AGORA] Requesting engine instance from singleton (should be pre-initialized)');

      final engine = await _AgoraManager.ensureEngineInitialized(widget.appId)
          .timeout(
        const Duration(seconds: 5), // Reduced timeout since engine should already be ready
        onTimeout: () {
          throw TimeoutException(
            'Agora engine not available after 5s (should have been pre-initialized at app startup)',
          );
        },
      );

      _AgoraManager._engine = engine;
      debugPrint('✅ Engine ready from singleton');
      print('🎥 [AGORA] ✅ Engine instance obtained (pre-initialized: ${_AgoraManager._engineManager.isInitialized})');

      // STEP 4 : Event handlers already registered globally in AgoraEngineManager
      // They are now listened via stream subscription setup in initState
      debugPrint('');
      debugPrint('📋 STEP 4: Event handlers ready (listening via global stream)');
      print('🎥 [AGORA] === STEP 4: EVENT HANDLERS ===');
      print('🎥 [AGORA] Event handlers already registered globally in manager');
      
      // STEP 5 : Set client role (for Communication profile, all users are broadcasters by default)
      debugPrint('');
      debugPrint('📋 STEP 5: Setting client role...');
      print('🎥 [AGORA] === STEP 5: CLIENT ROLE ===');
      print('🎥 [AGORA] Setting client role to broadcaster...');
      await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      debugPrint('✅ Client role set to broadcaster');
      print('🎥 [AGORA] ✅ Client role set successfully');
      
      // STEP 6 : Enable video and start preview
      debugPrint('');
      debugPrint('📋 STEP 6: Enabling video and starting preview...');
      print('🎥 [AGORA] === STEP 6: VIDEO & AUDIO ===');
      print('🎥 [AGORA] Enabling video module...');
      await engine.enableVideo();
      debugPrint('✅ Video enabled');
      print('🎥 [AGORA] ✅ Video enabled');
      
      print('🎥 [AGORA] Starting local preview...');
      await engine.startPreview();
      debugPrint('✅ Preview started');
      print('🎥 [AGORA] ✅ Preview started');
      
      print('🎥 [AGORA] Setting audio route to speakerphone...');
      await engine.setDefaultAudioRouteToSpeakerphone(true);
      debugPrint('✅ Audio route set to speakerphone');
      print('🎥 [AGORA] ✅ Audio route configured');
      
      // STEP 7 : Calculate UID
      debugPrint('');
      debugPrint('📋 STEP 7: Calculating Agora UID...');
      print('🎥 [AGORA] === STEP 7: UID CALCULATION ===');
      print('🎥 [AGORA] Calculating UID from userId: ${widget.userId.substring(0, min(8, widget.userId.length))}***');
      final localUidInt = functions.generateAgoraUid(widget.userId);
      debugPrint('✅ Agora UID: $localUidInt');
      print('🎥 [AGORA] ✅ Calculated UID: $localUidInt');
      print('🎥 [AGORA] Source userId: ${widget.userId.substring(0, min(8, widget.userId.length))}***');
      
      // STEP 8 : Join channel
      debugPrint('');
      debugPrint('📋 STEP 8: Joining channel...');
      print('🎥 [AGORA] === STEP 8: JOIN CHANNEL ===');
      debugPrint('Channel: ${widget.channelName.substring(0, min(8, widget.channelName.length))}***');
      print('🎥 [AGORA] Channel name: ${widget.channelName.substring(0, min(8, widget.channelName.length))}***');
      debugPrint('Local UID: $localUidInt');
      print('🎥 [AGORA] Local UID: $localUidInt');
      
      print('🎥 [AGORA] About to join channel with options:');
      print('🎥 [AGORA]   - channelId: ${widget.channelName.substring(0, min(8, widget.channelName.length))}***');
      print('🎥 [AGORA]   - uid: $localUidInt');
      print('🎥 [AGORA]   - token length: ${widget.token.length}');
      print('🎥 [AGORA]   - token prefix: ${widget.token.substring(0, min(10, widget.token.length))}');
      
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
      print('🎥 [AGORA] joinChannel() call completed');
      
      debugPrint('✅ joinChannel() called successfully');
      debugPrint('⏳ Waiting for onJoinChannelSuccess callback...');
      debugPrint('═══════════════════════════════════════════');
      
      // Marquer le canal courant et fin d\'initialisation
      _AgoraManager._currentChannel = widget.channelName;
      _AgoraManager._initializing = false;
      
    } catch (e, stackTrace) {
      debugPrint('');
      debugPrint('❌❌❌ EXCEPTION IN INIT AGORA ❌❌❌');
      print('🎥 [AGORA] ❌❌❌ EXCEPTION CAUGHT ❌❌❌');
      debugPrint('Error: $e');
      print('🎥 [AGORA] Exception: $e');
      debugPrint('Error type: ${e.runtimeType}');
      print('🎥 [AGORA] Exception type: ${e.runtimeType}');
      debugPrint('Stack trace:');
      debugPrint(stackTrace.toString());
      print('🎥 [AGORA] Stack trace:');
      print('🎥 [AGORA] ${stackTrace.toString()}');
      
      // Log avec print() pour forcer l'affichage en production
      print('🚨 AGORA INIT FAILED: $e');
      print('🚨 Error type: ${e.runtimeType}');
      print('🎥 [AGORA] 🚨 Calling onCallEnd() due to exception');
      
      try {
        SecureLogger.error('Critical error in Agora initialization', error: e);
      } catch (logError) {
        print('⚠️ SecureLogger failed: $logError');
      }
      
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
