import '/auth/supabase_auth/auth_util.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import 'notification_settings_widget.dart' show NotificationSettingsWidget;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NotificationSettingsModel
    extends FlutterFlowModel<NotificationSettingsWidget> {
  ///  Local state fields for this page.

  bool chatMessageBool = false;

  bool connectionRequestBool = false;

  bool wishlistAddBool = false;

  bool professionalAlertReminder24hBool = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in NotificationSettings widget.
  List<NotificationSettingsRow>? userNotificationsSettings;
  // State field(s) for Switch_msg widget.
  bool? switchMsgValue;
  // Stores action output result for [Custom Action - upsertNotificationSetting] action in Switch_msg widget.
  bool? chatMessageOn;
  // Stores action output result for [Custom Action - upsertNotificationSetting] action in Switch_msg widget.
  bool? chatMessageOff;
  // State field(s) for Switch_contactRequest widget.
  bool? switchContactRequestValue;
  // Stores action output result for [Custom Action - upsertNotificationSettingsBatch] action in Switch_contactRequest widget.
  bool? connectionRequestOn;
  // Stores action output result for [Custom Action - upsertNotificationSettingsBatch] action in Switch_contactRequest widget.
  bool? connectionRequestOff;
  // State field(s) for Switch_wishlist widget.
  bool? switchWishlistValue;
  // Stores action output result for [Custom Action - upsertNotificationSetting] action in Switch_wishlist widget.
  bool? wishlistAddOn;
  // Stores action output result for [Custom Action - upsertNotificationSetting] action in Switch_wishlist widget.
  bool? wishlistAddOff;
  // State field(s) for Switch_alertExpiration widget.
  bool? switchAlertExpirationValue;
  // Stores action output result for [Custom Action - upsertNotificationSetting] action in Switch_alertExpiration widget.
  bool? professionalAlertReminder24hOn;
  // Stores action output result for [Custom Action - upsertNotificationSetting] action in Switch_alertExpiration widget.
  bool? professionalAlertReminder24hOff;
  // Model for HeaderBar component.
  late HeaderBarModel headerBarModel;

  @override
  void initState(BuildContext context) {
    headerBarModel = createModel(context, () => HeaderBarModel());
  }

  @override
  void dispose() {
    headerBarModel.dispose();
  }
}
