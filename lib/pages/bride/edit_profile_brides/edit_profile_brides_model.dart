import '/components/nav/header_bar/header_bar_widget.dart';
import '/core/utils/input_validators.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'edit_profile_brides_widget.dart' show EditProfileBridesWidget;
import 'package:flutter/material.dart';

class EditProfileBridesModel extends FlutterFlowModel<EditProfileBridesWidget> {
  ///  Local state fields for this page.

  String? localAvatarPath;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - pickLocalImage] action in Stack widget.
  String? pickedPath;
  // State field(s) for FullName widget.
  FocusNode? fullNameFocusNode;
  TextEditingController? fullNameTextController;
  String? Function(BuildContext, String?)? fullNameTextControllerValidator;
  // State field(s) for EmailAddress widget.
  FocusNode? emailAddressFocusNode;
  TextEditingController? emailAddressTextController;
  String? Function(BuildContext, String?)? emailAddressTextControllerValidator;
  // Stores action output result for [Custom Action - uploadAvatar] action in Button widget.
  String? publicAvatarUrl;
  // Model for HeaderBar component.
  late HeaderBarModel headerBarModel;

  @override
  void initState(BuildContext context) {
    headerBarModel = createModel(context, () => HeaderBarModel());

    // Initialize validators using centralized InputValidators
    fullNameTextControllerValidator = (_, value) =>
        InputValidators.validateName(value);
    // Email is read-only in this screen, but validate for safety
    emailAddressTextControllerValidator = (_, value) =>
        InputValidators.validateEmail(value);
  }

  @override
  void dispose() {
    fullNameFocusNode?.dispose();
    fullNameTextController?.dispose();

    emailAddressFocusNode?.dispose();
    emailAddressTextController?.dispose();

    headerBarModel.dispose();
  }
}
