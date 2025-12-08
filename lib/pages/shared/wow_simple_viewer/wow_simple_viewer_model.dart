import '/flutter_flow/flutter_flow_util.dart';
import 'wow_simple_viewer_widget.dart' show WowSimpleViewerWidget;
import 'package:flutter/material.dart';

class WowSimpleViewerModel extends FlutterFlowModel<WowSimpleViewerWidget> {
  /// Page controller for the image carousel
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    pageViewController?.dispose();
  }
}
