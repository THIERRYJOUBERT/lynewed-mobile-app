import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/select_date_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/compo_finaux/address_search/address_search_widget.dart';
import '/flutter_flow/random_data_util.dart' as random_data;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'create_edit_point_of_interest_sheet_model.dart';
export 'create_edit_point_of_interest_sheet_model.dart';

class CreateEditPointOfInterestSheetWidget extends StatefulWidget {
  const CreateEditPointOfInterestSheetWidget({
    super.key,
    this.filtersOn,
    this.nav,
  });

  final QueryFiltersStruct? filtersOn;
  final Future Function(MapCommandStruct mapCommand)? nav;

  @override
  State<CreateEditPointOfInterestSheetWidget> createState() =>
      _CreateEditPointOfInterestSheetWidgetState();
}

class _CreateEditPointOfInterestSheetWidgetState
    extends State<CreateEditPointOfInterestSheetWidget> {
  late CreateEditPointOfInterestSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateEditPointOfInterestSheetModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.budgetMin = widget.filtersOn?.budgetMin;
      _model.budgetMax = widget.filtersOn?.budgetMax;
      _model.professions =
          widget.filtersOn!.professions.toList().cast<Profession>();
      safeSetState(() {});
    });

    _model.textFieldDateTextController ??= TextEditingController();
    _model.textFieldDateFocusNode ??= FocusNode();

    _model.textFieldDateMask = MaskTextInputFormatter(mask: '##/##/####');
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return Stack(
      children: [
        Container(
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
            padding: const EdgeInsetsDirectional.fromSTEB(20.0, 20.0, 20.0, 20.0),
            child: SingleChildScrollView(
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
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10.0,
                                color: FlutterFlowTheme.of(context).secondary,
                                offset: const Offset(
                                  0.0,
                                  0.0,
                                ),
                              )
                            ],
                            borderRadius: BorderRadius.circular(100.0),
                            border: Border.all(
                              color: FlutterFlowTheme.of(context)
                                  .secondaryBackground,
                            ),
                          ),
                          child: Icon(
                            Icons.location_on_outlined,
                            color: FlutterFlowTheme.of(context).primaryText,
                            size: 24.0,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'MY WEDDING SPOT',
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
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
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 24.0,
                        ),
                      ),
                    ].divide(const SizedBox(width: 8.0)),
                  ),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Text(
                                'LOCATION',
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
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 14.0, 0.0, 10.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Flexible(
                                child: SizedBox(
                                  width: MediaQuery.sizeOf(context).width * 1.0,
                                  height: 50.0,
                                  child: AddressSearchWidget(
                                    width: MediaQuery.sizeOf(context).width * 1.0,
                                    height: 50.0,
                                    hintText: 'Rechercher',
                                    initialValue: _model.searchText,
                                    debounceMs: 200,
                                    suggestionsPosition: SuggestionsPosition.above,
                                    locale: valueOrDefault<String>(
                                      FFAppState()
                                          .currentUserPreferences
                                          .defaultLocale,
                                      'en',
                                    ),
                                    onAddressSelected: (PlaceDetailsDataStruct details) {
                                      _model.placeCoordinates = details;
                                      _model.placeLatLng = details.coords;
                                      _model.searchText = details.formattedAddress;
                                      _model.selectedPlace = details;
                                      safeSetState(() {});
                                    },
                                    onAddressCleared: () {
                                      _model.placeCoordinates = null;
                                      _model.placeLatLng = null;
                                      _model.searchText = null;
                                      _model.selectedPlace = null;
                                      safeSetState(() {});
                                    },
                                    onSearchTextChanged: (String text) {
                                      _model.searchText = text;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ].divide(const SizedBox(height: 0.0)),
                    ),
                  ),
                  Divider(
                    height: 1.0,
                    thickness: 1.0,
                    color: FlutterFlowTheme.of(context).tertiary,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
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
                          value: _model.checkboxNearbyValue ??= false,
                          onChanged: (newValue) async {
                            safeSetState(
                                () => _model.checkboxNearbyValue = newValue!);
                            if (newValue!) {
                              _model.isPublic = true;
                              safeSetState(() {});
                            } else {
                              _model.isPublic = false;
                              safeSetState(() {});
                            }
                          },
                          side: BorderSide(
                            width: 2,
                            color: FlutterFlowTheme.of(context).secondaryText,
                          ),
                          activeColor: FlutterFlowTheme.of(context).primary,
                          checkColor: FlutterFlowTheme.of(context).info,
                        ),
                      ),
                      Text(
                        'Public',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              fontFamily: 'Haas Grot Text Trial',
                              letterSpacing: 0.0,
                            ),
                      ),
                    ],
                  ),
                  if (_model.isPublic == true)
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () async {
                                  _model.isPublic = !_model.isPublic;
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
                                              fontFamily:
                                                  'Haas Grot Text Trial',
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 14.0, 0.0, 0.0),
                                child: Row(
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
                                                checkboxTheme:
                                                    CheckboxThemeData(
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
                                                    _model.professions.contains(
                                                        Profession
                                                            .PHOTOGRAPHER),
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model
                                                          .checkboxPHOTOGRAPHERValue =
                                                      newValue!);
                                                  if (newValue!) {
                                                    _model.addToProfessions(
                                                        Profession
                                                            .PHOTOGRAPHER);
                                                    safeSetState(() {});
                                                  } else {
                                                    _model
                                                        .removeFromProfessions(
                                                            Profession
                                                                .PHOTOGRAPHER);
                                                    safeSetState(() {});
                                                  }
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                                checkboxTheme:
                                                    CheckboxThemeData(
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
                                                    _model.professions.contains(
                                                        Profession.FILMMAKER),
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model
                                                          .checkboxFILMMAKERValue =
                                                      newValue!);
                                                  if (newValue!) {
                                                    _model.addToProfessions(
                                                        Profession.FILMMAKER);
                                                    safeSetState(() {});
                                                  } else {
                                                    _model
                                                        .removeFromProfessions(
                                                            Profession
                                                                .FILMMAKER);
                                                    safeSetState(() {});
                                                  }
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                                checkboxTheme:
                                                    CheckboxThemeData(
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
                                                    _model.professions.contains(
                                                        Profession.HAIRDRESSER),
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model
                                                          .checkboxHAIRDRESSERValue =
                                                      newValue!);
                                                  if (newValue!) {
                                                    _model.addToProfessions(
                                                        Profession.HAIRDRESSER);
                                                    safeSetState(() {});
                                                  } else {
                                                    _model
                                                        .removeFromProfessions(
                                                            Profession
                                                                .HAIRDRESSER);
                                                    safeSetState(() {});
                                                  }
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                                checkboxTheme:
                                                    CheckboxThemeData(
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
                                                    _model.professions.contains(
                                                        Profession.MAKEUP),
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model
                                                          .checkboxMAKEUPValue =
                                                      newValue!);
                                                  if (newValue!) {
                                                    _model.addToProfessions(
                                                        Profession.MAKEUP);
                                                    safeSetState(() {});
                                                  } else {
                                                    _model
                                                        .removeFromProfessions(
                                                            Profession.MAKEUP);
                                                    safeSetState(() {});
                                                  }
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                                checkboxTheme:
                                                    CheckboxThemeData(
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
                                                    _model.professions.contains(
                                                        Profession.FLORIST),
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model
                                                          .checkboxFLORISTValue =
                                                      newValue!);
                                                  if (newValue!) {
                                                    _model.addToProfessions(
                                                        Profession.FLORIST);
                                                    safeSetState(() {});
                                                  } else {
                                                    _model
                                                        .removeFromProfessions(
                                                            Profession.FLORIST);
                                                    safeSetState(() {});
                                                  }
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                                checkboxTheme:
                                                    CheckboxThemeData(
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
                                                    _model.professions.contains(
                                                        Profession.PLANNER),
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model
                                                          .checkboxPLANNERValue =
                                                      newValue!);
                                                  if (newValue!) {
                                                    _model.addToProfessions(
                                                        Profession.PLANNER);
                                                    safeSetState(() {});
                                                  } else {
                                                    _model
                                                        .removeFromProfessions(
                                                            Profession.PLANNER);
                                                    safeSetState(() {});
                                                  }
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                                checkboxTheme:
                                                    CheckboxThemeData(
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
                                                    _model.professions.contains(
                                                        Profession.DESIGNER),
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model
                                                          .checkboxDESIGNERValue =
                                                      newValue!);
                                                  if (newValue!) {
                                                    _model.addToProfessions(
                                                        Profession.DESIGNER);
                                                    safeSetState(() {});
                                                  } else {
                                                    _model
                                                        .removeFromProfessions(
                                                            Profession
                                                                .DESIGNER);
                                                    safeSetState(() {});
                                                  }
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                                checkboxTheme:
                                                    CheckboxThemeData(
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
                                                    _model.professions.contains(
                                                        Profession.VENUE),
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model
                                                          .checkboxVENUESValue =
                                                      newValue!);
                                                  if (newValue!) {
                                                    _model.addToProfessions(
                                                        Profession.VENUE);
                                                    safeSetState(() {});
                                                  } else {
                                                    _model
                                                        .removeFromProfessions(
                                                            Profession.VENUE);
                                                    safeSetState(() {});
                                                  }
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                                                checkboxTheme:
                                                    CheckboxThemeData(
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
                                                    _model.professions.contains(
                                                        Profession.BRIDALSHOP),
                                                onChanged: (newValue) async {
                                                  safeSetState(() => _model
                                                          .checkboxBRIDALValue =
                                                      newValue!);
                                                  if (newValue!) {
                                                    _model.addToProfessions(
                                                        Profession.BRIDALSHOP);
                                                    safeSetState(() {});
                                                  } else {
                                                    _model.addToProfessions(
                                                        Profession.BRIDALSHOP);
                                                    safeSetState(() {});
                                                  }
                                                },
                                                side: (FlutterFlowTheme.of(
                                                                context)
                                                            .secondaryText !=
                                                        null)
                                                    ? BorderSide(
                                                        width: 2,
                                                        color:
                                                            FlutterFlowTheme.of(
                                                                    context)
                                                                .secondaryText,
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
                                              style:
                                                  FlutterFlowTheme.of(context)
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
                              ),
                              Align(
                                alignment: const AlignmentDirectional(0.0, -1.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 20.0, 0.0, 0.0),
                                  child: Container(
                                    width: double.infinity,
                                    height: 1.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
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
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0.0, 14.0, 0.0, 0.0),
                                child: SizedBox(
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
                          Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'DATE',
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
                                ],
                              ),
                              Align(
                                alignment: const AlignmentDirectional(-1.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      0.0, 14.0, 0.0, 0.0),
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
                                        return Padding(
                                          padding: MediaQuery.viewInsetsOf(context),
                                          child: SelectDateWidget(
                                            initialDate: _model.eventStartDate != null
                                                ? _model.eventStartDate!
                                                : getCurrentTimestamp,
                                            actionDate: (selectedDate) async {
                                              _model.eventStartDate = selectedDate;
                                              safeSetState(() {});
                                            },
                                          ),
                                        );
                                      },
                                    ).then((value) => safeSetState(() {}));
                                  },
                                  child: Container(
                                    width: 140.0,
                                    height: 40.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryBackground,
                                      borderRadius: BorderRadius.circular(4.0),
                                      border: Border.all(
                                        color: FlutterFlowTheme.of(context).tertiary,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(
                                              8.0, 0.0, 0.0, 0.0),
                                          child: Text(
                                            valueOrDefault<String>(
                                              dateTimeFormat(
                                                "d/M/y",
                                                _model.eventStartDate,
                                                locale: FFLocalizations.of(context)
                                                    .languageCode,
                                              ),
                                              'Date...',
                                            ),
                                            style: FlutterFlowTheme.of(context)
                                                .bodyMedium
                                                .override(
                                                  fontFamily: 'Haas Grot Text Trial',
                                                  letterSpacing: 0.0,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  FFButtonWidget(
                    onPressed: () async {
                      var shouldSetState = false;
                      if (_model.isPublic == true) {
                        if (_model.placeLatLng != null) {
                          _model.newPinId = await actions.upsertWeddingPin(
                            _model.placeLatLng!,
                            100,
                            _model.professions.map((e) => e.name).toList(),
                            (_model.budgetMin!).toInt(),
                            (_model.budgetMax!).toInt(),
                            FFAppState().currentUserPreferences.currency,
                            _model.eventStartDate,
                            _model.eventStartDate
                                ?.add(const Duration(days: 30)),
                            '${_model.selectedPlace?.city} ${_model.selectedPlace?.country}',
                          );
                          shouldSetState = true;
                          if (_model.newPinId != null &&
                              _model.newPinId != '') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Research published !',
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
                            
                            // Naviguer vers le point créé sur la carte
                            if (widget.nav != null) {
                              await widget.nav!(
                                MapCommandStruct(
                                  type: MapActionType.moveToTarget,
                                  target: _model.placeLatLng,
                                  id: random_data.randomString(
                                    12,
                                    12,
                                    true,
                                    true,
                                    true,
                                  ),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'An error occurred, please try again.',
                                  style: TextStyle(
                                    color: FlutterFlowTheme.of(context)
                                        .primaryText,
                                  ),
                                ),
                                duration: const Duration(milliseconds: 2000),
                                backgroundColor:
                                    FlutterFlowTheme.of(context).error,
                              ),
                            );
                          }

                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You must add a valid location.',
                                style: TextStyle(
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
                          return;
                        }
                      } else {
                        _model.newPoiId = await actions.upsertUserPoi(
                          _model.selectedPlace!.formattedAddress,
                          _model.placeLatLng!,
                          100,
                          _model.professions.map((e) => e.name).toList(),
                          0,
                          0,
                          FFAppState().currentUserPreferences.currency,
                          getCurrentTimestamp,
                          getCurrentTimestamp,
                          '',
                        );
                        shouldSetState = true;
                        if (_model.newPoiId != null && _model.newPoiId != '') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Point of interest added.',
                                style: TextStyle(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              duration: const Duration(milliseconds: 2000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).success,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'An error occurred, please try again.',
                                style: TextStyle(
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                ),
                              ),
                              duration: const Duration(milliseconds: 2000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).error,
                            ),
                          );
                        }

                        Navigator.pop(context);
                      }

                      if (shouldSetState) safeSetState(() {});
                    },
                    text: 'Add this point',
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 48.0,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding:
                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle:
                          FlutterFlowTheme.of(context).titleSmall.override(
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
                ].divide(const SizedBox(height: 20.0)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
