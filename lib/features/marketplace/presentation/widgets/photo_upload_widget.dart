/// Photo upload widget for marketplace listings.
///
/// Displays a grid of photos with add/remove functionality.
/// Supports drag-and-drop reordering. First photo is the cover.
/// Requires minimum 5, maximum 10 photos.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '/core/design/design.dart';

/// Widget for uploading and managing listing photos.
///
/// Features:
/// - Add photos from camera or gallery
/// - Remove individual photos
/// - Reorder via drag-and-drop (long press)
/// - First photo is marked as "Cover"
/// - Shows upload progress when publishing
class PhotoUploadWidget extends StatefulWidget {
  /// Creates a photo upload widget.
  const PhotoUploadWidget({
    super.key,
    required this.photos,
    required this.onPhotosChanged,
    this.uploadProgress,
    this.minPhotos = 5,
    this.maxPhotos = 10,
    this.errorText,
  });

  /// Current list of photo file paths.
  final List<String> photos;

  /// Callback when the photo list changes (add, remove, reorder).
  final ValueChanged<List<String>> onPhotosChanged;

  /// Upload progress (0.0 to 1.0). Null when not uploading.
  final double? uploadProgress;

  /// Minimum required photos (default 5).
  final int minPhotos;

  /// Maximum allowed photos (default 10).
  final int maxPhotos;

  /// Optional error text to display.
  final String? errorText;

  @override
  State<PhotoUploadWidget> createState() => _PhotoUploadWidgetState();
}

class _PhotoUploadWidgetState extends State<PhotoUploadWidget> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addPhotos() async {
    if (widget.photos.length >= widget.maxPhotos) return;

    final remaining = widget.maxPhotos - widget.photos.length;

    final images = await _picker.pickMultiImage(
      limit: remaining,
      imageQuality: 85,
      maxWidth: 1920,
      maxHeight: 1920,
    );

    if (images.isEmpty) return;

    final newPhotos = List<String>.from(widget.photos);
    for (final image in images) {
      if (newPhotos.length >= widget.maxPhotos) break;
      newPhotos.add(image.path);
    }
    widget.onPhotosChanged(newPhotos);
  }

  void _removePhoto(int index) {
    final newPhotos = List<String>.from(widget.photos);
    newPhotos.removeAt(index);
    widget.onPhotosChanged(newPhotos);
  }

  void _onReorder(int oldIndex, int newIndex) {
    // Guard against invalid indices (e.g. non-photo items).
    if (oldIndex >= widget.photos.length || newIndex > widget.photos.length) {
      return;
    }
    final newPhotos = List<String>.from(widget.photos);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = newPhotos.removeAt(oldIndex);
    newPhotos.insert(newIndex, item);
    widget.onPhotosChanged(newPhotos);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LynewedSectionTitle(
          'Photos',
          trailing: Text(
            '${widget.photos.length}/${widget.maxPhotos}',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: LynewedSpacing.xs),
        Text(
          'Minimum ${widget.minPhotos} photos required. First photo is the cover.',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        if (widget.uploadProgress != null) ...[
          _buildUploadProgress(),
          const SizedBox(height: LynewedSpacing.sm),
        ],
        _buildPhotoGrid(),
        if (widget.errorText != null) ...[
          const SizedBox(height: LynewedSpacing.xs),
          Text(
            widget.errorText!,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Uploading photos...',
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: LynewedSpacing.xs),
        LinearProgressIndicator(
          value: widget.uploadProgress,
          backgroundColor: LynewedColors.gray200,
          valueColor:
              const AlwaysStoppedAnimation<Color>(LynewedColors.primary),
        ),
      ],
    );
  }

  Widget _buildPhotoGrid() {
    return SizedBox(
      height: 120,
      child: Row(
        children: [
          Expanded(
            child: widget.photos.isEmpty
                ? const SizedBox.shrink()
                : ReorderableListView.builder(
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: false,
                    onReorder: _onReorder,
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) => Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(8),
                          child: child,
                        ),
                        child: child,
                      );
                    },
                    itemCount: widget.photos.length,
                    itemBuilder: (context, index) {
                      return _buildPhotoTile(
                        index: index,
                        path: widget.photos[index],
                        key: ValueKey(widget.photos[index]),
                      );
                    },
                  ),
          ),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildPhotoTile({
    required int index,
    required String path,
    required Key key,
  }) {
    return ReorderableDelayedDragStartListener(
      key: key,
      index: index,
      child: Container(
        width: 100,
        height: 120,
        margin: const EdgeInsets.only(right: LynewedSpacing.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: index == 0
              ? Border.all(color: LynewedColors.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            // Photo (supports both local file paths and network URLs)
            ClipRRect(
              borderRadius: BorderRadius.circular(index == 0 ? 6 : 8),
              child: path.startsWith('http')
                  ? Image.network(
                      path,
                      width: 100,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: LynewedColors.surface,
                        child: const Icon(
                          Icons.broken_image,
                          color: LynewedColors.gray300,
                        ),
                      ),
                    )
                  : Image.file(
                      File(path),
                      width: 100,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: LynewedColors.surface,
                        child: const Icon(
                          Icons.broken_image,
                          color: LynewedColors.gray300,
                        ),
                      ),
                    ),
            ),
            // Cover badge
            if (index == 0)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: LynewedColors.primary.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: Text(
                    'Cover',
                    textAlign: TextAlign.center,
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: LynewedColors.textOnPrimary,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            // Remove button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removePhoto(index),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: LynewedColors.primary.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: LynewedColors.textOnPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    final canAdd = widget.photos.length < widget.maxPhotos;

    return GestureDetector(
      onTap: canAdd ? _addPhotos : null,
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: canAdd ? LynewedColors.gray200 : LynewedColors.gray300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 28,
              color:
                  canAdd ? LynewedColors.textSecondary : LynewedColors.gray300,
            ),
            const SizedBox(height: 4),
            Text(
              'Add',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: canAdd
                    ? LynewedColors.textSecondary
                    : LynewedColors.gray300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
