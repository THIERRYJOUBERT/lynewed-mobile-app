/// Album page for guests.
///
/// Displays the guest's personal album with photos and videos.
/// Includes FAB for uploading new media.
/// Supports downloading photos and videos.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '/core/design/design.dart';
import '/core/utils/video_utils.dart';
import '/features/my_wedding/data/datasources/download_data_source_impl.dart';
import '/features/my_wedding/domain/usecases/download_media_use_case.dart';
import '/features/my_wedding/presentation/widgets/caption_input_widget.dart';
import '/features/my_wedding/presentation/widgets/download_button.dart';
import '/features/my_wedding/presentation/widgets/full_screen_media_viewer.dart';
import '/features/my_wedding/presentation/widgets/media_picker_sheet.dart';
import '/core/constants/cgvu_texts.dart';
import '/features/my_wedding/domain/usecases/accept_cgvu_use_case.dart';
import '../dialogs/media_upload_cgvu_dialog.dart';
import '../../data/repositories/guest_album_repository_impl.dart';
import '../../domain/entities/guest_media.dart';
import '../../domain/repositories/guest_album_repository.dart';
import '../widgets/album_filter_chips.dart';
import '../widgets/album_stats_header.dart';
import '../widgets/date_group_header.dart';
import '../widgets/guest_media_tile.dart';

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
  const GuestAlbumPage({super.key, this.brideName});

  /// Bride's name for personalized UI.
  final String? brideName;

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
  Set<String> _favoritedIds = {};
  AlbumFilter _activeFilter = AlbumFilter.all;
  bool _cgvuAccepted = false;

  @override
  void initState() {
    super.initState();
    _repository = GuestAlbumRepositoryImpl();
    _downloadUseCase = DownloadMediaUseCase(DownloadDataSourceImpl());

    _checkInitialCgvuAcceptance();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadWeddingAndMedia();
    });
  }

  /// Checks CGVU acceptance status at page init (cache warm-up).
  Future<void> _checkInitialCgvuAcceptance() async {
    try {
      final useCase = const AcceptCgvuUseCase();
      final alreadyAccepted = await useCase.hasAccepted(
        cgvuType: guestMediaUploadCgvuType,
        cgvuVersion: guestMediaUploadCgvuVersion,
      );
      if (!mounted) return;
      setState(() => _cgvuAccepted = alreadyAccepted);
    } catch (_) {
      // If DB check fails, stay false -> dialog will show
      if (!mounted) return;
      setState(() => _cgvuAccepted = false);
    }
  }

  /// Ensures CGVU is accepted before allowing upload.
  ///
  /// Returns true if upload can proceed, false otherwise.
  /// Guards against parallel uploads and shows CGVU dialog if needed.
  Future<bool> _ensureCgvuAccepted() async {
    // Guard against parallel uploads
    if (_isUploading) {
      _showErrorSnackBar('Please wait for current upload to finish');
      return false;
    }

    if (_cgvuAccepted) return true;

    if (!mounted) return false;
    final accepted = await showMediaUploadCgvuDialog(
      context: context,
      onAccepted: () {},
    );
    if (accepted && mounted) {
      setState(() => _cgvuAccepted = true);
    }
    return accepted;
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

  /// Loads the guest's media and favorites from the repository.
  Future<void> _loadMedia() async {
    if (!mounted || _weddingId == null) return;

    final result = await _repository.getMyMedia(weddingId: _weddingId!);

    if (!mounted) return;

    result.fold(
      onSuccess: (media) {
        setState(() {
          _media = media;
          _isLoading = false;
        });
        // Load favorites in background (non-blocking)
        _loadFavorites();
      },
      onFailure: (failure) => setState(() {
        _error = failure.message;
        _isLoading = false;
      }),
    );
  }

  /// Loads favorited media IDs from the repository.
  Future<void> _loadFavorites() async {
    if (!mounted || _weddingId == null || _media.isEmpty) return;

    final result =
        await _repository.getFavoritedMediaIds(weddingId: _weddingId!);

    if (!mounted) return;

    result.fold(
      onSuccess: (ids) => setState(() => _favoritedIds = ids),
      onFailure: (_) {}, // Silently fail - favorites are non-critical
    );
  }

  /// Returns the filtered media list based on the active filter.
  List<GuestMedia> get _filteredMedia {
    switch (_activeFilter) {
      case AlbumFilter.all:
        return _media;
      case AlbumFilter.photos:
        return _media.where((m) => m.isPhoto).toList();
      case AlbumFilter.videos:
        return _media.where((m) => m.isVideo).toList();
    }
  }

  /// Groups media by date, returning an ordered map.
  Map<String, List<GuestMedia>> _groupByDate(List<GuestMedia> media) {
    final groups = <String, List<GuestMedia>>{};
    for (final item in media) {
      final key = DateGroupHeader.formatDateLabel(item.createdAt.toLocal());
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  /// Shows the media picker sheet.
  void _showMediaPickerSheet() {
    MediaPickerSheet.show(
      context: context,
      onPhotoSelected: _pickAndUploadPhoto,
      onVideoSelected: _pickAndUploadVideo,
      onMultipleSelected: _pickAndUploadMultipleMedia,
    );
  }

  /// Picks and uploads multiple media from gallery.
  Future<void> _pickAndUploadMultipleMedia() async {
    if (!await _ensureCgvuAccepted()) return;
    try {
      // pickMultipleMedia allows selecting both photos and videos
      final pickedFiles = await _imagePicker.pickMultipleMedia();

      if (pickedFiles.isEmpty || !mounted) return;

      // Show multi-media preview sheet
      final result = await _showMultiMediaPreview(files: pickedFiles);

      if (result == null || !mounted) return;

      await _uploadMultipleFiles(
        files: result.files,
        caption: result.caption,
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to pick media: $e');
      }
    }
  }

  /// Shows preview sheet for multiple media.
  Future<_MultiMediaPreviewResult?> _showMultiMediaPreview({
    required List<XFile> files,
  }) async {
    return showModalBottomSheet<_MultiMediaPreviewResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _MultiMediaPreviewSheet(
        files: files,
        onConfirm: (caption, selectedFiles) {
          Navigator.pop(
            sheetContext,
            _MultiMediaPreviewResult(
              files: selectedFiles,
              caption: caption,
            ),
          );
        },
        onCancel: () => Navigator.pop(sheetContext),
      ),
    );
  }

  /// Uploads multiple files to the guest's album with parallelization.
  ///
  /// Optimizations:
  /// - Compresses images before upload (30-50% smaller)
  /// - Processes up to 3 files concurrently
  /// - Generates video thumbnails in parallel
  Future<void> _uploadMultipleFiles({
    required List<XFile> files,
    String? caption,
  }) async {
    if (_weddingId == null) {
      _showErrorSnackBar('No wedding found');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    int successCount = 0;
    int failCount = 0;
    final totalFiles = files.length;
    int completedFiles = 0;

    // Prepare upload data for each file (validation + preprocessing)
    final preparedFiles = <_PreparedUploadFile>[];
    for (int i = 0; i < files.length; i++) {
      final xFile = files[i];
      final isVideo = _isVideoFile(xFile.path);

      // Validate video
      if (isVideo) {
        final extensionResult = validateVideoExtension(xFile.path);
        if (!extensionResult.isValid) {
          failCount++;
          continue;
        }

        final file = File(xFile.path);
        final fileStat = await file.stat();
        final sizeResult = validateVideoFileSize(fileStat.size);
        if (!sizeResult.isValid) {
          failCount++;
          continue;
        }
      }

      preparedFiles.add(_PreparedUploadFile(
        originalFile: xFile,
        isVideo: isVideo,
        index: i,
      ));
    }

    if (preparedFiles.isEmpty) {
      setState(() => _isUploading = false);
      _showErrorSnackBar('No valid files to upload');
      return;
    }

    // Process files with concurrency limit (3 simultaneous)
    await _processWithConcurrencyLimit(
      preparedFiles,
      (prepared) async {
        try {
          File fileToUpload;
          String? thumbnailPath;

          if (prepared.isVideo) {
            // Generate thumbnail for video
            thumbnailPath = await _generateVideoThumbnail(
              prepared.originalFile.path,
            );
            fileToUpload = File(prepared.originalFile.path);
          } else {
            // Compress image before upload
            fileToUpload = await _compressImage(prepared.originalFile.path);
          }

          final result = await _repository.uploadMedia(
            file: fileToUpload,
            weddingId: _weddingId!,
            mediaType: prepared.isVideo ? 'video' : 'photo',
            caption: prepared.index == 0 ? caption : null,
            thumbnailPath: thumbnailPath,
          );

          result.fold(
            onSuccess: (_) => successCount++,
            onFailure: (_) => failCount++,
          );

          // Clean up temporary files
          if (thumbnailPath != null) {
            try {
              await File(thumbnailPath).delete();
            } catch (_) {}
          }
          // Clean up compressed image (if different from original)
          if (!prepared.isVideo &&
              fileToUpload.path != prepared.originalFile.path) {
            try {
              await fileToUpload.delete();
            } catch (_) {}
          }
        } catch (e) {
          failCount++;
        }

        // Update progress
        completedFiles++;
        if (mounted) {
          setState(() => _uploadProgress = completedFiles / totalFiles);
        }
      },
      maxConcurrent: 3,
    );

    if (!mounted) return;

    setState(() => _isUploading = false);

    // Show result
    if (failCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$successCount ${successCount == 1 ? 'item' : 'items'} uploaded',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$successCount uploaded, $failCount failed',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor:
              successCount > 0 ? LynewedColors.warning : LynewedColors.error,
        ),
      );
    }

    _loadMedia(); // Refresh the grid
  }

  /// Processes items with a concurrency limit.
  ///
  /// Unlike simple chunking, this starts a new task as soon as one completes,
  /// maximizing throughput.
  Future<void> _processWithConcurrencyLimit<T>(
    List<T> items,
    Future<void> Function(T) processor, {
    int maxConcurrent = 3,
  }) async {
    if (items.isEmpty) return;

    var nextIndex = 0;
    var runningCount = 0;
    final completer = Completer<void>();

    void startNext() {
      while (runningCount < maxConcurrent && nextIndex < items.length) {
        final index = nextIndex++;
        runningCount++;

        processor(items[index]).whenComplete(() {
          runningCount--;

          if (nextIndex < items.length) {
            startNext();
          } else if (runningCount == 0) {
            completer.complete();
          }
        });
      }
    }

    startNext();
    await completer.future;
  }

  /// Compresses an image file for faster upload.
  ///
  /// Returns the compressed file, or the original if compression fails.
  Future<File> _compressImage(String imagePath) async {
    try {
      final tempDir = Directory.systemTemp;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final targetPath = '${tempDir.path}/compressed_$timestamp.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        quality: 85,
        minWidth: 1920,
        minHeight: 1920,
      );

      if (result != null) {
        return File(result.path);
      }
    } catch (e) {
      // Compression failed, use original
    }
    return File(imagePath);
  }

  /// Generates a thumbnail for a video file.
  Future<String?> _generateVideoThumbnail(String videoPath) async {
    try {
      final thumbnail = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 75,
      );
      return thumbnail;
    } catch (e) {
      // Failed to generate thumbnail - continue without it
      return null;
    }
  }

  /// Checks if a file path is a video.
  bool _isVideoFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'].contains(ext);
  }

  /// Picks and uploads a photo from gallery.
  Future<void> _pickAndUploadPhoto() async {
    if (!await _ensureCgvuAccepted()) return;
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
    if (!await _ensureCgvuAccepted()) return;
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

      // Generate thumbnail
      final thumbnailPath = await _generateVideoThumbnail(pickedFile.path);

      // Show upload preview with caption input
      final result = await _showUploadPreview(
        file: file,
        isVideo: true,
        thumbnailPath: thumbnailPath,
      );

      if (result == null || !mounted) return;

      await _uploadFile(
        file: file,
        mediaType: 'video',
        caption: result.caption,
        durationSeconds: result.durationSeconds,
        thumbnailPath: thumbnailPath,
      );

      // Clean up temporary thumbnail
      if (thumbnailPath != null) {
        try {
          await File(thumbnailPath).delete();
        } catch (_) {
          // Ignore cleanup errors
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to pick video: $e');
      }
    }
  }

  /// Shows the upload preview sheet with caption input.
  ///
  /// The sheet manages its own TextEditingController internally to avoid
  /// lifecycle issues when dismissed.
  Future<_UploadPreviewResult?> _showUploadPreview({
    required File file,
    required bool isVideo,
    String? thumbnailPath,
  }) async {
    final result = await showModalBottomSheet<_UploadPreviewResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _UploadPreviewSheet(
        file: file,
        isVideo: isVideo,
        thumbnailPath: thumbnailPath,
        onConfirm: (caption) {
          Navigator.pop(
            sheetContext,
            _UploadPreviewResult(
              caption: caption,
              durationSeconds: null, // Not tracking for now
            ),
          );
        },
        onCancel: () => Navigator.pop(sheetContext),
      ),
    );

    return result;
  }

  /// Uploads a file to the guest's album.
  Future<void> _uploadFile({
    required File file,
    required String mediaType,
    String? caption,
    int? durationSeconds,
    String? thumbnailPath,
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
      thumbnailPath: thumbnailPath,
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
    // Build the storage URL for the media
    final supabase = Supabase.instance.client;
    final storageUrl = supabase.storage
        .from('wedding-albums')
        .getPublicUrl(media.storagePath);

    // Open full-screen viewer
    FullScreenMediaViewer.show(
      context,
      imageUrl: storageUrl,
      isVideo: media.isVideo,
      fileName: media.storagePath.split('/').last,
      caption: media.caption,
      createdAt: media.createdAt,
      durationSeconds: media.durationSeconds,
      fileSizeBytes: media.fileSizeBytes,
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

    if (_media.isEmpty) {
      return Stack(
        children: [
          _buildEmptyState(),
          _buildFab(),
        ],
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadMedia,
          color: LynewedColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Stats header
              SliverToBoxAdapter(
                child: AlbumStatsHeader(
                  photoCount: _media.where((m) => m.isPhoto).length,
                  videoCount: _media.where((m) => m.isVideo).length,
                  lovedCount: _favoritedIds.length,
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: AlbumFilterChips(
                  activeFilter: _activeFilter,
                  onFilterChanged: (filter) =>
                      setState(() => _activeFilter = filter),
                ),
              ),

              // Date-grouped masonry grids
              ..._buildDateGroupedSlivers(),

              // Bottom padding for FAB
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),

        // FAB
        _buildFab(),
      ],
    );
  }

  /// Builds the sliver list of date-grouped masonry grids.
  List<Widget> _buildDateGroupedSlivers() {
    final filtered = _filteredMedia;
    if (filtered.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _activeFilter == AlbumFilter.photos
                        ? Icons.photo_camera_outlined
                        : Icons.videocam_outlined,
                    size: 48,
                    color: LynewedColors.gray300,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _activeFilter == AlbumFilter.photos
                        ? 'No photos yet'
                        : 'No videos yet',
                    style: LynewedTextStyles.bodyMedium.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    final dateGroups = _groupByDate(filtered);
    final slivers = <Widget>[];

    for (final entry in dateGroups.entries) {
      final label = entry.key;
      final items = entry.value;

      // Date header
      slivers.add(
        SliverToBoxAdapter(
          child: DateGroupHeader(label: label, itemCount: items.length),
        ),
      );

      // Masonry grid for this date group
      slivers.add(
        SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          childCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GuestMediaTile(
              media: item,
              onTap: () => _onMediaTap(item),
              onLongPress: () => _onMediaLongPress(item),
              isFavorited: _favoritedIds.contains(item.id),
              isHero: index == 0,
            );
          },
        ),
      );
    }

    return slivers;
  }

  /// Builds the FAB for adding media.
  Widget _buildFab() {
    return Positioned(
      right: 0,
      bottom: 0,
      child: FloatingActionButton(
        onPressed: _isUploading ? null : _showMediaPickerSheet,
        backgroundColor:
            _isUploading ? LynewedColors.gray300 : LynewedColors.primary,
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
    );
  }

  /// Builds the empty state widget.
  Widget _buildEmptyState() {
    final brideName = widget.brideName ?? 'the wedding';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: LynewedColors.gray200,
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.camera_alt_outlined,
              size: 40,
              color: LynewedColors.gray300,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Capture the Moment',
            style: LynewedTextStyles.headlineMedium.copyWith(
              color: LynewedColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Share your photos and videos\nfrom $brideName's wedding",
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LynewedButton(
            text: 'Add Your First Photo',
            onPressed: _showMediaPickerSheet,
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
///
/// This is a StatefulWidget that manages its own TextEditingController
/// to avoid lifecycle issues when the sheet is dismissed.
class _UploadPreviewSheet extends StatefulWidget {
  const _UploadPreviewSheet({
    required this.file,
    required this.isVideo,
    required this.onConfirm,
    required this.onCancel,
    this.thumbnailPath,
  });

  final File file;
  final bool isVideo;
  final String? thumbnailPath;

  /// Called when user confirms upload. Provides the caption text.
  final ValueChanged<String?> onConfirm;
  final VoidCallback onCancel;

  @override
  State<_UploadPreviewSheet> createState() => _UploadPreviewSheetState();
}

class _UploadPreviewSheetState extends State<_UploadPreviewSheet> {
  late final TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    final caption =
        _captionController.text.isEmpty ? null : _captionController.text;
    widget.onConfirm(caption);
  }

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
                widget.isVideo ? 'Upload Video' : 'Upload Photo',
                style: LynewedTextStyles.sheetTitle,
              ),
              const SizedBox(height: 20),

              // Preview
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPreview(),
                ),
              ),
              const SizedBox(height: 20),

              // Caption input using CaptionInputWidget
              CaptionInputWidget(
                controller: _captionController,
                label: 'Caption (optional)',
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: LynewedButton(
                      text: 'Cancel',
                      onPressed: widget.onCancel,
                      type: LynewedButtonType.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LynewedButton(
                      text: 'Upload',
                      onPressed: _handleConfirm,
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

  Widget _buildPreview() {
    // For photos, show the image
    if (!widget.isVideo) {
      return Image.file(
        widget.file,
        height: 200,
        fit: BoxFit.cover,
      );
    }

    // For videos with thumbnail, show the thumbnail with play icon
    if (widget.thumbnailPath != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Image.file(
            File(widget.thumbnailPath!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      );
    }

    // Fallback for videos without thumbnail
    return Container(
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
    );
  }
}

/// Result from multi-media preview sheet.
class _MultiMediaPreviewResult {
  const _MultiMediaPreviewResult({
    required this.files,
    this.caption,
  });

  final List<XFile> files;
  final String? caption;
}

/// Multi-media preview sheet with grid preview and caption input.
class _MultiMediaPreviewSheet extends StatefulWidget {
  const _MultiMediaPreviewSheet({
    required this.files,
    required this.onConfirm,
    required this.onCancel,
  });

  final List<XFile> files;
  final void Function(String? caption, List<XFile> selectedFiles) onConfirm;
  final VoidCallback onCancel;

  @override
  State<_MultiMediaPreviewSheet> createState() => _MultiMediaPreviewSheetState();
}

class _MultiMediaPreviewSheetState extends State<_MultiMediaPreviewSheet> {
  late final TextEditingController _captionController;
  late Set<int> _selectedIndices;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
    // Select all files by default
    _selectedIndices = Set.from(List.generate(widget.files.length, (i) => i));
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _handleConfirm() {
    if (_selectedIndices.isEmpty) return;

    final caption =
        _captionController.text.isEmpty ? null : _captionController.text;
    final selectedFiles =
        _selectedIndices.map((i) => widget.files[i]).toList();
    widget.onConfirm(caption, selectedFiles);
  }

  bool _isVideoFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'].contains(ext);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedIndices.length;

    return Container(
      decoration: const BoxDecoration(
        color: LynewedColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: LynewedColors.gray300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upload ${widget.files.length} items',
                    style: LynewedTextStyles.sheetTitle,
                  ),
                  Text(
                    '$selectedCount selected',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Grid preview
            SizedBox(
              height: 220,
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.0,
                ),
                itemCount: widget.files.length,
                itemBuilder: (context, index) {
                  final file = widget.files[index];
                  final isSelected = _selectedIndices.contains(index);
                  final isVideo = _isVideoFile(file.path);

                  return GestureDetector(
                    onTap: () => _toggleSelection(index),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isVideo
                              ? Container(
                                  color: LynewedColors.gray200,
                                  child: const Icon(
                                    Icons.videocam,
                                    color: LynewedColors.gray300,
                                  ),
                                )
                              : Image.file(
                                  File(file.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                        // Selection overlay
                        if (!isSelected)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        // Video icon
                        if (isVideo)
                          const Center(
                            child: Icon(
                              Icons.play_circle_outline,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        // Checkbox
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? LynewedColors.primary
                                  : Colors.white.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? LynewedColors.primary
                                    : LynewedColors.gray300,
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Caption input
            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CaptionInputWidget(
                    controller: _captionController,
                    label: 'Caption for all (optional)',
                  ),
                  const SizedBox(height: 24),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: LynewedButton(
                          text: 'Cancel',
                          onPressed: widget.onCancel,
                          type: LynewedButtonType.secondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LynewedButton(
                          text: 'Upload $selectedCount',
                          onPressed:
                              selectedCount > 0 ? _handleConfirm : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper class for prepared upload file data.
class _PreparedUploadFile {
  const _PreparedUploadFile({
    required this.originalFile,
    required this.isVideo,
    required this.index,
  });

  final XFile originalFile;
  final bool isVideo;
  final int index;
}
