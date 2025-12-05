import '/backend/schema/enums/enums.dart';
import '/backend/schema/enums/country_filter.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import '/core/widgets/currency_dropdown.dart';
import 'preference_model.dart';
export 'preference_model.dart';

class PreferenceWidget extends StatefulWidget {
  const PreferenceWidget({super.key});

  static String routeName = 'Preference';
  static String routePath = '/preference';

  @override
  State<PreferenceWidget> createState() => _PreferenceWidgetState();
}

class _PreferenceWidgetState extends State<PreferenceWidget> {
  late PreferenceModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PreferenceModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      setAppLanguage(
          context,
          valueOrDefault<String>(
            FFAppState().currentUserPreferences.defaultLocale,
            'en',
          ));
    });
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Align(
          alignment: const AlignmentDirectional(0.0, -1.0),
          child: SizedBox(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: MediaQuery.sizeOf(context).height * 1.0,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 130.0, 20.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 24.0, 0.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Currency selection',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                                Text(
                                  'Choose between the dollar and the euro as your reference currency.',
                                  style: FlutterFlowTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        fontFamily: 'Haas Grot Text Trial',
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText,
                                        fontSize: 12.0,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: CurrencyDropdown(
                                    value: _model.dropDownCurrencyValue ??
                                        valueOrDefault<String>(
                                          FFAppState()
                                              .currentUserPreferences
                                              .currency,
                                          'USD',
                                        ),
                                    onChanged: (code) async {
                                      safeSetState(() =>
                                          _model.dropDownCurrencyValue = code);
                                      FFAppState()
                                          .updateCurrentUserPreferencesStruct(
                                            (e) => e..currency = code,
                                          );
                                      safeSetState(() {});
                                      _model.saveUserPreferencesCurrency =
                                          await actions.saveUserPreferences(
                                        FFAppState().currentUserPreferences,
                                        '',
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Saved currency preference',
                                            style: TextStyle(
                                              color: FlutterFlowTheme.of(context)
                                                  .primaryText,
                                            ),
                                          ),
                                          duration: const Duration(milliseconds: 2000),
                                          backgroundColor:
                                              FlutterFlowTheme.of(context).success,
                                        ),
                                      );

                                      safeSetState(() {});
                                    },
                                  ),
                                ),
                              ].divide(const SizedBox(height: 10.0)),
                            ),
                          ),
                          Divider(
                            thickness: 1.0,
                            color: FlutterFlowTheme.of(context).secondary,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choice of unit of measurement',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Text(
                                'Select the reference unit of measurement between kilometers and miles. ',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                              FlutterFlowDropDown<String>(
                                controller:
                                    _model.dropDownDistanceValueController ??=
                                        FormFieldController<String>(
                                  _model.dropDownDistanceValue ??=
                                      valueOrDefault<String>(
                                    FFAppState()
                                        .currentUserPreferences
                                        .distanceUnit
                                        .name,
                                    'km',
                                  ),
                                ),
                                options: const ['km', 'miles'],
                                onChanged: (val) async {
                                  safeSetState(
                                      () => _model.dropDownDistanceValue = val);
                                  FFAppState()
                                      .updateCurrentUserPreferencesStruct(
                                    (e) => e
                                      ..distanceUnit =
                                          _model.dropDownDistanceValue == 'km'
                                              ? DistanceUnit.km
                                              : DistanceUnit.miles,
                                  );
                                  safeSetState(() {});
                                  _model.saveUserPreferencesUnit =
                                      await actions.saveUserPreferences(
                                    FFAppState().currentUserPreferences,
                                    '',
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Saved unit preference',
                                        style: TextStyle(
                                          color: FlutterFlowTheme.of(context)
                                              .primaryText,
                                        ),
                                      ),
                                      duration: const Duration(milliseconds: 2000),
                                      backgroundColor:
                                          FlutterFlowTheme.of(context).success,
                                    ),
                                  );

                                  safeSetState(() {});
                                },
                                width: 90.0,
                                textStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      letterSpacing: 0.0,
                                    ),
                                hintText: 'km',
                                icon: Icon(
                                  Icons.keyboard_arrow_right,
                                  color: FlutterFlowTheme.of(context)
                                      .secondaryText,
                                  size: 14.0,
                                ),
                                elevation: 0.0,
                                borderColor: Colors.transparent,
                                borderWidth: 1.0,
                                borderRadius: 0.0,
                                margin: const EdgeInsetsDirectional.fromSTEB(
                                    4.0, 0.0, 12.0, 10.0),
                                isOverButton: false,
                                isSearchable: false,
                                isMultiSelect: false,
                              ),
                            ].divide(const SizedBox(height: 10.0)),
                          ),
                          Divider(
                            thickness: 1.0,
                            color: FlutterFlowTheme.of(context).secondary,
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Country',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              Text(
                                'Select your country for personalized content and market segmentation.',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                    ),
                              ),
                              _buildCountrySelector(),
                            ].divide(const SizedBox(height: 10.0)),
                          ),
                          Divider(
                            thickness: 1.0,
                            color: FlutterFlowTheme.of(context).secondary,
                          ),
                        ].divide(const SizedBox(height: 14.0)),
                      ),
                    ),
                  ],
                ),
                wrapWithModel(
                  model: _model.headerBarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const HeaderBarWidget(
                    title: 'PREFERENCE',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Get current country from preferences
  CountryFilter _getCurrentCountry() {
    final countryCode = FFAppState().currentUserPreferences.defaultCountry;
    if (countryCode.isEmpty) {
      return CountryFilter.world;
    }
    // Find matching country
    try {
      return CountryFilter.values.firstWhere(
        (c) => c.code.toUpperCase() == countryCode.toUpperCase(),
        orElse: () => CountryFilter.world,
      );
    } catch (_) {
      return CountryFilter.world;
    }
  }

  String _getCountryFlag(String countryCode) {
    if (countryCode.isEmpty) return '🌍';
    final flag = countryCode.toUpperCase().codeUnits
        .map((c) => String.fromCharCode(c + 127397))
        .join();
    return flag;
  }

  Widget _buildCountrySelector() {
    final currentCountry = _model.selectedCountry ?? _getCurrentCountry();
    
    return GestureDetector(
      onTap: _showCountryPicker,
      child: Container(
        width: 200,
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: FlutterFlowTheme.of(context).accent1,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Text(
              _getCountryFlag(currentCountry.code),
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                currentCountry.isWorld 
                    ? 'Select country' 
                    : currentCountry.displayName,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  fontFamily: 'Haas Grot Text Trial',
                  color: currentCountry.isWorld 
                      ? FlutterFlowTheme.of(context).secondaryText
                      : FlutterFlowTheme.of(context).primaryText,
                  letterSpacing: 0.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker() {
    final TextEditingController searchController = TextEditingController();
    List<CountryFilter> filteredCountries = CountryFilter.values.toList()
      ..remove(CountryFilter.world);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Select your country',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    // Search field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Search country...',
                          hintStyle: TextStyle(
                            fontFamily: 'Haas Grot Text Trial',
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        style: const TextStyle(
                          fontFamily: 'Haas Grot Text Trial',
                        ),
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
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    // Country list
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = filteredCountries[index];
                          final currentCountry = _model.selectedCountry ?? _getCurrentCountry();
                          final isSelected = country == currentCountry;
                          return InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              
                              // Update local state
                              safeSetState(() {
                                _model.selectedCountry = country;
                              });
                              
                              // Update app state
                              FFAppState().updateCurrentUserPreferencesStruct(
                                (e) => e..defaultCountry = country.code,
                              );
                              safeSetState(() {});
                              
                              // Save to database (this will sync to profiles and professional_details)
                              _model.saveUserPreferencesCountry =
                                  await actions.saveUserPreferences(
                                FFAppState().currentUserPreferences,
                                '',
                              );
                              
                              if (mounted) {
                                ScaffoldMessenger.of(this.context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Country updated to ${country.displayName}',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(this.context)
                                            .primaryText,
                                      ),
                                    ),
                                    duration: const Duration(milliseconds: 2000),
                                    backgroundColor:
                                        FlutterFlowTheme.of(this.context).success,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              color: isSelected ? const Color(0xFFF0F0F0) : null,
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
                                      style: TextStyle(
                                        fontFamily: 'Haas Grot Text Trial',
                                        fontSize: 15,
                                        fontWeight: isSelected 
                                            ? FontWeight.w500 
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check, size: 20),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
