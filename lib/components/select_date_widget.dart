import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'select_date_model.dart';
export 'select_date_model.dart';

class SelectDateWidget extends StatefulWidget {
  const SelectDateWidget({
    super.key,
    required this.actionDate,
    required this.initialDate,
  });

  final Future Function(DateTime endDate)? actionDate;
  final DateTime? initialDate;

  @override
  State<SelectDateWidget> createState() => _SelectDateWidgetState();
}

class _SelectDateWidgetState extends State<SelectDateWidget> {
  late SelectDateModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SelectDateModel());

    // On component load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (dateTimeFormat(
                "EEEE",
                widget.initialDate,
                locale: FFLocalizations.of(context).languageCode,
              ) !=
              '') {
        _model.endTime = widget.initialDate;
        safeSetState(() {});
      } else {
        _model.endTime = getCurrentTimestamp;
        safeSetState(() {});
      }
    });
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(2.0),
      ),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 1.0,
        height: 250.0,
        child: custom_widgets.CustomCalendarWidget(
          width: MediaQuery.sizeOf(context).width * 1.0,
          height: 250.0,
          initialDate: _model.endTime,
          onDateSelected: (dateValue) async {
            await widget.actionDate?.call(
              dateValue,
            );
          },
        ),
      ),
    );
  }
}
