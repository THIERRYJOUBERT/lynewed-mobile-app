/// Layout Option Tile for magazine page editing.
///
/// Displays a schematic representation of a page layout with a label.
library;

import 'package:flutter/material.dart';
import '/core/design/design.dart';
import '../../domain/entities/magazine_page.dart';

/// A tile showing a layout option for magazine pages.
class LayoutOptionTile extends StatelessWidget {
  /// Creates a layout option tile.
  const LayoutOptionTile({
    super.key,
    required this.layout,
    required this.isSelected,
    required this.onTap,
    this.isEnabled = true,
  });

  /// The layout this tile represents.
  final EditablePageLayout layout;

  /// Whether this layout is currently selected.
  final bool isSelected;

  /// Callback when tapped.
  final VoidCallback onTap;

  /// Whether this option is enabled (has enough photos).
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? LynewedColors.primary
        : isEnabled
            ? LynewedColors.gray200
            : LynewedColors.gray100;
    final bgColor = isSelected
        ? LynewedColors.primary.withValues(alpha: 0.05)
        : LynewedColors.background;

    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          width: 72,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: _buildLayoutDiagram(),
              ),
              const SizedBox(height: 6),
              Text(
                layout.label,
                style: LynewedTextStyles.labelSmall.copyWith(
                  color: isSelected
                      ? LynewedColors.primary
                      : LynewedColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutDiagram() {
    const gap = 2.0;
    const color = LynewedColors.gray300;
    const radius = BorderRadius.all(Radius.circular(2));

    return switch (layout) {
      EditablePageLayout.single => Container(
          decoration: const BoxDecoration(color: color, borderRadius: radius),
        ),
      EditablePageLayout.double => Row(
          children: [
            Expanded(
              child: Container(
                decoration:
                    const BoxDecoration(color: color, borderRadius: radius),
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: Container(
                decoration:
                    const BoxDecoration(color: color, borderRadius: radius),
              ),
            ),
          ],
        ),
      EditablePageLayout.doubleStacked => Column(
          children: [
            Expanded(
              child: Container(
                decoration:
                    const BoxDecoration(color: color, borderRadius: radius),
              ),
            ),
            const SizedBox(height: gap),
            Expanded(
              child: Container(
                decoration:
                    const BoxDecoration(color: color, borderRadius: radius),
              ),
            ),
          ],
        ),
      EditablePageLayout.mosaic4 => Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: gap),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      EditablePageLayout.feature4 => Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                decoration:
                    const BoxDecoration(color: color, borderRadius: radius),
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(height: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(height: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      EditablePageLayout.mosaic5 => Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: gap),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      EditablePageLayout.mosaic6 => Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: gap),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                          color: color, borderRadius: radius),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    };
  }
}
