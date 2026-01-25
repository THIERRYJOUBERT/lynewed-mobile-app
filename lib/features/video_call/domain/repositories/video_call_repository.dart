/// VideoCallRepository interface.
///
/// Defines the contract for video call data operations.
/// Implemented by VideoCallRepositoryImpl in the data layer.
library;

import '../entities/video_session.dart';

/// Result wrapper for repository operations.
class VideoCallResult<T> {
  /// Creates a successful result with data.
  const VideoCallResult.success(this.data) : error = null;

  /// Creates a failure result with error message.
  const VideoCallResult.failure(this.error) : data = null;

  /// The data returned on success.
  final T? data;

  /// The error message on failure.
  final String? error;

  /// Whether the operation was successful.
  bool get isSuccess => error == null;

  /// Whether the operation failed.
  bool get isFailure => error != null;
}

/// Video call repository interface.
///
/// Provides methods for managing video call sessions.
abstract class VideoCallRepository {
  /// Gets a video session by ID.
  ///
  /// Returns null if the session doesn't exist.
  Future<VideoCallResult<VideoSession?>> getSession({
    required String sessionId,
  });

  /// Creates a new video session between two users.
  ///
  /// This will generate Agora channel credentials on the server.
  Future<VideoCallResult<VideoSession>> createSession({
    required String callerProfileId,
    required String receiverProfileId,
  });

  /// Updates the status of a video session.
  Future<VideoCallResult<void>> updateSessionStatus({
    required String sessionId,
    required VideoSessionStatus status,
  });

  /// Ends a video session.
  ///
  /// Sets the status to ended and records the end time.
  Future<VideoCallResult<void>> endSession({
    required String sessionId,
  });

  /// Gets the active session for a user, if any.
  Future<VideoCallResult<VideoSession?>> getActiveSessionForUser({
    required String profileId,
  });
}
