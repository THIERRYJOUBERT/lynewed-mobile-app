/// Video URL helpers for YouTube, Vimeo, and direct video files
/// 
/// Provides utilities to:
/// - Detect video platform from URL
/// - Extract video IDs
/// - Validate video URLs
library;

/// Video platform types
enum VideoPlatform {
  youtube,
  vimeo,
  directFile,
  unknown,
}

/// Video URL helper utilities
class VideoUrlHelpers {
  VideoUrlHelpers._();

  /// YouTube URL patterns
  static final _youtubePatterns = [
    RegExp(r'(?:youtube\.com\/watch\?v=|youtu\.be\/)([a-zA-Z0-9_-]{11})'),
    RegExp(r'youtube\.com\/embed\/([a-zA-Z0-9_-]{11})'),
    RegExp(r'youtube\.com\/v\/([a-zA-Z0-9_-]{11})'),
  ];

  /// Vimeo URL patterns
  static final _vimeoPatterns = [
    RegExp(r'vimeo\.com\/(\d+)'),
    RegExp(r'player\.vimeo\.com\/video\/(\d+)'),
  ];

  /// Direct video file extensions
  static const _videoExtensions = ['.mp4', '.m4v', '.mov', '.webm', '.avi'];

  /// Detect the video platform from a URL
  static VideoPlatform detectPlatform(String? url) {
    if (url == null || url.isEmpty) return VideoPlatform.unknown;

    final lowerUrl = url.toLowerCase();

    // Check YouTube
    if (lowerUrl.contains('youtube.com') || lowerUrl.contains('youtu.be')) {
      return VideoPlatform.youtube;
    }

    // Check Vimeo
    if (lowerUrl.contains('vimeo.com')) {
      return VideoPlatform.vimeo;
    }

    // Check direct video file
    for (final ext in _videoExtensions) {
      if (lowerUrl.endsWith(ext)) {
        return VideoPlatform.directFile;
      }
    }

    return VideoPlatform.unknown;
  }

  /// Check if URL is a valid YouTube URL
  static bool isYouTubeUrl(String? url) {
    return detectPlatform(url) == VideoPlatform.youtube;
  }

  /// Check if URL is a valid Vimeo URL
  static bool isVimeoUrl(String? url) {
    return detectPlatform(url) == VideoPlatform.vimeo;
  }

  /// Check if URL is a direct video file
  static bool isDirectVideoUrl(String? url) {
    return detectPlatform(url) == VideoPlatform.directFile;
  }

  /// Check if URL is a valid video URL (any supported platform)
  static bool isValidVideoUrl(String? url) {
    final platform = detectPlatform(url);
    return platform != VideoPlatform.unknown;
  }

  /// Check if URL is a streamable video (YouTube or Vimeo)
  static bool isStreamableVideoUrl(String? url) {
    final platform = detectPlatform(url);
    return platform == VideoPlatform.youtube || platform == VideoPlatform.vimeo;
  }

  /// Extract YouTube video ID from URL
  /// Returns null if not a valid YouTube URL
  static String? extractYouTubeId(String? url) {
    if (url == null || url.isEmpty) return null;

    for (final pattern in _youtubePatterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Extract Vimeo video ID from URL
  /// Returns null if not a valid Vimeo URL
  static String? extractVimeoId(String? url) {
    if (url == null || url.isEmpty) return null;

    for (final pattern in _vimeoPatterns) {
      final match = pattern.firstMatch(url);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  /// Get YouTube thumbnail URL from video ID
  static String? getYouTubeThumbnail(String? videoId, {String quality = 'hqdefault'}) {
    if (videoId == null || videoId.isEmpty) return null;
    // Quality options: default, mqdefault, hqdefault, sddefault, maxresdefault
    return 'https://img.youtube.com/vi/$videoId/$quality.jpg';
  }

  /// Get YouTube embed URL from video ID
  static String? getYouTubeEmbedUrl(String? videoId) {
    if (videoId == null || videoId.isEmpty) return null;
    return 'https://www.youtube.com/embed/$videoId';
  }

  /// Get Vimeo thumbnail URL (requires API call, returns placeholder)
  /// Note: Vimeo thumbnails require an API call to fetch
  static String? getVimeoThumbnailPlaceholder(String? videoId) {
    // Vimeo doesn't have a simple thumbnail URL pattern
    // Would need to call Vimeo API: https://vimeo.com/api/v2/video/{id}.json
    return null;
  }
}
