import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/item_all_alert_widget.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/components/ui_system/empty_state/empty_state_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'dashboard_pro_widget.dart' show DashboardProWidget;
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
    as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class DashboardProModel extends FlutterFlowModel<DashboardProWidget> {
  ///  Local state fields for this page.

  List<WishlistedByBrideItemStruct> wishlistedByBrides = [];
  void addToWishlistedByBrides(WishlistedByBrideItemStruct item) =>
      wishlistedByBrides.add(item);
  void removeFromWishlistedByBrides(WishlistedByBrideItemStruct item) =>
      wishlistedByBrides.remove(item);
  void removeAtIndexFromWishlistedByBrides(int index) =>
      wishlistedByBrides.removeAt(index);
  void insertAtIndexInWishlistedByBrides(
          int index, WishlistedByBrideItemStruct item) =>
      wishlistedByBrides.insert(index, item);
  void updateWishlistedByBridesAtIndex(
          int index, Function(WishlistedByBrideItemStruct) updateFn) =>
      wishlistedByBrides[index] = updateFn(wishlistedByBrides[index]);

  int unreadNotificationsCount = 0;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - getWishlistedByBridesAction] action in DashboardPro widget.
  List<WishlistedByBrideItemStruct>? bridesList;
  // Stores action output result for [Custom Action - getUnreadNotificationsCount] action in DashboardPro widget.
  int? getUndeadNotifPro;
  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Models for ItemAllAlert dynamic component.
  late FlutterFlowDynamicModels<ItemAllAlertModel> itemAllAlertModels;
  // Model for NavBarPro component.
  late NavBarProModel navBarProModel;

  @override
  void initState(BuildContext context) {
    itemAllAlertModels = FlutterFlowDynamicModels(() => ItemAllAlertModel());
    navBarProModel = createModel(context, () => NavBarProModel());
  }

  @override
  void dispose() {
    itemAllAlertModels.dispose();
    navBarProModel.dispose();
  }
}
