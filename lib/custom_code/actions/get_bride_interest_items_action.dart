// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// Set your action name, define your arguments and return parameter,
// and then add the boilerplate code using the green button on the right!
LatLng? _latLngFromGeoJson(dynamic geo) {
  try {
    if (geo is Map<String, dynamic> &&
        (geo['type']?.toString().toUpperCase() == 'POINT') &&
        geo['coordinates'] is List &&
        (geo['coordinates'] as List).length >= 2) {
      final coords = geo['coordinates'] as List;
      return LatLng(
        (coords[1] as num).toDouble(),
        (coords[0] as num).toDouble(),
      );
    }
  } catch (_) {}
  return null;
}

Profession? _professionFromToken(String? s) {
  if (s == null) return null;
  try {
    // Utilise la fonction custom pour mapper les tokens
    return professionFromSupabaseToken(s);
  } catch (_) {
    return null;
  }
}

Future<List<WeddingPinItemDataStruct>> getBrideInterestItemsAction() async {
  final client = SupaFlow.client;
  final out = <WeddingPinItemDataStruct>[];

  try {
    final res = await client.rpc('get_bride_interest_items');
    if (res == null) return out;

    final List data =
        (res is List) ? res : (res is String ? jsonDecode(res) : []);
    for (final it in data) {
      if (it is! Map) continue;

      final src = (it['source']?.toString() ?? 'poiPrivate');
      final geo = it['center'];
      LatLng? center = _latLngFromGeoJson(geo);

      // Fallback: certains drivers peuvent renvoyer {lat,lng}
      if (center == null && geo is Map<String, dynamic>) {
        final lat = (geo['lat'] as num?)?.toDouble();
        final lng = (geo['lng'] as num?)?.toDouble();
        if (lat != null && lng != null) center = LatLng(lat, lng);
      }

      final profs = <Profession>[];
      final rawProfs = (it['professionsNeeded'] as List?) ?? const [];
      for (final p in rawProfs) {
        final e = _professionFromToken(p?.toString());
        if (e != null) profs.add(e);
      }

      out.add(WeddingPinItemDataStruct(
        // WeddingPin fields
        weddingPinId: it['weddingPinId']?.toString(),
        brideProfileId: it['brideProfileId']?.toString(),
        locationLabel: it['locationLabel']?.toString() ?? '',
        center: center,
        radiusKm: (it['radiusKm'] as num?)?.toInt(),
        professionsNeeded: profs,
        eventStartDate: it['eventStartDate'] != null
            ? DateTime.tryParse(it['eventStartDate'].toString())
            : null,
        budgetMin: (it['budgetMin'] as num?)?.toInt(),
        budgetMax: (it['budgetMax'] as num?)?.toInt(),
        currency: it['currency']?.toString(),
        isContactable: it['isContactable'] == true,
        brideAvatarUrl: it['brideAvatarUrl']?.toString(),
        // Extensions pour POI
        poiId: it['poiId']?.toString(),
        source: src == 'weddingPin'
            ? MapMarkerType.weddingPin
            : MapMarkerType.poiPrivate,
        createdAt: it['createdAt'] != null
            ? DateTime.tryParse(it['createdAt'].toString())
            : null,
      ));
    }
    return out;
  } catch (e) {
    return out;
  }
}
