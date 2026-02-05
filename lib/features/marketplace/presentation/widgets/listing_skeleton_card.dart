/// Skeleton loading card for marketplace feed.
///
/// Shows a shimmer-like placeholder while listings are being loaded.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// A skeleton placeholder card that mimics the layout of [ListingCard].
///
/// Displayed during initial loading and page loading states.
class ListingSkeletonCard extends StatelessWidget {
  /// Creates a skeleton card.
  const ListingSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: LynewedColors.primary.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo placeholder
          const AspectRatio(
            aspectRatio: 1,
            child: ColoredBox(color: LynewedColors.gray200),
          ),
          // Info placeholders
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: LynewedColors.gray200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: LynewedColors.gray200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Price placeholder
                  Container(
                    height: 14,
                    width: 60,
                    decoration: BoxDecoration(
                      color: LynewedColors.gray200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  // Location placeholder
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: LynewedColors.gray200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
