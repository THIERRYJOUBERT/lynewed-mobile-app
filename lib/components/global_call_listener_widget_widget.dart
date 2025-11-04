import '/components/incoming_call_sheet_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'global_call_listener_widget_model.dart';
export 'global_call_listener_widget_model.dart';

class GlobalCallListenerWidgetWidget extends StatefulWidget {
  const GlobalCallListenerWidgetWidget({super.key});

  @override
  State<GlobalCallListenerWidgetWidget> createState() =>
      _GlobalCallListenerWidgetWidgetState();
}

class _GlobalCallListenerWidgetWidgetState
    extends State<GlobalCallListenerWidgetWidget> {
  late GlobalCallListenerWidgetModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => GlobalCallListenerWidgetModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      _model.instantTimer = InstantTimer.periodic(
        duration: const Duration(milliseconds: 1000),
        callback: (timer) async {
          if (FFAppState().incomingVideoCallData != null) {
            await showModalBottomSheet(
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              enableDrag: false,
              context: context,
              builder: (context) {
                return Padding(
                  padding: MediaQuery.viewInsetsOf(context),
                  child: IncomingCallSheetWidget(
                    videoSessionId: getJsonField(
                      FFAppState().incomingVideoCallData,
                      r'''$.video_session_id''',
                    ).toString(),
                    channelName: getJsonField(
                      FFAppState().incomingVideoCallData,
                      r'''$.agora_channel_name''',
                    ).toString(),
                    callerName: getJsonField(
                      FFAppState().incomingVideoCallData,
                      r'''$.sender_full_name''',
                    ).toString(),
                    callerAvatar: getJsonField(
                      FFAppState().incomingVideoCallData,
                      r'''$.sender_avatar_url''',
                    ).toString(),
                  ),
                );
              },
            ).then((value) => safeSetState(() {}));

            FFAppState().incomingVideoCallData = jsonDecode('null');
            safeSetState(() {});
          }
        },
        startImmediately: true,
      );
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
      width: 0.0,
      height: 0.0,
      decoration: const BoxDecoration(),
    );
  }
}
