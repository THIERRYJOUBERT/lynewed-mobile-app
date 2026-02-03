/// Magazine Format Card widget.
///
/// Displays a selectable format option with name, size, and price.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_format.dart';

/// Card for displaying and selecting a magazine format.
class MagazineFormatCard extends StatelessWidget {
  /// Creates a magazine format card.
  const MagazineFormatCard({
    super.key,
    required this.format,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
  });

  /// The format to display.
  final MagazineFormat format;

  /// Whether this format is currently selected.
  final bool isSelected;

  /// Whether this format can be selected (has enough capacity).
  final bool isEnabled;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.primary : LynewedColors.background,
          border: Border.all(
            color: isSelected
                ? LynewedColors.primary
                : isEnabled
                    ? LynewedColors.border
                    : LynewedColors.gray200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child: Row(
            children: [
              // Selection indicator
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? LynewedColors.textOnPrimary
                        : LynewedColors.gray300,
                    width: 2,
                  ),
                  color: isSelected
                      ? LynewedColors.textOnPrimary
                      : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: LynewedColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              // Format details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          format.name,
                          style: LynewedTextStyles.titleMedium.copyWith(
                            color: isSelected
                                ? LynewedColors.textOnPrimary
                                : LynewedColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (format.isPremium) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? LynewedColors.textOnPrimary.withValues(alpha: 0.2)
                                  : LynewedColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Premium',
                              style: LynewedTextStyles.labelSmall.copyWith(
                                color: isSelected
                                    ? LynewedColors.textOnPrimary
                                    : LynewedColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${format.size} - ${format.spreads} spreads - Up to ${format.maxPhotos} photos',
                      style: LynewedTextStyles.bodySmall.copyWith(
                        color: isSelected
                            ? LynewedColors.textOnPrimary.withValues(alpha: 0.8)
                            : LynewedColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                format.priceFormatted,
                style: LynewedTextStyles.titleLarge.copyWith(
                  color: isSelected
                      ? LynewedColors.textOnPrimary
                      : LynewedColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
