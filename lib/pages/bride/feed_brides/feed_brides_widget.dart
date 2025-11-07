import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'feed_brides_model.dart';
export 'feed_brides_model.dart';
import 'feed_profession_grid.dart';

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
      _model.psQueryFilters = QueryFiltersStruct(
        radiusKm: 100.0,
        professions: Profession.values,
        budgetMin: 0.0,
        budgetMax: 40000.0,
      );
      _model.psFiltersDraft = QueryFiltersStruct(
        radiusKm: 100.0,
        professions: Profession.values,
        budgetMin: 0.0,
        budgetMax: 40000.0,
      );
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: const AlignmentDirectional(1.0, 0.0),
                                      child: SizedBox(
                                        height: 45.0,
                                        child: Stack(
                                          alignment:
                                              const AlignmentDirectional(0.0, 1.0),
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.sizeOf(context)
                                                      .width *
                                                  1.0,
                                              height: 50.0,
                                              child: custom_widgets
                                                  .InstantSearchTextField(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                height: 50.0,
                                                hintText: 'Country or city',
                                                initialValue:
                                                    _model.psSearchText,
                                                debounceMs: 200,
                                                onChanged: (value) async {
                                                  _model.predictionsResult =
                                                      await actions
                                                          .getPlacePredictions(
                                                    value,
                                                    _model.psPlacesSessionToken,
                                                    valueOrDefault<String>(
                                                      FFAppState()
                                                          .currentUserPreferences
                                                          .defaultLocale,
                                                      'en',
                                                    ),
                                                  );
                                                  _model.psPlaceSuggestions = _model
                                                      .predictionsResult!
                                                      .suggestions
                                                      .toList()
                                                      .cast<
                                                          PlaceSuggestionStruct>();
                                                  _model.psPlacesSessionToken =
                                                      _model.predictionsResult
                                                          ?.newSessionToken;
                                                  safeSetState(() {});

                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    splashColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    onTap: () async {
                                      // Reset filters to default values
                                      _model.updatePsFiltersDraftStruct(
                                        (e) => e
                                          ..professions = [
                                            Profession.PHOTOGRAPHER,
                                            Profession.FILMMAKER,
                                            Profession.PLANNER,
                                            Profession.MAKEUP,
                                            Profession.MAKEUPARTIST,
                                            Profession.HAIRDRESSER,
                                            Profession.DESIGNER,
                                            Profession.EVENTDESIGNER,
                                            Profession.BRIDALDESIGNER,
                                            Profession.VENUE,
                                            Profession.BRIDALSHOP,
                                            Profession.FLORIST,
                                            Profession.PHOTOMOVIE,
                                          ]
                                          ..budgetMin = 0.0
                                          ..budgetMax = 40000.0
                                          ..center = null
                                          ..radiusKm = 100.0,
                                      );
                                      _model.budgetMin = 0.0;
                                      _model.budgetMax = 40000.0;
                                      _model.sliderValue = 100.0;
                                      _model.psSearchText = '';
                                      safeSetState(() {});
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              4.0, 4.0, 0.0, 4.0),
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
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                              if (_model.psPlaceSuggestions.isNotEmpty)
                                Builder(
                                  builder: (context) {
                                    final placeSuggestionList =
                                        _model.psPlaceSuggestions.toList();
                                    if (placeSuggestionList.isEmpty) {
                                      return const Center(
                                        child: EmptyStateWidget(
                                          message: 'Aucune adresse trouvée...',
                                        ),
                                      );
                                    }

                                    return ListView.separated(
                                      padding: EdgeInsets.zero,
                                      primary: false,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      itemCount: placeSuggestionList.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10.0),
                                      itemBuilder:
                                          (context, placeSuggestionListIndex) {
                                        final placeSuggestionListItem =
                                            placeSuggestionList[
                                                placeSuggestionListIndex];
                                        return InkWell(
                                          splashColor: Colors.transparent,
                                          focusColor: Colors.transparent,
                                          hoverColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                          onTap: () async {
                                            _model.placeCoordinates =
                                                await actions
                                                    .getPlaceDetailsRich(
                                              placeSuggestionListItem.placeId,
                                              _model.psPlacesSessionToken!,
                                              valueOrDefault<String>(
                                                FFAppState()
                                                    .currentUserPreferences
                                                    .defaultLocale,
                                                'en',
                                              ),
                                            );
                                            _model.placeSelected =
                                                _model.placeCoordinates;
                                            _model.psSearchText =
                                                placeSuggestionListItem
                                                    .primaryText;
                                            _model.psPlaceSuggestions = [];
                                            _model.psPlacesSessionToken = null;
                                            _model.updatePsFiltersDraftStruct(
                                              (e) => e
                                                ..center = _model
                                                    .placeCoordinates?.coords,
                                            );
                                            safeSetState(() {});

                                            safeSetState(() {});
                                          },
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text(
                                                    placeSuggestionListItem
                                                        .primaryText,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Haas Grot Text Trial',
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: [
                                                  Text(
                                                    placeSuggestionListItem
                                                        .secondaryText,
                                                    style: FlutterFlowTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          fontFamily:
                                                              'Haas Grot Text Trial',
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .accent1,
                                                          fontSize: 12.0,
                                                          letterSpacing: 0.0,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Slider(
                                    activeColor:
                                        FlutterFlowTheme.of(context).primary,
                                    inactiveColor:
                                        FlutterFlowTheme.of(context).alternate,
                                    min: 5.0,
                                    max: 500.0,
                                    value: _model.sliderValue ??=
                                        valueOrDefault<double>(
                                      _model.psFiltersDraft?.radiusKm,
                                      100.0,
                                    ),
                                    divisions: 99,
                                    onChanged: (newValue) {
                                      newValue = double.parse(
                                          newValue.toStringAsFixed(2));
                                      safeSetState(
                                          () => _model.sliderValue = newValue);
                                    },
                                    onChangeEnd: (newValue) async {
                                      newValue = double.parse(
                                          newValue.toStringAsFixed(2));
                                      safeSetState(
                                          () => _model.sliderValue = newValue);
                                      _model.updatePsFiltersDraftStruct(
                                        (e) => e..radiusKm = _model.sliderValue,
                                      );
                                      safeSetState(() {});
                                    },
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Text(
                                        '${_model.sliderValue?.toString()} km',
                                        style: FlutterFlowTheme.of(context)
                                            .bodyMedium
                                            .override(
                                              fontFamily:
                                                  'Haas Grot Text Trial',
                                              letterSpacing: 0.0,
                                            ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                    child: FeedProfessionGrid(
                                      filters: _model.psFiltersDraft,
                                      onFiltersUpdate: (updateFn) {
                                        _model.updatePsFiltersDraftStruct(updateFn);
                                      },
                                      onSetState: () {
                                        safeSetState(() {});
                                      },
                                    ),
                                  ),
                                ],
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
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 100.0,
                                        child: custom_widgets
                                            .CustomRangeSliderWidget(
                                          width: double.infinity,
                                          height: 100.0,
                                          minValue: 0.0,
                                          maxValue: 40000.0,
                                          lowerValue: valueOrDefault<double>(
                                            _model.budgetMin,
                                            0.0,
                                          ),
                                          upperValue: valueOrDefault<double>(
                                            _model.budgetMax,
                                            40000.0,
                                          ),
                                          onChanged:
                                              (lowerValue, upperValue) async {
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
            ],
          ),
        ),
      ),
    );
  }
}
