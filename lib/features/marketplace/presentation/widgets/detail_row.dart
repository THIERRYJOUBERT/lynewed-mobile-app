/// DetailRow widget for listing detail pages.
///
/// Displays a label-value pair with an optional icon, used in the
/// listing info section to show details like category, size, brand, etc.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';

/// A row displaying a label-value pair with an optional leading icon.
///
/// Used in listing detail pages to show structured information
/// like "Category: Dress" or "Size: S".
class DetailRow extends StatelessWidget {
  /// Creates a detail row.
  const DetailRow({
    required this.label,
    required this.value,
    this.icon,
    super.key,
  });

  /// The label text (left side).
  final String label;

  /// The value text (right side).
  final String value;

  /// Optional leading icon.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: LynewedSpacing.sm),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: LynewedColors.gray300),
            SizedBox(width: LynewedSpacing.sm),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: LynewedTextStyles.bodySmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
