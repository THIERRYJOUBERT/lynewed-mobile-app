/// Full-screen media viewer widget.
///
/// Displays photos and videos in full-screen with zoom, download,
/// and close functionality.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '/core/design/design.dart';
import '../../data/datasources/download_data_source_impl.dart';
import '../../domain/usecases/download_media_use_case.dart';
import 'download_button.dart';

/// Full-screen viewer for photos and videos.
///
/// Features:
/// - Pinch to zoom (photos)
/// - Tap to close
/// - Download button with progress
/// - Dark background for immersive viewing
/// - Info panel with caption and metadata
class FullScreenMediaViewer extends StatefulWidget {
  /// Creates a full-screen media viewer.
  const FullScreenMediaViewer({
    super.key,
    required this.imageUrl,
    this.isVideo = false,
    this.fileName,
    this.caption,
    this.createdAt,
    this.durationSeconds,
    this.fileSizeBytes,
  });

  /// The URL of the media to display.
  final String imageUrl;

  /// Whether this is a video (affects icon display).
  final bool isVideo;

  /// Optional filename for download.
  final String? fileName;

  /// Optional caption to display.
  final String? caption;

  /// When the media was uploaded.
  final DateTime? createdAt;

  /// Video duration in seconds.
  final int? durationSeconds;

  /// File size in bytes.
  final int? fileSizeBytes;

