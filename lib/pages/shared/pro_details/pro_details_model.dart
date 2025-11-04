import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'pro_details_widget.dart' show ProDetailsWidget;
import 'package:flutter/material.dart';

class ProDetailsModel extends FlutterFlowModel<ProDetailsWidget> {
  ///  Local state fields for this page.

  bool fav = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Stores action output result for [Custom Action - toggleWishlistAction] action in ToggleIcon widget.
  bool? toggleResult;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
