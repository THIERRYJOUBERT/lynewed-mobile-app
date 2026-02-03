/// Album page for guests.
///
/// Displays the guest's personal album with photos and videos.
/// Includes FAB for uploading new media.
/// Supports downloading photos and videos.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '/core/design/design.dart';
import '/core/utils/video_utils.dart';
import '/features/my_wedding/data/datasources/download_data_source_impl.dart';
import '/features/my_wedding/domain/usecases/download_media_use_case.dart';
import '/features/my_wedding/presentation/widgets/caption_input_widget.dart';
import '/features/my_wedding/presentation/widgets/download_button.dart';
import '/features/my_wedding/presentation/widgets/media_picker_sheet.dart';
import '../../data/repositories/guest_album_repository_impl.dart';
import '../../domain/entities/guest_media.dart';
import '../../domain/repositories/guest_album_repository.dart';
import '../widgets/guest_media_grid.dart';

/// Album page for guests.
///
/// Shows the guest's personal album with photos and videos.
/// Features:
/// - FAB for uploading photos and videos
/// - Auto-creates album on first upload
/// - Grid view of uploaded media
/// - Delete via long-press
/// - Progress indicator during upload
class GuestAlbumPage extends StatefulWidget {
  /// Creates a guest album page.
  const GuestAlbumPage({super.key});

  @override
  State<GuestAlbumPage> createState() => _GuestAlbumPageState();
}

class _GuestAlbumPageState extends State<GuestAlbumPage> {
  final _imagePicker = ImagePicker();
  late GuestAlbumRepository _repository;
  late DownloadMediaUseCase _downloadUseCase;

  bool _isLoading = true;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _error;
  String? _weddingId;
  List<GuestMedia> _media = [];