  /// Shows the viewer as a full-screen route.
  static void show(
    BuildContext context, {
    required String imageUrl,
    bool isVideo = false,
    String? fileName,
    String? caption,
    DateTime? createdAt,
    int? durationSeconds,
    int? fileSizeBytes,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(
          imageUrl: imageUrl,
          isVideo: isVideo,
          fileName: fileName,
          caption: caption,
          createdAt: createdAt,
          durationSeconds: durationSeconds,
          fileSizeBytes: fileSizeBytes,
        ),
      ),
    );
  }

  @override
  State<FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<FullScreenMediaViewer> {
  late DownloadMediaUseCase _downloadUseCase;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _showInfoPanel = false;

  // Video player state
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _isBuffering = false;
  bool _hasVideoError = false;
  bool _showControls = true;

  /// Whether there is any info to show in the panel.
  bool get _hasInfoToShow =>
      (widget.caption != null && widget.caption!.isNotEmpty) ||
      widget.createdAt != null ||
      widget.durationSeconds != null ||
      widget.fileSizeBytes != null;

  @override
  void initState() {
    super.initState();
    _downloadUseCase = DownloadMediaUseCase(DownloadDataSourceImpl());

    if (widget.isVideo) {
      _initializeVideoPlayer();
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.imageUrl),
    );

    try {
      await _videoController!.initialize();
      _videoController!.addListener(_videoListener);
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
        // Auto-play the video
        _videoController!.play();
      }
    } catch (e) {
      // Video failed to load - keep showing error state
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _videoListener() {
    if (!mounted || _videoController == null) return;

    final value = _videoController!.value;

    // Check for errors
    if (value.hasError && !_hasVideoError) {
      setState(() {
        _hasVideoError = true;
      });
      return;
    }

    // Update buffering state
    final isBuffering = value.isBuffering;
    if (isBuffering != _isBuffering) {
      setState(() {
        _isBuffering = isBuffering;
      });
    }

    // Update playing state
    final isPlaying = value.isPlaying;
    if (isPlaying != _isVideoPlaying) {
      setState(() {
        _isVideoPlaying = isPlaying;
      });
    }

    // Force rebuild to update progress bar and time display
    // This ensures the slider and time labels stay in sync
    if (value.isInitialized) {
      setState(() {});
    }
  }

  void _togglePlayPause() {
    if (_videoController == null || !_isVideoInitialized) return;

    setState(() {
      if (_isVideoPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _downloadMedia() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    final fileName = widget.fileName ?? _extractFileName(widget.imageUrl);
    final result = await _downloadUseCase.downloadSingle(
      storageUrl: widget.imageUrl,
      fileName: fileName,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _isDownloading = false;
    });

    result.fold(
      onSuccess: (file) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isVideo ? 'Video downloaded' : 'Photo downloaded',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.success,
          ),
        );
      },
      onFailure: (failure) {
        showDialog(
          context: context,
          builder: (ctx) => RetryDownloadDialog(
            message: failure.message,
            onCancel: () => Navigator.pop(ctx),
            onRetry: () {
              Navigator.pop(ctx);
              _downloadMedia();
            },
          ),
        );
      },
    );
  }

  String _extractFileName(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return segments.isNotEmpty ? segments.last : 'media';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Only close on tap for photos, videos have their own controls
        onTap: widget.isVideo ? null : () => Navigator.pop(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media content with zoom
            InteractiveViewer(
              child: Center(
                child: widget.isVideo
                    ? _buildVideoPlayer()
                    : CachedNetworkImage(
                        imageUrl: widget.imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white,
                          size: 64,
                        ),
                      ),
              ),
            ),

            // Top bar with close and download buttons
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Spacer for balance
                  const SizedBox(width: 44),
                  const Spacer(),
                  // Info button (if there's info to show)
                  if (_hasInfoToShow) ...[
                    _buildActionButton(
                      onTap: () => setState(() => _showInfoPanel = !_showInfoPanel),
                      child: Icon(
                        _showInfoPanel ? Icons.info : Icons.info_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Download button
                  _buildActionButton(
                    onTap: _isDownloading ? null : _downloadMedia,
                    child: _isDownloading
                        ? _buildDownloadProgress()
                        : const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 8),
                  // Close button
                  _buildActionButton(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            // Info panel at bottom
            if (_showInfoPanel && _hasInfoToShow)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildInfoPanel(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Caption
          if (widget.caption != null && widget.caption!.isNotEmpty) ...[
            Text(
              widget.caption!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Metadata row
          Row(
            children: [
              // Timestamp
              if (widget.createdAt != null) ...[
                Icon(
                  Icons.access_time,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(widget.createdAt!),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // Duration (for videos)
              if (widget.durationSeconds != null) ...[
                Icon(
                  Icons.videocam_outlined,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDurationSeconds(widget.durationSeconds!),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(width: 16),
              ],

              // File size
              if (widget.fileSizeBytes != null) ...[
                Icon(
                  Icons.sd_storage_outlined,
                  color: Colors.white70,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatFileSize(widget.fileSizeBytes!),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return 'Today at $hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];
      return '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    }
  }

  String _formatDurationSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  Widget _buildVideoPlayer() {
    // Error state
    if (_hasVideoError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white54,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load video',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    // Loading state
    if (!_isVideoInitialized || _videoController == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: _toggleControls,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),

          // Buffering indicator
          if (_isBuffering)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
            ),

          // Play/Pause overlay (hide when buffering)
          if (_showControls && !_isBuffering)
            GestureDetector(
              onTap: _togglePlayPause,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isVideoPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),

          // Progress bar at bottom
          if (_showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildVideoProgressBar(),
            ),
        ],
      ),
    );
  }

  Widget _buildVideoProgressBar() {
    final duration = _videoController!.value.duration;
    final position = _videoController!.value.position;

    // Clamp position to valid range to prevent slider errors
    final maxMs = duration.inMilliseconds.toDouble();
    final posMs = position.inMilliseconds.toDouble().clamp(0.0, maxMs > 0 ? maxMs : 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: LynewedColors.primary,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
              thumbColor: LynewedColors.primary,
            ),
            child: Slider(
              value: posMs,
              min: 0,
              max: maxMs > 0 ? maxMs : 1.0,
              onChanged: (value) {
                final seekPosition = Duration(milliseconds: value.toInt());
                _videoController!.seekTo(seekPosition);
              },
            ),
          ),
          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Widget _buildActionButton({
    required VoidCallback? onTap,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }

  Widget _buildDownloadProgress() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: _downloadProgress,
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        Text(
          '${(_downloadProgress * 100).toInt()}%',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
