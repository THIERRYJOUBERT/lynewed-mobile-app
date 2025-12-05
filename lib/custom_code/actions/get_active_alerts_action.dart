import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
import '/flutter_flow/custom_functions.dart';

/// Get active alerts filtered by user's market region
/// Returns alerts visible to the current user based on their market (IN or GLOBAL)
Future<List<AlertItemDataStruct>> getActiveAlertsAction() async {
  try {
    final response = await SupaFlow.client.rpc('get_active_alerts_for_market');
    
    if (response == null) return [];
    
    final List<dynamic> data = response as List<dynamic>;
    
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return AlertItemDataStruct(
        alertId: map['id']?.toString(),
        motifCode: map['alertType']?.toString(),
        motifLabel: map['title']?.toString(),
        message: map['message']?.toString(),
        locationLabel: map['locationLabel']?.toString(),
        startAt: map['createdAt'] != null 
            ? DateTime.tryParse(map['createdAt'].toString())
            : null,
        endAt: map['expiresAt'] != null 
            ? DateTime.tryParse(map['expiresAt'].toString())
            : null,
        authorProfileId: map['authorProfileId']?.toString(),
        authorFullName: map['authorFullName']?.toString(),
        authorAvatarUrl: stringToImagePath(map['authorAvatarUrl']?.toString() ?? ''),
        authorProfession: _parseProfession(map['authorProfession']?.toString()),
        isOwn: map['isOwn'] == true,
        isContactable: map['isOwn'] != true,
      );
    }).toList();
  } catch (e) {
    print('Error getting active alerts: $e');
    return [];
  }
}

Profession? _parseProfession(String? value) {
  if (value == null || value.isEmpty) return null;
  try {
    return Profession.values.firstWhere(
      (p) => p.name.toUpperCase() == value.toUpperCase(),
      orElse: () => Profession.OTHER,
    );
  } catch (_) {
    return null;
  }
}
