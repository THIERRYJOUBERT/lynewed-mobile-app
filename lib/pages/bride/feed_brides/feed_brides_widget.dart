import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'feed_brides_model.dart';
export 'feed_brides_model.dart';

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
      safeSetState(() {});
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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Padding(
                padding:
                    EdgeInsetsDirectional.fromSTEB(14.0, 130.0, 14.0, 90.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
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
                  ].divide(SizedBox(height: 0.0)),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.navBarBridesModel,
                  updateCallback: () => safeSetState(() {}),
                  child: NavBarBridesWidget(
                    number: 2,
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(0.0, -1.0),
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
                        padding: EdgeInsetsDirectional.fromSTEB(
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
                        alignment: AlignmentDirectional(0.0, 1.0),
                        child: Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(
                              0.0, 14.0, 0.0, 0.0),
                          child: Container(
                            width: double.infinity,
                            height: 1.0,
                            decoration: BoxDecoration(
                              color: FlutterFlowTheme.of(context).secondary,
                            ),
                            alignment: AlignmentDirectional(0.0, 1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_model.filterVisibility == true)
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 110.0, 0.0, 0.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
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
                                      alignment: AlignmentDirectional(1.0, 0.0),
                                      child: Container(
                                        height: 45.0,
                                        child: Stack(
                                          alignment:
                                              AlignmentDirectional(0.0, 1.0),
                                          children: [
                                            Container(
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
                                ].divide(SizedBox(width: 8.0)),
                              ),
                              if (_model.psPlaceSuggestions.length != 0)
                                Builder(
                                  builder: (context) {
                                    final placeSuggestionList =
                                        _model.psPlaceSuggestions.toList();
                                    if (placeSuggestionList.isEmpty) {
                                      return Center(
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
                                          SizedBox(height: 10.0),
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
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              checkboxTheme: CheckboxThemeData(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: Checkbox(
                                              value: _model
                                                      .checkboxPHOTOGRAPHERValue ??=
                                                  _model.psQueryFilters!
                                                      .professions
                                                      .contains(Profession
                                                          .PHOTOGRAPHER),
                                              onChanged: (newValue) async {
                                                safeSetState(() => _model
                                                        .checkboxPHOTOGRAPHERValue =
                                                    newValue!);
                                                if (newValue!) {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.add(Profession
                                                            .PHOTOGRAPHER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.remove(
                                                            Profession
                                                                .PHOTOGRAPHER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              side:
                                                  (FlutterFlowTheme.of(context)
                                                              .secondaryText !=
                                                          null)
                                                      ? BorderSide(
                                                          width: 2,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText!,
                                                        )
                                                      : null,
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              checkColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                          ),
                                          Text(
                                            'PHOTOGRAPHER',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              checkboxTheme: CheckboxThemeData(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: Checkbox(
                                              value: _model
                                                      .checkboxFILMMAKERValue ??=
                                                  _model.psQueryFilters!
                                                      .professions
                                                      .contains(
                                                          Profession.FILMMAKER),
                                              onChanged: (newValue) async {
                                                safeSetState(() => _model
                                                        .checkboxFILMMAKERValue =
                                                    newValue!);
                                                if (newValue!) {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.add(Profession
                                                            .FILMMAKER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.remove(
                                                            Profession
                                                                .FILMMAKER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              side:
                                                  (FlutterFlowTheme.of(context)
                                                              .secondaryText !=
                                                          null)
                                                      ? BorderSide(
                                                          width: 2,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText!,
                                                        )
                                                      : null,
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              checkColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                          ),
                                          Text(
                                            'FILMMAKER',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              checkboxTheme: CheckboxThemeData(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: Checkbox(
                                              value: _model
                                                      .checkboxHAIRDRESSERValue ??=
                                                  _model.psQueryFilters!
                                                      .professions
                                                      .contains(Profession
                                                          .HAIRDRESSER),
                                              onChanged: (newValue) async {
                                                safeSetState(() => _model
                                                        .checkboxHAIRDRESSERValue =
                                                    newValue!);
                                                if (newValue!) {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.add(Profession
                                                            .HAIRDRESSER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.remove(
                                                            Profession
                                                                .HAIRDRESSER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              side:
                                                  (FlutterFlowTheme.of(context)
                                                              .secondaryText !=
                                                          null)
                                                      ? BorderSide(
                                                          width: 2,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText!,
                                                        )
                                                      : null,
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              checkColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                          ),
                                          Text(
                                            'HAIRDRESSER',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              checkboxTheme: CheckboxThemeData(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: Checkbox(
                                              value: _model
                                                      .checkboxMAKEUPValue ??=
                                                  _model.psQueryFilters!
                                                      .professions
                                                      .contains(
                                                          Profession.MAKEUP),
                                              onChanged: (newValue) async {
                                                safeSetState(() =>
                                                    _model.checkboxMAKEUPValue =
                                                        newValue!);
                                                if (newValue!) {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.add(
                                                            Profession.MAKEUP),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.remove(
                                                            Profession.MAKEUP),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              side:
                                                  (FlutterFlowTheme.of(context)
                                                              .secondaryText !=
                                                          null)
                                                      ? BorderSide(
                                                          width: 2,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText!,
                                                        )
                                                      : null,
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              checkColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                          ),
                                          Text(
                                            'MAKE-UP',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              checkboxTheme: CheckboxThemeData(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: Checkbox(
                                              value: _model
                                                      .checkboxFLORISTValue ??=
                                                  _model.psQueryFilters!
                                                      .professions
                                                      .contains(
                                                          Profession.FLORIST),
                                              onChanged: (newValue) async {
                                                safeSetState(() => _model
                                                        .checkboxFLORISTValue =
                                                    newValue!);
                                                if (newValue!) {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.add(
                                                            Profession.FLORIST),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.remove(
                                                            Profession.FLORIST),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              side:
                                                  (FlutterFlowTheme.of(context)
                                                              .secondaryText !=
                                                          null)
                                                      ? BorderSide(
                                                          width: 2,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText!,
                                                        )
                                                      : null,
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              checkColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                          ),
                                          Text(
                                            'FLORIST',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              checkboxTheme: CheckboxThemeData(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: Checkbox(
                                              value: _model
                                                      .checkboxPLANNERValue ??=
                                                  _model.psQueryFilters!
                                                      .professions
                                                      .contains(
                                                          Profession.PLANNER),
                                              onChanged: (newValue) async {
                                                safeSetState(() => _model
                                                        .checkboxPLANNERValue =
                                                    newValue!);
                                                if (newValue!) {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.add(
                                                            Profession.PLANNER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.remove(
                                                            Profession.PLANNER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              side:
                                                  (FlutterFlowTheme.of(context)
                                                              .secondaryText !=
                                                          null)
                                                      ? BorderSide(
                                                          width: 2,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText!,
                                                        )
                                                      : null,
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              checkColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                          ),
                                          Text(
                                            'PLANNER',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              checkboxTheme: CheckboxThemeData(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: Checkbox(
                                              value: _model
                                                      .checkboxDESIGNERValue ??=
                                                  _model.psQueryFilters!
                                                      .professions
                                                      .contains(
                                                          Profession.DESIGNER),
                                              onChanged: (newValue) async {
                                                safeSetState(() => _model
                                                        .checkboxDESIGNERValue =
                                                    newValue!);
                                                if (newValue!) {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.add(Profession
                                                            .DESIGNER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.remove(
                                                            Profession
                                                                .DESIGNER),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              side:
                                                  (FlutterFlowTheme.of(context)
                                                              .secondaryText !=
                                                          null)
                                                      ? BorderSide(
                                                          width: 2,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText!,
                                                        )
                                                      : null,
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              checkColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                          ),
                                          Text(
                                            'DESIGNER',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              checkboxTheme: CheckboxThemeData(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: Checkbox(
                                              value: _model
                                                      .checkboxVENUESValue ??=
                                                  _model.psQueryFilters!
                                                      .professions
                                                      .contains(
                                                          Profession.VENUE),
                                              onChanged: (newValue) async {
                                                safeSetState(() =>
                                                    _model.checkboxVENUESValue =
                                                        newValue!);
                                                if (newValue!) {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.add(
                                                            Profession.VENUE),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.remove(
                                                            Profession.VENUE),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              side:
                                                  (FlutterFlowTheme.of(context)
                                                              .secondaryText !=
                                                          null)
                                                      ? BorderSide(
                                                          width: 2,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText!,
                                                        )
                                                      : null,
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              checkColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                          ),
                                          Text(
                                            'VENUES',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Theme(
                                            data: ThemeData(
                                              checkboxTheme: CheckboxThemeData(
                                                visualDensity:
                                                    VisualDensity.compact,
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          0.0),
                                                ),
                                              ),
                                              unselectedWidgetColor:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                            child: Checkbox(
                                              value: _model
                                                      .checkboxBRIDALValue ??=
                                                  _model.psQueryFilters!
                                                      .professions
                                                      .contains(Profession
                                                          .BRIDALSHOP),
                                              onChanged: (newValue) async {
                                                safeSetState(() =>
                                                    _model.checkboxBRIDALValue =
                                                        newValue!);
                                                if (newValue!) {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.add(Profession
                                                            .BRIDALSHOP),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                } else {
                                                  _model
                                                      .updatePsFiltersDraftStruct(
                                                    (e) => e
                                                      ..updateProfessions(
                                                        (e) => e.remove(
                                                            Profession
                                                                .BRIDALSHOP),
                                                      ),
                                                  );
                                                  safeSetState(() {});
                                                }
                                              },
                                              side:
                                                  (FlutterFlowTheme.of(context)
                                                              .secondaryText !=
                                                          null)
                                                      ? BorderSide(
                                                          width: 2,
                                                          color: FlutterFlowTheme
                                                                  .of(context)
                                                              .secondaryText!,
                                                        )
                                                      : null,
                                              activeColor:
                                                  FlutterFlowTheme.of(context)
                                                      .primary,
                                              checkColor:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                            ),
                                          ),
                                          Text(
                                            'BRIDAL',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily:
                                                      'Haas Grot Text Trial',
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(
                                          0.0, 8.0, 0.0, 0.0),
                                      child: Container(
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
                                      alignment: AlignmentDirectional(0.0, 1.0),
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
                                              EdgeInsetsDirectional.fromSTEB(
                                                  16.0, 0.0, 16.0, 0.0),
                                          iconPadding:
                                              EdgeInsetsDirectional.fromSTEB(
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
                            ].divide(SizedBox(height: 14.0)),
                          ),
                        ].divide(SizedBox(height: 20.0)),
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
