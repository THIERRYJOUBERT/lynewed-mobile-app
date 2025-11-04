import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'public_pro_profile_view_widget.dart' show PublicProProfileViewWidget;
import 'package:flutter/material.dart';

class PublicProProfileViewModel
    extends FlutterFlowModel<PublicProProfileViewWidget> {
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
  // Model for NavBarPro component.
  late NavBarProModel navBarProModel;

  @override
  void initState(BuildContext context) {
    navBarProModel = createModel(context, () => NavBarProModel());
  }

  @override
  void dispose() {
    navBarProModel.dispose();
  }
}
