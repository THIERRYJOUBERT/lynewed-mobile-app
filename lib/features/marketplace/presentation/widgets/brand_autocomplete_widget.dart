/// Brand autocomplete widget for marketplace listings.
///
/// Provides an autocomplete text field with predefined brand suggestions.
/// Supports custom brand entry for brands not in the list.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../data/brands_data.dart';

/// Widget for selecting or entering a brand name.
///
/// Uses Flutter's Autocomplete widget with predefined brand lists.
/// Shows different brand lists for dresses vs shoes.
/// Allows custom entry for brands not in the list.
class BrandAutocompleteWidget extends StatelessWidget {
  /// Creates a brand autocomplete widget.
  const BrandAutocompleteWidget({
    super.key,
    required this.category,
    required this.controller,
    required this.onBrandSelected,
  });

  /// The category determines which brand list to show ('dress' or 'shoes').
  final String? category;

  /// The text controller for the brand input.
  final TextEditingController controller;

  /// Callback when a brand is selected or entered.
  final ValueChanged<String> onBrandSelected;

  @override
  Widget build(BuildContext context) {
    final brands = category != null ? getBrandsForCategory(category!) : <String>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Designer / Brand', style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return brands;
            }
            return brands.where((brand) => brand
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (brand) {
            controller.text = brand;
            onBrandSelected(brand);
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
            // Sync the external controller with the autocomplete controller
            if (controller.text.isNotEmpty && textController.text.isEmpty) {
              textController.text = controller.text;
            }
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              onChanged: (value) {
                controller.text = value;
                onBrandSelected(value);
              },
              onFieldSubmitted: (_) => onFieldSubmitted(),
              style: LynewedTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w300,
              ),
              decoration: InputDecoration(
                hintText: 'Search or enter brand name',
                hintStyle: LynewedTextStyles.inputHint,
                filled: true,
                fillColor: const Color(0xFFF2F2F2),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(4),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Text(
                            option,
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
