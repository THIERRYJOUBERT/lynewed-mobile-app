/// Content block widget for content feature.
///
/// Renders different types of content blocks including text,
/// image, video, and quote blocks.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/wed_content_block.dart';

/// Content block widget.
///
/// Renders a single content block based on its type.
/// Supports text, image, video, and quote block types.
class ContentBlockWidget extends StatelessWidget {
  /// The content block to render.
  final WedContentBlock block;

  /// Creates a content block widget.
  const ContentBlockWidget({
    required this.block,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    switch (block.type) {
      case ContentBlockType.text:
        return _buildTextBlock();
      case ContentBlockType.image:
        return _buildImageBlock();
      case ContentBlockType.video:
        return _buildVideoBlock();
      case ContentBlockType.quote:
        return _buildQuoteBlock();
    }
  }

  Widget _buildTextBlock() {
    if (block.content == null || block.content!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        block.content!,
        style: LynewedTextStyles.bodyMedium.copyWith(
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildImageBlock() {
    if (block.imageUrl == null) {
      return _buildImagePlaceholder();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: LynewedColors.gray200,
              image: DecorationImage(
                image: NetworkImage(block.imageUrl!),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: LynewedColors.gray200,
            child: const Center(
              child: Icon(
                Icons.image_outlined,
                size: 48.0,
                color: LynewedColors.gray300,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoBlock() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            color: LynewedColors.gray200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_circle_outline,
                      size: 40.0,
                      color: LynewedColors.primary,
                    ),
                  ),
                  if (block.videoUrl != null) ...[
                    const SizedBox(height: 8.0),
                    Text(
                      'Play Video',
                      style: LynewedTextStyles.labelMedium.copyWith(
                        color: LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuoteBlock() {
    if (block.content == null || block.content!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: const Border(
            left: BorderSide(
              color: LynewedColors.primary,
              width: 4.0,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.format_quote,
              size: 24.0,
              color: LynewedColors.gray100,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                block.content!,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
