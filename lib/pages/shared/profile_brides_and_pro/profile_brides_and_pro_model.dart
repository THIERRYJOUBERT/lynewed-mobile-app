import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'profile_brides_and_pro_widget.dart' show ProfileBridesAndProWidget;
import 'package:flutter/material.dart';

class ProfileBridesAndProModel
    extends FlutterFlowModel<ProfileBridesAndProWidget> {
  ///  State fields for stateful widgets in this page.

  // Model for NavBarBrides component.
  late NavBarBridesModel navBarBridesModel;
  // Model for NavBarPro component.
  late NavBarProModel navBarProModel;

  @override
  void initState(BuildContext context) {
    navBarBridesModel = createModel(context, () => NavBarBridesModel());
    navBarProModel = createModel(context, () => NavBarProModel());
  }

  @override
  void dispose() {
    navBarBridesModel.dispose();
    navBarProModel.dispose();
  }
}
