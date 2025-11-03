import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/index.dart';
import 'profile_brides_and_pro_widget.dart' show ProfileBridesAndProWidget;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
