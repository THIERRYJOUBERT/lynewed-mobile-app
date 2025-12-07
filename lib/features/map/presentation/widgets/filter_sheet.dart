/// FilterSheet - Reusable filter bottom sheet for map
/// 
/// Clean replacement for add_filter_sheet_widget.dart (693 lines → ~300 lines)
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
import '/core/utils/budget_formatter.dart';
import '/core/services/currency_service.dart';
import '/backend/schema/enums/enums.dart' as backend_enums show Profession, getAvailableProfessions;
import '/flutter_flow/profession_display_helper.dart';
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
    this.userMarket = 'GLOBAL',
  });

  final MapFilter currentFilter;
  final String userRole;
  final OnFilterApply onApply;
  final String userMarket;

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
    // Get available professions from backend enum (market-filtered)
    final availableProfessions = backend_enums.getAvailableProfessions(widget.userMarket);
    
    // Convert selected map professions to backend profession names for comparison
    final selectedNames = _selectedProfessions.map((p) => p.name.toUpperCase()).toSet();
    
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
          children: availableProfessions.map((backendProf) {
            final isSelected = selectedNames.contains(backendProf.name);
            // Using Design System chip styling - Standardized 4px radius
            return FilterChip(
              label: Text(
                getProfessionDisplayName(backendProf),
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
                  // Convert backend profession to map profession
                  final mapProf = _backendToMapProfession(backendProf);
                  if (mapProf != null) {
                    if (selected) {
                      _selectedProfessions.add(mapProf);
                    } else {
                      _selectedProfessions.remove(mapProf);
                    }
                    _filter = _filter.copyWith(
                      professions: _selectedProfessions.toList(),
                    );
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
  
  /// Convert backend Profession enum to Map module Profession enum
  Profession? _backendToMapProfession(backend_enums.Profession backendProf) {
    // Handle all cases explicitly
    switch (backendProf) {
      case backend_enums.Profession.PHOTOGRAPHER:
        return Profession.photographer;
      case backend_enums.Profession.FILMMAKER:
        return Profession.filmmaker;
      case backend_enums.Profession.PLANNER:
        return Profession.planner;
      case backend_enums.Profession.MAKEUP:
        return Profession.makeup;
      case backend_enums.Profession.HAIRDRESSER:
        return Profession.hairdresser;
      case backend_enums.Profession.DESIGNER:
        return Profession.designer;
      case backend_enums.Profession.BRIDALDESIGNER:
        return Profession.bridalDesigner;
      case backend_enums.Profession.VENUE:
        return Profession.venue;
      case backend_enums.Profession.BRIDALSHOP:
        return Profession.bridalShop;
      case backend_enums.Profession.FLORIST:
        return Profession.florist;
      case backend_enums.Profession.PHOTOMOVIE:
        return Profession.photoMovie;
      case backend_enums.Profession.MAKEUPARTIST:
        return Profession.makeupArtist;
      case backend_enums.Profession.EVENTDESIGNER:
        return Profession.eventDesigner;
      case backend_enums.Profession.OTHER:
        return Profession.other;
      // Global professions (available everywhere)
      case backend_enums.Profession.MUSIC:
        return Profession.music;
      case backend_enums.Profession.STATIONERY:
        return Profession.stationery;
      // India-only professions
      case backend_enums.Profession.CATERER:
        return Profession.caterer;
      case backend_enums.Profession.BRIDALWEARDESIGNER:
        return Profession.bridalWearDesigner;
      // Global-only professions (not in India)
      case backend_enums.Profession.JEWELLER:
        return Profession.jeweller;
      case backend_enums.Profession.CONTENTCREATOR:
        return Profession.contentCreator;
    }
  }

  Widget _buildBudgetSlider() {
    final userCurrency = BudgetFormatter.userCurrency;
    final min = _filter.budgetMin ?? 0;
    final max = _filter.budgetMax ?? CurrencyService.instance.getMaxBudgetForCurrency(userCurrency);

    return LynewedBudgetSlider(
      lowerValue: min,
      upperValue: max,
      currency: userCurrency,
      onChanged: (lower, upper) {
        setState(() {
          _filter = _filter.copyWith(
            budgetMin: lower,
            budgetMax: upper,
            currency: userCurrency,
          );
        });
      },
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
}
