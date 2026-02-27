import '/backend/supabase/supabase.dart';
import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'settings_permissions_widget.dart' show SettingsPermissionsWidget;
import 'package:flutter/material.dart';

class SettingsPermissionsModel
    extends FlutterFlowModel<SettingsPermissionsWidget> {
  ///  Local state fields for this page.

  bool proRecentVisibility = false;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - Query Rows] action in SettingsPermissions widget.
  List<ProRecentLocationsRow>? proRecentStatus;
  // Stores action output result for [Custom Action - checkAndRequestPermission] action in LocationAccess widget.
  String? permissionResult;
  // Stores action output result for [Custom Action - checkAndRequestPermission] action in PushNotifications widget.
  String? permissionResultCopy;
  // Stores action output result for [Custom Action - checkAndRequestPermission] action in CameraAccess widget.
  String? permissionResultCopyCopy;
  // Stores action output result for [Custom Action - checkAndRequestPermission] action in PhotoLibraryAccess widget.
  String? permissionResultCopyCopyCopy;
  // Stores action output result for [Custom Action - checkAndRequestPermission] action in MicrophoneAccess widget.
  String? permissionResultCopyCopyCopyCopy;
  // State field(s) for Switch widget.
  bool? switchValue;
  // Stores action output result for [Custom Action - upsertProRecentOptIn] action in Switch widget.
  bool? upsertProRecentOptInOn;
  // Stores action output result for [Custom Action - upsertProRecentOptIn] action in Switch widget.
  bool? upsertProRecentOptInOff;
  // Stores action output result for [Custom Action - callDeleteAccountEdgeFunction] action in Text widget.
  bool? deleteSucceeded;
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
