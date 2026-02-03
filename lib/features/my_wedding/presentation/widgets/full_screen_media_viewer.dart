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
class FullScreenMediaViewer extends StatefulWidget {
  /// Creates a full-screen media viewer.
  const FullScreenMediaViewer({
    super.key,
    required this.imageUrl,
    this.isVideo = false,
    this.fileName,
    this.caption,
  });

  /// The URL of the media to display.
  final String imageUrl;

  /// Whether this is a video (affects icon display).
  final bool isVideo;

  /// Optional filename for download.
  final String? fileName;

  /// Optional caption to display.
  final String? caption;

  /// Shows the viewer as a full-screen route.
  static void show(
    BuildContext context, {
    required String imageUrl,
    bool isVideo = false,
    String? fileName,
    String? caption,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenMediaViewer(
          imageUrl: imageUrl,
          isVideo: isVideo,
          fileName: fileName,
          caption: caption,
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

  // Video player state
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _showControls = true;

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
    if (!mounted) return;

    final isPlaying = _videoController?.value.isPlaying ?? false;
    if (isPlaying != _isVideoPlaying) {
      setState(() {
        _isVideoPlaying = isPlaying;
      });
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

            // Caption at bottom if provided
            if (widget.caption != null && widget.caption!.isNotEmpty)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.caption!,
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized || _videoController == null) {
      // Loading state
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

          // Play/Pause overlay
          if (_showControls)
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
              value: position.inMilliseconds.toDouble(),
              min: 0,
              max: duration.inMilliseconds.toDouble().clamp(1, double.infinity),
              onChanged: (value) {
                _videoController!.seekTo(Duration(milliseconds: value.toInt()));
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
