/// FilterSheet - Contextual filter bottom sheet for map
///
/// Shows professional filters when Professionals toggle is active,
/// marketplace filters when Marketplace toggle is active, or both.
library;

import 'package:flutter/material.dart';

import '/core/design/design.dart';
import '/core/design/widgets/widgets.dart';
import '/core/utils/budget_formatter.dart';
import '/core/services/currency_service.dart';
import '/backend/schema/enums/enums.dart' as backend_enums
    show Profession, getAvailableProfessions;
import '/flutter_flow/profession_display_helper.dart';
import '../../domain/entities/entities.dart';
import '/features/reviews/presentation/widgets/rating_filter_chips.dart';

/// Callback quand les filtres sont appliqués
typedef OnFilterApply = void Function(MapFilter filter);

/// Marketplace condition options
const _conditionOptions = ['new', 'excellent', 'good', 'fair'];
const _conditionLabels = {
  'new': 'New with tags',
  'excellent': 'Excellent',
  'good': 'Good',
  'fair': 'Fair',
};

/// Sheet de filtres pour la map - contextuel selon les toggles actifs
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

  bool get _showProsSection =>
      _filter.toggles.showPros || _filter.toggles.showFixedLocations;
  bool get _showMarketplaceSection => _filter.toggles.showMarketplace;
  bool get _isBride => widget.userRole == 'bride';

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
    _selectedProfessions = Set.from(_filter.professions);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: LynewedColors.background,
        borderRadius: LynewedBorders.sheetBorderRadius,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              _buildHandle(),
              _buildHeader(context),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  children: [
                    // Professional filters (contextual)
                    if (_showProsSection) ...[
                      if (_showMarketplaceSection) _buildSectionDivider('Professionals'),
                      _buildSection(
                        title: 'Filter by profession',
                        child: _buildProfessionChips(),
                      ),
                      if (_isBride) ...[
                        LynewedGap.verticalXxl,
                        _buildSection(
                          title: 'Budget range',
                          child: _buildBudgetSlider(),
                        ),
                      ],
                      if (_isBride) ...[
                        LynewedGap.verticalXxl,
                        _buildSection(
                          title: 'Rating',
                          child: _buildRatingFilter(),
                        ),
                      ],
                      if (_isBride) ...[
                        LynewedGap.verticalXxl,
                        _buildSection(
                          title: 'Special offers',
                          child: _buildSpecialOffersFilter(),
                        ),
                      ],
                    ],

                    // Marketplace filters (contextual)
                    if (_showMarketplaceSection) ...[
                      if (_showProsSection) const SizedBox(height: 30),
                      _buildSectionDivider('Marketplace'),
                      _buildSection(
                        title: 'Category',
                        child: _buildMarketplaceCategoryChips(),
                      ),
                      LynewedGap.verticalXxl,
                      _buildSection(
                        title: 'Price range',
                        child: _buildMarketplacePriceSlider(),
                      ),
                      LynewedGap.verticalXxl,
                      _buildSection(
                        title: 'Condition',
                        child: _buildMarketplaceConditionChips(),
                      ),
                    ],

                    // Empty state
                    if (!_showProsSection && !_showMarketplaceSection)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: Text(
                            'Activate a layer to see filters',
                            style: LynewedTextStyles.bodyMedium.copyWith(
                              color: LynewedColors.textSecondary,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
              _buildApplyButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: const EdgeInsets.only(top: LynewedSpacing.md),
      width: 40,
      height: 4,
      decoration: const BoxDecoration(
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
          const Text(
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

  /// Section divider with label - shown when both pro and marketplace are active
  Widget _buildSectionDivider(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: LynewedColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: LynewedTextStyles.labelMedium.copyWith(
                color: LynewedColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              color: LynewedColors.gray200,
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
        Text(title, style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  // ==========================================================================
  // Professional filters (existing)
  // ==========================================================================

  Widget _buildProfessionChips() {
    final availableProfessions =
        backend_enums.getAvailableProfessions(widget.userMarket);
    final selectedNames =
        _selectedProfessions.map((p) => p.name.toUpperCase()).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            return FilterChip(
              label: Text(
                getProfessionDisplayName(backendProf),
                style: LynewedTextStyles.bodyMedium.copyWith(
                  color: isSelected ? Colors.white : LynewedColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                ),
              ),
              selected: isSelected,
              backgroundColor: LynewedColors.gray200,
              selectedColor: LynewedColors.primary,
              checkmarkColor: Colors.white,
              showCheckmark: false,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onSelected: (selected) {
                setState(() {
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

  Profession? _backendToMapProfession(backend_enums.Profession backendProf) {
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
      case backend_enums.Profession.MUSIC:
        return Profession.music;
      case backend_enums.Profession.STATIONERY:
        return Profession.stationery;
      case backend_enums.Profession.CATERER:
        return Profession.caterer;
      case backend_enums.Profession.BRIDALWEARDESIGNER:
        return Profession.bridalWearDesigner;
      case backend_enums.Profession.JEWELLER:
        return Profession.jeweller;
      case backend_enums.Profession.CONTENTCREATOR:
        return Profession.contentCreator;
    }
  }

  Widget _buildBudgetSlider() {
    final userCurrency = BudgetFormatter.userCurrency;
    final min = _filter.budgetMin ?? 0;
    final max = _filter.budgetMax ??
        CurrencyService.instance.getMaxBudgetForCurrency(userCurrency);

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

  Widget _buildRatingFilter() {
    return RatingFilterChips(
      value: _filter.minRating,
      onChanged: (value) {
        setState(() {
          if (value == null) {
            _filter = _filter.copyWith(clearMinRating: true);
          } else {
            _filter = _filter.copyWith(minRating: value);
          }
        });
      },
    );
  }

  Widget _buildSpecialOffersFilter() {
    return Column(
      children: [
        CheckboxListTile(
          value: _filter.weddingBookFree ?? false,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _filter = _filter.copyWith(weddingBookFree: true);
              } else {
                _filter = _filter.copyWith(clearWeddingBookFree: true);
              }
            });
          },
          title: Text(
            'Free wedding book',
            style: LynewedTextStyles.bodyMedium,
          ),
          subtitle: Text(
            'Only show pros offering a complimentary wedding album',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: LynewedColors.primary,
        ),
        CheckboxListTile(
          value: _filter.trailerFree ?? false,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                _filter = _filter.copyWith(trailerFree: true);
              } else {
                _filter = _filter.copyWith(clearTrailerFree: true);
              }
            });
          },
          title: Text(
            'Free wedding trailer',
            style: LynewedTextStyles.bodyMedium,
          ),
          subtitle: Text(
            'Only show pros offering a complimentary trailer video',
            style: LynewedTextStyles.labelSmall.copyWith(
              color: LynewedColors.textSecondary,
            ),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          dense: true,
          contentPadding: EdgeInsets.zero,
          activeColor: LynewedColors.primary,
        ),
      ],
    );
  }

  // ==========================================================================
  // Marketplace filters (EPIC-14)
  // ==========================================================================

  Widget _buildMarketplaceCategoryChips() {
    return Wrap(
      spacing: LynewedSpacing.sm,
      runSpacing: LynewedSpacing.sm,
      children: [
        _buildMarketplaceChip(
          label: 'Dress',
          icon: Icons.checkroom_outlined,
          isSelected: _filter.marketplaceCategory == 'dress',
          onTap: () {
            setState(() {
              if (_filter.marketplaceCategory == 'dress') {
                _filter = _filter.copyWith(clearMarketplaceCategory: true);
              } else {
                _filter = _filter.copyWith(marketplaceCategory: 'dress');
              }
            });
          },
        ),
        _buildMarketplaceChip(
          label: 'Shoes',
          icon: Icons.shopping_bag_outlined,
          isSelected: _filter.marketplaceCategory == 'shoes',
          onTap: () {
            setState(() {
              if (_filter.marketplaceCategory == 'shoes') {
                _filter = _filter.copyWith(clearMarketplaceCategory: true);
              } else {
                _filter = _filter.copyWith(marketplaceCategory: 'shoes');
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildMarketplaceChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? LynewedColors.primary : LynewedColors.gray200,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : LynewedColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: isSelected ? Colors.white : LynewedColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketplacePriceSlider() {
    final minPrice = (_filter.marketplaceMinPrice ?? 0) / 100;
    final maxPrice = (_filter.marketplaceMaxPrice ?? 5000000) / 100;

    return LynewedRangeSlider(
      lowerValue: minPrice,
      upperValue: maxPrice.clamp(0, 50000),
      minValue: 0,
      maxValue: 50000,
      step: 100,
      formatValue: (v) => '\$${v.toInt()}',
      onChanged: (lower, upper) {
        setState(() {
          final minCents = lower > 0 ? (lower * 100).toInt() : null;
          final maxCents = upper < 50000 ? (upper * 100).toInt() : null;

          if (minCents == null && maxCents == null) {
            _filter = _filter.copyWith(clearMarketplacePrice: true);
          } else {
            _filter = _filter.copyWith(
              marketplaceMinPrice: minCents,
              marketplaceMaxPrice: maxCents,
            );
          }
        });
      },
    );
  }

  Widget _buildMarketplaceConditionChips() {
    final selectedConditions = _filter.marketplaceConditions ?? [];
    return Wrap(
      spacing: LynewedSpacing.sm,
      runSpacing: LynewedSpacing.sm,
      children: _conditionOptions.map((condition) {
        final isSelected = selectedConditions.contains(condition);
        return FilterChip(
          label: Text(
            _conditionLabels[condition] ?? condition,
            style: LynewedTextStyles.bodyMedium.copyWith(
              color: isSelected ? Colors.white : LynewedColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
            ),
          ),
          selected: isSelected,
          backgroundColor: LynewedColors.gray200,
          selectedColor: LynewedColors.primary,
          checkmarkColor: Colors.white,
          showCheckmark: false,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onSelected: (selected) {
            setState(() {
              final newConditions = List<String>.from(selectedConditions);
              if (selected) {
                newConditions.add(condition);
              } else {
                newConditions.remove(condition);
              }
              if (newConditions.isEmpty) {
                _filter =
                    _filter.copyWith(clearMarketplaceConditions: true);
              } else {
                _filter =
                    _filter.copyWith(marketplaceConditions: newConditions);
              }
            });
          },
        );
      }).toList(),
    );
  }

  // ==========================================================================
  // Apply / Reset
  // ==========================================================================

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
              style: LynewedTextStyles.buttonPrimary,
            ),
          ),
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _filter = MapFilter.defaults.copyWith(
        toggles: _filter.toggles, // Keep current toggles
      );
      _selectedProfessions.clear();
    });
  }
}
