/// Album Detail Page - View and manage images and videos in an inspiration album
///
/// Displays uploaded images, videos, and saved posts in a grid.
/// Allows uploading new photos and videos from gallery and deleting existing ones.
/// Videos are validated for duration (max 10 min) and file size (max 500 MB).
/// Supports downloading single files and multiple files via selection mode.
library;

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '/core/design/design.dart';
import '/core/utils/video_utils.dart';
import '/utils/secure_logger.dart';
import '../../data/datasources/download_data_source_impl.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';
import '../../domain/usecases/download_media_use_case.dart';
import '../bloc/magazine_selection_cubit.dart';
import '../widgets/download_button.dart';
import '../widgets/media_picker_sheet.dart';

/// Album Detail Page
class AlbumDetailPage extends StatefulWidget {
  const AlbumDetailPage({
    super.key,
    required this.album,
    required this.onUpdated,
    this.isReadOnly = false,
  });

  final InspirationAlbum album;
  final VoidCallback onUpdated;
  final bool isReadOnly;

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  late MyWeddingRepository _repository;
  late DownloadMediaUseCase _downloadUseCase;
  final _imagePicker = ImagePicker();

  bool _isLoading = true;
  bool _isUploading = false;
  String? _error;
  List<AlbumImage> _uploadedImages = [];
  List<SavedPost> _savedPosts = [];

  // Selection mode state
  bool _isSelectionMode = false;
  final Set<String> _selectedMediaIds = {};

  // Download state
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _currentDownloadId;

