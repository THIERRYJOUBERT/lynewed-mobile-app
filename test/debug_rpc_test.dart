
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../lib/features/map/domain/entities/wedding_details.dart';

// Mock minimal pour SupabaseClient si besoin, ou appel réel si on peut configurer l'env
// Pour un test rapide, on va juste tester le parsing JSON avec la réponse exacte du RPC qu'on a vue en SQL

void main() {
  test('WeddingDetails.fromJson parses RPC response correctly', () {
    // Réponse réelle obtenue via SQL
    final json = {
      "id": "e99055cb-330f-45c0-bf40-61118cd374c7",
      "isOwn": true,
      "status": "planning",
      "currency": "EUR",
      "brideInfo": {
        "fullName": "Marie Martin",
        "avatarUrl": "https://hekyovgnovhfhmkpfrna.supabase.co/storage/v1/object/public/avatars/cc949a0a-5b02-45d1-a2e8-61046b1f9297/profile_1764150233848.jpg"
      },
      "budgetMax": 70000,
      "budgetMin": 50000,
      "createdAt": "2025-11-26T08:22:34.992163+00:00",
      "eventDate": "2026-07-26",
      "venueLabel": "Paris 8ème",
      "visibility": "visible_to_pros",
      "weddingName": "Léo Mariage",
      "eventEndDate": "2026-07-29",
      "brideProfileId": "cc949a0a-5b02-45d1-a2e8-61046b1f9297",
      "searchRadiusKm": 50,
      "professionsNeeded": ["PHOTOGRAPHER", "VENUE", "FLORIST", "BRIDALDESIGNER", "MAKEUPARTIST"]
    };

    try {
      final details = WeddingDetails.fromJson(json);
      print('Parsing successful: ${details.weddingName}');
      print('Bride Name: ${details.brideName}');
      
      expect(details.id, "e99055cb-330f-45c0-bf40-61118cd374c7");
      expect(details.isOwn, true);
      expect(details.brideName, "Marie Martin"); // C'était le point critique
      expect(details.professionsNeeded.length, 5);
    } catch (e, stack) {
      print('Parsing failed: $e');
      print(stack);
      fail('Parsing failed');
    }
  });
}
