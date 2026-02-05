/// FilterSheet widget - Advanced filter modal for marketplace listings.
///
/// Displays filter sections for category, price range, size, brand,
/// condition, and country. Includes preview count with debounce and
/// apply/clear functionality.
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/design/widgets/lynewed_range_slider.dart';
import '../../data/brands_data.dart';
import '../../data/sizes_data.dart';
import '../../domain/entities/listing_filter.dart';
import '../../domain/repositories/marketplace_repository.dart';

/// Advanced filter sheet for marketplace listings.
///
/// Provides filter sections for:
/// - Category (dress/shoes)
/// - Price range ($0 - $50,000)
/// - Size (conditional on category)
/// - Brand (with search)
/// - Condition (new/excellent/good/fair)
/// - Country (dropdown)
///
/// Shows a live preview count of matching listings with debounce.
class FilterSheet extends StatefulWidget {
  /// Creates a filter sheet.
  const FilterSheet({
    required this.initialFilter,
    required this.repository,
    required this.onApply,
    this.scrollController,
    super.key,
  });

  /// The initial filter state to display.
  final ListingFilter initialFilter;

  /// Repository for preview count queries.
  final MarketplaceRepository repository;

  /// Callback when user applies the filters.
  final void Function(ListingFilter filter) onApply;

  /// Optional scroll controller for DraggableScrollableSheet integration.
  final ScrollController? scrollController;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late ListingFilter _currentFilter;
  Timer? _previewTimer;
  int _previewCount = 0;
  bool _isLoadingPreview = false;

