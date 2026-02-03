/// Magazine Single Page widget.
///
/// Displays a single large photo page in the magazine.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_page.dart';

/// Widget for displaying a single photo magazine page.
class MagazineSinglePage extends StatelessWidget {
  /// Creates a magazine single page widget.
  const MagazineSinglePage({
    super.key,
    required this.page,
  });

  /// The single page data.
  final SinglePage page;

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
        child: CachedNetworkImage(
          imageUrl: page.photo.thumbnailUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: LynewedColors.surface,
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(LynewedColors.primary),
              ),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: LynewedColors.surface,
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: LynewedColors.gray300,
            ),
          ),
        ),
      ),
    );
  }
}
