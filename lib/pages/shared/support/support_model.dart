import '/components/nav/header_bar/header_bar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'support_widget.dart' show SupportWidget;
import 'package:flutter/material.dart';

class SupportModel extends FlutterFlowModel<SupportWidget> {
  ///  Local state fields for this page.

  bool other = false;

  ///  State fields for stateful widgets in this page.

  // State field(s) for DropDownSubject widget.
  String? dropDownSubjectValue;
  FormFieldController<String>? dropDownSubjectValueController;
  // State field(s) for TextField_OtherSubject widget.
  FocusNode? textFieldOtherSubjectFocusNode;
  TextEditingController? textFieldOtherSubjectTextController;
  String? Function(BuildContext, String?)?
      textFieldOtherSubjectTextControllerValidator;
  // State field(s) for TextField_Details widget.
  FocusNode? textFieldDetailsFocusNode;
  TextEditingController? textFieldDetailsTextController;
  String? Function(BuildContext, String?)?
      textFieldDetailsTextControllerValidator;
  // Model for HeaderBar component.
  late HeaderBarModel headerBarModel;

  @override
  void initState(BuildContext context) {
    headerBarModel = createModel(context, () => HeaderBarModel());
  }

  @override
  void dispose() {
    textFieldOtherSubjectFocusNode?.dispose();
    textFieldOtherSubjectTextController?.dispose();

    textFieldDetailsFocusNode?.dispose();
    textFieldDetailsTextController?.dispose();

    headerBarModel.dispose();
  }
}
