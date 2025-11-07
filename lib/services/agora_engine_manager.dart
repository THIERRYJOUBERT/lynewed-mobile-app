import 'dart:async';
import 'dart:math';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

class AgoraEngineManager {
  AgoraEngineManager._();

  static final AgoraEngineManager instance = AgoraEngineManager._();

  RtcEngine? _engine;
  Completer<RtcEngine>? _initializationCompleter;
  
  // Stream pour dispatcher les événements aux widgets
  final StreamController<Map<String, dynamic>> _eventController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  RtcEngine? get engine => _engine;
  bool get isInitialized => _engine != null;

  Future<RtcEngine> ensureInitialized({
    required String appId,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    if (_engine != null) {
      return _engine!;
    }

    if (appId.isEmpty) {
      throw ArgumentError('Agora App ID is empty.');
    }

    if (_initializationCompleter != null) {
      return _waitForInitialization(timeout);
    }

    _initializationCompleter = Completer<RtcEngine>();

    try {
      final engine = createAgoraRtcEngine();
      
      // STEP 1: Initialize engine FIRST (required by Agora docs)
      debugPrint('🎥 [AGORA_MANAGER] Initializing engine...');
      await engine
          .initialize(
            RtcEngineContext(
              appId: appId,
              channelProfile: ChannelProfileType.channelProfileCommunication,
            ),
          )
          .timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException(
                'Agora engine initialization timed out after '
                '${timeout.inSeconds}s',
              );
            },
          );
      debugPrint('🎥 [AGORA_MANAGER] ✅ Engine initialized');
      
      // STEP 2: Register event handlers AFTER initialize() (per Agora docs)
      // "You must call initialize before calling registerEventHandler"
      debugPrint('🎥 [AGORA_MANAGER] Registering event handlers...');
      engine.registerEventHandler(RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          final channelId = connection.channelId ?? '';
          final maskedChannel = channelId.length > 8 ? '${channelId.substring(0, 8)}***' : channelId;
          debugPrint('🎊 [AGORA_MANAGER] onJoinChannelSuccess: channel=$maskedChannel, uid=${connection.localUid}, elapsed=${elapsed}ms');
          _eventController.add({
            'event': 'joinChannelSuccess',
            'channelId': connection.channelId,
            'uid': connection.localUid,
            'elapsed': elapsed,
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          final channelId = connection.channelId ?? '';
          final maskedChannel = channelId.length > 8 ? '${channelId.substring(0, 8)}***' : channelId;
          debugPrint('👤 [AGORA_MANAGER] onUserJoined: remoteUid=$remoteUid in $maskedChannel');
          _eventController.add({
            'event': 'userJoined',
            'channelId': connection.channelId,
            'remoteUid': remoteUid,
            'elapsed': elapsed,
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint('👋 [AGORA_MANAGER] onUserOffline: remoteUid=$remoteUid, reason=$reason');
          _eventController.add({
            'event': 'userOffline',
            'channelId': connection.channelId,
            'remoteUid': remoteUid,
            'reason': reason.toString(),
          });
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint('⚠️ [AGORA_MANAGER] onError: $err - $msg');
          _eventController.add({
            'event': 'error',
            'errorCode': err.toString(),
            'message': msg,
          });
        },
        onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
          final channelId = connection.channelId ?? '';
          final maskedChannel = channelId.length > 8 ? '${channelId.substring(0, 8)}***' : channelId;
          debugPrint('🔗 [AGORA_MANAGER] onConnectionStateChanged: channel=$maskedChannel, state=$state, reason=$reason');
          _eventController.add({
            'event': 'connectionStateChanged',
            'channelId': connection.channelId,
            'state': state.toString(),
            'reason': reason.toString(),
          });
        },
      ));
      debugPrint('🎥 [AGORA_MANAGER] ✅ Event handlers registered');
      
      _engine = engine;
      _initializationCompleter!.complete(engine);
      return engine;
    } catch (error, stackTrace) {
      if (!(_initializationCompleter?.isCompleted ?? true)) {
        _initializationCompleter!.completeError(error, stackTrace);
      }
      rethrow;
    } finally {
      _initializationCompleter = null;
    }
  }

  Future<RtcEngine> _waitForInitialization(Duration timeout) async {
    final completer = _initializationCompleter;
    if (completer == null) {
      throw StateError('Agora engine initialization state lost.');
    }

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        throw TimeoutException(
          'Agora engine initialization timed out after ${timeout.inSeconds}s',
        );
      },
    );
  }

  Future<void> releaseEngine() async {
    if (_engine == null) {
      return;
    }

    try {
      await _engine!.stopPreview();
    } catch (_) {}

    try {
      await _engine!.leaveChannel();
    } catch (_) {}

    try {
      await _engine!.release();
    } catch (_) {}

    _engine = null;
  }
  
  void dispose() {
    _eventController.close();
  }
}
