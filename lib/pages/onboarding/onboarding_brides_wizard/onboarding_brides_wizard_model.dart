import '/backend/schema/structs/index.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'onboarding_brides_wizard_widget.dart' show OnboardingBridesWizardWidget;
import 'package:flutter/material.dart';

class OnboardingBridesWizardModel
    extends FlutterFlowModel<OnboardingBridesWizardWidget> {
  ///  Local state fields for this page.

  String? fullName;

  String? localAvatarFile;

  String? localAvatarPath;

  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController;

  int get pageViewCurrentIndex => pageViewController != null &&
          pageViewController!.hasClients &&
          pageViewController!.page != null
      ? pageViewController!.page!.round()
      : 0;
  // Stores action output result for [Custom Action - pickLocalImage] action in StackAvatar widget.
  String? pickedPath;
  // State field(s) for FirstName widget.
  FocusNode? firstNameFocusNode;
  TextEditingController? firstNameTextController;
  String? Function(BuildContext, String?)? firstNameTextControllerValidator;
  // State field(s) for Lastname widget.
  FocusNode? lastnameFocusNode;
  TextEditingController? lastnameTextController;
  String? Function(BuildContext, String?)? lastnameTextControllerValidator;
  // State field(s) for DropDown_currency widget.
  String? dropDownCurrencyValue;
  FormFieldController<String>? dropDownCurrencyValueController;
  // State field(s) for DropDown_Distance widget.
  String? dropDownDistanceValue;
  FormFieldController<String>? dropDownDistanceValueController;
  // Stores action output result for [Custom Action - uploadAvatar] action in ButtonStep1 widget.
  String? publicAvatarUrl;
  // Stores action output result for [Custom Action - getDeviceLocale] action in ButtonStep1 widget.
  String? deviceLocale;
  // Stores action output result for [Custom Action - saveUserPreferences] action in ButtonStep1 widget.
  UserPreferencesStruct? updatedPreferences;
  // Stores action output result for [Custom Action - saveProfileFields] action in ButtonStep1 widget.
  PublicProfileStruct? updatedProfile;
  // Stores action output result for [Custom Action - checkTosAccepted] action in Button_Finish widget.
  bool? tosAlreadyAccepted;
  // Stores action output result for [Custom Action - insertLegalAcceptance] action in Button_Finish widget.
  bool? insertLegalAcceptanceSucces;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    firstNameFocusNode?.dispose();
    firstNameTextController?.dispose();

    lastnameFocusNode?.dispose();
    lastnameTextController?.dispose();
  }
}
