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

Future<List<AlertMotifStruct>> fetchAlertMotifsAction() async {
  try {
    final locale = FFAppState().currentUserPreferences.defaultLocale ?? 'en';
    final langColumn =
        (locale.toLowerCase().startsWith('fr')) ? 'name_fr' : 'name_en';

    final response = await SupaFlow.client
        .from('alert_motifs')
        .select('code, $langColumn')
        .eq('is_active', true)
        .order('sort_order', ascending: true);

    return (response)
        .map((item) => AlertMotifStruct(
              code: item['code']?.toString() ?? '',
              name: item[langColumn]?.toString() ?? '',
            ))
        .toList();
  } catch (e) {
    print('fetchAlertMotifsAction error: $e');
    return [];
  }
}
