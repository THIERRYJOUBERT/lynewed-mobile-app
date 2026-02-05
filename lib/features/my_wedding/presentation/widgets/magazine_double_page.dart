/// Magazine Double Page widget.
///
/// Displays two photos side by side in a spread layout.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_page.dart';

/// Widget for displaying a double photo spread page.
class MagazineDoublePage extends StatelessWidget {
  /// Creates a magazine double page widget.
  const MagazineDoublePage({
    super.key,
    required this.page,
  });

  /// The double page data.
  final DoublePage page;

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
        child: page.isStacked
            ? Column(
                children: [
                  Expanded(
                    child: _buildPhoto(page.leftPhoto.thumbnailUrl),
                  ),
                  Container(
                    height: 2,
                    color: LynewedColors.gray200,
                  ),
                  Expanded(
                    child: _buildPhoto(page.rightPhoto.thumbnailUrl),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buildPhoto(page.leftPhoto.thumbnailUrl),
                  ),
                  Container(
                    width: 2,
                    color: LynewedColors.gray200,
                  ),
                  Expanded(
                    child: _buildPhoto(page.rightPhoto.thumbnailUrl),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPhoto(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: LynewedColors.surface,
        child: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(LynewedColors.primary),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: LynewedColors.surface,
        child: const Icon(
          Icons.image_not_supported_outlined,
          size: 32,
          color: LynewedColors.gray300,
        ),
      ),
    );
  }
}
