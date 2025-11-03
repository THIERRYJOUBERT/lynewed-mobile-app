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

/// Set your action name, define your arguments and return parameter, and then
/// add the boilerplate code using the green button on the right!
Profession? _professionFromString(String? s) {
  if (s == null) return null;
  try {
    return Profession.values
        .firstWhere((e) => e.name.toUpperCase() == s.toUpperCase());
  } catch (_) {
    return null;
  }
}

Future<AlertItemDataStruct?> getAlertItemDetailsRpc(String alertId) async {
  if (alertId.isEmpty) {
    print('getAlertItemDetailsRpc error: alertId is empty.');
    return null;
  }
  try {
    final data = await SupaFlow.client
        .rpc('get_alert_item_details', params: {'p_alert_id': alertId});

    if (data is! Map<String, dynamic>) {
      print('getAlertItemDetailsRpc error: Invalid payload received.');
      return null;
    }

    return AlertItemDataStruct(
      alertId: data['alertId']?.toString() ?? '',
      motifCode: data['motifCode']?.toString() ?? '',
      motifLabel: data['motifLabel']?.toString() ?? '',
      message: data['message']?.toString() ?? '',
      locationLabel: data['locationLabel']?.toString() ?? '',
      startAt: DateTime.tryParse(data['startAt']?.toString() ?? ''),
      endAt: DateTime.tryParse(data['endAt']?.toString() ?? ''),
      authorProfileId: data['authorProfileId']?.toString() ?? '',
      authorAvatarUrl: data['authorAvatarUrl']?.toString() ?? '',
      authorFullName: data['authorFullName']?.toString() ?? '',
      authorProfession:
          _professionFromString(data['authorProfession']?.toString()),
      isOwn: data['isOwn'] == true,
      isContactable: data['isContactable'] == true,
    );
  } catch (e) {
    print('getAlertItemDetailsRpc error: $e');
    return null;
  }
}
