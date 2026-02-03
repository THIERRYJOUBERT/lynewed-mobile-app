/// Magazine Format Selector widget.
///
/// Displays all available formats for selection with validation.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_format.dart';
import 'magazine_format_card.dart';

/// Widget for selecting a magazine format.
class MagazineFormatSelector extends StatelessWidget {
  /// Creates a magazine format selector.
  const MagazineFormatSelector({
    super.key,
    required this.photoCount,
    required this.selectedFormat,
    required this.onFormatSelected,
  });

  /// Number of photos selected (for validation).
  final int photoCount;

  /// Currently selected format.
  final MagazineFormat? selectedFormat;

  /// Callback when a format is selected.
  final ValueChanged<MagazineFormat> onFormatSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your magazine format',
                style: LynewedTextStyles.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                '$photoCount photo${photoCount != 1 ? 's' : ''} selected',
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: LynewedColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Format cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: MagazineFormats.all.map((format) {
              final isValid = format.isValidForPhotoCount(photoCount);
              final isSelected = selectedFormat == format;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: MagazineFormatCard(
                  format: format,
                  isSelected: isSelected,
                  isEnabled: isValid,
                  onTap: isValid ? () => onFormatSelected(format) : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
