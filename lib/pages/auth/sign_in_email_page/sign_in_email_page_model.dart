import '/core/utils/input_validators.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'sign_in_email_page_widget.dart' show SignInEmailPageWidget;
import 'package:flutter/material.dart';

class SignInEmailPageModel extends FlutterFlowModel<SignInEmailPageWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for EmailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // State field(s) for Password widget.
  FocusNode? passwordFocusNode;
  TextEditingController? passwordTextController;
  late bool passwordVisibility;
  String? Function(BuildContext, String?)? passwordTextControllerValidator;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;

    // Initialize validators using centralized InputValidators
    // Note: For sign-in, we use less strict validation (just email format)
    // because users may have accounts with older password requirements
    emailAddressTextControllerValidator = (_, value) =>
        InputValidators.validateEmail(value);
    // For sign-in, we just check password is not empty (no strength requirements)
    passwordTextControllerValidator = (_, value) {
      if (value == null || value.isEmpty) {
        return 'Password is required';
      }
      if (value.length > InputValidators.maxPasswordLength) {
        return 'Password is too long';
      }
      return null;
    };
  }

  @override
  void dispose() {
    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    passwordFocusNode?.dispose();
    passwordTextController?.dispose();
  }
}
