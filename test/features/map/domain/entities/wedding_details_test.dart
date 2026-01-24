import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/map/domain/entities/entities.dart';

void main() {
  group('WeddingDetails', () {
    test('should create from JSON correctly', () {
      // Phase 5: Updated JSON structure to match new WeddingDetails entity
      final json = {
        'id': 'test-wedding-id',
        'brideProfileId': 'bride-id',
        'weddingName': 'Marie & Jean Wedding',
        'venueLabel': 'Paris, France',
        'searchRadiusKm': 50,
        'professionsNeeded': ['photographer', 'filmmaker'],
        'eventDate': '2024-12-15',
        'budgetMin': 5000,
        'budgetMax': 15000,
        'currency': 'EUR',
        'visibility': 'visible_to_pros',
        'status': 'planning',
        'brideAvatarUrl': 'https://example.com/avatar.jpg',
        'brideInfo': {
          'fullName': 'Marie Dupont',
          'avatarUrl': 'https://example.com/avatar.jpg',
        },
      };

      final details = WeddingDetails.fromJson(json);

      expect(details.id, 'test-wedding-id');
      expect(details.brideId, 'bride-id');
      expect(details.weddingName, 'Marie & Jean Wedding');
      expect(details.venueLabel, 'Paris, France');
      expect(details.searchRadiusKm, 50);
      expect(details.professionsNeeded.length, 2);
      expect(details.professionsNeeded, contains(Profession.photographer));
      expect(details.budgetMin, 5000);
      expect(details.budgetMax, 15000);
      expect(details.visibility, WeddingVisibility.visibleToPros);
      expect(details.brideFullName, 'Marie Dupont');
    });

    test('budgetRange should format correctly', () {
      const details = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        budgetMin: 5000,
        budgetMax: 15000,
        currency: 'EUR',
      );

      expect(details.budgetRange, '5000 - 15000 EUR');
    });

    test('budgetRange should handle partial values', () {
      const detailsMin = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        budgetMin: 5000,
      );
      expect(detailsMin.budgetRange, 'From 5000 EUR');

      const detailsMax = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        budgetMax: 15000,
      );
      expect(detailsMax.budgetRange, 'Up to 15000 EUR');

      const detailsNone = WeddingDetails(
        id: 'test',
        brideId: 'bride',
      );
      expect(detailsNone.budgetRange, 'Not specified');
    });

    test('daysUntilWedding should calculate correctly', () {
      final futureWedding = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        eventDate: DateTime.now().add(const Duration(days: 30)),
      );

      // Allow for timing variance (29-30 days)
      expect(futureWedding.daysUntilWedding, greaterThanOrEqualTo(29));
      expect(futureWedding.daysUntilWedding, lessThanOrEqualTo(30));
      expect(futureWedding.isUpcoming, true);
      expect(futureWedding.isPast, false);
    });

    test('isPast should return true for past weddings', () {
      final pastWedding = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        eventDate: DateTime.now().subtract(const Duration(days: 30)),
      );

      expect(pastWedding.daysUntilWedding, 0);
      expect(pastWedding.isUpcoming, false);
      expect(pastWedding.isPast, true);
    });

    test('professionsNeededFormatted should format correctly', () {
      const details = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        professionsNeeded: [Profession.photographer, Profession.filmmaker],
      );

      expect(details.professionsNeededFormatted, 'Photographer, Filmmaker');
    });

    test('professionsNeededFormatted should handle empty list', () {
      const details = WeddingDetails(
        id: 'test',
        brideId: 'bride',
      );

      expect(details.professionsNeededFormatted, 'Not specified');
    });

    test('radiusFormatted should format correctly', () {
      const details = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        searchRadiusKm: 50,
      );

      expect(details.radiusFormatted, '50 km');
    });
  });
}
