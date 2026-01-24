/// Album Detail Page - View and manage images in an inspiration album
///
/// Displays uploaded images and saved posts in a grid.
/// Allows uploading new images from gallery and deleting existing ones.
library;

import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/core/design/design.dart';
import '/utils/secure_logger.dart';
import '../../data/repositories/my_wedding_repository_impl.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/my_wedding_repository.dart';

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
  final _imagePicker = ImagePicker();

  bool _isLoading = true;
  bool _isUploading = false;
  String? _error;
  List<AlbumImage> _uploadedImages = [];
  List<SavedPost> _savedPosts = [];

  @override
  void initState() {
    super.initState();
    _repository = MyWeddingRepositoryImpl();

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
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
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
                        widget.album.name,
                        style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.album.isPrivate) ...[
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
                const SizedBox(height: 2),
                Text(
                  '$_totalImages image${_totalImages != 1 ? 's' : ''}',
                  style: LynewedTextStyles.labelSmall.copyWith(
                    color: LynewedColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isReadOnly)
            GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadImage,
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
              text: 'Upload Image',
              onPressed: _pickAndUploadImage,
              width: double.infinity,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedImageTile(AlbumImage image) {
    return GestureDetector(
      onTap: () => _viewImage(image.imageUrl),
      onLongPressStart: widget.isReadOnly
          ? null
          : (details) => _showImageOptions(
                globalPosition: details.globalPosition,
                imageUrl: image.imageUrl,
                onDelete: () => _deleteUploadedImage(image),
              ),
      child: CachedNetworkImage(
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

  void _viewImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _FullScreenImageView(imageUrl: imageUrl),
      ),
    );
  }

  void _showImageOptions({
    required Offset globalPosition,
    required String imageUrl,
    required VoidCallback onDelete,
    String? sourceName,
  }) {
    final screenSize = MediaQuery.of(context).size;
    const menuWidth = 200.0;
    const menuHeight = 120.0; // Approximate height

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

/// Full screen image viewer
class _FullScreenImageView extends StatelessWidget {
  const _FullScreenImageView({required this.imageUrl});

  final String imageUrl;

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
                  imageUrl: imageUrl,
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
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: GestureDetector(
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
            ),
          ],
        ),
      ),
    );
  }
}
