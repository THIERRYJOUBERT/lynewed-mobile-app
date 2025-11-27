/// FilterSheet - Reusable filter bottom sheet for map
/// 
/// Clean replacement for add_filter_sheet_widget.dart (693 lines → ~300 lines)
library;

import 'package:flutter/material.dart';

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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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

              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Layer toggles
                    _buildSection(
                      title: 'Show on map',
                      child: _buildLayerToggles(),
                    ),

                    const SizedBox(height: 24),

                    // Professions
                    _buildSection(
                      title: 'Professions',
                      child: _buildProfessionChips(),
                    ),

                    const SizedBox(height: 24),

                    // Budget (only for brides)
                    if (widget.userRole == 'bride') ...[
                      _buildSection(
                        title: 'Budget range',
                        child: _buildBudgetSlider(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Distance
                    _buildSection(
                      title: 'Search radius',
                      child: _buildDistanceSlider(),
                    ),

                    const SizedBox(height: 100), // Space for button
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
      margin: const EdgeInsets.only(top: 12),
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Filters',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset'),
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
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildLayerToggles() {
    return Column(
      children: [
        _buildToggleRow(
          label: 'Professionals',
          value: _filter.toggles.showPros,
          onChanged: (v) => _updateToggles(showPros: v),
        ),
        _buildToggleRow(
          label: 'Fixed locations',
          value: _filter.toggles.showFixedLocations,
          onChanged: (v) => _updateToggles(showFixedLocations: v),
        ),
        _buildToggleRow(
          label: 'Community alerts',
          value: _filter.toggles.showAlerts,
          onChanged: (v) => _updateToggles(showAlerts: v),
        ),
        if (widget.userRole == 'professional')
          _buildToggleRow(
            label: 'Visible weddings',
            value: _filter.toggles.showWeddings,
            onChanged: (v) => _updateToggles(showWeddings: v),
          ),
        if (widget.userRole == 'professional')
          _buildToggleRow(
            label: 'Only my profession',
            value: _filter.toggles.showOnlyMyProfession,
            onChanged: (v) => _updateToggles(showOnlyMyProfession: v),
          ),
      ],
    );
  }

  Widget _buildToggleRow({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: Profession.values.map((profession) {
        final isSelected = _selectedProfessions.contains(profession);
        return FilterChip(
          label: Text(_professionLabel(profession)),
          selected: isSelected,
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
    );
  }

  Widget _buildBudgetSlider() {
    final min = _filter.budgetMin ?? 0;
    final max = _filter.budgetMax ?? 50000;

    return Column(
      children: [
        RangeSlider(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${_filter.currency} ${min.toInt()}'),
            Text('${_filter.currency} ${max.toInt()}'),
          ],
        ),
      ],
    );
  }

  Widget _buildDistanceSlider() {
    final radius = _filter.radiusKm ?? 50;

    return Column(
      children: [
        Slider(
          value: radius,
          min: 5,
          max: 200,
          divisions: 39,
          label: '${radius.toInt()} km',
          onChanged: (value) {
            setState(() {
              _filter = _filter.copyWith(radiusKm: value);
            });
          },
        ),
        Text('${radius.toInt()} km radius'),
      ],
    );
  }

  Widget _buildApplyButton(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => widget.onApply(_filter),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Apply Filters',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _updateToggles({
    bool? showPros,
    bool? showFixedLocations,
    bool? showAlerts,
    bool? showWeddings,
    bool? showOnlyMyProfession,
  }) {
    setState(() {
      _filter = _filter.copyWith(
        toggles: _filter.toggles.copyWith(
          showPros: showPros,
          showFixedLocations: showFixedLocations,
          showAlerts: showAlerts,
          showWeddings: showWeddings,
          showOnlyMyProfession: showOnlyMyProfession,
        ),
      );
    });
  }

  void _resetFilters() {
    setState(() {
      _filter = MapFilter.defaults;
      _selectedProfessions.clear();
    });
  }

  String _professionLabel(Profession profession) {
    switch (profession) {
      case Profession.photographer:
        return 'Photographer';
      case Profession.videographer:
        return 'Videographer';
      case Profession.weddingPlanner:
        return 'Wedding Planner';
      case Profession.venue:
        return 'Venue';
      case Profession.caterer:
        return 'Caterer';
      case Profession.dj:
        return 'DJ';
      case Profession.florist:
        return 'Florist';
      case Profession.makeupArtist:
        return 'Makeup Artist';
      case Profession.hairStylist:
        return 'Hair Stylist';
      case Profession.officiant:
        return 'Officiant';
      case Profession.rentals:
        return 'Rentals';
      case Profession.transportation:
        return 'Transportation';
      case Profession.stationery:
        return 'Stationery';
      case Profession.cake:
        return 'Cake';
      case Profession.jewelry:
        return 'Jewelry';
      case Profession.attire:
        return 'Attire';
      case Profession.musician:
        return 'Musician';
      case Profession.other:
        return 'Other';
    }
  }
}