  @override
  void initState() {
    super.initState();
    _repository = MyWeddingRepositoryImpl();
    _downloadUseCase = DownloadMediaUseCase(DownloadDataSourceImpl());

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadImages();
    });
  }

  Future<void> _loadImages() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final results = await Future.wait([
      _repository.getAlbumImages(albumId: widget.album.id),
      _repository.getSavedPosts(albumId: widget.album.id),
    ]);

    final imagesResult = results[0] as RepositoryResult<List<AlbumImage>>;
    final postsResult = results[1] as RepositoryResult<List<SavedPost>>;

    if (!mounted) return;

    if (imagesResult.isSuccess && postsResult.isSuccess) {
      setState(() {
        _uploadedImages = imagesResult.data ?? [];
        _savedPosts = postsResult.data ?? [];
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = imagesResult.error ?? postsResult.error;
        _isLoading = false;
      });
    }
  }

  int get _totalImages => _uploadedImages.length + _savedPosts.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LynewedColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: LynewedColors.gray200),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
      floatingActionButton: _buildSelectionFab(),
    );
  }

  /// Builds the FAB for selected media actions.
  Widget? _buildSelectionFab() {
    if (!_isSelectionMode || _selectedMediaIds.isEmpty) {
      return null;
    }

    if (_isDownloading) {
      return FloatingActionButton.extended(
        onPressed: null,
        backgroundColor: LynewedColors.gray300,
        icon: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: _downloadProgress,
            strokeWidth: 2,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        label: Text('${(_downloadProgress * 100).toInt()}%'),
      );
    }

    // Show action buttons row for selection
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Add to Magazine button
          FloatingActionButton.extended(
            heroTag: 'magazine',
            onPressed: () => _addToMagazine(),
            backgroundColor: LynewedColors.surface,
            foregroundColor: LynewedColors.textPrimary,
            icon: const Icon(Icons.auto_stories_outlined),
            label: const Text('Magazine'),
          ),
          const SizedBox(width: 12),
          // Download button
          FloatingActionButton.extended(
            heroTag: 'download',
            onPressed: _downloadSelected,
            backgroundColor: LynewedColors.primary,
            icon: const Icon(Icons.download_rounded, color: Colors.white),
            label: Text(
              'Download ${_selectedMediaIds.length}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Adds selected photos to the magazine.
  Future<void> _addToMagazine() async {
    if (_selectedMediaIds.isEmpty) return;

    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You must be logged in to add photos to magazine',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
      return;
    }

    // Get selected images with their URLs
    final selectedImages = _uploadedImages
        .where((img) => _selectedMediaIds.contains(img.id))
        .toList();

    if (selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No photos selected',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
      return;
    }

    // Create a temporary cubit to add photos
    final cubit = MagazineSelectionCubit(
      weddingId: widget.album.weddingId,
      userId: userId,
      getThumbnailUrl: (_, __) async => null,
    );

    // Load existing selections first
    await cubit.loadSelections();

    // Prepare media items to add
    final mediaItems = selectedImages.map((img) => MagazineMediaItem(
          mediaType: 'album_image',
          mediaId: img.id,
          thumbnailUrl: img.thumbnailUrl ?? img.imageUrl,
        ));

    // Add to magazine
    await cubit.addPhotos(mediaItems.toList());

    // Check result
    final state = cubit.state;

    if (state.errorMessage != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage!,
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } else {
      // Exit selection mode
      setState(() {
        _isSelectionMode = false;
        _selectedMediaIds.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedImages.length} photo${selectedImages.length != 1 ? 's' : ''} added to magazine',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.success,
          ),
        );
      }
    }

    await cubit.close();
  }

  /// Toggles selection mode on/off.
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedMediaIds.clear();
      }
    });
  }

  /// Handles long press on media to enter selection mode.
  void _onMediaLongPress(String mediaId) {
    if (!_isSelectionMode) {
      setState(() {
        _isSelectionMode = true;
        _selectedMediaIds.add(mediaId);
      });
    }
  }

  /// Toggles selection of a media item.
  void _toggleMediaSelection(String mediaId) {
    setState(() {
      if (_selectedMediaIds.contains(mediaId)) {
        _selectedMediaIds.remove(mediaId);
        if (_selectedMediaIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMediaIds.add(mediaId);
      }
    });
  }

  /// Downloads selected media items.
  Future<void> _downloadSelected() async {
    if (_selectedMediaIds.isEmpty) return;

    // Get selected media info
    final selectedMedia = _uploadedImages
        .where((img) => _selectedMediaIds.contains(img.id))
        .map((img) => MediaDownloadInfo(
              mediaId: img.id,
              storageUrl: img.imageUrl,
              fileName: _extractFileName(img.imageUrl),
              fileSizeBytes: img.fileSizeBytes,
            ))
        .toList();

    if (selectedMedia.isEmpty) return;

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    // Show progress dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) {
            return DownloadProgressDialog(
              progress: _downloadProgress,
              message: 'Downloading files...',
              totalFiles: selectedMedia.length,
              currentFile: (_downloadProgress * selectedMedia.length).ceil(),
              onCancel: () {
                Navigator.pop(ctx);
                setState(() {
                  _isDownloading = false;
                });
              },
            );
          },
        ),
      );
    }

    final result = await _downloadUseCase.downloadMultiple(
      mediaList: selectedMedia,
      weddingId: widget.album.weddingId,
      onProgress: (progress) {
        if (mounted) {
          setState(() {
            _downloadProgress = progress;
          });
        }
      },
    );

    if (!mounted) return;

    // Close progress dialog
    Navigator.of(context).pop();

    setState(() {
      _isDownloading = false;
      _isSelectionMode = false;
      _selectedMediaIds.clear();
    });

    result.fold(
      onSuccess: (file) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedMedia.length} files downloaded',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.success,
          ),
        );
      },
      onFailure: (failure) {
        _showRetryDialog(failure.message, _downloadSelected);
      },
    );
  }

  /// Downloads a single media item.
  Future<void> _downloadSingleMedia(AlbumImage image) async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _currentDownloadId = image.id;
    });

    final result = await _downloadUseCase.downloadSingle(
      storageUrl: image.imageUrl,
      fileName: _extractFileName(image.imageUrl),
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
      _currentDownloadId = null;
    });

    result.fold(
      onSuccess: (file) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              image.isVideo ? 'Video downloaded' : 'Photo downloaded',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.success,
          ),
        );
      },
      onFailure: (failure) {
        _showRetryDialog(failure.message, () => _downloadSingleMedia(image));
      },
    );
  }

  /// Shows retry dialog for failed downloads.
  void _showRetryDialog(String message, VoidCallback onRetry) {
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

  /// Extracts filename from URL.
  String _extractFileName(String url) {
    final uri = Uri.parse(url);
    final segments = uri.pathSegments;
    return segments.isNotEmpty ? segments.last : 'media';
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          // Back button or close selection mode
          if (_isSelectionMode)
            GestureDetector(
              onTap: _toggleSelectionMode,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: LynewedColors.surface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 22,
                  color: LynewedColors.textPrimary,
                ),
              ),
            )
          else
            LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _isSelectionMode
                            ? '${_selectedMediaIds.length} selected'
                            : widget.album.name,
                        style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!_isSelectionMode && widget.album.isPrivate) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: LynewedColors.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 10,
                              color: LynewedColors.textSecondary,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              'Private',
                              style: LynewedTextStyles.labelSmall.copyWith(
                                color: LynewedColors.textSecondary,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                if (!_isSelectionMode) ...[
                  const SizedBox(height: 2),
                  Text(
                    '$_totalImages image${_totalImages != 1 ? 's' : ''}',
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Select all button in selection mode
          if (_isSelectionMode)
            TextButton(
              onPressed: () {
                setState(() {
                  if (_selectedMediaIds.length == _uploadedImages.length) {
                    _selectedMediaIds.clear();
                  } else {
                    _selectedMediaIds.addAll(_uploadedImages.map((i) => i.id));
                  }
                });
              },
              child: Text(
                _selectedMediaIds.length == _uploadedImages.length
                    ? 'Clear'
                    : 'Select all',
                style: LynewedTextStyles.labelLarge.copyWith(
                  color: LynewedColors.primary,
                ),
              ),
            )
          else if (!widget.isReadOnly)
            GestureDetector(
              onTap: _isUploading ? null : _showMediaPickerSheet,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: LynewedColors.surface,
                  shape: BoxShape.circle,
                ),
                child: _isUploading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            LynewedColors.primary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 22,
                        color: LynewedColors.textPrimary,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
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
            const Icon(
              Icons.error_outline,
              size: 48,
              color: LynewedColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: LynewedTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
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
              onPressed: _loadImages,
              type: LynewedButtonType.secondary,
            ),
          ],
        ),
      );
    }

    if (_totalImages == 0) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadImages,
      color: LynewedColors.primary,
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: _totalImages,
        itemBuilder: (context, index) {
          if (index < _uploadedImages.length) {
            return _buildUploadedImageTile(_uploadedImages[index]);
          } else {
            final savedIndex = index - _uploadedImages.length;
            return _buildSavedPostTile(_savedPosts[savedIndex]);
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 64,
              color: LynewedColors.gray300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No images yet',
              style: LynewedTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Upload images from your gallery or save images from the feed.',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            LynewedButton(
              text: 'Add Media',
              onPressed: _showMediaPickerSheet,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedImageTile(AlbumImage image) {
    final isSelected = _selectedMediaIds.contains(image.id);
    final isCurrentlyDownloading =
        _isDownloading && _currentDownloadId == image.id;

    return GestureDetector(
      onTap: () {
        if (_isSelectionMode) {
          _toggleMediaSelection(image.id);
        } else {
          _viewMedia(image);
        }
      },
      onLongPress: widget.isReadOnly
          ? null
          : () => _onMediaLongPress(image.id),
      onLongPressStart: widget.isReadOnly || _isSelectionMode
          ? null
          : (details) => _showImageOptions(
                globalPosition: details.globalPosition,
                imageUrl: image.imageUrl,
                image: image,
                onDelete: () => _deleteUploadedImage(image),
                onDownload: () => _downloadSingleMedia(image),
              ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: image.thumbnailUrl ?? image.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: LynewedColors.gray200,
            ),
            errorWidget: (_, __, ___) => Container(
              color: LynewedColors.gray200,
              child: const Icon(
                Icons.broken_image_outlined,
                color: LynewedColors.gray300,
              ),
            ),
          ),
          // Selection overlay
          if (_isSelectionMode)
            Container(
              color: isSelected
                  ? LynewedColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
            ),
          // Selection checkbox
          if (_isSelectionMode)
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
          // Video play icon overlay
          if (image.isVideo && !_isSelectionMode)
            Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          // Download progress overlay
          if (isCurrentlyDownloading)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _downloadProgress,
                        strokeWidth: 3,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      Text(
                        '${(_downloadProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSavedPostTile(SavedPost post) {
    return GestureDetector(
      onTap: () => _viewImage(post.imageUrl),
      onLongPressStart: widget.isReadOnly
          ? null
          : (details) => _showImageOptions(
                globalPosition: details.globalPosition,
                imageUrl: post.imageUrl,
                onDelete: () => _deleteSavedPost(post),
                sourceName: post.sourceProfileName,
              ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: post.imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              color: LynewedColors.gray200,
            ),
            errorWidget: (_, __, ___) => Container(
              color: LynewedColors.gray200,
              child: const Icon(
                Icons.broken_image_outlined,
                color: LynewedColors.gray300,
              ),
            ),
          ),
          // Saved from feed indicator
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.bookmark,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewImage(String imageUrl, {bool isVideo = false, String? fileName}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(
          imageUrl: imageUrl,
          isVideo: isVideo,
          fileName: fileName,
        ),
      ),
    );
  }

  void _showImageOptions({
    required Offset globalPosition,
    required String imageUrl,
    required VoidCallback onDelete,
    AlbumImage? image,
    VoidCallback? onDownload,
    String? sourceName,
  }) {
    final screenSize = MediaQuery.of(context).size;
    const menuWidth = 200.0;
    const menuHeight = 160.0; // Approximate height (added download option)

    // Calculate position: below tap point, centered horizontally
    double left = globalPosition.dx - menuWidth / 2;
    double top = globalPosition.dy + 8; // 8px below tap

    // Ensure menu stays within screen bounds
    if (left < 16) left = 16;
    if (left + menuWidth > screenSize.width - 16) {
      left = screenSize.width - menuWidth - 16;
    }
    if (top + menuHeight > screenSize.height - 16) {
      top = globalPosition.dy - menuHeight - 8; // Show above if no space below
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.pop(dialogContext),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: menuWidth,
                  decoration: BoxDecoration(
                    color: LynewedColors.surface,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sourceName != null) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              'From: $sourceName',
                              style: LynewedTextStyles.labelSmall.copyWith(
                                color: LynewedColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                        _buildOptionRow(
                          icon: Icons.fullscreen,
                          label: 'View Full Size',
                          onTap: () {
                            Navigator.pop(dialogContext);
                            _viewImage(imageUrl);
                          },
                        ),
                        if (onDownload != null) ...[
                          const SizedBox(height: 4),
                          _buildOptionRow(
                            icon: Icons.download_rounded,
                            label: image?.isVideo == true
                                ? 'Download Video'
                                : 'Download Photo',
                            onTap: () {
                              Navigator.pop(dialogContext);
                              onDownload();
                            },
                          ),
                        ],
                        const SizedBox(height: 4),
                        _buildOptionRow(
                          icon: Icons.checklist_rounded,
                          label: 'Select Multiple',
                          onTap: () {
                            Navigator.pop(dialogContext);
                            if (image != null) {
                              _onMediaLongPress(image.id);
                            }
                          },
                        ),
                        const SizedBox(height: 4),
                        _buildOptionRow(
                          icon: Icons.delete_outline,
                          label: 'Remove',
                          onTap: () {
                            Navigator.pop(dialogContext);
                            onDelete();
                          },
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color =
        isDestructive ? LynewedColors.error : LynewedColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: const BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: LynewedColors.background,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 14),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: LynewedTextStyles.labelLarge.copyWith(
                color:
                    isDestructive ? LynewedColors.error : LynewedColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMediaPickerSheet() {
    MediaPickerSheet.show(
      context: context,
      onPhotoSelected: _pickAndUploadImage,
      onVideoSelected: _pickAndUploadVideo,
    );
  }

  void _viewMedia(AlbumImage image) {
    // View the original image URL for full quality download support
    // For videos, show the thumbnail for preview but original for download
    final displayUrl = image.thumbnailUrl ?? image.imageUrl;
    _viewImage(
      displayUrl,
      isVideo: image.isVideo,
      fileName: _extractFileName(image.imageUrl),
    );
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final file = File(pickedFile.path);
      final fileName =
          '${widget.album.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storagePath = '${widget.album.weddingId}/$fileName';

      final supabase = Supabase.instance.client;

      await supabase.storage.from('wedding-albums').upload(
            storagePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final imageUrl =
          supabase.storage.from('wedding-albums').getPublicUrl(storagePath);

      await _repository.uploadAlbumImage(
        albumId: widget.album.id,
        imageUrl: imageUrl,
      );

      // Update album cover if this is the first image
      if (_totalImages == 0) {
        await _repository.updateInspirationAlbum(
          albumId: widget.album.id,
          coverImageUrl: imageUrl,
        );
      }

      widget.onUpdated();
      await _loadImages();
    } catch (e) {
      SecureLogger.error('Failed to upload image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to upload image',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickAndUploadVideo() async {
    try {
      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: Duration(seconds: VideoConstants.maxDurationSeconds),
      );

      if (pickedFile == null) return;

      // Validate video extension
      final extensionResult = validateVideoExtension(pickedFile.path);
      if (!extensionResult.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                extensionResult.error!,
                style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
              ),
              backgroundColor: LynewedColors.error,
            ),
          );
        }
        return;
      }

      final file = File(pickedFile.path);

      // Validate file size
      final fileSize = await file.length();
      final sizeResult = validateVideoFileSize(fileSize);
      if (!sizeResult.isValid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                sizeResult.error!,
                style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
              ),
              backgroundColor: LynewedColors.error,
            ),
          );
        }
        return;
      }

      setState(() => _isUploading = true);

      // Generate thumbnail
      String? thumbnailPath;
      try {
        thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: pickedFile.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 512,
          quality: 75,
        );
      } catch (e) {
        SecureLogger.error('Failed to generate video thumbnail: $e');
        // Continue without thumbnail
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = getExtension(pickedFile.path).toLowerCase();
      final videoFileName = '${widget.album.id}_video_$timestamp.$extension';
      final videoStoragePath = '${widget.album.weddingId}/$videoFileName';

      final supabase = Supabase.instance.client;

      // Upload video
      await supabase.storage.from('wedding-albums').upload(
            videoStoragePath,
            file,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );

      final videoUrl =
          supabase.storage.from('wedding-albums').getPublicUrl(videoStoragePath);

      // Upload thumbnail if generated
      String? thumbnailUrl;
      if (thumbnailPath != null) {
        final thumbnailFileName = '${widget.album.id}_thumb_$timestamp.jpg';
        final thumbnailStoragePath = '${widget.album.weddingId}/$thumbnailFileName';
        final thumbnailFile = File(thumbnailPath);

        await supabase.storage.from('wedding-albums').upload(
              thumbnailStoragePath,
              thumbnailFile,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: false,
              ),
            );

        thumbnailUrl =
            supabase.storage.from('wedding-albums').getPublicUrl(thumbnailStoragePath);
      }

      // Save to database
      await _repository.uploadAlbumMedia(
        albumId: widget.album.id,
        mediaUrl: videoUrl,
        mediaType: 'video',
        thumbnailUrl: thumbnailUrl,
        fileSizeBytes: fileSize,
      );

      // Update album cover if this is the first media
      if (_totalImages == 0 && thumbnailUrl != null) {
        await _repository.updateInspirationAlbum(
          albumId: widget.album.id,
          coverImageUrl: thumbnailUrl,
        );
      }

      widget.onUpdated();
      await _loadImages();
    } catch (e) {
      SecureLogger.error('Failed to upload video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to upload video',
              style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
            ),
            backgroundColor: LynewedColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _deleteUploadedImage(AlbumImage image) async {
    final result = await _repository.deleteAlbumImage(imageId: image.id);
    if (result.isSuccess) {
      widget.onUpdated();
      _loadImages();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Failed to delete image',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }

  Future<void> _deleteSavedPost(SavedPost post) async {
    final result = await _repository.removeSavedPost(savedPostId: post.id);
    if (result.isSuccess) {
      widget.onUpdated();
      _loadImages();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result.error ?? 'Failed to remove image',
            style: LynewedTextStyles.bodySmall.copyWith(color: Colors.white),
          ),
          backgroundColor: LynewedColors.error,
        ),
      );
    }
  }
}

/// Full screen image viewer with download support
class _FullScreenImageView extends StatefulWidget {
  const _FullScreenImageView({
    required this.imageUrl,
    this.isVideo = false,
    this.fileName,
  });

  final String imageUrl;
  final bool isVideo;
  final String? fileName;

  @override
  State<_FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<_FullScreenImageView> {
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
            InteractiveViewer(
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                  // Close button (center)
                  const Spacer(),
                  // Download button
                  GestureDetector(
                    onTap: _isDownloading ? null : _downloadMedia,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: _isDownloading
                          ? Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    value: _downloadProgress,
                                    strokeWidth: 2,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Colors.white),
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
                            )
                          : const Icon(
                              Icons.download_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
