/// Preference page - Clean Architecture
/// 
/// Unified preference page for both Brides and Professionals.
/// Handles currency, distance unit, and country preferences.
/// 
/// DESIGN SYSTEM v3 APPLIED:
/// - Header: Back button (LynewedComponentStyles.backButton) + Title
/// - Divider under header (LynewedColors.gray200)
/// - Typography: LynewedTextStyles.sectionTitle for section headers
/// - Spacing: 30px inter-section
/// - Dropdowns: Same style as CurrencyDropdown (grey background)
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core/design/design.dart';
import '/core/widgets/currency_dropdown.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/enums/country_filter.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;

class PreferenceWidget extends StatefulWidget {
  const PreferenceWidget({super.key});

  static String routeName = 'Preference';
  static String routePath = '/preference';

  @override
  State<PreferenceWidget> createState() => _PreferenceWidgetState();
}

class _PreferenceWidgetState extends State<PreferenceWidget> {
  String? _selectedCurrency;
  String? _selectedDistanceUnit;
  CountryFilter? _selectedCountry;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentPreferences();
  }

  void _loadCurrentPreferences() {
    final prefs = FFAppState().currentUserPreferences;
    _selectedCurrency = prefs.currency.isNotEmpty ? prefs.currency : 'EUR';
    _selectedDistanceUnit = prefs.distanceUnit.name;
    _selectedCountry = _getCountryFromCode(prefs.defaultCountry);
  }

  CountryFilter _getCountryFromCode(String code) {
    if (code.isEmpty) return CountryFilter.world;
    try {
      return CountryFilter.values.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
        orElse: () => CountryFilter.world,
      );
    } catch (_) {
      return CountryFilter.world;
    }
  }

  String _getCountryFlag(String countryCode) {
    if (countryCode.isEmpty) return '🌍';
    return countryCode.toUpperCase().codeUnits
        .map((c) => String.fromCharCode(c + 127397))
        .join();
  }

  Future<void> _savePreference(String type) async {
    setState(() => _isSaving = true);
    
    try {
      await actions.saveUserPreferences(
        FFAppState().currentUserPreferences,
        '',
      );
      
      if (mounted) {
        _showSnackBar('$type preference saved', LynewedColors.success);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to save preference', LynewedColors.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 2000),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: LynewedColors.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Divider
              const Divider(height: 1, color: LynewedColors.gray200),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Currency Section
                      _buildPreferenceItem(
                        title: 'Currency',
                        description: 'Choose your reference currency for prices and budgets.',
                        child: CurrencyDropdown(
                          value: _selectedCurrency ?? 'EUR',
                          filled: true, // Grey background style
                          onChanged: (code) async {
                            setState(() => _selectedCurrency = code);
                            FFAppState().updateCurrentUserPreferencesStruct(
                              (e) => e..currency = code,
                            );
                            await _savePreference('Currency');
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Distance Unit Section
                      _buildPreferenceItem(
                        title: 'Distance Unit',
                        description: 'Select your preferred unit for distances.',
                        child: _buildDistanceUnitSelector(),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Country Section
                      _buildPreferenceItem(
                        title: 'Country',
                        description: 'Select your country for personalized content and market segmentation.',
                        child: _buildCountrySelector(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 20, 20, 12),
      child: Row(
        children: [
          LynewedComponentStyles.backButton(context),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Preferences',
              style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
            ),
          ),
          if (_isSaving)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: LynewedColors.primary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: LynewedTextStyles.sectionTitle),
        const SizedBox(height: 8),
        Text(
          description,
          style: LynewedTextStyles.bodySmall.copyWith(
            color: LynewedColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildDistanceUnitSelector() {
    final displayText = _selectedDistanceUnit == 'km' ? 'Kilometers' : 'Miles';
    
    return GestureDetector(
      onTap: _showDistanceUnitPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayText,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: LynewedColors.gray300,
            ),
          ],
        ),
      ),
    );
  }

  void _showDistanceUnitPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(LynewedBorders.xl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: LynewedColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Unit',
                      style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: LynewedColors.gray300,
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Divider(height: 1, color: LynewedColors.gray200),
            ),
            // Options
            _buildDistanceOption('km', 'Kilometers'),
            _buildDistanceOption('miles', 'Miles'),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDistanceOption(String value, String label) {
    final isSelected = _selectedDistanceUnit == value;
    return InkWell(
      onTap: () async {
        Navigator.pop(context);
        setState(() => _selectedDistanceUnit = value);
        FFAppState().updateCurrentUserPreferencesStruct(
          (e) => e..distanceUnit = value == 'km' 
              ? DistanceUnit.km 
              : DistanceUnit.miles,
        );
        await _savePreference('Distance unit');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        color: isSelected ? LynewedColors.surface : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                size: 20,
                color: LynewedColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountrySelector() {
    final country = _selectedCountry ?? CountryFilter.world;
    
    return GestureDetector(
      onTap: _showCountryPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              _getCountryFlag(country.code),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                country.isWorld ? 'Select country' : country.displayName,
                style: LynewedTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w300,
                  color: country.isWorld 
                      ? LynewedColors.textSecondary 
                      : LynewedColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: LynewedColors.gray300,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker() {
    final searchController = TextEditingController();
    List<CountryFilter> filteredCountries = CountryFilter.values.toList()
      ..remove(CountryFilter.world);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(LynewedBorders.xl),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: LynewedColors.gray300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select Country',
                            style: LynewedTextStyles.sheetTitle.copyWith(fontSize: 20),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            size: 24,
                            color: LynewedColors.gray300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Divider(height: 1, color: LynewedColors.gray200),
                  ),
                  
                  // Search field
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search country...',
                        hintStyle: LynewedTextStyles.inputHint,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: const Color(0xFFF2F2F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      style: LynewedTextStyles.bodyMedium,
                      onChanged: (query) {
                        setSheetState(() {
                          if (query.isEmpty) {
                            filteredCountries = CountryFilter.values.toList()
                              ..remove(CountryFilter.world);
                          } else {
                            filteredCountries = CountryFilter.search(query, excludeIndia: false)
                              ..remove(CountryFilter.world);
                          }
                        });
                      },
                    ),
                  ),
                  
                  // Country list
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        final isSelected = country == _selectedCountry;
                        
                        return InkWell(
                          onTap: () async {
                            Navigator.pop(context);
                            
                            setState(() => _selectedCountry = country);
                            FFAppState().updateCurrentUserPreferencesStruct(
                              (e) => e..defaultCountry = country.code,
                            );
                            await _savePreference('Country');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            color: isSelected ? LynewedColors.surface : null,
                            child: Row(
                              children: [
                                Text(
                                  _getCountryFlag(country.code),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    country.displayName,
                                    style: LynewedTextStyles.bodyMedium.copyWith(
                                      fontWeight: isSelected 
                                          ? FontWeight.w500 
                                          : FontWeight.w300,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check,
                                    size: 20,
                                    color: LynewedColors.primary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
