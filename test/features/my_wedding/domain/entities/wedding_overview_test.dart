import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:lynewed_beta/features/map/domain/entities/wedding_details.dart'
    show WeddingVisibility;
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_overview.dart';

void main() {
  group('WeddingOverview', () {
    // ==============================================================
    // TEST DATA
    // ==============================================================

    final tCreatedAt = DateTime(2026, 1, 1);
    final tEventDate = DateTime(2026, 6, 15);
    final tEventEndDate = DateTime(2026, 6, 16);
    const tPosition = gmaps.LatLng(48.8566, 2.3522);

    final tWedding = WeddingOverview(
      id: 'wedding-1',
      brideId: 'bride-1',
      name: 'My Wedding',
      position: tPosition,
      eventDate: tEventDate,
      eventEndDate: tEventEndDate,
      venueName: 'Chateau de Versailles',
      venueAddress: 'Place d\'Armes, 78000 Versailles',
      countryCode: 'FR',
      visibility: WeddingVisibility.visibleToPros,
      guestCount: 100,
      budgetMin: 10000,
      budgetMax: 50000,
      currency: 'EUR',
      professionsNeeded: ['photographer', 'caterer'],
      searchRadiusKm: 100,
      coverImageUrl: 'https://example.com/cover.jpg',
      noteForPros: 'Looking for experienced professionals',
      status: WeddingStatus.active,
      onboardingStep: null,
      cancelledAt: null,
      createdAt: tCreatedAt,
      teamChatRoomId: 'chat-123',
      participantsCount: 3,
    );

    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create WeddingOverview with required fields', () {
        final wedding = WeddingOverview(
          id: 'w1',
          brideId: 'p1',
        );

        expect(wedding.id, 'w1');
        expect(wedding.brideId, 'p1');
        expect(wedding.name, isNull);
        expect(wedding.position, isNull);
        expect(wedding.eventDate, isNull);
        expect(wedding.eventEndDate, isNull);
        expect(wedding.venueName, isNull);
        expect(wedding.venueAddress, isNull);
        expect(wedding.countryCode, isNull);
        expect(wedding.visibility, WeddingVisibility.private);
        expect(wedding.guestCount, isNull);
        expect(wedding.budgetMin, isNull);
        expect(wedding.budgetMax, isNull);
        expect(wedding.currency, 'EUR');
        expect(wedding.professionsNeeded, isEmpty);
        expect(wedding.searchRadiusKm, 50);
        expect(wedding.coverImageUrl, isNull);
        expect(wedding.noteForPros, isNull);
        expect(wedding.status, WeddingStatus.active);
        expect(wedding.onboardingStep, isNull);
        expect(wedding.cancelledAt, isNull);
        expect(wedding.createdAt, isNull);
        expect(wedding.teamChatRoomId, isNull);
        expect(wedding.participantsCount, 0);
      });

      test('should create WeddingOverview with all optional fields', () {
        expect(tWedding.id, 'wedding-1');
        expect(tWedding.brideId, 'bride-1');
        expect(tWedding.name, 'My Wedding');
        expect(tWedding.position, tPosition);
        expect(tWedding.eventDate, tEventDate);
        expect(tWedding.eventEndDate, tEventEndDate);
        expect(tWedding.venueName, 'Chateau de Versailles');
        expect(tWedding.venueAddress, 'Place d\'Armes, 78000 Versailles');
        expect(tWedding.countryCode, 'FR');
        expect(tWedding.visibility, WeddingVisibility.visibleToPros);
        expect(tWedding.guestCount, 100);
        expect(tWedding.budgetMin, 10000);
        expect(tWedding.budgetMax, 50000);
        expect(tWedding.currency, 'EUR');
        expect(tWedding.professionsNeeded, ['photographer', 'caterer']);
        expect(tWedding.searchRadiusKm, 100);
        expect(tWedding.coverImageUrl, 'https://example.com/cover.jpg');
        expect(tWedding.noteForPros, 'Looking for experienced professionals');
        expect(tWedding.status, WeddingStatus.active);
        expect(tWedding.onboardingStep, isNull);
        expect(tWedding.createdAt, tCreatedAt);
        expect(tWedding.teamChatRoomId, 'chat-123');
        expect(tWedding.participantsCount, 3);
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse wedding with all fields', () {
        final json = {
          'id': 'wedding-1',
          'bride_profile_id': 'bride-1',
          'wedding_name': 'My Wedding',
          'venue_coords': 'POINT(2.3522 48.8566)',
          'event_date': '2026-06-15T00:00:00Z',
          'event_end_date': '2026-06-16T00:00:00Z',
          'venue_label': 'Chateau de Versailles',
          'location_country_code': 'FR',
          'visibility': 'visible_to_pros',
          'guest_count': 100,
          'budget_min': 10000,
          'budget_max': 50000,
          'currency': 'EUR',
          'professions_needed': ['photographer', 'caterer'],
          'search_radius_km': 100,
          'cover_image_url': 'https://example.com/cover.jpg',
          'note_for_pros': 'Looking for experienced professionals',
          'status': 'active',
          'onboarding_step': null,
          'cancelled_at': null,
          'created_at': '2026-01-01T00:00:00Z',
          'team_chat_room_id': 'chat-123',
          'participants_count': 3,
        };

        final wedding = WeddingOverview.fromJson(json);

        expect(wedding.id, 'wedding-1');
        expect(wedding.brideId, 'bride-1');
        expect(wedding.name, 'My Wedding');
        expect(wedding.position?.latitude, closeTo(48.8566, 0.0001));
        expect(wedding.position?.longitude, closeTo(2.3522, 0.0001));
        expect(wedding.eventDate?.year, 2026);
        expect(wedding.eventDate?.month, 6);
        expect(wedding.eventDate?.day, 15);
        expect(wedding.eventEndDate?.year, 2026);
        expect(wedding.venueName, 'Chateau de Versailles');
        expect(wedding.countryCode, 'FR');
        expect(wedding.visibility, WeddingVisibility.visibleToPros);
        expect(wedding.guestCount, 100);
        expect(wedding.budgetMin, 10000);
        expect(wedding.budgetMax, 50000);
        expect(wedding.currency, 'EUR');
        expect(wedding.professionsNeeded, ['photographer', 'caterer']);
        expect(wedding.searchRadiusKm, 100);
        expect(wedding.coverImageUrl, 'https://example.com/cover.jpg');
        expect(wedding.noteForPros, 'Looking for experienced professionals');
        expect(wedding.status, WeddingStatus.active);
        expect(wedding.onboardingStep, isNull);
        expect(wedding.teamChatRoomId, 'chat-123');
        expect(wedding.participantsCount, 3);
      });

      test('should parse wedding with minimal fields', () {
        final json = {
          'id': 'wedding-1',
          'bride_profile_id': 'bride-1',
        };

        final wedding = WeddingOverview.fromJson(json);

        expect(wedding.id, 'wedding-1');
        expect(wedding.brideId, 'bride-1');
        expect(wedding.name, isNull);
        expect(wedding.position, isNull);
        expect(wedding.eventDate, isNull);
        expect(wedding.visibility, WeddingVisibility.private);
        expect(wedding.currency, 'EUR');
        expect(wedding.professionsNeeded, isEmpty);
        expect(wedding.searchRadiusKm, 50);
        expect(wedding.status, WeddingStatus.active);
        expect(wedding.participantsCount, 0);
      });

      test('should throw when id is missing', () {
        final json = {
          'bride_profile_id': 'bride-1',
        };

        expect(() => WeddingOverview.fromJson(json), throwsArgumentError);
      });

      test('should throw when bride_profile_id is missing', () {
        final json = {
          'id': 'wedding-1',
        };

        expect(() => WeddingOverview.fromJson(json), throwsArgumentError);
      });

      test('should parse position from POINT format', () {
        final json = {
          'id': 'w1',
          'bride_profile_id': 'b1',
          'venue_coords': 'POINT(2.3522 48.8566)',
        };

        final wedding = WeddingOverview.fromJson(json);

        expect(wedding.position, isNotNull);
        expect(wedding.position!.latitude, closeTo(48.8566, 0.0001));
        expect(wedding.position!.longitude, closeTo(2.3522, 0.0001));
      });

      test('should handle null venue_coords', () {
        final json = {
          'id': 'w1',
          'bride_profile_id': 'b1',
          'venue_coords': null,
        };

        final wedding = WeddingOverview.fromJson(json);

        expect(wedding.position, isNull);
      });

      test('should handle invalid venue_coords format', () {
        final json = {
          'id': 'w1',
          'bride_profile_id': 'b1',
          'venue_coords': 'INVALID',
        };

        final wedding = WeddingOverview.fromJson(json);

        expect(wedding.position, isNull);
      });

      test('should parse visibility visible_to_pros', () {
        final json = {
          'id': 'w1',
          'bride_profile_id': 'b1',
          'visibility': 'visible_to_pros',
        };

        final wedding = WeddingOverview.fromJson(json);

        expect(wedding.visibility, WeddingVisibility.visibleToPros);
      });

      test('should default visibility to private', () {
        final json = {
          'id': 'w1',
          'bride_profile_id': 'b1',
          'visibility': 'unknown',
        };

        final wedding = WeddingOverview.fromJson(json);

        expect(wedding.visibility, WeddingVisibility.private);
      });

      test('should parse status cancelled', () {
        final json = {
          'id': 'w1',
          'bride_profile_id': 'b1',
          'status': 'cancelled',
          'cancelled_at': '2026-01-15T00:00:00Z',
        };

        final wedding = WeddingOverview.fromJson(json);

        expect(wedding.status, WeddingStatus.cancelled);
        expect(wedding.cancelledAt, isNotNull);
      });

      test('should default status to active', () {
        final json = {
          'id': 'w1',
          'bride_profile_id': 'b1',
          'status': 'unknown',
        };

        final wedding = WeddingOverview.fromJson(json);

        expect(wedding.status, WeddingStatus.active);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should update specified fields', () {
        final updated = tWedding.copyWith(name: 'Updated Wedding');

        expect(updated.name, 'Updated Wedding');
        expect(updated.id, tWedding.id); // unchanged
        expect(updated.brideId, tWedding.brideId); // unchanged
        expect(updated.eventDate, tWedding.eventDate); // unchanged
      });

      test('should preserve all unchanged fields', () {
        final updated = tWedding.copyWith(name: 'New Name');

        expect(updated.position, tWedding.position);
        expect(updated.eventDate, tWedding.eventDate);
        expect(updated.eventEndDate, tWedding.eventEndDate);
        expect(updated.venueName, tWedding.venueName);
        expect(updated.venueAddress, tWedding.venueAddress);
        expect(updated.countryCode, tWedding.countryCode);
        expect(updated.visibility, tWedding.visibility);
        expect(updated.guestCount, tWedding.guestCount);
        expect(updated.budgetMin, tWedding.budgetMin);
        expect(updated.budgetMax, tWedding.budgetMax);
        expect(updated.currency, tWedding.currency);
        expect(updated.professionsNeeded, tWedding.professionsNeeded);
        expect(updated.searchRadiusKm, tWedding.searchRadiusKm);
        expect(updated.coverImageUrl, tWedding.coverImageUrl);
        expect(updated.noteForPros, tWedding.noteForPros);
        expect(updated.status, tWedding.status);
        expect(updated.onboardingStep, tWedding.onboardingStep);
        expect(updated.cancelledAt, tWedding.cancelledAt);
        expect(updated.createdAt, tWedding.createdAt);
        expect(updated.teamChatRoomId, tWedding.teamChatRoomId);
        expect(updated.participantsCount, tWedding.participantsCount);
      });

      test('should update multiple fields at once', () {
        final updated = tWedding.copyWith(
          name: 'New Name',
          guestCount: 200,
          budgetMax: 100000,
          status: WeddingStatus.cancelled,
        );

        expect(updated.name, 'New Name');
        expect(updated.guestCount, 200);
        expect(updated.budgetMax, 100000);
        expect(updated.status, WeddingStatus.cancelled);
      });

      test('should not modify original', () {
        tWedding.copyWith(name: 'Modified');

        expect(tWedding.name, 'My Wedding');
      });

      test('should update onboardingStep', () {
        final updated = tWedding.copyWith(onboardingStep: 2);

        expect(updated.onboardingStep, 2);
      });

      test('should update position', () {
        const newPosition = gmaps.LatLng(40.7128, -74.0060);
        final updated = tWedding.copyWith(position: newPosition);

        expect(updated.position, newPosition);
      });
    });

    // ==============================================================
    // COMPUTED PROPERTIES TESTS
    // ==============================================================

    group('computed properties', () {
      group('isOnboardingComplete', () {
        test('should be true when onboardingStep is null', () {
          expect(tWedding.isOnboardingComplete, isTrue);
        });

        test('should be false when onboardingStep is set', () {
          final wedding = tWedding.copyWith(onboardingStep: 2);

          expect(wedding.isOnboardingComplete, isFalse);
        });

        test('should be false when onboardingStep is 0', () {
          final wedding = tWedding.copyWith(onboardingStep: 0);

          expect(wedding.isOnboardingComplete, isFalse);
        });
      });

      group('isActive', () {
        test('should be true when status is active', () {
          expect(tWedding.isActive, isTrue);
        });

        test('should be false when status is cancelled', () {
          final wedding = tWedding.copyWith(status: WeddingStatus.cancelled);

          expect(wedding.isActive, isFalse);
        });
      });

      group('isCancelled', () {
        test('should be false when status is active', () {
          expect(tWedding.isCancelled, isFalse);
        });

        test('should be true when status is cancelled', () {
          final wedding = tWedding.copyWith(status: WeddingStatus.cancelled);

          expect(wedding.isCancelled, isTrue);
        });
      });

      group('daysUntilWedding', () {
        test('should return null when eventDate is null', () {
          final wedding = WeddingOverview(
            id: 'w1',
            brideId: 'b1',
            eventDate: null,
          );

          expect(wedding.daysUntilWedding, isNull);
        });

        test('should return 0 when eventDate is in the past', () {
          final wedding = WeddingOverview(
            id: 'w1',
            brideId: 'b1',
            eventDate: DateTime.now().subtract(const Duration(days: 10)),
          );

          expect(wedding.daysUntilWedding, 0);
        });

        test('should return days until wedding when in the future', () {
          final futureDate = DateTime.now().add(const Duration(days: 30));
          final wedding = WeddingOverview(
            id: 'w1',
            brideId: 'b1',
            eventDate: futureDate,
          );

          // Allow for test execution time
          expect(wedding.daysUntilWedding, inInclusiveRange(29, 30));
        });
      });

      group('isPast', () {
        test('should return false when eventDate is null', () {
          final wedding = WeddingOverview(
            id: 'w1',
            brideId: 'b1',
            eventDate: null,
          );

          expect(wedding.isPast, isFalse);
        });

        test('should return false when eventDate is in the future', () {
          final wedding = WeddingOverview(
            id: 'w1',
            brideId: 'b1',
            eventDate: DateTime.now().add(const Duration(days: 30)),
          );

          expect(wedding.isPast, isFalse);
        });

        test('should return true when eventDate is in the past', () {
          final wedding = WeddingOverview(
            id: 'w1',
            brideId: 'b1',
            eventDate: DateTime.now().subtract(const Duration(days: 1)),
          );

          expect(wedding.isPast, isTrue);
        });
      });

      group('searchRadius', () {
        test('should return searchRadiusKm', () {
          expect(tWedding.searchRadius, 100);
        });

        test('should return default searchRadiusKm of 50', () {
          final wedding = WeddingOverview(
            id: 'w1',
            brideId: 'b1',
          );

          expect(wedding.searchRadius, 50);
        });
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is same', () {
        final wedding1 = WeddingOverview(
          id: 'wedding-1',
          brideId: 'bride-1',
          name: 'Wedding One',
        );
        final wedding2 = WeddingOverview(
          id: 'wedding-1',
          brideId: 'bride-2',
          name: 'Wedding Two',
        );

        expect(wedding1, equals(wedding2));
        expect(wedding1.hashCode, equals(wedding2.hashCode));
      });

      test('should not be equal when id differs', () {
        final wedding1 = WeddingOverview(
          id: 'wedding-1',
          brideId: 'bride-1',
          name: 'Same Name',
        );
        final wedding2 = WeddingOverview(
          id: 'wedding-2',
          brideId: 'bride-1',
          name: 'Same Name',
        );

        expect(wedding1, isNot(equals(wedding2)));
      });

      test('should return identical for same instance', () {
        expect(tWedding == tWedding, isTrue);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string with id and name', () {
        final result = tWedding.toString();

        expect(result, contains('wedding-1'));
        expect(result, contains('My Wedding'));
      });

      test('should include onboarding step', () {
        final wedding = tWedding.copyWith(onboardingStep: 3);
        final result = wedding.toString();

        expect(result, contains('3'));
      });

      test('should handle null name', () {
        final wedding = WeddingOverview(
          id: 'w1',
          brideId: 'b1',
        );
        final result = wedding.toString();

        expect(result, contains('w1'));
        expect(result, contains('null'));
      });
    });
  });

  // ==============================================================
  // WEDDINGSTATUS ENUM TESTS
  // ==============================================================

  group('WeddingStatus', () {
    test('should have all expected values', () {
      expect(WeddingStatus.values, contains(WeddingStatus.active));
      expect(WeddingStatus.values, contains(WeddingStatus.cancelled));
      expect(WeddingStatus.values.length, 2);
    });
  });
}
