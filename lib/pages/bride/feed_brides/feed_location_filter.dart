import 'package:flutter/material.dart';
import '/backend/schema/enums/country_filter.dart';
import '/backend/schema/structs/index.dart';
import '/compo_finaux/address_search/address_search_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Location filter widget with toggle between Country dropdown and Address search
/// 
/// When in Country mode (default):
/// - Country dropdown takes most space
/// - Address search shows as compact "Search" button
/// 
/// When in Address Search mode:
/// - Address search takes most space  
/// - Country dropdown shows as compact "Country" button with globe icon
class FeedLocationFilter extends StatefulWidget {
  const FeedLocationFilter({
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
  State<FeedLocationFilter> createState() => _FeedLocationFilterState();
}

class _FeedLocationFilterState extends State<FeedLocationFilter> {
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
        width: MediaQuery.of(context).size.width - 32, // Full width minus padding
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 54),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0)),
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
                        hintStyle: const TextStyle(
                          fontFamily: 'Haas Grot Text Trial',
                          fontSize: 14,
                          color: Color(0xFF888888),
                        ),
                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF888888)),
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'Haas Grot Text Trial',
                        fontSize: 14,
                      ),
                      // Search is handled by the listener in initState
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
                            color: isSelected ? const Color(0xFFF0F0F0) : null,
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
                                    style: TextStyle(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 14,
                                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
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
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(25),
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
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    fontFamily: 'Haas Grot Text Trial',
                    fontSize: 14,
                    letterSpacing: 0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                _isCountryDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: const Color(0xFF888888),
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
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(25),
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
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Haas Grot Text Trial',
                fontSize: 12,
                letterSpacing: 0,
                color: const Color(0xFF666666),
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
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search,
              color: Color(0xFF888888),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Search',
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                fontFamily: 'Haas Grot Text Trial',
                fontSize: 14,
                letterSpacing: 0,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedAddressSearch() {
    return AddressSearchWidget(
      height: 50,
      hintText: 'Search city or address',
      initialValue: widget.searchText,
      enabled: true,
      debounceMs: 200,
      locale: widget.locale,
      onAddressSelected: widget.onAddressSelected,
      onAddressCleared: widget.onAddressCleared,
      onSearchTextChanged: widget.onSearchTextChanged,
    );
  }
}
