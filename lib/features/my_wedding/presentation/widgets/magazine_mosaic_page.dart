/// Magazine Mosaic Page widget.
///
/// Displays multiple photos in a grid/mosaic layout.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_page.dart';
import '../bloc/magazine_selection_state.dart';

/// Widget for displaying a mosaic photo page.
class MagazineMosaicPage extends StatelessWidget {
  /// Creates a magazine mosaic page widget.
  const MagazineMosaicPage({
    super.key,
    required this.page,
  });

  /// The mosaic page data.
  final MosaicPage page;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: _buildLayout(),
        ),
      ),
    );
  }

  Widget _buildLayout() {
    final photos = page.mosaicPhotos;
    final count = photos.length;

    // Different layouts based on photo count
    switch (count) {
      case 4:
        return page.isFeatureLayout
            ? _buildFeature4Layout(photos)
            : _build2x2Grid(photos);
      case 5:
        return _build5PhotoLayout(photos);
      case 6:
        return _build3x2Grid(photos);
      default:
        // Fallback to simple grid
        return _buildSimpleGrid(photos);
    }
  }

  /// Feature layout: 1 large photo on the left, 3 small on the right.
  Widget _buildFeature4Layout(List<MagazinePhoto> photos) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildPhotoTile(photos[0]),
        ),
        const SizedBox(width: 4),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              Expanded(child: _buildPhotoTile(photos[1])),
              const SizedBox(height: 4),
              Expanded(child: _buildPhotoTile(photos[2])),
              const SizedBox(height: 4),
              Expanded(child: _buildPhotoTile(photos[3])),
            ],
          ),
        ),
      ],
    );
  }

  /// 2x2 grid layout for 4 photos.
  Widget _build2x2Grid(List<MagazinePhoto> photos) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPhotoTile(photos[0])),
              const SizedBox(width: 4),
              Expanded(child: _buildPhotoTile(photos[1])),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPhotoTile(photos[2])),
              const SizedBox(width: 4),
              Expanded(child: _buildPhotoTile(photos[3])),
            ],
          ),
        ),
      ],
    );
  }

  /// Layout for 5 photos: 2 on top, 3 on bottom.
  Widget _build5PhotoLayout(List<MagazinePhoto> photos) {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(child: _buildPhotoTile(photos[0])),
              const SizedBox(width: 4),
              Expanded(child: _buildPhotoTile(photos[1])),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(child: _buildPhotoTile(photos[2])),
              const SizedBox(width: 4),
              Expanded(child: _buildPhotoTile(photos[3])),
              const SizedBox(width: 4),
              Expanded(child: _buildPhotoTile(photos[4])),
            ],
          ),
        ),
      ],
    );
  }

  /// 3x2 grid layout for 6 photos.
  Widget _build3x2Grid(List<MagazinePhoto> photos) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPhotoTile(photos[0])),
              const SizedBox(width: 4),
              Expanded(child: _buildPhotoTile(photos[1])),
              const SizedBox(width: 4),
              Expanded(child: _buildPhotoTile(photos[2])),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildPhotoTile(photos[3])),
              const SizedBox(width: 4),
              Expanded(child: _buildPhotoTile(photos[4])),
              const SizedBox(width: 4),
              Expanded(child: _buildPhotoTile(photos[5])),
            ],
          ),
        ),
      ],
    );
  }

  /// Simple grid fallback.
  Widget _buildSimpleGrid(List<MagazinePhoto> photos) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) => _buildPhotoTile(photos[index]),
    );
  }

  Widget _buildPhotoTile(MagazinePhoto photo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: CachedNetworkImage(
        imageUrl: photo.thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: LynewedColors.surface,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(LynewedColors.primary),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: LynewedColors.surface,
          child: const Icon(
            Icons.image_not_supported_outlined,
            size: 24,
            color: LynewedColors.gray300,
          ),
        ),
      ),
    );
  }
}
