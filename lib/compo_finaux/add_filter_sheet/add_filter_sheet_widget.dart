import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'add_filter_sheet_model.dart';
export 'add_filter_sheet_model.dart';

class AddFilterSheetWidget extends StatefulWidget {
  const AddFilterSheetWidget({
    super.key,
    required this.onFiltersApplied,
    required this.filtersOn,
  });

  final Future Function(QueryFiltersStruct appliedFilters)? onFiltersApplied;
  final QueryFiltersStruct? filtersOn;

  @override
  State<AddFilterSheetWidget> createState() => _AddFilterSheetWidgetState();
}

class _AddFilterSheetWidgetState extends State<AddFilterSheetWidget> {
  late AddFilterSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => AddFilterSheetModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.budgetMin = widget!.filtersOn?.budgetMin;
      _model.budgetMax = widget!.filtersOn?.budgetMax;
      _model.selectedProfessions =
          widget!.filtersOn!.professions.toList().cast<Profession>();
      _model.showPros = widget!.filtersOn!.showPros;
      _model.showProRecent = widget!.filtersOn!.showProRecent;
      _model.showWeddingPins = widget!.filtersOn!.showWeddingPins;
      _model.showProAlerts = widget!.filtersOn!.showProAlerts;
      safeSetState(() {});
      await Future.wait([
        Future(() async {
          safeSetState(() {
            _model.checkboxProfessionalValue = _model.showPros;
          });
        }),
        Future(() async {
          safeSetState(() {
            _model.checkboxProRecentValue = _model.showProRecent;
          });
        }),
        Future(() async {
          safeSetState(() {
            _model.checkboxAlertValue = _model.showProAlerts;
          });
        }),
        Future(() async {
          safeSetState(() {
            _model.checkboxWeddingPinValue = _model.showWeddingPins;
          });
        }),
      ]);
      _model.budgetVisible = widget!.filtersOn!.budgetMax > 1.0;
      _model.professionVisible = widget!.filtersOn!.professions.length >= 1;
      _model.typeVisible = true;
      safeSetState(() {});
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Container(
      width: MediaQuery.sizeOf(context).width * 1.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(0.0),
          bottomRight: Radius.circular(0.0),
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Material(
                  color: Colors.transparent,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10.0,
                          color: FlutterFlowTheme.of(context).secondary,
                          offset: Offset(
                            0.0,
                            0.0,
                          ),
                        )
                      ],
                      borderRadius: BorderRadius.circular(100.0),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                      ),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 24.0,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'FILTER SEARCHES',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () async {
                    _model.newDefaultFilters =
                        await actions.resetAndApplyDefaultFilters(
                      context,
                      widget!.filtersOn!,
                    );
                    await widget.onFiltersApplied?.call(
                      _model.newDefaultFilters!,
                    );
                    Navigator.pop(context);

                    safeSetState(() {});
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding:
                            EdgeInsetsDirectional.fromSTEB(4.0, 4.0, 0.0, 4.0),
                        child: Text(
                          'Reset Filters',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
              ].divide(SizedBox(width: 8.0)),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 6.0),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () async {
                      _model.typeVisible = !_model.typeVisible;
                      safeSetState(() {});
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            'TYPE',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Haas Grot Text Trial',
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                        Icon(
                          Icons.add,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_model.typeVisible == true)
                  Align(
                    alignment: AlignmentDirectional(-1.0, 0.0),
                    child: Wrap(
                      spacing: 10.0,
                      runSpacing: 2.0,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      direction: Axis.horizontal,
                      runAlignment: WrapAlignment.start,
                      verticalDirection: VerticalDirection.down,
                      clipBehavior: Clip.none,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Theme(
                              data: ThemeData(
                                checkboxTheme: CheckboxThemeData(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                ),
                                unselectedWidgetColor:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              child: Checkbox(
                                value: _model.checkboxProfessionalValue ??=
                                    _model.showPros,
                                onChanged: (newValue) async {
                                  safeSetState(() => _model
                                      .checkboxProfessionalValue = newValue!);
                                  if (newValue!) {
                                    _model.showPros = true;
                                    safeSetState(() {});
                                  } else {
                                    _model.showPros = false;
                                    safeSetState(() {});
                                  }
                                },
                                side: (FlutterFlowTheme.of(context)
                                            .secondaryText !=
                                        null)
                                    ? BorderSide(
                                        width: 2,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText!,
                                      )
                                    : null,
                                activeColor:
                                    FlutterFlowTheme.of(context).primary,
                                checkColor: FlutterFlowTheme.of(context).info,
                              ),
                            ),
                            Text(
                              'Professional',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Theme(
                              data: ThemeData(
                                checkboxTheme: CheckboxThemeData(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                ),
                                unselectedWidgetColor:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              child: Checkbox(
                                value: _model.checkboxProRecentValue ??=
                                    _model.showProRecent,
                                onChanged: (newValue) async {
                                  safeSetState(() => _model
                                      .checkboxProRecentValue = newValue!);
                                  if (newValue!) {
                                    _model.showProRecent = true;
                                    safeSetState(() {});
                                  } else {
                                    _model.showProRecent = false;
                                    safeSetState(() {});
                                  }
                                },
                                side: (FlutterFlowTheme.of(context)
                                            .secondaryText !=
                                        null)
                                    ? BorderSide(
                                        width: 2,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText!,
                                      )
                                    : null,
                                activeColor:
                                    FlutterFlowTheme.of(context).primary,
                                checkColor: FlutterFlowTheme.of(context).info,
                              ),
                            ),
                            Text(
                              'proRecent',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Theme(
                              data: ThemeData(
                                checkboxTheme: CheckboxThemeData(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                ),
                                unselectedWidgetColor:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              child: Checkbox(
                                value: _model.checkboxAlertValue ??=
                                    _model.showProAlerts,
                                onChanged: (newValue) async {
                                  safeSetState(() =>
                                      _model.checkboxAlertValue = newValue!);
                                  if (newValue!) {
                                    _model.showProAlerts = true;
                                    safeSetState(() {});
                                  } else {
                                    _model.showProAlerts = false;
                                    safeSetState(() {});
                                  }
                                },
                                side: (FlutterFlowTheme.of(context)
                                            .secondaryText !=
                                        null)
                                    ? BorderSide(
                                        width: 2,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText!,
                                      )
                                    : null,
                                activeColor:
                                    FlutterFlowTheme.of(context).primary,
                                checkColor: FlutterFlowTheme.of(context).info,
                              ),
                            ),
                            Text(
                              'Alert',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Theme(
                              data: ThemeData(
                                checkboxTheme: CheckboxThemeData(
                                  visualDensity: VisualDensity.compact,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(0.0),
                                  ),
                                ),
                                unselectedWidgetColor:
                                    FlutterFlowTheme.of(context).secondaryText,
                              ),
                              child: Checkbox(
                                value: _model.checkboxWeddingPinValue ??=
                                    _model.showWeddingPins,
                                onChanged: (newValue) async {
                                  safeSetState(() => _model
                                      .checkboxWeddingPinValue = newValue!);
                                  if (newValue!) {
                                    _model.showWeddingPins = true;
                                    safeSetState(() {});
                                  } else {
                                    _model.showWeddingPins = false;
                                    safeSetState(() {});
                                  }
                                },
                                side: (FlutterFlowTheme.of(context)
                                            .secondaryText !=
                                        null)
                                    ? BorderSide(
                                        width: 2,
                                        color: FlutterFlowTheme.of(context)
                                            .secondaryText!,
                                      )
                                    : null,
                                activeColor:
                                    FlutterFlowTheme.of(context).primary,
                                checkColor: FlutterFlowTheme.of(context).info,
                              ),
                            ),
                            Text(
                              'weddingPin',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ].divide(SizedBox(height: 6.0)),
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).tertiary,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 6.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _model.professionVisible = !_model.professionVisible;
                        safeSetState(() {});
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              'SERVICE PROVIDERS',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.add,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_model.professionVisible == true)
                    Align(
                      alignment: AlignmentDirectional(-1.0, 0.0),
                      child: Wrap(
                        spacing: 4.0,
                        runSpacing: 0.0,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        direction: Axis.horizontal,
                        runAlignment: WrapAlignment.start,
                        verticalDirection: VerticalDirection.down,
                        clipBehavior: Clip.none,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxPHOTOGRAPHERValue ??=
                                      _model.selectedProfessions
                                          .contains(Profession.PHOTOGRAPHER),
                                  onChanged: (newValue) async {
                                    safeSetState(() => _model
                                        .checkboxPHOTOGRAPHERValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.PHOTOGRAPHER);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.PHOTOGRAPHER);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'PHOTOGRAPHER',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxFILMMAKERValue ??=
                                      _model.selectedProfessions
                                          .contains(Profession.FILMMAKER),
                                  onChanged: (newValue) async {
                                    safeSetState(() => _model
                                        .checkboxFILMMAKERValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.FILMMAKER);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.FILMMAKER);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'FILMMAKER',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxHAIRDRESSERValue ??=
                                      _model.selectedProfessions
                                          .contains(Profession.HAIRDRESSER),
                                  onChanged: (newValue) async {
                                    safeSetState(() => _model
                                        .checkboxHAIRDRESSERValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.HAIRDRESSER);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.HAIRDRESSER);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'HAIRDRESSER',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxBRIDALDESIGNERValue ??=
                                      _model.selectedProfessions
                                          .contains(Profession.BRIDALDESIGNER),
                                  onChanged: (newValue) async {
                                    safeSetState(() =>
                                        _model.checkboxBRIDALDESIGNERValue =
                                            newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.BRIDALDESIGNER);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.BRIDALDESIGNER);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'BRIDALDESIGNER',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxMAKEUPValue ??= _model
                                      .selectedProfessions
                                      .contains(Profession.MAKEUP),
                                  onChanged: (newValue) async {
                                    safeSetState(() =>
                                        _model.checkboxMAKEUPValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.MAKEUP);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.MAKEUP);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'MAKE-UP',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxFLORISTValue ??= _model
                                      .selectedProfessions
                                      .contains(Profession.FLORIST),
                                  onChanged: (newValue) async {
                                    safeSetState(() => _model
                                        .checkboxFLORISTValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.FLORIST);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.FLORIST);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'FLORIST',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxPLANNERValue ??= _model
                                      .selectedProfessions
                                      .contains(Profession.PLANNER),
                                  onChanged: (newValue) async {
                                    safeSetState(() => _model
                                        .checkboxPLANNERValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.PLANNER);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.PLANNER);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'PLANNER',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxPHOTOMOVIEValue ??=
                                      _model.selectedProfessions
                                          .contains(Profession.PHOTOMOVIE),
                                  onChanged: (newValue) async {
                                    safeSetState(() => _model
                                        .checkboxPHOTOMOVIEValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.PHOTOMOVIE);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.PHOTOMOVIE);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'PHOTOMOVIE',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxDESIGNERValue ??= _model
                                      .selectedProfessions
                                      .contains(Profession.DESIGNER),
                                  onChanged: (newValue) async {
                                    safeSetState(() => _model
                                        .checkboxDESIGNERValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.DESIGNER);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.DESIGNER);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'DESIGNER',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxVENUESValue ??= _model
                                      .selectedProfessions
                                      .contains(Profession.VENUE),
                                  onChanged: (newValue) async {
                                    safeSetState(() =>
                                        _model.checkboxVENUESValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.VENUE);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.VENUE);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'VENUES',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxBRIDALValue ??= _model
                                      .selectedProfessions
                                      .contains(Profession.BRIDALSHOP),
                                  onChanged: (newValue) async {
                                    safeSetState(() =>
                                        _model.checkboxBRIDALValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.BRIDALSHOP);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.BRIDALSHOP);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'BRIDALSHOP',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxMAKEUPARTISTValue ??=
                                      _model.selectedProfessions
                                          .contains(Profession.MAKEUPARTIST),
                                  onChanged: (newValue) async {
                                    safeSetState(() => _model
                                        .checkboxMAKEUPARTISTValue = newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.MAKEUPARTIST);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.MAKEUPARTIST);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'MAKEUPARTIST',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Theme(
                                data: ThemeData(
                                  checkboxTheme: CheckboxThemeData(
                                    visualDensity: VisualDensity.compact,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0.0),
                                    ),
                                  ),
                                  unselectedWidgetColor:
                                      FlutterFlowTheme.of(context)
                                          .secondaryText,
                                ),
                                child: Checkbox(
                                  value: _model.checkboxEVENTDESIGNERValue ??=
                                      _model.selectedProfessions
                                          .contains(Profession.EVENTDESIGNER),
                                  onChanged: (newValue) async {
                                    safeSetState(() =>
                                        _model.checkboxEVENTDESIGNERValue =
                                            newValue!);
                                    if (newValue!) {
                                      _model.addToSelectedProfessions(
                                          Profession.EVENTDESIGNER);
                                      safeSetState(() {});
                                    } else {
                                      _model.removeFromSelectedProfessions(
                                          Profession.EVENTDESIGNER);
                                      safeSetState(() {});
                                    }
                                  },
                                  side: (FlutterFlowTheme.of(context)
                                              .secondaryText !=
                                          null)
                                      ? BorderSide(
                                          width: 2,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText!,
                                        )
                                      : null,
                                  activeColor:
                                      FlutterFlowTheme.of(context).primary,
                                  checkColor: FlutterFlowTheme.of(context).info,
                                ),
                              ),
                              Text(
                                'EVENTDESIGNER',
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      fontSize: 11.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).tertiary,
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 6.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _model.budgetVisible = !_model.budgetVisible;
                        safeSetState(() {});
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(
                              'BUDGET',
                              style: FlutterFlowTheme.of(context)
                                  .bodyMedium
                                  .override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ),
                          Icon(
                            Icons.add,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_model.budgetVisible == true)
                    Padding(
                      padding:
                          EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        height: 100.0,
                        child: custom_widgets.CustomRangeSliderWidget(
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
                            5000.0,
                          ),
                          onChanged: (lowerValue, upperValue) async {
                            _model.budgetMin = lowerValue;
                            _model.budgetMax = upperValue;
                            safeSetState(() {});
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Divider(
              height: 1.0,
              thickness: 1.0,
              color: FlutterFlowTheme.of(context).tertiary,
            ),
            FFButtonWidget(
              onPressed: () async {
                _model.newFiltersJson = await actions.filtersToJsonString(
                  QueryFiltersStruct(
                    professions: _model.selectedProfessions,
                    budgetMin: _model.budgetMin,
                    budgetMax: _model.budgetMax,
                    currency: FFAppState().currentUserPreferences.currency,
                    showPros: _model.showPros,
                    showProRecent: _model.showProRecent,
                    showWeddingPins: _model.showWeddingPins,
                    showProAlerts: _model.showProAlerts,
                    center: widget!.filtersOn?.center,
                    radiusKm: widget!.filtersOn?.radiusKm,
                    nearby: false,
                    showFixedLocations: _model.showPros,
                    showBridePrivatePoi: widget!.filtersOn?.showBridePrivatePoi,
                    showOnlyMyProfessionPins:
                        widget!.filtersOn?.showOnlyMyProfessionPins,
                  ),
                );
                _model.saveUserPreferencesSuccess =
                    await actions.saveUserPreferences(
                  FFAppState().currentUserPreferences,
                  _model.newFiltersJson,
                );
                FFAppState().updateCurrentUserPreferencesStruct(
                  (e) => e..lastFiltersJson = _model.newFiltersJson,
                );
                safeSetState(() {});
                await widget.onFiltersApplied?.call(
                  QueryFiltersStruct(
                    professions: _model.selectedProfessions,
                    budgetMin: _model.budgetMin,
                    budgetMax: _model.budgetMax,
                    currency: FFAppState().currentUserPreferences.currency,
                    showPros: _model.showPros,
                    showProRecent: _model.showProRecent,
                    showWeddingPins: _model.showWeddingPins,
                    showProAlerts: _model.showProAlerts,
                    center: widget!.filtersOn?.center,
                    radiusKm: widget!.filtersOn?.radiusKm,
                    nearby: false,
                    showFixedLocations: _model.showPros,
                    showBridePrivatePoi: widget!.filtersOn?.showBridePrivatePoi,
                    showOnlyMyProfessionPins:
                        widget!.filtersOn?.showOnlyMyProfessionPins,
                  ),
                );
                Navigator.pop(context);

                safeSetState(() {});
              },
              text: 'Filter and search',
              options: FFButtonOptions(
                width: double.infinity,
                height: 48.0,
                padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: FlutterFlowTheme.of(context).primary,
                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                      fontFamily: 'Haas Grot Text Trial',
                      color: Colors.white,
                      fontSize: 14.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.normal,
                    ),
                elevation: 0.0,
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ].divide(SizedBox(height: 20.0)),
        ),
      ),
    );
  }
}
