import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'set_password_page_pro_widget.dart' show SetPasswordPageProWidget;
import 'package:flutter/material.dart';

class SetPasswordPageProModel
    extends FlutterFlowModel<SetPasswordPageProWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for EmailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();
  }
}
