/// VideoCallCubit for managing video call state.
///
/// Handles call lifecycle, media controls, and Agora integration.
/// Note: Actual Agora SDK calls should be handled at the widget level
/// to allow for mocking in tests.
library;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/call_status.dart';
import '../../domain/entities/video_session.dart';
import '../../domain/repositories/video_call_repository.dart';
import 'video_call_state.dart';

/// Cubit for managing video call state.
///
/// Provides methods for joining calls, controlling media (mute, camera),
/// and ending calls. The actual Agora SDK integration should be handled
/// at the widget level.
class VideoCallCubit extends Cubit<VideoCallState> {
  /// Creates a VideoCallCubit with the given repository.
  VideoCallCubit({
    required VideoCallRepository repository,
  })  : _repository = repository,
        super(const VideoCallState());

  /// The repository for video call operations.
  final VideoCallRepository _repository;

  /// Joins an existing video call session.
  ///
  /// Fetches the session from the server and updates state to connected.
  /// The widget should use the session data to initialize Agora SDK.
  Future<void> joinCall({required String sessionId}) async {
    emit(state.copyWith(status: CallStatus.connecting, clearError: true));

    final result = await _repository.getSession(sessionId: sessionId);

    if (result.isFailure) {
      emit(state.copyWith(
        status: CallStatus.error,
        error: result.error,
      ));
      return;
    }

    final session = result.data;
    if (session == null) {
      emit(state.copyWith(
        status: CallStatus.error,
        error: 'Session not found',
      ));
      return;
    }

    // Update session status in the database
    await _repository.updateSessionStatus(
      sessionId: sessionId,
      status: VideoSessionStatus.connected,
    );

    emit(state.copyWith(
      status: CallStatus.connected,
      session: session,
    ));
  }

  /// Toggles the microphone mute state.
  ///
  /// Only works when the call is connected.
  void toggleMute() {
    if (!state.canToggleControls) return;

    emit(state.copyWith(isMuted: !state.isMuted));
  }

  /// Toggles the camera on/off.
  ///
  /// Only works when the call is connected.
  void toggleCamera() {
    if (!state.canToggleControls) return;

    emit(state.copyWith(isCameraOn: !state.isCameraOn));
  }

  /// Switches between front and back camera.
  ///
  /// Only works when the call is connected.
  void switchCamera() {
    if (!state.canToggleControls) return;

    emit(state.copyWith(isFrontCamera: !state.isFrontCamera));
  }

  /// Ends the current call.
  ///
  /// Updates the session status in the database and emits ended state.
  Future<void> endCall() async {
    if (state.status == CallStatus.ended) return;

    final session = state.session;
    if (session != null) {
      await _repository.endSession(sessionId: session.id);
    }

    emit(state.copyWith(status: CallStatus.ended));
  }

  /// Sets the remote user who joined the call.
  ///
  /// Called when Agora notifies that a remote user joined.
  void setRemoteUser({required int uid}) {
    emit(state.copyWith(remoteUid: uid));
  }

  /// Removes the remote user from the call.
  ///
  /// Called when Agora notifies that a remote user left.
  void removeRemoteUser() {
    emit(state.copyWith(clearRemoteUid: true));
  }

  /// Updates the call duration.
  ///
  /// Should be called periodically by a timer in the widget.
  void updateCallDuration(Duration duration) {
    emit(state.copyWith(callDuration: duration));
  }

  /// Clears the current error state.
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
