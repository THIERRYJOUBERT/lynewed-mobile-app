import '/core/utils/input_validators.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'sign_up_email_page_widget.dart' show SignUpEmailPageWidget;
import 'package:flutter/material.dart';

class SignUpEmailPageModel extends FlutterFlowModel<SignUpEmailPageWidget> {
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
  // State field(s) for Confirm_Password widget.
  FocusNode? confirmPasswordFocusNode;
  TextEditingController? confirmPasswordTextController;
  late bool confirmPasswordVisibility;
  String? Function(BuildContext, String?)?
      confirmPasswordTextControllerValidator;
  // State field(s) for Checkbox_CGU widget.
  bool? checkboxCGUValue;
  // Stores action output result for [Custom Action - signUpBride] action in Button widget.
  bool? signUpSuccess;

  @override
  void initState(BuildContext context) {
    passwordVisibility = false;
    confirmPasswordVisibility = false;

    // Initialize validators using centralized InputValidators
    emailAddressTextControllerValidator = (_, value) =>
        InputValidators.validateEmail(value);
    passwordTextControllerValidator = (_, value) =>
        InputValidators.validatePassword(value);
    confirmPasswordTextControllerValidator = (_, value) {
      // First validate password format
      final formatError = InputValidators.validatePassword(value);
      if (formatError != null) return formatError;
      // Then check if passwords match
      if (value != passwordTextController?.text) {
        return 'Passwords do not match';
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

    confirmPasswordFocusNode?.dispose();
    confirmPasswordTextController?.dispose();
  }
}