  @override
  void initState() {
    super.initState();
    _repository = GuestAlbumRepositoryImpl();
    _downloadUseCase = DownloadMediaUseCase(DownloadDataSourceImpl());

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadWeddingAndMedia();
    });
  }

  /// Loads the wedding ID and then the media.
  Future<void> _loadWeddingAndMedia() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get the user's joined wedding
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _error = 'Not authenticated';
          _isLoading = false;
        });
        return;
      }

      final guestInfo = await supabase
          .from('wedding_guests')
          .select('wedding_id')
          .eq('user_id', userId)
          .eq('status', 'joined')
          .maybeSingle();

      if (!mounted) return;

      if (guestInfo == null) {
        setState(() {
          _error = 'No wedding found';
          _isLoading = false;
        });
        return;
      }

      _weddingId = guestInfo['wedding_id'] as String;
      await _loadMedia();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// Loads the guest's media from the repository.
  Future<void> _loadMedia() async {
    if (!mounted || _weddingId == null) return;

    final result = await _repository.getMyMedia(weddingId: _weddingId!);

    if (!mounted) return;

    result.fold(
      onSuccess: (media) => setState(() {
        _media = media;
        _isLoading = false;
      }),
      onFailure: (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
    );
  }

  /// Shows the media picker sheet.
  void _showMediaPickerSheet() {
    MediaPickerSheet.show(
      context: context,
      onPhotoSelected: _pickAndUploadPhoto,
      onVideoSelected: _pickAndUploadVideo,
    );
  }

  /// Picks and uploads a photo from gallery.
  Future<void> _pickAndUploadPhoto() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null || !mounted) return;

      // Create file instance once to reuse
      final file = File(pickedFile.path);

      // Show upload preview with caption input
      final result = await _showUploadPreview(
        file: file,
        isVideo: false,
      );

      if (result == null || !mounted) return;

      await _uploadFile(
        file: file,
        mediaType: 'photo',
        caption: result.caption,
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to pick photo: $e');
      }
    }
  }

  /// Picks and uploads a video from gallery.
  Future<void> _pickAndUploadVideo() async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(seconds: VideoConstants.maxDurationSeconds),
      );

      if (pickedFile == null || !mounted) return;

      // Validate video extension FIRST (fast, no I/O)
      final extensionResult = validateVideoExtension(pickedFile.path);
      if (!extensionResult.isValid) {
        _showErrorSnackBar(extensionResult.error!);
        return;
      }

      // Validate file size using stat() - reads metadata only, not file content
      // This prevents OOM for very large files
      final file = File(pickedFile.path);
      final fileStat = await file.stat();
      final sizeResult = validateVideoFileSize(fileStat.size);
      if (!sizeResult.isValid) {
        _showErrorSnackBar(sizeResult.error!);
        return;
      }

      if (!mounted) return;

      // Show upload preview with caption input
      final result = await _showUploadPreview(
        file: file,
        isVideo: true,
      );

      if (result == null || !mounted) return;

      await _uploadFile(
        file: file,
        mediaType: 'video',
        caption: result.caption,
        durationSeconds: result.durationSeconds,
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to pick video: $e');
      }
    }
  }

  /// Shows the upload preview sheet with caption input.
  Future<_UploadPreviewResult?> _showUploadPreview({
    required File file,
    required bool isVideo,
  }) async {
    final captionController = TextEditingController();

    final result = await showModalBottomSheet<_UploadPreviewResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UploadPreviewSheet(
        file: file,
        isVideo: isVideo,
        captionController: captionController,
        onConfirm: () {
          Navigator.pop(
            context,
            _UploadPreviewResult(
              caption: captionController.text.isEmpty
                  ? null
                  : captionController.text,
              durationSeconds: null, // Not tracking for now
            ),
          );
        },
        onCancel: () => Navigator.pop(context),
      ),
    );

    captionController.dispose();
    return result;
  }

  /// Uploads a file to the guest's album.
  Future<void> _uploadFile({
    required File file,
    required String mediaType,
    String? caption,
    int? durationSeconds,
  }) async {
    if (_weddingId == null) {
      _showErrorSnackBar('No wedding found');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final result = await _repository.uploadMedia(
      file: file,
      weddingId: _weddingId!,
      mediaType: mediaType,
      caption: caption,
      durationSeconds: durationSeconds,
      onProgress: (progress) {
        if (mounted) {
          setState(() => _uploadProgress = progress);
        }
      },
    );

    if (!mounted) return;

    setState(() => _isUploading = false);

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              mediaType == 'video' ? 'Video uploaded' : 'Photo uploaded',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.success,
          ),
        );
        _loadMedia(); // Refresh the grid
      },
      onFailure: (failure) {
        _showErrorSnackBar(failure.message);
      },
    );
  }

  /// Shows an error snack bar.
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: LynewedColors.error,
      ),
    );
  }

  /// Handles tapping on a media item.
  void _onMediaTap(GuestMedia media) {
    // TODO: Navigate to full-screen viewer
    // For now, show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          media.isVideo ? 'Video viewer coming soon!' : 'Photo viewer coming soon!',
          style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows options for a media item (download, delete).
  void _onMediaLongPress(GuestMedia media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: LynewedColors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LynewedColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.download_rounded, color: LynewedColors.textPrimary),
              title: Text(
                media.isVideo ? 'Download Video' : 'Download Photo',
                style: LynewedTextStyles.bodyMedium,
              ),
              onTap: () {
                Navigator.pop(context);
                _downloadMedia(media);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: LynewedColors.error),
              title: Text(
                'Delete',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteMedia(media);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Downloads a single media item.
  Future<void> _downloadMedia(GuestMedia media) async {
    if (_weddingId == null) return;

    // Build the storage URL
    final supabase = Supabase.instance.client;
    final storageUrl = supabase.storage
        .from('wedding-albums')
        .getPublicUrl(media.storagePath);

    // Show download progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return DownloadProgressDialog(
            progress: 0.0,
            message: media.isVideo ? 'Downloading video...' : 'Downloading photo...',
          );
        },
      ),
    );

    final result = await _downloadUseCase.downloadSingle(
      storageUrl: storageUrl,
      fileName: media.storagePath.split('/').last,
    );

    if (!mounted) return;

    // Close progress dialog
    Navigator.of(context).pop();

    result.fold(
      onSuccess: (file) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              media.isVideo ? 'Video downloaded' : 'Photo downloaded',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.success,
          ),
        );
      },
      onFailure: (failure) {
        _showRetryDownloadDialog(failure.message, () => _downloadMedia(media));
      },
    );
  }

  /// Shows retry dialog for failed downloads.
  void _showRetryDownloadDialog(String message, VoidCallback onRetry) {
    showDialog(
      context: context,
      builder: (ctx) => RetryDownloadDialog(
        message: message,
        onCancel: () => Navigator.pop(ctx),
        onRetry: () {
          Navigator.pop(ctx);
          onRetry();
        },
      ),
    );
  }

  /// Confirms deletion of a media item.
  void _confirmDeleteMedia(GuestMedia media) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete media'),
        content: Text(
          media.isVideo
              ? 'Are you sure you want to delete this video?'
              : 'Are you sure you want to delete this photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: LynewedColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteMedia(media);
    }
  }

  /// Deletes a media item.
  Future<void> _deleteMedia(GuestMedia media) async {
    final result = await _repository.deleteMedia(mediaId: media.id);

    if (!mounted) return;

    result.fold(
      onSuccess: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Media deleted',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.success,
          ),
        );
        _loadMedia();
      },
      onFailure: (failure) {
        _showErrorSnackBar(failure.message);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            LynewedButton(
              text: 'Retry',
              onPressed: _loadWeddingAndMedia,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        // Content (grid or empty state)
        if (_media.isEmpty)
          _buildEmptyState()
        else
          GuestMediaGrid(
            media: _media,
            onRefresh: _loadMedia,
            onMediaTap: _onMediaTap,
            onMediaLongPress: _onMediaLongPress,
          ),

        // FAB for adding media
        Positioned(
          right: 0,
          bottom: 0,
          child: FloatingActionButton(
            onPressed: _isUploading ? null : _showMediaPickerSheet,
            backgroundColor: _isUploading
                ? LynewedColors.gray300
                : LynewedColors.primary,
            child: _isUploading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: _uploadProgress,
                      strokeWidth: 2,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        LynewedColors.background,
                      ),
                    ),
                  )
                : Icon(
                    Icons.add,
                    color: LynewedColors.background,
                  ),
          ),
        ),
      ],
    );
  }

  /// Builds the empty state widget.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: LynewedColors.gray300,
          ),
          SizedBox(height: LynewedSpacing.lg),
          Text(
            'Your Wedding Memories',
            style: LynewedTextStyles.titleSmall.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          SizedBox(height: LynewedSpacing.sm),
          Text(
            'Tap the + button to add\nphotos and videos',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Result from the upload preview sheet.
class _UploadPreviewResult {
  const _UploadPreviewResult({
    this.caption,
    this.durationSeconds,
  });

  final String? caption;
  final int? durationSeconds;
}

/// Upload preview sheet with file preview and caption input.
class _UploadPreviewSheet extends StatelessWidget {
  const _UploadPreviewSheet({
    required this.file,
    required this.isVideo,
    required this.captionController,
    required this.onConfirm,
    required this.onCancel,
  });

  final File file;
  final bool isVideo;
  final TextEditingController captionController;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LynewedColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                isVideo ? 'Upload Video' : 'Upload Photo',
                style: LynewedTextStyles.sheetTitle,
              ),
              const SizedBox(height: 20),

              // Preview (for photos only, videos would need thumbnail)
              if (!isVideo)
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      file,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Center(
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: LynewedColors.gray200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.videocam,
                          size: 48,
                          color: LynewedColors.gray300,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Video selected',
                          style: LynewedTextStyles.bodyMedium.copyWith(
                            color: LynewedColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),

              // Caption input using CaptionInputWidget
              CaptionInputWidget(
                controller: captionController,
                label: 'Caption (optional)',
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: LynewedButton(
                      text: 'Cancel',
                      onPressed: onCancel,
                      type: LynewedButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LynewedButton(
                      text: 'Upload',
                      onPressed: onConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
