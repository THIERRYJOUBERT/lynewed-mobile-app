/// Magazine Cover widget.
///
/// Displays the magazine cover page with branding, photo, title, and date.
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_page.dart';

/// Widget for displaying the magazine cover page.
class MagazineCover extends StatelessWidget {
  /// Creates a magazine cover widget.
  const MagazineCover({
    super.key,
    required this.page,
  });

  /// The cover page data.
  final CoverPage page;

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
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Cover photo
            CachedNetworkImage(
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
            // Gradient overlay for text legibility
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                  stops: const [0.0, 0.25, 0.6, 1.0],
                ),
              ),
            ),
            // Top branding
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'DIGITAL EDITION',
                    style: LynewedTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      letterSpacing: 2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    page.formattedDate,
                    style: LynewedTextStyles.labelMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'LYNEWED',
                    style: LynewedTextStyles.displayMedium.copyWith(
                      color: Colors.white,
                      letterSpacing: 4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom title
            Positioned(
              bottom: 32,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text(
                    page.weddingTitle,
                    style: LynewedTextStyles.headlineLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Captured by our loved ones',
                    style: LynewedTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'THE LOVE STORY',
                        style: LynewedTextStyles.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '-',
                          style: LynewedTextStyles.labelSmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      Text(
                        'EXCLUSIVE',
                        style: LynewedTextStyles.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
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
