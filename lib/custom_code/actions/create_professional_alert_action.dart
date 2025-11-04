// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

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
    debugPrint('createProfessionalAlertAction error: $e');
    return null;
  }
}
