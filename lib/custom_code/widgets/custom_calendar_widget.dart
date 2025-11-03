// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/cupertino.dart';

class CustomCalendarWidget extends StatefulWidget {
  const CustomCalendarWidget({
    super.key,
    this.width,
    this.height,
    this.initialDate,
    this.onDateSelected,
  });

  final double? width;
  final double? height;
  final DateTime? initialDate;
  final Future Function(DateTime dateValue)? onDateSelected;

  @override
  State<CustomCalendarWidget> createState() => _CustomCalendarWidgetState();
}

class _CustomCalendarWidgetState extends State<CustomCalendarWidget> {
  late DateTime _uiSelectedDate;
  late DateTime _minDate;
  late DateTime _maxDate;

  @override
  void initState() {
    super.initState();

    // Définit la borne min et max
    final now = DateTime.now();
    _minDate = DateTime(now.year, now.month, now.day); // aujourd'hui à 00:00
    _maxDate = DateTime(now.year, now.month, now.day, 23, 59, 59)
        .add(const Duration(days: 30)); // J+30 à 23:59:59

    // Initialise la date de départ
    // Si initialDate est null, on utilise maintenant (currentTime)
    DateTime init = widget.initialDate ?? now;

    // Clamp dans l'intervalle [today 00:00, today+30 23:59]
    if (init.isBefore(_minDate)) {
      init = _minDate;
    }
    if (init.isAfter(_maxDate)) {
      init = _maxDate;
    }

    _uiSelectedDate = init;
  }

  @override
  void didUpdateWidget(CustomCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si le paramètre initialDate change, on met à jour
    if (widget.initialDate != oldWidget.initialDate) {
      DateTime newInit = widget.initialDate ?? DateTime.now();

      if (newInit.isBefore(_minDate)) {
        newInit = _minDate;
      }
      if (newInit.isAfter(_maxDate)) {
        newInit = _maxDate;
      }

      setState(() {
        _uiSelectedDate = newInit;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height ?? 300.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.dateAndTime,
        initialDateTime: _uiSelectedDate,
        minimumDate: _minDate,
        maximumDate: _maxDate,
        use24hFormat: true,
        onDateTimeChanged: (DateTime newDate) async {
          setState(() => _uiSelectedDate = newDate);

          // Appel du callback si défini
          if (widget.onDateSelected != null) {
            await widget.onDateSelected!(newDate);
          }
        },
      ),
    );
  }
}
