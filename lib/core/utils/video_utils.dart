/// Video utilities for media validation and formatting
///
/// Provides constants, validation functions, and formatting helpers
/// for video uploads in the My Wedding inspiration albums.
library;

/// Video validation constants
class VideoConstants {
  VideoConstants._();

  /// Maximum video duration in seconds (10 minutes)
  static const int maxDurationSeconds = 600;

  /// Maximum file size in bytes (500 MB)
  static const int maxFileSizeBytes = 524288000;

  /// Allowed video file extensions
  static const List<String> allowedExtensions = ['mp4', 'mov', 'm4v'];

  /// Human-readable maximum duration
  static const String maxDurationFormatted = '10 minutes';

  /// Human-readable maximum file size
  static const String maxFileSizeFormatted = '500 MB';
}

/// Result of video validation
class VideoValidationResult {
  /// Creates a valid result with duration and file size
  const VideoValidationResult.valid({
    required int this.durationSeconds,
    required int this.fileSizeBytes,
  })  : isValid = true,
        error = null;

  /// Creates an invalid result with an error message
  const VideoValidationResult.invalid(String this.error)
      : isValid = false,
        durationSeconds = null,
        fileSizeBytes = null;

  /// Creates a partial valid result (used for single-field validation)
  const VideoValidationResult._validPartial()
      : isValid = true,
        error = null,
        durationSeconds = null,
        fileSizeBytes = null;

  /// Whether the video is valid
  final bool isValid;

  /// Error message if invalid
  final String? error;

  /// Video duration in seconds (only set when valid with full info)
  final int? durationSeconds;

  /// File size in bytes (only set when valid with full info)
  final int? fileSizeBytes;
}

/// Validates a video file extension
///
/// Returns a [VideoValidationResult] indicating whether the extension is allowed.
/// Accepts mp4, mov, and m4v extensions (case insensitive).
VideoValidationResult validateVideoExtension(String filePath) {
  final ext = getExtension(filePath).toLowerCase();
  if (!VideoConstants.allowedExtensions.contains(ext)) {
    return const VideoValidationResult.invalid(
      'Please select an MP4, MOV, or M4V video',
    );
  }
  return const VideoValidationResult._validPartial();
}

/// Validates video file size
///
/// Returns a [VideoValidationResult] indicating whether the file size is within limits.
/// Maximum allowed size is 500 MB (524,288,000 bytes).
VideoValidationResult validateVideoFileSize(int fileSizeBytes) {
  if (fileSizeBytes > VideoConstants.maxFileSizeBytes) {
    return const VideoValidationResult.invalid(
      'Video must be 500 MB or less',
    );
  }
  return const VideoValidationResult._validPartial();
}

/// Validates video duration
///
/// Returns a [VideoValidationResult] indicating whether the duration is within limits.
/// Maximum allowed duration is 10 minutes (600 seconds).
VideoValidationResult validateVideoDuration(int durationSeconds) {
  if (durationSeconds > VideoConstants.maxDurationSeconds) {
    return const VideoValidationResult.invalid(
      'Video must be 10 minutes or less',
    );
  }
  return const VideoValidationResult._validPartial();
}

/// Checks if a file extension is a valid video extension
///
/// Returns true if the extension is mp4, mov, or m4v (case insensitive).
bool isVideoExtension(String extension) {
  return VideoConstants.allowedExtensions.contains(extension.toLowerCase());
}

/// Extracts file extension from a file path
///
/// Returns the extension without the dot, or empty string if no extension.
String getExtension(String filePath) {
  if (filePath.isEmpty) return '';
  final lastDot = filePath.lastIndexOf('.');
  if (lastDot == -1 || lastDot == filePath.length - 1) return '';
  return filePath.substring(lastDot + 1);
}

/// Formats duration in seconds to MM:SS string
///
/// Example: formatDuration(125) returns "2:05"
String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final remainingSeconds = seconds % 60;
  return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
}

/// Formats file size in bytes to human-readable string
///
/// Example: formatFileSize(5242880) returns "5.0 MB"
String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    return '${(bytes / 1024).toStringAsFixed(1)} KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  } else {
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
