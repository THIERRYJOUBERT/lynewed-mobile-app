// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!

Future<PoiItemDataStruct?> getPoiItemDetails(
  String poiId,
) async {
  if (poiId.isEmpty) {
    debugPrint('getPoiItemDetails error: poiId is empty.');
    return null;
  }

  try {
    final data = await SupaFlow.client
        .from('user_pois')
        .select('id, label, created_at') // Sélectionne les colonnes nécessaires
        .eq('id', poiId)
        .single();

    return PoiItemDataStruct(
      poiId: data['id'],
      label: data['label'] ?? 'Point d\'intérêt',
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'])
          : null,
      // Le champ 'address' a été supprimé car redondant avec 'label'
    );
  } catch (e) {
    debugPrint('Error in getPoiItemDetails: $e');
    return null;
  }
}
