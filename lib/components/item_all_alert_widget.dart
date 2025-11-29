import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'item_all_alert_model.dart';
export 'item_all_alert_model.dart';

class ItemAllAlertWidget extends StatefulWidget {
  const ItemAllAlertWidget({
    super.key,
    required this.alertInfos,
    this.onAlertDeleted,
  });

  final AlertItemDataStruct? alertInfos;
  final VoidCallback? onAlertDeleted;

  @override
  State<ItemAllAlertWidget> createState() => _ItemAllAlertWidgetState();
}

class _ItemAllAlertWidgetState extends State<ItemAllAlertWidget> {
  late ItemAllAlertModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ItemAllAlertModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
          borderRadius: BorderRadius.circular(2.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).secondaryBackground,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).accent2,
                          borderRadius: BorderRadius.circular(100.0),
                        ),
                        child: const Icon(
                          Icons.crisis_alert,
                          color: Colors.white,
                          size: 14.0,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          valueOrDefault<String>(
                            widget.alertInfos?.motifLabel,
                            'Reason...',
                          ),
                          style:
                              FlutterFlowTheme.of(context).bodyMedium.override(
                                    fontFamily: 'Haas Grot Text Trial',
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ].divide(const SizedBox(width: 10.0)),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(2.0, 2.0, 2.0, 2.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                valueOrDefault<String>(
                                  widget.alertInfos?.message,
                                  'Message...',
                                ),
                                maxLines: 2,
                                style: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      fontFamily: 'Haas Grot Text Trial',
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      fontSize: 12.0,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ].divide(const SizedBox(height: 10.0)),
                          ),
                        ),
                      ].divide(const SizedBox(width: 8.0)),
                    ),
                  ),
                ].divide(const SizedBox(height: 10.0)),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Posted ${dateTimeFormat(
                      "M/d H:mm",
                      widget.alertInfos?.startAt,
                      locale: FFLocalizations.of(context).languageCode,
                    )}',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          color: FlutterFlowTheme.of(context).alternate,
                          fontSize: 10.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                  Stack(
                    children: [
                      if (widget.alertInfos?.isOwn == true)
                        FFButtonWidget(
                          onPressed: () async {
                            _model.deleteAlert =
                                await actions.cancelProfessionalAlertAction(
                              widget.alertInfos!.alertId,
                            );
                            if (_model.deleteAlert == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Alert deleted successfully !',
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
                              // Notify parent to refresh alerts list
                              widget.onAlertDeleted?.call();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Unable to delete the alert, an error occurred.',
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

                            safeSetState(() {});
                          },
                          text: 'Delete',
                          options: FFButtonOptions(
                            height: 30.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                14.0, 0.0, 14.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Haas Grot Text Trial',
                                  color: FlutterFlowTheme.of(context).error,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).accent2,
                            ),
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                      if (widget.alertInfos?.isOwn == false)
                        FFButtonWidget(
                          onPressed: () async {
                            _model.getProDetails =
                                await actions.getProItemDetailsAction(
                              widget.alertInfos!.authorProfileId,
                            );
                            if (_model.getProDetails?.proProfileId != null &&
                                _model.getProDetails?.proProfileId != '') {
                              context.pushNamed(
                                ProDetailsWidget.routeName,
                                queryParameters: {
                                  'proDetails': serializeParam(
                                    _model.getProDetails,
                                    ParamType.DataStruct,
                                  ),
                                }.withoutNulls,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Unable to navigate to your profile, please try again.',
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

                            safeSetState(() {});
                          },
                          text: 'View profil',
                          options: FFButtonOptions(
                            height: 30.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                14.0, 0.0, 14.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 0.0, 0.0),
                            color:
                                FlutterFlowTheme.of(context).primaryBackground,
                            textStyle: FlutterFlowTheme.of(context)
                                .titleSmall
                                .override(
                                  fontFamily: 'Haas Grot Text Trial',
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  fontSize: 12.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.normal,
                                ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).secondaryText,
                            ),
                            borderRadius: BorderRadius.circular(0.0),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
