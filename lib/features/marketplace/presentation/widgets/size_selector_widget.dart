/// Size selector widget for marketplace listings.
///
/// Displays a tappable field that opens a bottom sheet with size options.
/// Shows different sizes for dresses vs shoes.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../data/sizes_data.dart';

/// Widget for selecting the size of a marketplace item.
///
/// Displays a read-only text field that opens a sheet with size options.
/// Size options change based on the selected category (dress/shoes).
class SizeSelectorWidget extends StatelessWidget {
  /// Creates a size selector.
  const SizeSelectorWidget({
    super.key,
    required this.category,
    required this.selectedSize,
    required this.onSizeSelected,
    this.errorText,
  });

  /// The category determines which size list to show ('dress' or 'shoes').
  final String? category;

  /// The currently selected size value.
  final String? selectedSize;

  /// Callback when a size is selected.
  final ValueChanged<String> onSizeSelected;

  /// Optional error text to display.
  final String? errorText;

  String get _displayText {
    if (selectedSize == null || category == null) return '';
    final sizes = getSizesForCategory(category!);
    final match = sizes.where((s) => s.value == selectedSize);
    if (match.isNotEmpty) return match.first.label;
    return selectedSize!;
  }

  void _showSizeSheet(BuildContext context) {
    if (category == null) return;

    final sizes = getSizesForCategory(category!);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: LynewedColors.transparent,
      builder: (context) => LynewedSheet(
        title: 'Select Size',
        onClose: () => Navigator.pop(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: sizes.map((size) {
            final isSelected = selectedSize == size.value;
            return InkWell(
              onTap: () {
                onSizeSelected(size.value);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: LynewedSpacing.md,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        size.label,
                        style: LynewedTextStyles.bodyMedium.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w300,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check,
                        size: LynewedSpacing.iconSize,
                        color: LynewedColors.primary,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: _displayText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LynewedTextField(
          controller: controller,
          label: 'Size',
          hint: category == null ? 'Select a category first' : 'Select size',
          readOnly: true,
          enabled: category != null,
          onTap: () => _showSizeSheet(context),
          suffixIcon: const Icon(
            Icons.expand_more,
            size: LynewedSpacing.iconSize,
            color: LynewedColors.textSecondary,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: LynewedSpacing.xs),
          Text(
            errorText!,
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
