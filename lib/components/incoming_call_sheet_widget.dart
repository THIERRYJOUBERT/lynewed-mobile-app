import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/actions/index.dart' as actions;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'package:flutter/material.dart';
import 'incoming_call_sheet_model.dart';
export 'incoming_call_sheet_model.dart';

class IncomingCallSheetWidget extends StatefulWidget {
  const IncomingCallSheetWidget({
    super.key,
    required this.videoSessionId,
    required this.channelName,
    required this.callerName,
    required this.callerAvatar,
  });

  final String? videoSessionId;
  final String? channelName;
  final String? callerName;
  final String? callerAvatar;

  @override
  State<IncomingCallSheetWidget> createState() =>
      _IncomingCallSheetWidgetState();
}

class _IncomingCallSheetWidgetState extends State<IncomingCallSheetWidget> {
  late IncomingCallSheetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => IncomingCallSheetModel());
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 1.0),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xCC1A1A1A),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(0.0),
            bottomRight: Radius.circular(0.0),
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(48.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80.0,
                height: 80.0,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.network(
                  widget.callerAvatar!,
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    valueOrDefault<String>(
                      widget.callerName,
                      'Name',
                    ),
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          color: Colors.white,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    'Incoming video call...',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          fontFamily: 'Haas Grot Text Trial',
                          color: FlutterFlowTheme.of(context).secondaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ].divide(const SizedBox(height: 10.0)),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 10.0, 0.0, 20.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        _model.updateVideoSessionResult =
                            await actions.updateVideoSessionStatusAction(
                          widget.videoSessionId!,
                          VideoSessionStatus.accepted,
                        );
                        _model.agoraToken = await actions.getAgoraTokenAction(
                          widget.channelName!,
                          functions.generateAgoraUid(currentUserUid).toString(),
                        );
                        if (_model.agoraToken != null &&
                            _model.agoraToken != '') {
                          Navigator.pop(context);
                          await Future.delayed(
                            const Duration(
                              milliseconds: 250,
                            ),
                          );

                          context.pushNamed(
                            VideoCallPageWidget.routeName,
                            queryParameters: {
                              'videoSessionId': serializeParam(
                                widget.videoSessionId,
                                ParamType.String,
                              ),
                              'channelName': serializeParam(
                                widget.channelName,
                                ParamType.String,
                              ),
                              'agoraToken': serializeParam(
                                _model.agoraToken,
                                ParamType.String,
                              ),
                              'isInitiator': serializeParam(
                                false,
                                ParamType.bool,
                              ),
                            }.withoutNulls,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                'Impossible de rejoindre l\'appel',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              duration: const Duration(milliseconds: 4000),
                              backgroundColor:
                                  FlutterFlowTheme.of(context).accent2,
                            ),
                          );
                        }

                        safeSetState(() {});
                      },
                      child: Container(
                        width: 72.0,
                        height: 72.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                        child: Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Icon(
                            Icons.call,
                            color: FlutterFlowTheme.of(context).success,
                            size: 36.0,
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
                        await actions.updateVideoSessionStatusAction(
                          widget.videoSessionId!,
                          VideoSessionStatus.declined,
                        );
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 72.0,
                        height: 72.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99.0),
                        ),
                        child: Align(
                          alignment: const AlignmentDirectional(0.0, 0.0),
                          child: Icon(
                            Icons.call_end,
                            color: FlutterFlowTheme.of(context).accent2,
                            size: 36.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ].divide(const SizedBox(height: 32.0)),
          ),
        ),
      ),
    );
  }
}
