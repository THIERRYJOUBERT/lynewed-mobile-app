// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
Future<bool> cancelProfessionalAlertAction(
  String alertId,
) async {
  try {
    final res = await SupaFlow.client
        .rpc('cancel_professional_alert', params: {'p_alert_id': alertId});
    return res == true;
  } catch (e) {
    debugPrint('cancelProfessionalAlertAction error: $e');
    return false;
  }
}
