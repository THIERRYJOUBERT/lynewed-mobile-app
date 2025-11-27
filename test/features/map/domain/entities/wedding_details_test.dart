import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/map/domain/entities/entities.dart';

void main() {
  group('WeddingDetails', () {
    test('should create from JSON correctly', () {
      final json = {
        'weddingPinId': 'test-wedding-id',
        'brideProfileId': 'bride-id',
        'locationLabel': 'Paris, France',
        'center': {
          'type': 'Point',
          'coordinates': [2.3522, 48.8566],
        },
        'radiusKm': 50,
        'professionsNeeded': ['photographer', 'videographer'],
        'eventStartDate': '2024-12-15',
        'budgetMin': 5000,
        'budgetMax': 15000,
        'currency': 'EUR',
        'isContactable': true,
        'brideAvatarUrl': 'https://example.com/avatar.jpg',
        'brideName': 'Marie',
        'guestCount': 150,
      };

      final details = WeddingDetails.fromJson(json);

      expect(details.id, 'test-wedding-id');
      expect(details.brideId, 'bride-id');
      expect(details.locationLabel, 'Paris, France');
      expect(details.center?.latitude, 48.8566);
      expect(details.center?.longitude, 2.3522);
      expect(details.radiusKm, 50);
      expect(details.professionsNeeded.length, 2);
      expect(details.professionsNeeded, contains(Profession.photographer));
      expect(details.budgetMin, 5000);
      expect(details.budgetMax, 15000);
      expect(details.isContactable, true);
      expect(details.guestCount, 150);
    });

    test('budgetRange should format correctly', () {
      final details = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        budgetMin: 5000,
        budgetMax: 15000,
        currency: 'EUR',
      );

      expect(details.budgetRange, '5000 - 15000 EUR');
    });

    test('budgetRange should handle partial values', () {
      final detailsMin = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        budgetMin: 5000,
      );
      expect(detailsMin.budgetRange, 'From 5000 EUR');

      final detailsMax = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        budgetMax: 15000,
      );
      expect(detailsMax.budgetRange, 'Up to 15000 EUR');

      final detailsNone = WeddingDetails(
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
      final details = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        professionsNeeded: [Profession.photographer, Profession.videographer],
      );

      expect(details.professionsNeededFormatted, 'Photographer, Videographer');
    });

    test('professionsNeededFormatted should handle empty list', () {
      final details = WeddingDetails(
        id: 'test',
        brideId: 'bride',
      );

      expect(details.professionsNeededFormatted, 'Not specified');
    });

    test('radiusFormatted should format correctly', () {
      final details = WeddingDetails(
        id: 'test',
        brideId: 'bride',
        radiusKm: 50,
      );

      expect(details.radiusFormatted, '50 km');
    });
  });
}
