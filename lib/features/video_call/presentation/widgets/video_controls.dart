/// VideoControls widget for video call.
///
/// Provides control buttons for:
/// - Mute/unmute microphone
/// - Toggle camera on/off
/// - Switch front/back camera
/// - End call
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// Control buttons for the video call screen.
///
/// Displays a row of circular buttons for controlling the call:
/// - Mute button (toggles microphone)
/// - Camera button (toggles video)
/// - Switch camera button (toggles front/back)
/// - End call button (red, ends the call)
class VideoControls extends StatelessWidget {
  /// Creates video controls.
  const VideoControls({
    super.key,
    required this.isMuted,
    required this.isCameraOn,
    required this.isFrontCamera,
    required this.canToggle,
    this.onMuteToggle,
    this.onCameraToggle,
    this.onSwitchCamera,
    this.onEndCall,
  });

  /// Whether the microphone is muted.
  final bool isMuted;

  /// Whether the camera is on.
  final bool isCameraOn;

  /// Whether using the front camera.
  final bool isFrontCamera;

  /// Whether the user can toggle controls (only when connected).
  final bool canToggle;

  /// Called when the mute button is tapped.
  final VoidCallback? onMuteToggle;

  /// Called when the camera button is tapped.
  final VoidCallback? onCameraToggle;

  /// Called when the switch camera button is tapped.
  final VoidCallback? onSwitchCamera;

  /// Called when the end call button is tapped.
  final VoidCallback? onEndCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute button
          _ControlButton(
            icon: isMuted ? Icons.mic_off : Icons.mic,
            label: isMuted ? 'Unmute' : 'Mute',
            isActive: !isMuted,
            enabled: canToggle,
            onTap: canToggle ? onMuteToggle : null,
          ),

          // Camera toggle button
          _ControlButton(
            icon: isCameraOn ? Icons.videocam : Icons.videocam_off,
            label: isCameraOn ? 'Camera Off' : 'Camera On',
            isActive: isCameraOn,
            enabled: canToggle,
            onTap: canToggle ? onCameraToggle : null,
          ),

          // Switch camera button
          _ControlButton(
            icon: Icons.cameraswitch,
            label: 'Flip',
            isActive: true,
            enabled: canToggle,
            onTap: canToggle ? onSwitchCamera : null,
          ),

          // End call button (always enabled)
          _ControlButton(
            icon: Icons.call_end,
            label: 'End',
            isActive: false,
            isEndCall: true,
            enabled: true,
            onTap: onEndCall,
          ),
        ],
      ),
    );
  }
}

/// Individual control button.
class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.enabled,
    this.isEndCall = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final bool isEndCall;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isEndCall
        ? LynewedColors.error
        : isActive
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.3);

    final iconColor = isEndCall
        ? Colors.white
        : enabled
            ? Colors.white
            : Colors.white.withValues(alpha: 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: isEndCall
                  ? [
                      BoxShadow(
                        color: LynewedColors.error.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: LynewedTextStyles.bodySmall.copyWith(
            color: Colors.white.withValues(alpha: enabled ? 0.8 : 0.5),
          ),
        ),
      ],
    );
  }
}
