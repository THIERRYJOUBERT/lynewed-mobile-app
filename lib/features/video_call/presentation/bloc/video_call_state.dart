/// VideoCallState for VideoCallCubit.
///
/// Defines the state for managing video call UI state.
/// Tracks call status, media controls, and remote user presence.
library;

import 'package:flutter/foundation.dart';

import '../../domain/entities/call_status.dart';
import '../../domain/entities/video_session.dart';

/// State for the video call Cubit.
///
/// Tracks the call status, session data, media controls, and call duration.
@immutable
class VideoCallState {
  /// Creates a video call state.
  const VideoCallState({
    this.status = CallStatus.initial,
    this.session,
    this.remoteUid,
    this.isMuted = false,
    this.isCameraOn = true,
    this.isFrontCamera = true,
    this.error,
    this.callDuration = Duration.zero,
  });

  /// Current call status.
  final CallStatus status;

  /// The video session data from the server.
  final VideoSession? session;

  /// The Agora user ID of the remote participant.
  final int? remoteUid;

  /// Whether the local microphone is muted.
  final bool isMuted;

  /// Whether the local camera is on.
  final bool isCameraOn;

  /// Whether using the front camera.
  final bool isFrontCamera;

  /// Error message, if any.
  final String? error;

  /// Duration of the current call.
  final Duration callDuration;

  /// Whether the call is currently active (connecting, ringing, or connected).
  bool get isCallActive => status.isActive;

  /// Whether the user can toggle audio/video controls.
  bool get canToggleControls => status == CallStatus.connected;

  /// Whether a remote user has joined the call.
  bool get hasRemoteUser => remoteUid != null;

  /// Formatted call duration string (MM:SS or HH:MM:SS).
  String get formattedDuration {
    final hours = callDuration.inHours;
    final minutes = callDuration.inMinutes.remainder(60);
    final seconds = callDuration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Creates a copy with updated values.
  ///
  /// Use [clearError] to explicitly set error to null.
  VideoCallState copyWith({
    CallStatus? status,
    VideoSession? session,
    int? remoteUid,
    bool? isMuted,
    bool? isCameraOn,
    bool? isFrontCamera,
    String? error,
    Duration? callDuration,
    bool clearError = false,
    bool clearRemoteUid = false,
  }) {
    return VideoCallState(
      status: status ?? this.status,
      session: session ?? this.session,
      remoteUid: clearRemoteUid ? null : (remoteUid ?? this.remoteUid),
      isMuted: isMuted ?? this.isMuted,
      isCameraOn: isCameraOn ?? this.isCameraOn,
      isFrontCamera: isFrontCamera ?? this.isFrontCamera,
      error: clearError ? null : (error ?? this.error),
      callDuration: callDuration ?? this.callDuration,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VideoCallState &&
        other.status == status &&
        other.session == session &&
        other.remoteUid == remoteUid &&
        other.isMuted == isMuted &&
        other.isCameraOn == isCameraOn &&
        other.isFrontCamera == isFrontCamera &&
        other.error == error &&
        other.callDuration == callDuration;
  }

  @override
  int get hashCode => Object.hash(
        status,
        session,
        remoteUid,
        isMuted,
        isCameraOn,
        isFrontCamera,
        error,
        callDuration,
      );
}
