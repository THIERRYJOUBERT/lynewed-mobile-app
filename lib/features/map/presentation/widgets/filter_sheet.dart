/// FilterSheet - Reusable filter bottom sheet for map
/// 
/// Clean replacement for add_filter_sheet_widget.dart (693 lines → ~300 lines)
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '../../domain/entities/entities.dart';

/// Callback quand les filtres sont appliqués
typedef OnFilterApply = void Function(MapFilter filter);

/// Sheet de filtres pour la map
class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.currentFilter,
    required this.userRole,
    required this.onApply,
  });

  final MapFilter currentFilter;
  final String userRole;
  final OnFilterApply onApply;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late MapFilter _filter;
  late Set<Profession> _selectedProfessions;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _selectedProfessions = Set.from(_filter.professions);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LynewedColors.background,
        borderRadius: LynewedBorders.sheetBorderRadius,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              _buildHandle(),

              // Header
              _buildHeader(context),

              // Content - Simplified: Only Professions, Budget, Distance
              // Layer toggles are now chips in map_page.dart bottom bar
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  children: [
                    // Professions filter
                    _buildSection(
                      title: 'Filter by profession',
                      child: _buildProfessionChips(),
                    ),

                    // Budget (only for brides)
                    if (widget.userRole == 'bride') ...[
                      LynewedGap.verticalXxl,
                      _buildSection(
                        title: 'Budget range',
                        child: _buildBudgetSlider(),
                      ),
                    ],

                    SizedBox(height: 80), // Space for button
                  ],
                ),
              ),

              // Apply button
              _buildApplyButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: LynewedSpacing.md),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: LynewedColors.gray200,
        borderRadius: LynewedBorders.borderRadiusSm,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filters',
            style: LynewedTextStyles.titleLarge,
          ),
          TextButton(
            style: LynewedComponentStyles.textButton(),
            onPressed: _resetFilters,
            child: Text(
              'Reset',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: LynewedTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        LynewedGap.verticalMd,
        child,
      ],
    );
  }

  Widget _buildProfessionChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected count indicator
        if (_selectedProfessions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${_selectedProfessions.length} selected',
              style: LynewedTextStyles.labelSmall.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ),
        Wrap(
          spacing: LynewedSpacing.sm,
          runSpacing: LynewedSpacing.sm,
          children: Profession.values.map((profession) {
            final isSelected = _selectedProfessions.contains(profession);
            // Using Design System chip styling - Standardized 4px radius
            return FilterChip(
              label: Text(
                _professionLabel(profession),
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : LynewedColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              backgroundColor: LynewedColors.gray200,
              selectedColor: LynewedColors.primary,
              checkmarkColor: Colors.white,
              showCheckmark: false, // Design preference for cleaner look with color change
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // 4px max radius
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), // Uniformized padding
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedProfessions.add(profession);
                  } else {
                    _selectedProfessions.remove(profession);
                  }
                  _filter = _filter.copyWith(
                    professions: _selectedProfessions.toList(),
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBudgetSlider() {
    final min = _filter.budgetMin ?? 0;
    final max = _filter.budgetMax ?? 50000;

    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: LynewedColors.primary,
            inactiveTrackColor: LynewedColors.surface,
            thumbColor: LynewedColors.primary,
            overlayColor: LynewedColors.primary.withValues(alpha: 0.1),
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: RangeValues(min, max),
            min: 0,
            max: 50000,
            divisions: 50,
            labels: RangeLabels(
              '${_filter.currency} ${min.toInt()}',
              '${_filter.currency} ${max.toInt()}',
            ),
            onChanged: (values) {
              setState(() {
                _filter = _filter.copyWith(
                  budgetMin: values.start,
                  budgetMax: values.end,
                );
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_filter.currency} ${min.toInt()}',
              style: LynewedTextStyles.bodySmall,
            ),
            Text(
              '${_filter.currency} ${max.toInt()}',
              style: LynewedTextStyles.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          height: LynewedSpacing.buttonHeight,
          child: ElevatedButton(
            onPressed: () => widget.onApply(_filter),
            style: LynewedComponentStyles.primaryButton(),
            child: Text(
              'Apply Filters',
              style: LynewedTextStyles.bodyLarge.copyWith(
                color: LynewedColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _filter = MapFilter.defaults;
      _selectedProfessions.clear();
    });
  }

  /// Use the displayName getter from Profession enum
  String _professionLabel(Profession profession) => profession.displayName;
}
