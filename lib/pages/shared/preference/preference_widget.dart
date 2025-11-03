import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
          alignment: AlignmentDirectional(0.0, -1.0),
          child: Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: MediaQuery.sizeOf(context).height * 1.0,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(
                          20.0, 130.0, 20.0, 0.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
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
                                FlutterFlowDropDown<String>(
                                  controller:
                                      _model.dropDownCurrencyValueController ??=
                                          FormFieldController<String>(
                                    _model.dropDownCurrencyValue ??=
                                        valueOrDefault<String>(
                                      FFAppState()
                                          .currentUserPreferences
                                          .currency,
                                      'USD',
                                    ),
                                  ),
                                  options: ['USD', 'EUR', 'GBP', 'CAD', 'CHF'],
                                  onChanged: (val) async {
                                    safeSetState(() =>
                                        _model.dropDownCurrencyValue = val);
                                    FFAppState()
                                        .updateCurrentUserPreferencesStruct(
                                      (e) => e
                                        ..currency =
                                            _model.dropDownCurrencyValue,
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
                                        duration: Duration(milliseconds: 2000),
                                        backgroundColor:
                                            FlutterFlowTheme.of(context)
                                                .success,
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
                                  hintText: 'USD',
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
                                  margin: EdgeInsetsDirectional.fromSTEB(
                                      4.0, 0.0, 12.0, 10.0),
                                  isOverButton: false,
                                  isSearchable: false,
                                  isMultiSelect: false,
                                ),
                              ].divide(SizedBox(height: 10.0)),
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
                                options: ['km', 'miles'],
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
                                      duration: Duration(milliseconds: 2000),
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
                                margin: EdgeInsetsDirectional.fromSTEB(
                                    4.0, 0.0, 12.0, 10.0),
                                isOverButton: false,
                                isSearchable: false,
                                isMultiSelect: false,
                              ),
                            ].divide(SizedBox(height: 10.0)),
                          ),
                          Divider(
                            thickness: 1.0,
                            color: FlutterFlowTheme.of(context).secondary,
                          ),
                        ].divide(SizedBox(height: 14.0)),
                      ),
                    ),
                  ],
                ),
                wrapWithModel(
                  model: _model.headerBarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: HeaderBarWidget(
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
}
