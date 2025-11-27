import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/compo_finaux/add_filter_sheet/add_filter_sheet_widget.dart';
import '/compo_finaux/info_alert_item_sheet/info_alert_item_sheet_widget.dart';
import '/compo_finaux/info_poi_sheet/info_poi_sheet_widget.dart';
import '/compo_finaux/info_pro_item_sheet/info_pro_item_sheet_widget.dart';
import '/compo_finaux/info_wedding_pin_sheet/info_wedding_pin_sheet_widget.dart';
import '/compo_finaux/points_of_interest_sheet/points_of_interest_sheet_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/compo_finaux/address_search/address_search_widget.dart';
import '/flutter_flow/custom_functions.dart' as functions;
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'map_brides_large_model.dart';
export 'map_brides_large_model.dart';

class MapBridesLargeWidget extends StatefulWidget {
  const MapBridesLargeWidget({
    super.key,
    this.initialCenter,
  });

  final LatLng? initialCenter;

  static String routeName = 'MapBridesLarge';
  static String routePath = '/mapBridesLarge';

  @override
  State<MapBridesLargeWidget> createState() => _MapBridesLargeWidgetState();
}

class _MapBridesLargeWidgetState extends State<MapBridesLargeWidget> {
  late MapBridesLargeModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  LatLng? currentUserLocationValue;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MapBridesLargeModel());

    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _model.psQueryFilters =
          FFAppState().currentUserPreferences.lastFiltersJson != ''
              ? functions.jsonToQueryFilters(
                  FFAppState().currentUserPreferences.lastFiltersJson)
              : QueryFiltersStruct(
                  currency: valueOrDefault<String>(
                    FFAppState().currentUserPreferences.currency,
                    'USD',
                  ),
                  radiusKm: FFAppState()
                      .currentUserPreferences
                      .defaultRadiusKm
                      .toDouble(),
                  showPros: true,
                  showProRecent: true,
                  showFixedLocations: true,
                  showBridePrivatePoi: true,
                  showWeddingPins: true,
                  showProAlerts: true,
                  showOnlyMyProfessionPins: false,
                );
      _model.psMapData = // Crée une instance de MapdatabundleStruct avec des listes initialisées.
          MapdatabundleStruct(
        markers: <MapMarkerStruct>[],
        weddingPins: <WeddingPinOverlayStruct>[],
        debugStats: 'Initialized on page load',
      );
      if (mounted) {
        safeSetState(() {});
      }
    });

    getCurrentUserLocation(defaultLocation: const LatLng(0.0, 0.0), cached: true)
        .then((loc) => safeSetState(() => currentUserLocationValue = loc));
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    if (currentUserLocationValue == null) {
      return Container(
        color: FlutterFlowTheme.of(context).primaryBackground,
        child: Center(
          child: SizedBox(
            width: 50.0,
            height: 50.0,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: SizedBox(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: MediaQuery.sizeOf(context).height * 1.0,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: MediaQuery.sizeOf(context).height * 1.0,
                decoration: const BoxDecoration(),
                child: Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 150.0),
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width * 1.0,
                      height: MediaQuery.sizeOf(context).height * 1.0,
                      child: custom_widgets.LynewedInteractiveMap(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        height: MediaQuery.sizeOf(context).height * 1.0,
                        initialZoom: 12.0,
                        enableMyLocationLayer: true,
                        userRole: FFAppState().currentUserRole,
                        initialCenter: widget.initialCenter ?? currentUserLocationValue,
                        markers: _model.psMapData?.markers,
                        weddingPinOverlays: _model.psMapData?.weddingPins,
                        filters: _model.psQueryFilters,
                        command: _model.psMapCommand,
                        searchTargetMarker: _model.psSearchTargetMarker,
                        debounceMs: 500,
                        mapStyle: _model.mapStyle,
                        enableClustering: true,
                        clusterRadiusPx: 56.0,
                        minClusterSize: 8,
                        onDataLoaded: (data) async {
                          _model.psMapData = data;
                          safeSetState(() {});
                        },
                        onMarkerTap: (marker) async {
                          var shouldSetState = false;
                          if ((marker.type == MapMarkerType.professional) ||
                              (marker.type == MapMarkerType.proFixedLocation)) {
                            _model.proDetailsFromAction =
                                await actions.getProItemDetailsAction(
                              marker.id,
                            );
                            shouldSetState = true;
                            if (_model.proDetailsFromAction != null) {
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                enableDrag: false,
                                context: context,
                                builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                    },
                                    child: Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: InfoProItemSheetWidget(
                                        proDetails:
                                            _model.proDetailsFromAction!,
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));

                              if (shouldSetState) safeSetState(() {});
                              return;
                            }
                          } else {
                            if (marker.type == MapMarkerType.poiPrivate) {
                              _model.poiDetailsData =
                                  await actions.getPoiItemDetails(
                                marker.id,
                              );
                              shouldSetState = true;
                              if (_model.poiDetailsData != null) {
                                await showModalBottomSheet(
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  enableDrag: false,
                                  context: context,
                                  builder: (context) {
                                    return GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();
                                      },
                                      child: Padding(
                                        padding:
                                            MediaQuery.viewInsetsOf(context),
                                        child: InfoPoiSheetWidget(
                                          poiData: _model.poiDetailsData!,
                                        ),
                                      ),
                                    );
                                  },
                                ).then((value) => safeSetState(() {}));

                                if (shouldSetState) safeSetState(() {});
                                return;
                              }
                            } else {
                              if (marker.type == MapMarkerType.weddingPin) {
                                _model.weddingPinDetailsData =
                                    await actions.getWeddingPinItemDetailsRpc(
                                  marker.id,
                                );
                                shouldSetState = true;
                                if (_model.weddingPinDetailsData != null) {
                                  await showModalBottomSheet(
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    enableDrag: false,
                                    context: context,
                                    builder: (context) {
                                      return GestureDetector(
                                        onTap: () {
                                          FocusScope.of(context).unfocus();
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        child: Padding(
                                          padding:
                                              MediaQuery.viewInsetsOf(context),
                                          child: InfoWeddingPinSheetWidget(
                                            weddingPinData:
                                                _model.weddingPinDetailsData!,
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((value) => safeSetState(() {}));

                                  if (shouldSetState) safeSetState(() {});
                                  return;
                                }
                              } else {
                                if (marker.type ==
                                    MapMarkerType.professionalAlert) {
                                  _model.alertDetails =
                                      await actions.getAlertItemDetailsRpc(
                                    marker.id,
                                  );
                                  shouldSetState = true;
                                  if (_model.alertDetails != null) {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: InfoAlertItemSheetWidget(
                                              alertDetails:
                                                  _model.alertDetails!,
                                            ),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));

                                    if (shouldSetState) safeSetState(() {});
                                    return;
                                  }
                                } else {
                                  await showDialog(
                                    context: context,
                                    builder: (alertDialogContext) {
                                      return AlertDialog(
                                        title: const Text('An error has occurred'),
                                        content: const Text(
                                            'Unable to open the information for this item. Please try again.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                alertDialogContext),
                                            child: const Text('Ok'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (shouldSetState) safeSetState(() {});
                                  return;
                                }
                              }
                            }
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'An error occurred, please try again.',
                                style: TextStyle(
                                  fontFamily: 'Haas Grot Text Trial',
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              duration: const Duration(milliseconds: 2000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).error,
                            ),
                          );
                          if (shouldSetState) safeSetState(() {});
                        },
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(1.0, -1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 80.0, 20.0, 0.0),
                  child: FlutterFlowIconButton(
                    borderRadius: 4.0,
                    buttonSize: 40.0,
                    fillColor: FlutterFlowTheme.of(context).primary,
                    icon: FaIcon(
                      FontAwesomeIcons.locationArrow,
                      color: FlutterFlowTheme.of(context).info,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      _model.psMapCommand = MapCommandStruct(
                        type: MapActionType.locateUser,
                        id: random_data.randomString(
                          12,
                          12,
                          true,
                          true,
                          true,
                        ),
                      );
                      safeSetState(() {});
                    },
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(1.0, -1.0),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 160.0, 20.0, 0.0),
                  child: FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.add,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      _model.psMapCommand = MapCommandStruct(
                        type: MapActionType.zoomIn,
                        id: random_data.randomString(
                          12,
                          12,
                          true,
                          true,
                          true,
                        ),
                      );
                      safeSetState(() {});
                    },
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(1.0, -1.0),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 210.0, 20.0, 0.0),
                  child: FlutterFlowIconButton(
                    borderRadius: 8.0,
                    buttonSize: 40.0,
                    icon: Icon(
                      Icons.remove,
                      color: FlutterFlowTheme.of(context).primary,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      _model.psMapCommand = MapCommandStruct(
                        type: MapActionType.zoomOut,
                        id: random_data.randomString(
                          12,
                          12,
                          true,
                          true,
                          true,
                        ),
                      );
                      safeSetState(() {});
                    },
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-1.0, -1.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 70.0, 0.0, 0.0),
                  child: FlutterFlowIconButton(
                    borderRadius: 100.0,
                    borderWidth: 0.0,
                    buttonSize: 40.0,
                    fillColor: FlutterFlowTheme.of(context).primary,
                    icon: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      size: 17.0,
                    ),
                    onPressed: () async {
                      context.safePop();
                    },
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(1.0, -1.0),
                child: Padding(
                  padding:
                      const EdgeInsetsDirectional.fromSTEB(0.0, 136.0, 25.0, 0.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Zoom',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Haas Grot Text Trial',
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(0.0, 1.0),
                      child: SizedBox(
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        child: Stack(
                          alignment: const AlignmentDirectional(0.0, 1.0),
                          children: [
                            Align(
                              alignment: const AlignmentDirectional(1.0, 1.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                child: SizedBox(
                                  width: 40.0,
                                  height: 90.0,
                                  child: Stack(
                                    alignment: const AlignmentDirectional(1.0, 1.0),
                                    children: [
                                      if (_model.viewMapStyle == true)
                                        Container(
                                          decoration: const BoxDecoration(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  _model.mapStyle =
                                                      MapStyleType.satellite;
                                                  _model.viewMapStyle = false;
                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    color: _model.mapStyle ==
                                                            MapStyleType
                                                                .satellite
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .success
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(2.0),
                                                    child: Container(
                                                      width: 40.0,
                                                      height: 40.0,
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Image.asset(
                                                        'assets/images/SCR-20251017-jqhr.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                splashColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () async {
                                                  _model.mapStyle =
                                                      MapStyleType.normal;
                                                  _model.viewMapStyle = false;
                                                  safeSetState(() {});
                                                },
                                                child: Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    color: _model.mapStyle ==
                                                            MapStyleType.normal
                                                        ? FlutterFlowTheme.of(
                                                                context)
                                                            .success
                                                        : FlutterFlowTheme.of(
                                                                context)
                                                            .tertiary,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(2.0),
                                                    child: Container(
                                                      width: 40.0,
                                                      height: 40.0,
                                                      clipBehavior:
                                                          Clip.antiAlias,
                                                      decoration: const BoxDecoration(
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Image.asset(
                                                        'assets/images/SCR-20251017-jpwd.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ].divide(const SizedBox(height: 8.0)),
                                          ),
                                        ),
                                      if (_model.viewMapStyle == false)
                                        Align(
                                          alignment:
                                              const AlignmentDirectional(1.0, 1.0),
                                          child: FlutterFlowIconButton(
                                            borderRadius: 100.0,
                                            buttonSize: 40.0,
                                            fillColor:
                                                FlutterFlowTheme.of(context)
                                                    .primary,
                                            icon: Icon(
                                              Icons.map,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .info,
                                              size: 24.0,
                                            ),
                                            onPressed: () async {
                                              _model.viewMapStyle = true;
                                              safeSetState(() {});
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: const AlignmentDirectional(-1.0, 1.0),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    20.0, 0.0, 20.0, 0.0),
                                child: FlutterFlowIconButton(
                                  borderRadius: 100.0,
                                  buttonSize: 40.0,
                                  fillColor:
                                      FlutterFlowTheme.of(context).primary,
                                  icon: Icon(
                                    Icons.pin_drop_sharp,
                                    color: FlutterFlowTheme.of(context).info,
                                    size: 24.0,
                                  ),
                                  onPressed: () async {
                                    await showModalBottomSheet(
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      enableDrag: false,
                                      context: context,
                                      builder: (context) {
                                        return GestureDetector(
                                          onTap: () {
                                            FocusScope.of(context).unfocus();
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                          },
                                          child: Padding(
                                            padding: MediaQuery.viewInsetsOf(
                                                context),
                                            child: PointsOfInterestSheetWidget(
                                              nav: (mapCommand) async {
                                                _model.psMapCommand =
                                                    mapCommand;
                                                safeSetState(() {});
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, 1.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: MediaQuery.sizeOf(context).width * 1.0,
                        // Expand height when suggestions are visible to make room for dropdown
                        constraints: BoxConstraints(
                          minHeight: _model.suggestionsVisible ? 420.0 : 0.0,
                        ),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(0.0),
                            bottomRight: Radius.circular(0.0),
                            topLeft: Radius.circular(24.0),
                            topRight: Radius.circular(24.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              20.0, 20.0, 20.0, 50.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Align(
                                alignment: const AlignmentDirectional(-1.0, 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Align(
                                      alignment:
                                          const AlignmentDirectional(-1.0, -1.0),
                                      child: InkWell(
                                        splashColor: Colors.transparent,
                                        focusColor: Colors.transparent,
                                        hoverColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () async {
                                          await showModalBottomSheet(
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            enableDrag: false,
                                            context: context,
                                            builder: (context) {
                                              return GestureDetector(
                                                onTap: () {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  FocusManager
                                                      .instance.primaryFocus
                                                      ?.unfocus();
                                                },
                                                child: Padding(
                                                  padding:
                                                      MediaQuery.viewInsetsOf(
                                                          context),
                                                  child: AddFilterSheetWidget(
                                                    filtersOn:
                                                        _model.psQueryFilters!,
                                                    onFiltersApplied:
                                                        (appliedFilters) async {
                                                      _model.psQueryFilters =
                                                          appliedFilters;
                                                      safeSetState(() {});
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ).then(
                                              (value) => safeSetState(() {}));
                                        },
                                        child: Container(
                                          height: 32.0,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(99.0),
                                            border: Border.all(
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                            ),
                                          ),
                                          child: Padding(
                                            padding:
                                                const EdgeInsetsDirectional.fromSTEB(
                                                    12.0, 0.0, 12.0, 0.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.filter_list,
                                                  color: FlutterFlowTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size: 18.0,
                                                ),
                                                Text(
                                                  'Apply Filters',
                                                  style: FlutterFlowTheme.of(
                                                          context)
                                                      .bodyMedium
                                                      .override(
                                                        fontFamily:
                                                            'Haas Grot Text Trial',
                                                        letterSpacing: 0.0,
                                                      ),
                                                ),
                                              ].divide(const SizedBox(width: 6.0)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                                                      ].divide(const SizedBox(width: 12.0)),
                                ),
                              ),
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
                                              child: AddressSearchWidget(
                                                width:
                                                    MediaQuery.sizeOf(context)
                                                            .width *
                                                        1.0,
                                                height: 50.0,
                                                hintText: 'Country or city',
                                                initialValue: _model.searchText,
                                                debounceMs: 200,
                                                locale: valueOrDefault<String>(
                                                  FFAppState()
                                                      .currentUserPreferences
                                                      .defaultLocale,
                                                  'en',
                                                ),
                                                onAddressSelected: (PlaceDetailsDataStruct details) {
                                                  // TODO: Convert searchTarget to overlay (Phase 2+)
                                                  // _model.psSearchTargetMarker =
                                                  //     MapMarkerStruct(
                                                  //   id: 'search_target',
                                                  //   type: MapMarkerType.searchTarget, // REMOVED from enum
                                                  //   position: details.coords,
                                                  // );
                                                  _model.psMapCommand =
                                                      MapCommandStruct(
                                                    id: random_data.randomString(
                                                      12,
                                                      12,
                                                      true,
                                                      true,
                                                      true,
                                                    ),
                                                    type: MapActionType.moveToTarget,
                                                    target: details.coords,
                                                  );
                                                  safeSetState(() {});
                                                },
                                                onAddressCleared: () {
                                                  // Business logic: Clear search target
                                                  _model.psSearchTargetMarker = null;
                                                  safeSetState(() {});
                                                },
                                                onSearchTextChanged: (String text) {
                                                  _model.searchText = text;
                                                },
                                                onSuggestionsVisibilityChanged: (bool visible) {
                                                  _model.suggestionsVisible = visible;
                                                  safeSetState(() {});
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ].divide(const SizedBox(width: 8.0)),
                              ),
                                                          ].divide(const SizedBox(height: 14.0)),
                          ),
                        ),
                      ),
                    ),
                  ].divide(const SizedBox(height: 24.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
