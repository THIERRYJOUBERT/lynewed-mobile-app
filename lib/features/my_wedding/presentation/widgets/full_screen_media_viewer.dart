/// Full-screen media viewer widget.
///
/// Displays photos and videos in full-screen with zoom, download,
/// and close functionality.
library;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _downloadUseCase = DownloadMediaUseCase(DownloadDataSourceImpl());
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
        onTap: () => Navigator.pop(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Media content with zoom
            InteractiveViewer(
              child: Center(
                child: widget.isVideo
                    ? _buildVideoPlaceholder()
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

  Widget _buildVideoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.videocam_rounded,
          color: Colors.white54,
          size: 64,
        ),
        const SizedBox(height: 16),
        Text(
          'Video playback coming soon',
          style: LynewedTextStyles.bodyMedium.copyWith(
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap download to save',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: Colors.white38,
          ),
        ),
      ],
    );
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
