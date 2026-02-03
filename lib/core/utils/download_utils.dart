/// Download utility functions for media file downloads.
///
/// Provides helper functions for file naming, extension handling,
/// and file size formatting.
library;

/// Utility class for download-related operations.
class DownloadUtils {
  /// Private constructor to prevent instantiation.
  DownloadUtils._();

  /// Video file extensions.
  static const _videoExtensions = ['mp4', 'mov', 'm4v', 'avi', 'mkv', 'webm'];

  /// Generates a unique filename by appending a timestamp.
  ///
  /// Example: 'photo.jpg' -> 'photo_1706789012345.jpg'
  static String generateUniqueFileName(String baseName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = getFileExtension(baseName);

    if (extension.isEmpty) {
      return '${baseName}_$timestamp';
    }

    // Remove the extension, add timestamp, then add extension back
    final nameWithoutExt = baseName.substring(0, baseName.lastIndexOf('.'));
    return '${nameWithoutExt}_$timestamp.$extension';
  }

  /// Gets the file extension from a filename.
  ///
  /// Returns lowercase extension without the dot.
  /// Returns empty string if no extension found.
  static String getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1 || lastDotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(lastDotIndex + 1).toLowerCase();
  }

  /// Checks if a filename represents a video file.
  ///
  /// Based on the file extension.
  static bool isVideoFile(String fileName) {
    final extension = getFileExtension(fileName);
    return _videoExtensions.contains(extension);
  }

  /// Generates a zip filename for a wedding's media download.
  ///
  /// Format: '{weddingId}_media_{timestamp}.zip'
  static String generateZipFileName(String weddingId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${weddingId}_media_$timestamp.zip';
  }

  /// Formats a file size in bytes to a human-readable string.
  ///
  /// Examples: '500 B', '1.5 KB', '2.3 MB', '1.0 GB'
  static String formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var i = 0;
    var size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    if (i == 0) {
      return '$bytes ${suffixes[i]}';
    }
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}
