/// VideoCallPage - Main video call screen.
///
/// Displays the video call interface with:
/// - Remote video (full screen)
/// - Local video (PiP)
/// - Call controls (mute, camera, end call)
/// - Call status and duration
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/design/design.dart';
import '../../domain/entities/call_status.dart';
import '../bloc/video_call_cubit.dart';
import '../bloc/video_call_state.dart';
import '../widgets/video_controls.dart';

/// Main video call page.
///
/// Displays the video call interface with remote and local video,
/// call controls, and status information.
///
/// Note: Actual Agora video rendering should be added when integrating
/// with the Agora SDK. This widget provides the UI structure and state
/// management.
class VideoCallPage extends StatelessWidget {
  /// Route name for navigation.
  static const String routeName = 'video-call';

  /// Route path for navigation.
  static const String routePath = '/video-call/:sessionId';

  /// Creates a video call page.
  const VideoCallPage({
    super.key,
    required this.sessionId,
  });

  /// The video session ID to join.
  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VideoCallCubit, VideoCallState>(
      listener: (context, state) {
        // Auto-pop when call ends
        if (state.status == CallStatus.ended) {
          // Delay to show "Call Ended" message
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                // Remote video area (full screen)
                _buildRemoteVideo(state),

                // Status overlay
                _buildStatusOverlay(state),

                // Local video PiP
                _buildLocalVideoPip(state),

                // Controls at bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildControls(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRemoteVideo(VideoCallState state) {
    if (!state.hasRemoteUser && state.status == CallStatus.connected) {
      // Waiting for remote user to join
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                'Waiting for participant...',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (state.hasRemoteUser) {
      // Remote video placeholder - actual Agora view goes here
      return Container(
        color: Colors.grey[900],
        child: const Center(
          child: Icon(
            Icons.person,
            size: 120,
            color: Colors.white24,
          ),
        ),
      );
    }

    // Default: show status
    return Container(color: Colors.black);
  }

  Widget _buildStatusOverlay(VideoCallState state) {
    // Get participant name
    final participantName = state.session?.callerName ??
        state.session?.receiverName;

    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Participant name
          if (participantName != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                participantName,
                style: LynewedTextStyles.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 8),

          // Status text
          _buildStatusText(state),
        ],
      ),
    );
  }

  Widget _buildStatusText(VideoCallState state) {
    String text;
    Color? indicatorColor;

    switch (state.status) {
      case CallStatus.initial:
        text = 'Initializing...';
        break;
      case CallStatus.connecting:
        text = 'Connecting...';
        indicatorColor = LynewedColors.warning;
        break;
      case CallStatus.ringing:
        text = 'Ringing...';
        indicatorColor = LynewedColors.warning;
        break;
      case CallStatus.connected:
        text = state.formattedDuration;
        indicatorColor = LynewedColors.success;
        break;
      case CallStatus.ended:
        text = 'Call Ended';
        break;
      case CallStatus.error:
        text = state.error ?? 'Error';
        indicatorColor = LynewedColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (indicatorColor != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalVideoPip(VideoCallState state) {
    if (state.status != CallStatus.connected) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 100,
      right: 16,
      child: Container(
        width: 100,
        height: 140,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: state.isCameraOn
              ? Container(
                  color: Colors.grey[700],
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white24,
                    ),
                  ),
                )
              : Container(
                  color: Colors.black,
                  child: Center(
                    child: Icon(
                      Icons.videocam_off,
                      size: 32,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, VideoCallState state) {
    final cubit = context.read<VideoCallCubit>();

    return VideoControls(
      isMuted: state.isMuted,
      isCameraOn: state.isCameraOn,
      isFrontCamera: state.isFrontCamera,
      canToggle: state.canToggleControls,
      onMuteToggle: cubit.toggleMute,
      onCameraToggle: cubit.toggleCamera,
      onSwitchCamera: cubit.switchCamera,
      onEndCall: cubit.endCall,
    );
  }
}
