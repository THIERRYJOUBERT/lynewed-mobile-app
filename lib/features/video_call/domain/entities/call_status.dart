/// CallStatus enum for video call state management.
///
/// Represents the current state of a video call from the UI perspective.
/// Used by VideoCallCubit to track call progress.
library;

/// Current status of a video call in the UI.
enum CallStatus {
  /// Initial state, before any call action.
  initial,

  /// Connecting to the call (initializing Agora, etc.)
  connecting,

  /// Call is ringing on the other side.
  ringing,

  /// Call is connected and active.
  connected,

  /// Call has ended (normally or by user).
  ended,

  /// An error occurred during the call.
  error,
}

/// Extension to add computed properties to CallStatus.
extension CallStatusExtension on CallStatus {
  /// Whether the call is currently active (connecting, ringing, or connected).
  bool get isActive {
    return this == CallStatus.connecting ||
        this == CallStatus.ringing ||
        this == CallStatus.connected;
  }

  /// Whether the call can be ended (user can press end call button).
  bool get canEndCall {
    return this == CallStatus.connecting ||
        this == CallStatus.ringing ||
        this == CallStatus.connected;
  }

  /// Whether the call has reached a terminal state.
  bool get isTerminal {
    return this == CallStatus.ended || this == CallStatus.error;
  }

  /// Display name for the status.
  String get displayName {
    switch (this) {
      case CallStatus.initial:
        return 'Initializing...';
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.ringing:
        return 'Ringing...';
      case CallStatus.connected:
        return 'Connected';
      case CallStatus.ended:
        return 'Call Ended';
      case CallStatus.error:
        return 'Error';
    }
  }
}
