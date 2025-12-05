import '/backend/schema/enums/enums.dart';
import '/backend/schema/enums/country_filter.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/custom_code/actions/get_user_market_region.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/index.dart';
import '/core/services/currency_service.dart';
import '/core/utils/budget_formatter.dart';
import '/core/design/widgets/lynewed_budget_slider.dart';
import '/core/design/widgets/lynewed_distance_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'feed_brides_model.dart';
export 'feed_brides_model.dart';
import 'feed_profession_grid.dart';
import 'feed_location_filter.dart';

class FeedBridesWidget extends StatefulWidget {
  const FeedBridesWidget({super.key});

  static String routeName = 'FeedBrides';
  static String routePath = '/feedBrides';

  @override
  State<FeedBridesWidget> createState() => _FeedBridesWidgetState();
}

class _FeedBridesWidgetState extends State<FeedBridesWidget> {
  late FeedBridesModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FeedBridesModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      
      // Load user's market region first
      final market = await getUserMarketRegion();
      _model.userMarket = market;
      _model.marketLoaded = true;
      
      // For Indian users, force country to India
      final countryCode = market == 'IN' ? 'IN' : '';
      if (market == 'IN') {
        _model.selectedCountry = CountryFilter.india;
      }
      
      // Initialize with EMPTY professions list = no filter = show ALL pros
      // When user selects a profession, it filters by that profession
      final userCurrency = BudgetFormatter.userCurrency;
      final maxBudget = CurrencyService.instance.getMaxBudgetForCurrency(userCurrency);
      
