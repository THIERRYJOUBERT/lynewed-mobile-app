import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/components/nav/nav_bar_brides/nav_bar_brides_widget.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'wedding_of_the_week_widget.dart' show WeddingOfTheWeekWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WeddingOfTheWeekModel extends FlutterFlowModel<WeddingOfTheWeekWidget> {
  ///  Local state fields for this page.

  WedArticleStruct? wedArticle;
  void updateWedArticleStruct(Function(WedArticleStruct) updateFn) {
    updateFn(wedArticle ??= WedArticleStruct());
  }

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getLatestWedArticle] action in WeddingOfTheWeek widget.
  WedArticleStruct? latestArticle;
  // Model for NavBarBrides component.
  late NavBarBridesModel navBarBridesModel;
  // Model for NavBarPro component.
  late NavBarProModel navBarProModel;
  // Model for EmptyState component.
  late EmptyStateModel emptyStateModel;

  @override
  void initState(BuildContext context) {
    navBarBridesModel = createModel(context, () => NavBarBridesModel());
    navBarProModel = createModel(context, () => NavBarProModel());
    emptyStateModel = createModel(context, () => EmptyStateModel());
  }

  @override
  void dispose() {
    navBarBridesModel.dispose();
    navBarProModel.dispose();
    emptyStateModel.dispose();
  }
}
