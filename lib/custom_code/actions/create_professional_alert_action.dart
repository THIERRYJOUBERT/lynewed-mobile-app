// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
import '/flutter_flow/lat_lng.dart';

Future<String?> createProfessionalAlertAction(
  String motifCode,
  String message,
  DateTime endAt,
  LatLng coords,
  String locationLabel,
) async {
  try {
    final res = await SupaFlow.client.rpc('create_professional_alert', params: {
      'p_motif_code': motifCode,
      'p_message': message,
      'p_end_at': endAt.toIso8601String(),
      'p_lat': coords.latitude,
      'p_lng': coords.longitude,
      'p_location_label': locationLabel,
    });
    return res?.toString();
  } catch (e) {
    print('createProfessionalAlertAction error: $e');
    return null;
  }
}
