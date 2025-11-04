import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/instant_timer.dart';
import 'global_call_listener_widget_widget.dart'
    show GlobalCallListenerWidgetWidget;
import 'package:flutter/material.dart';

class GlobalCallListenerWidgetModel
    extends FlutterFlowModel<GlobalCallListenerWidgetWidget> {
  ///  State fields for stateful widgets in this component.

  InstantTimer? instantTimer;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }
}