      _model.psQueryFilters = QueryFiltersStruct(
        radiusKm: 100.0,
        professions: [], // Empty = no filter = show all
        budgetMin: 0.0,
        budgetMax: maxBudget,
        countryCode: countryCode,
      );
      _model.psFiltersDraft = QueryFiltersStruct(
        radiusKm: 100.0,
        professions: [], // Empty = no filter = show all
        budgetMin: 0.0,
        budgetMax: maxBudget,
        countryCode: countryCode,
      );
      _model.budgetMax = maxBudget;
      if (mounted) {
        safeSetState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
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
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(14.0, 130.0, 14.0, 90.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 1.0,
                        child: custom_widgets.FeedPortfolioGrid(
                          width: MediaQuery.sizeOf(context).width * 1.0,
                          height: MediaQuery.sizeOf(context).height * 1.0,
                          filters: _model.psQueryFilters,
                          onItemTap: (item) async {
                            context.pushNamed(
                              FeedDetailViewerWidget.routeName,
                              queryParameters: {
                                'feedInfosPro': serializeParam(
                                  item,
                                  ParamType.DataStruct,
                                ),
                              }.withoutNulls,
                            );
                          },
                        ),
                      ),
                    ),
                  ].divide(const SizedBox(height: 0.0)),
                ),
              ),
              // Show appropriate navbar based on user role
              if (FFAppState().currentUserRole == UserRole.bride)
                Align(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.navBarBridesModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const NavBarBridesWidget(
                      number: 2,
                    ),
                  ),
                ),
              if (FFAppState().currentUserRole == UserRole.professional)
                Align(
                  alignment: const AlignmentDirectional(0.0, 1.0),
                  child: wrapWithModel(
                    model: _model.navBarProModel,
                    updateCallback: () => safeSetState(() {}),
                    child: const NavBarProWidget(
                      number: 4, // Feed is position 4 in Pro navbar
                    ),
                  ),
                ),
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Container(
                  width: double.infinity,
                  height: 110.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).primaryBackground,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20.0, 0.0, 20.0, 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FILTER',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 18.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                _model.psFiltersDraft =
                                    functions.deepCopyQueryFilters(
                                        _model.psQueryFilters);
                                safeSetState(() {});
                                _model.filterVisibility =
                                    !_model.filterVisibility;
                                safeSetState(() {});
                              },
                              child: Text(
                                _model.filterVisibility == true
                                    ? 'See Less'
                                    : 'View All',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      decoration: TextDecoration.underline,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: const AlignmentDirectional(0.0, 1.0),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 14.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            height: 1.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondary,
                            ),
                            alignment: const AlignmentDirectional(0.0, 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_model.filterVisibility == true)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 110.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          20.0, 14.0, 20.0, 14.0),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Reset filters button at top
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      // Reset filters to default values based on market
                                      // Empty professions list = no filter = show all
                                      final countryCode = _model.isIndianMarket ? 'IN' : '';
                                      final maxBudget = CurrencyService.instance.getMaxBudgetForCurrency(BudgetFormatter.userCurrency);
                                      
                                      _model.updatePsFiltersDraftStruct(
                                        (e) => e
                                          ..professions = [] // Empty = no filter = show all
                                          ..budgetMin = 0.0
                                          ..budgetMax = maxBudget
                                          ..center = null
                                          ..radiusKm = 100.0
                                          ..countryCode = countryCode,
                                      );
                                      _model.budgetMin = 0.0;
                                      _model.budgetMax = maxBudget;
                                      _model.sliderValue = 100.0;
                                      _model.psSearchText = '';
                                      _model.selectedCountry = _model.isIndianMarket 
                                          ? CountryFilter.india 
                                          : CountryFilter.world;
                                      safeSetState(() {});
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              4.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            'Reset Filters',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  decoration: TextDecoration.underline,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12.0),
                              // Location filters - HIDDEN for Indian users
                              if (!_model.isIndianMarket) ...[
                                // Toggleable Country/Address search filter
                                FeedLocationFilter(
                                  selectedCountry: _model.selectedCountry,
                                  isAddressSearchMode: _model.isAddressSearchMode,
                                  searchText: _model.psSearchText,
                                  locale: valueOrDefault<String>(
                                    FFAppState().currentUserPreferences.defaultLocale,
                                    'en',
                                  ),
                                  onCountryChanged: (newValue) {
                                    _model.selectedCountry = newValue;
                                    _model.updatePsFiltersDraftStruct(
                                      (e) => e..countryCode = newValue.code,
                                    );
                                    // Also update psQueryFilters immediately to refresh feed
                                    _model.updatePsQueryFiltersStruct(
                                      (e) => e..countryCode = newValue.code,
                                    );
                                    // Reset address search when country is selected
                                    if (!newValue.isWorld) {
                                      _model.psSearchText = '';
                                      _model.updatePsFiltersDraftStruct(
                                        (e) => e..center = null,
                                      );
                                      _model.updatePsQueryFiltersStruct(
                                        (e) => e..center = null,
                                      );
                                    }
                                    safeSetState(() {});
                                  },
                                  onAddressSelected: (PlaceDetailsDataStruct details) {
                                    _model.placeSelected = details;
                                    _model.updatePsFiltersDraftStruct(
                                      (e) => e..center = details.coords,
                                    );
                                    _model.updatePsQueryFiltersStruct(
                                      (e) => e..center = details.coords,
                                    );
                                    safeSetState(() {});
                                  },
                                  onAddressCleared: () {
                                    _model.placeSelected = null;
                                    _model.updatePsFiltersDraftStruct(
                                      (e) => e..center = null,
                                    );
                                    _model.updatePsQueryFiltersStruct(
                                      (e) => e..center = null,
                                    );
                                    safeSetState(() {});
                                  },
                                  onSearchTextChanged: (String text) {
                                    _model.psSearchText = text;
                                  },
                                  onModeToggle: () {
                                    _model.isAddressSearchMode = !_model.isAddressSearchMode;
                                    // When switching to country mode, reset address search
                                    if (!_model.isAddressSearchMode) {
                                      _model.psSearchText = '';
                                      _model.placeSelected = null;
                                      _model.updatePsFiltersDraftStruct(
                                        (e) => e..center = null,
                                      );
                                      _model.updatePsQueryFiltersStruct(
                                        (e) => e..center = null,
                                      );
                                    }
                                    // When switching to address mode, reset country to World
                                    if (_model.isAddressSearchMode) {
                                      _model.selectedCountry = CountryFilter.world;
                                      _model.updatePsFiltersDraftStruct(
                                        (e) => e..countryCode = '',
                                      );
                                      _model.updatePsQueryFiltersStruct(
                                        (e) => e..countryCode = '',
                                      );
                                    }
                                    safeSetState(() {});
                                  },
                                ),
                                // Distance slider - only visible in address search mode
                                // Uses user's preferred unit (km or miles)
                                if (_model.isAddressSearchMode) ...[
                                  const SizedBox(height: 8.0),
                                  LynewedDistanceSlider(
                                    value: _model.sliderValue ?? 100.0,
                                    maxValueKm: 500.0,
                                    onChanged: (kmValue) {
                                      safeSetState(() => _model.sliderValue = kmValue);
                                      _model.updatePsFiltersDraftStruct(
                                        (e) => e..radiusKm = kmValue,
                                      );
                                      _model.updatePsQueryFiltersStruct(
                                        (e) => e..radiusKm = kmValue,
                                      );
                                      safeSetState(() {});
                                    },
                                  ),
                                ],
                              ],
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                child: FeedProfessionGrid(
                                  filters: _model.psFiltersDraft,
                                  userMarket: _model.userMarket,
                                  onFiltersUpdate: (updateFn) {
                                    _model.updatePsFiltersDraftStruct(updateFn);
                                  },
                                  onSetState: () {
                                    safeSetState(() {});
                                  },
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                decoration: const BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: LynewedBudgetSlider(
                                        lowerValue: valueOrDefault<double>(
                                          _model.budgetMin,
                                          0.0,
                                        ),
                                        upperValue: valueOrDefault<double>(
                                          _model.budgetMax,
                                          CurrencyService.instance.getMaxBudgetForCurrency(BudgetFormatter.userCurrency),
                                        ),
                                        onChanged: (lowerValue, upperValue) {
                                          _model.budgetMin = lowerValue;
                                          _model.budgetMax = upperValue;
                                          safeSetState(() {});
                                          _model.updatePsFiltersDraftStruct(
                                            (e) => e
                                              ..budgetMin = _model.budgetMin
                                              ..budgetMax = _model.budgetMax,
                                          );
                                          safeSetState(() {});
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Align(
                                      alignment: const AlignmentDirectional(0.0, 1.0),
                                      child: FFButtonWidget(
                                        onPressed: () async {
                                          _model.psQueryFilters =
                                              _model.psFiltersDraft;
                                          _model.filterVisibility = false;
                                          safeSetState(() {});
                                        },
                                        text: 'Apply filters',
                                        options: FFButtonOptions(
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  1.0,
                                          height: 50.0,
                                          padding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              const EdgeInsetsDirectional.fromSTEB(
                                                  0.0, 0.0, 0.0, 0.0),
                                          color: FlutterFlowTheme.of(context)
                                              .primary,
                                          textStyle:
                                              FlutterFlowTheme.of(context)
                                                  .titleSmall
                                                  .override(
                                                    fontFamily:
                                                        'Haas Grot Text Trial',
                                                    color: Colors.white,
                                                    fontSize: 14.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                          elevation: 0.0,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ].divide(const SizedBox(height: 14.0)),
                          ),
                        ].divide(const SizedBox(height: 20.0)),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