  /// Reference to the Autocomplete's internal controller.
  /// Set during fieldViewBuilder and used for clearing after selection.
  TextEditingController? _autocompleteController;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter;
    _updatePreviewCount();
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    super.dispose();
  }

  void _onFilterChanged(ListingFilter newFilter) {
    setState(() => _currentFilter = newFilter);
    _updatePreviewCount();
  }

  void _updatePreviewCount() {
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      setState(() => _isLoadingPreview = true);
      try {
        final count = await widget.repository
            .getFilteredListingsCount(_currentFilter);
        if (mounted) {
          setState(() {
            _previewCount = count;
            _isLoadingPreview = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isLoadingPreview = false);
      }
    });
  }

  void _clearAllFilters() {
    _onFilterChanged(const ListingFilter.empty());
    _autocompleteController?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        _buildHeader(),
        const Divider(height: 1, color: LynewedColors.gray200),

        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            controller: widget.scrollController,
            padding: LynewedSpacing.sheetContent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySection(),
                const SizedBox(height: LynewedSpacing.formSectionGap),
                _buildPriceRangeSection(),
                const SizedBox(height: LynewedSpacing.formSectionGap),
                _buildSizeSection(),
                const SizedBox(height: LynewedSpacing.formSectionGap),
                _buildBrandSection(),
                const SizedBox(height: LynewedSpacing.formSectionGap),
                _buildConditionSection(),
                const SizedBox(height: LynewedSpacing.formSectionGap),
                _buildCountrySection(),
                const SizedBox(height: LynewedSpacing.xxxl),
              ],
            ),
          ),
        ),

        // Bottom apply button
        _buildApplyButton(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filters',
              style: LynewedTextStyles.sheetTitle,
            ),
          ),
          LynewedButton(
            text: 'Clear All',
            type: LynewedButtonType.ghost,
            onPressed: _clearAllFilters,
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // Category Section
  // ==========================================================================

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Category'),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        Wrap(
          spacing: LynewedSpacing.sm,
          runSpacing: LynewedSpacing.sm,
          children: [
            LynewedChip(
              label: 'Dress',
              selected: _currentFilter.category == 'dress',
              onSelected: (_) {
                _onFilterChanged(_currentFilter.copyWith(
                  category: _currentFilter.category == 'dress'
                      ? null
                      : 'dress',
                  clearCategory: _currentFilter.category == 'dress',
                  // Clear sizes when category changes.
                  clearSizes: true,
                  clearBrands: true,
                ));
              },
            ),
            LynewedChip(
              label: 'Shoes',
              selected: _currentFilter.category == 'shoes',
              onSelected: (_) {
                _onFilterChanged(_currentFilter.copyWith(
                  category: _currentFilter.category == 'shoes'
                      ? null
                      : 'shoes',
                  clearCategory: _currentFilter.category == 'shoes',
                  // Clear sizes when category changes.
                  clearSizes: true,
                  clearBrands: true,
                ));
              },
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================================
  // Price Range Section
  // ==========================================================================

  Widget _buildPriceRangeSection() {
    final minPrice = (_currentFilter.minPriceCents ?? 0) / 100;
    final maxPrice = (_currentFilter.maxPriceCents ?? 5000000) / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Price Range'),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        LynewedRangeSlider(
          lowerValue: minPrice,
          upperValue: maxPrice.clamp(0, 50000),
          minValue: 0,
          maxValue: 50000,
          step: 100,
          formatValue: (v) => '\$${v.toInt()}',
          onChanged: (lower, upper) {
            // Only set if not at the extremes.
            final minCents = lower > 0 ? (lower * 100).toInt() : null;
            final maxCents = upper < 50000 ? (upper * 100).toInt() : null;

            _onFilterChanged(_currentFilter.copyWith(
              minPriceCents: minCents,
              maxPriceCents: maxCents,
              clearPriceRange: minCents == null && maxCents == null,
            ));
          },
        ),
      ],
    );
  }

  // ==========================================================================
  // Size Section
  // ==========================================================================

  Widget _buildSizeSection() {
    final category = _currentFilter.category;
    final List<SizeOption> sizes;

    if (category == 'dress') {
      sizes = dressSizes;
    } else if (category == 'shoes') {
      sizes = shoeSizes;
    } else {
      sizes = [];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Size'),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        if (sizes.isEmpty)
          Text(
            'Select a category first',
            style: LynewedTextStyles.bodySmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          )
        else
          Wrap(
            spacing: LynewedSpacing.sm,
            runSpacing: LynewedSpacing.sm,
            children: sizes.map((size) {
              final isSelected =
                  _currentFilter.sizes?.contains(size.value) ?? false;
              return LynewedChip(
                label: size.value,
                selected: isSelected,
                onSelected: (_) {
                  final newSizes =
                      List<String>.from(_currentFilter.sizes ?? []);
                  if (isSelected) {
                    newSizes.remove(size.value);
                  } else {
                    newSizes.add(size.value);
                  }
                  _onFilterChanged(_currentFilter.copyWith(
                    sizes: newSizes.isEmpty ? null : newSizes,
                    clearSizes: newSizes.isEmpty,
                  ));
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  // ==========================================================================
  // Brand Section
  // ==========================================================================

  Widget _buildBrandSection() {
    final category = _currentFilter.category;
    final List<String> availableBrands;

    if (category == 'dress') {
      availableBrands = popularWeddingDressBrands;
    } else if (category == 'shoes') {
      availableBrands = popularBridalShoeBrands;
    } else {
      availableBrands = [
        ...popularWeddingDressBrands,
        ...popularBridalShoeBrands,
      ];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Brand'),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        Autocomplete<String>(
          optionsBuilder: (textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return availableBrands.where((brand) => brand
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()));
          },
          onSelected: (brand) {
            final newBrands = List<String>.from(_currentFilter.brands ?? []);
            if (!newBrands.contains(brand)) {
              newBrands.add(brand);
              _onFilterChanged(_currentFilter.copyWith(brands: newBrands));
            }
            _autocompleteController?.clear();
          },
          fieldViewBuilder:
              (context, controller, focusNode, onFieldSubmitted) {
            // Capture reference for clearing after selection / clear all.
            _autocompleteController = controller;
            return LynewedTextField(
              controller: controller,
              focusNode: focusNode,
              hint: 'Search brands...',
              onEditingComplete: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  final newBrands =
                      List<String>.from(_currentFilter.brands ?? []);
                  if (!newBrands.contains(text)) {
                    newBrands.add(text);
                    _onFilterChanged(
                        _currentFilter.copyWith(brands: newBrands));
                  }
                  controller.clear();
                }
                focusNode.unfocus();
              },
            );
          },
        ),
        if (_currentFilter.brands != null &&
            _currentFilter.brands!.isNotEmpty) ...[
          const SizedBox(height: LynewedSpacing.sm),
          Wrap(
            spacing: LynewedSpacing.sm,
            runSpacing: LynewedSpacing.sm,
            children: _currentFilter.brands!.map((brand) {
              return _FilterBadge(
                label: brand,
                onRemove: () {
                  final newBrands =
                      List<String>.from(_currentFilter.brands!);
                  newBrands.remove(brand);
                  _onFilterChanged(_currentFilter.copyWith(
                    brands: newBrands.isEmpty ? null : newBrands,
                    clearBrands: newBrands.isEmpty,
                  ));
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ==========================================================================
  // Condition Section
  // ==========================================================================

  Widget _buildConditionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Condition'),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        Wrap(
          spacing: LynewedSpacing.sm,
          runSpacing: LynewedSpacing.sm,
          children: conditionOptions.map((condition) {
            final isSelected =
                _currentFilter.conditions?.contains(condition) ?? false;
            return LynewedChip(
              label: conditionLabels[condition] ?? condition,
              selected: isSelected,
              onSelected: (_) {
                final newConditions =
                    List<String>.from(_currentFilter.conditions ?? []);
                if (isSelected) {
                  newConditions.remove(condition);
                } else {
                  newConditions.add(condition);
                }
                _onFilterChanged(_currentFilter.copyWith(
                  conditions:
                      newConditions.isEmpty ? null : newConditions,
                  clearConditions: newConditions.isEmpty,
                ));
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==========================================================================
  // Country Section
  // ==========================================================================

  Widget _buildCountrySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const LynewedSectionTitle('Country'),
        const SizedBox(height: LynewedSpacing.labelFieldGap),
        DropdownButtonFormField<String>(
          value: _currentFilter.country,
          decoration: InputDecoration(
            hintText: 'Select country',
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
                color: LynewedColors.textPrimary,
                width: 1,
              ),
            ),
          ),
          style: LynewedTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w300,
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All countries'),
            ),
            ...countryOptions.map((c) {
              return DropdownMenuItem(value: c, child: Text(c));
            }),
          ],
          onChanged: (country) {
            _onFilterChanged(_currentFilter.copyWith(
              country: country,
              clearCountry: country == null,
            ));
          },
        ),
      ],
    );
  }

  // ==========================================================================
  // Apply Button
  // ==========================================================================

  Widget _buildApplyButton() {
    final buttonText = _isLoadingPreview
        ? 'Show Results...'
        : 'Show $_previewCount Results';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        border: Border(
          top: BorderSide(color: LynewedColors.gray100),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: LynewedButton(
          text: buttonText,
          type: LynewedButtonType.primary,
          isLoading: _isLoadingPreview,
          onPressed: () => widget.onApply(_currentFilter),
        ),
      ),
    );
  }
}

/// A small filter badge chip with a remove (X) button.
///
/// Used to display selected brands, since LynewedChip does not
/// support an onDelete callback.
class _FilterBadge extends StatelessWidget {
  const _FilterBadge({
    required this.label,
    required this.onRemove,
  });

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LynewedColors.primary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: LynewedTextStyles.chipText.copyWith(
              color: LynewedColors.textOnPrimary,
              fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: LynewedColors.textOnPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
