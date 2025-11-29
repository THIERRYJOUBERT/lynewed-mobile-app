import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
import '/components/item_all_alert_widget.dart';
import '/components/nav/nav_bar_pro/nav_bar_pro_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'dashboard_pro_widget.dart' show DashboardProWidget;
import 'package:flutter/material.dart';

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
  
  // Future for alerts list - allows refresh
  Future<List<ProfessionalAlertsRow>>? alertsFuture;
  
  /// Refresh alerts list
  void refreshAlerts() {
    alertsFuture = ProfessionalAlertsTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('status', 'active')
          .order('created_at'),
    );
  }

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
