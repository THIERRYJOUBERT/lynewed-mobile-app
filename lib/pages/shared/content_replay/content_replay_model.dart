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
import '/index.dart';
import 'content_replay_widget.dart' show ContentReplayWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ContentReplayModel extends FlutterFlowModel<ContentReplayWidget> {
  ///  Local state fields for this page.

  ReplayItemStruct? featuredReplay;
  void updateFeaturedReplayStruct(Function(ReplayItemStruct) updateFn) {
    updateFn(featuredReplay ??= ReplayItemStruct());
  }

  List<ReplayItemStruct> otherReplays = [];
  void addToOtherReplays(ReplayItemStruct item) => otherReplays.add(item);
  void removeFromOtherReplays(ReplayItemStruct item) =>
      otherReplays.remove(item);
  void removeAtIndexFromOtherReplays(int index) => otherReplays.removeAt(index);
  void insertAtIndexInOtherReplays(int index, ReplayItemStruct item) =>
      otherReplays.insert(index, item);
  void updateOtherReplaysAtIndex(
          int index, Function(ReplayItemStruct) updateFn) =>
      otherReplays[index] = updateFn(otherReplays[index]);

  bool isLoading = true;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - fetchReplaysBundle] action in ContentReplay widget.
  List<ReplayItemStruct>? replaysBundle;
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
