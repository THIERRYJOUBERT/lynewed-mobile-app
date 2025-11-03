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

Future<PoiItemDataStruct?> getPoiItemDetails(
  String poiId,
) async {
  if (poiId.isEmpty) {
    print('getPoiItemDetails error: poiId is empty.');
    return null;
  }

  try {
    final data = await SupaFlow.client
        .from('user_pois')
        .select('id, label, created_at') // Sélectionne les colonnes nécessaires
        .eq('id', poiId)
        .single();

    if (data is! Map<String, dynamic>) {
      print('getPoiItemDetails error: Invalid payload received.');
      return null;
    }

    return PoiItemDataStruct(
      poiId: data['id'],
      label: data['label'] ?? 'Point d\'intérêt',
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'])
          : null,
      // Le champ 'address' a été supprimé car redondant avec 'label'
    );
  } catch (e) {
    print('Error in getPoiItemDetails: $e');
    return null;
  }
}
