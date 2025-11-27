// Automatic FlutterFlow imports
import 'package:flutter/foundation.dart';
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
// Helper local pour la robustesse du parsing
Profession? _professionFromString(String? s) {
  if (s == null) return null;
  try {
    return Profession.values
        .firstWhere((e) => e.name.toUpperCase() == s.toUpperCase());
  } catch (_) {
    return null;
  }
}

LatLng? _latLngFromGeoJson(dynamic geo) {
  try {
    if (geo is Map<String, dynamic> &&
        (geo['type']?.toString().toUpperCase() == 'POINT') &&
        geo['coordinates'] is List &&
        (geo['coordinates'] as List).length >= 2) {
      final coords = geo['coordinates'] as List;
      return LatLng(
          (coords[1] as num).toDouble(), (coords[0] as num).toDouble());
    }
  } catch (_) {}
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    final normalized = value.replaceAll('"', '').trim();
    if (normalized.isEmpty) {
      return null;
    }
    return DateTime.tryParse(normalized);
  }
  return DateTime.tryParse(value.toString());
}

Future<WeddingPinItemDataStruct?> getWeddingPinItemDetailsRpc(
  String weddingPinId,
) async {
  if (weddingPinId.isEmpty) {
    debugPrint('getWeddingPinItemDetailsRpc error: weddingPinId is empty.');
    return null;
  }
  try {
    final data = await SupaFlow.client.rpc('get_wedding_pin_item_details',
        params: {'p_pin_id': weddingPinId});

    if (data is! Map<String, dynamic>) {
      debugPrint('getWeddingPinItemDetailsRpc error: Invalid payload received.');
      return null;
    }

    final profs = (data['professionsNeeded'] as List? ?? [])
        .map((p) => _professionFromString(p?.toString()))
        .whereType<Profession>()
        .toList();

    return WeddingPinItemDataStruct(
      weddingPinId: data['weddingPinId']?.toString() ?? '',
      brideProfileId: data['brideProfileId']?.toString() ?? '',
      locationLabel: data['locationLabel']?.toString() ?? '',
      center: _latLngFromGeoJson(data['center']),
      radiusKm: (data['radiusKm'] as num?)?.toInt(),
      professionsNeeded: profs,
      eventStartDate: _parseDate(data['eventStartDate']),
      budgetMin: (data['budgetMin'] as num?)?.toInt(),
      budgetMax: (data['budgetMax'] as num?)?.toInt(),
      currency: data['currency']?.toString(),
      isContactable: data['isContactable'] == true,
      brideAvatarUrl: data['brideAvatarUrl']?.toString(),
    );
  } catch (e) {
    debugPrint('getWeddingPinItemDetailsRpc error: $e');
    return null;
  }
}
