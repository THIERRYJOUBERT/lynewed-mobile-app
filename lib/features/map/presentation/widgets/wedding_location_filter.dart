/// Wedding Location Filter Widget
/// 
/// Allows brides to select a country (default) or search for a specific address.
/// Based on FeedLocationFilter but adapted for wedding creation context.
/// 
/// Key differences from Feed:
/// - Distance slider is optional (checkbox to enable)
/// - Default is country-only search (worldwide pros)
/// - Slider range: 5-500km
library;

import 'package:flutter/material.dart';
import '/backend/schema/enums/country_filter.dart';
import '/backend/schema/structs/index.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '/core/design/design.dart';

/// Location filter widget for wedding creation
/// 
/// Modes:
/// - Country mode (default): Dropdown to select country, search by country only
/// - Address mode: Search for specific address with optional distance filter
class WeddingLocationFilter extends StatefulWidget {
  const WeddingLocationFilter({
    super.key,
    required this.selectedCountry,
    required this.isAddressSearchMode,
    required this.searchText,
    required this.locale,
    required this.onCountryChanged,
    required this.onAddressSelected,
    required this.onAddressCleared,
    required this.onSearchTextChanged,
    required this.onModeToggle,
  });

  final CountryFilter selectedCountry;
  final bool isAddressSearchMode;
  final String? searchText;
  final String locale;
  final ValueChanged<CountryFilter> onCountryChanged;
  final ValueChanged<PlaceDetailsDataStruct> onAddressSelected;
  final VoidCallback onAddressCleared;
  final ValueChanged<String> onSearchTextChanged;
  final VoidCallback onModeToggle;

  @override
  State<WeddingLocationFilter> createState() => _WeddingLocationFilterState();
}

class _WeddingLocationFilterState extends State<WeddingLocationFilter> {
  // For searchable dropdown
  final TextEditingController _countrySearchController = TextEditingController();
  List<CountryFilter> _filteredCountries = [];
  bool _isCountryDropdownOpen = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _filteredCountries = CountryFilter.globalMarketCountries;
    _countrySearchController.addListener(_onSearchChanged);
  }
  
  void _onSearchChanged() {
    final query = _countrySearchController.text;
    setState(() {
      _filteredCountries = CountryFilter.search(query, excludeIndia: true);
    });
    _overlayEntry?.markNeedsBuild();
  }

  @override
  void dispose() {
    _countrySearchController.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isCountryDropdownOpen = false;
  }

  void _showCountryDropdown() {
    _removeOverlay();
    _isCountryDropdownOpen = true;
    _filteredCountries = CountryFilter.globalMarketCountries;
    _countrySearchController.clear();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 40, // Full width minus sheet padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 54),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: LynewedColors.gray200),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _countrySearchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search country...',
                        hintStyle: LynewedTextStyles.bodyMedium.copyWith(
                          color: LynewedColors.gray300,
                        ),
                        prefixIcon: const Icon(Icons.search, size: 20, color: LynewedColors.gray100),
                        filled: true,
                        fillColor: LynewedColors.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: LynewedTextStyles.bodyMedium,
                    ),
                  ),
                  const Divider(height: 1),
                  // Country list
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = _filteredCountries[index];
                        final isSelected = country == widget.selectedCountry;
                        return InkWell(
                          onTap: () {
                            widget.onCountryChanged(country);
                            _removeOverlay();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            color: isSelected ? LynewedColors.surface : null,
                            child: Row(
                              children: [
                                Text(
                                  _getCountryFlag(country.code),
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    country.displayName,
                                    style: LynewedTextStyles.bodyMedium.copyWith(
                                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check, size: 18, color: Colors.black),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  String _getCountryFlag(String countryCode) {
    if (countryCode.isEmpty) return '🌍';
    // Convert country code to flag emoji
    final flag = countryCode.toUpperCase().codeUnits
        .map((c) => String.fromCharCode(c + 127397))
        .join();
    return flag;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Row(
        children: [
          // Country dropdown (expanded or compact)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: widget.isAddressSearchMode ? 100 : null,
            child: widget.isAddressSearchMode
                ? _buildCompactCountryButton()
                : _buildExpandedCountryDropdown(),
          ),
          if (!widget.isAddressSearchMode) ...[
            const SizedBox(width: 12),
            // Compact search button
            _buildCompactSearchButton(),
          ],
          if (widget.isAddressSearchMode) ...[
            const SizedBox(width: 12),
            // Expanded address search
            Expanded(child: _buildExpandedAddressSearch()),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedCountryDropdown() {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isCountryDropdownOpen) {
            _removeOverlay();
          } else {
            _showCountryDropdown();
          }
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: LynewedColors.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Text(
                _getCountryFlag(widget.selectedCountry.code),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.selectedCountry.displayName,
                  style: LynewedTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _isCountryDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: LynewedColors.gray100,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCountryButton() {
    return GestureDetector(
      onTap: () {
        widget.onModeToggle();
        _removeOverlay();
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getCountryFlag(widget.selectedCountry.code),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 6),
            Text(
              widget.selectedCountry.isWorld ? 'Country' : widget.selectedCountry.code,
              style: LynewedTextStyles.labelMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSearchButton() {
    return GestureDetector(
      onTap: widget.onModeToggle,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: LynewedColors.surface,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search,
              color: LynewedColors.gray100,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Search',
              style: LynewedTextStyles.bodyMedium.copyWith(
                color: LynewedColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedAddressSearch() {
    return AddressSearchWidget(
      height: 48,
      hintText: 'Search city or address',
      initialValue: widget.searchText,
      enabled: true,
      debounceMs: 200,
      locale: widget.locale,
      borderRadius: 4.0, // Rectangular style to match Design System
      onAddressSelected: widget.onAddressSelected,
      onAddressCleared: widget.onAddressCleared,
      onSearchTextChanged: widget.onSearchTextChanged,
    );
  }
}
