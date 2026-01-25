import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/my_wedding/domain/entities/wedding_guest.dart';

void main() {
  group('WeddingGuest', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create WeddingGuest with required fields', () {
        const guest = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
        );

        expect(guest.id, 'guest-123');
        expect(guest.weddingId, 'wedding-456');
        expect(guest.name, isNull);
        expect(guest.email, isNull);
        expect(guest.phone, isNull);
        expect(guest.role, GuestRole.guest);
        expect(guest.notes, isNull);
        expect(guest.createdAt, isNull);
      });

      test('should create WeddingGuest with all optional fields', () {
        final createdAt = DateTime(2025, 1, 24, 10, 0, 0);
        final guest = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
          name: 'Marie Dupont',
          email: 'marie@example.com',
          phone: '+33612345678',
          role: GuestRole.bridesmaid,
          notes: 'Temoin de la mariee',
          createdAt: createdAt,
        );

        expect(guest.name, 'Marie Dupont');
        expect(guest.email, 'marie@example.com');
        expect(guest.phone, '+33612345678');
        expect(guest.role, GuestRole.bridesmaid);
        expect(guest.notes, 'Temoin de la mariee');
        expect(guest.createdAt, createdAt);
      });
    });

    // ==============================================================
    // FROMJSON TESTS
    // ==============================================================

    group('fromJson', () {
      test('should parse guest with all fields', () {
        final json = {
          'id': 'guest-123',
          'wedding_id': 'wedding-456',
          'name': 'Marie Dupont',
          'email': 'marie@example.com',
          'phone': '+33612345678',
          'role': 'bridesmaid',
          'notes': 'Temoin de la mariee',
          'created_at': '2025-01-24T10:00:00Z',
        };

        final guest = WeddingGuest.fromJson(json);

        expect(guest.id, 'guest-123');
        expect(guest.weddingId, 'wedding-456');
        expect(guest.name, 'Marie Dupont');
        expect(guest.email, 'marie@example.com');
        expect(guest.phone, '+33612345678');
        expect(guest.role, GuestRole.bridesmaid);
        expect(guest.notes, 'Temoin de la mariee');
        expect(guest.createdAt?.year, 2025);
        expect(guest.createdAt?.month, 1);
        expect(guest.createdAt?.day, 24);
      });

      test('should parse guest with minimal fields', () {
        final json = {
          'id': 'guest-123',
          'wedding_id': 'wedding-456',
        };

        final guest = WeddingGuest.fromJson(json);

        expect(guest.id, 'guest-123');
        expect(guest.weddingId, 'wedding-456');
        expect(guest.name, isNull);
        expect(guest.email, isNull);
        expect(guest.phone, isNull);
        expect(guest.role, GuestRole.guest);
        expect(guest.notes, isNull);
        expect(guest.createdAt, isNull);
      });

      test('should parse role "guest" correctly', () {
        final json = {
          'id': 'guest-1',
          'wedding_id': 'wedding-1',
          'role': 'guest',
        };

        expect(WeddingGuest.fromJson(json).role, GuestRole.guest);
      });

      test('should parse role "bridesmaid" correctly', () {
        final json = {
          'id': 'guest-1',
          'wedding_id': 'wedding-1',
          'role': 'bridesmaid',
        };

        expect(WeddingGuest.fromJson(json).role, GuestRole.bridesmaid);
      });

      test('should parse role "best_man" correctly', () {
        final json = {
          'id': 'guest-1',
          'wedding_id': 'wedding-1',
          'role': 'best_man',
        };

        expect(WeddingGuest.fromJson(json).role, GuestRole.bestMan);
      });

      test('should parse role "family" correctly', () {
        final json = {
          'id': 'guest-1',
          'wedding_id': 'wedding-1',
          'role': 'family',
        };

        expect(WeddingGuest.fromJson(json).role, GuestRole.family);
      });

      test('should parse role "witness" correctly', () {
        final json = {
          'id': 'guest-1',
          'wedding_id': 'wedding-1',
          'role': 'witness',
        };

        expect(WeddingGuest.fromJson(json).role, GuestRole.witness);
      });

      test('should parse role "other" correctly', () {
        final json = {
          'id': 'guest-1',
          'wedding_id': 'wedding-1',
          'role': 'other',
        };

        expect(WeddingGuest.fromJson(json).role, GuestRole.other);
      });

      test('should default to guest role for invalid value', () {
        final json = {
          'id': 'guest-1',
          'wedding_id': 'wedding-1',
          'role': 'invalid_role',
        };

        expect(WeddingGuest.fromJson(json).role, GuestRole.guest);
      });

      test('should default to guest role for null value', () {
        final json = {
          'id': 'guest-1',
          'wedding_id': 'wedding-1',
          'role': null,
        };

        expect(WeddingGuest.fromJson(json).role, GuestRole.guest);
      });
    });

    // ==============================================================
    // TOJSON TESTS
    // ==============================================================

    group('toJson', () {
      test('should serialize all fields correctly', () {
        const guest = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
          name: 'Marie Dupont',
          email: 'marie@example.com',
          phone: '+33612345678',
          role: GuestRole.bridesmaid,
          notes: 'Temoin de la mariee',
        );

        final json = guest.toJson();

        expect(json['wedding_id'], 'wedding-456');
        expect(json['name'], 'Marie Dupont');
        expect(json['email'], 'marie@example.com');
        expect(json['phone'], '+33612345678');
        expect(json['role'], 'bridesmaid');
        expect(json['notes'], 'Temoin de la mariee');
        // id and created_at are not serialized (auto-generated by DB)
        expect(json.containsKey('id'), false);
        expect(json.containsKey('created_at'), false);
      });

      test('should serialize null optional fields', () {
        const guest = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
        );

        final json = guest.toJson();

        expect(json['name'], isNull);
        expect(json['email'], isNull);
        expect(json['phone'], isNull);
        expect(json['notes'], isNull);
      });

      test('should serialize guest role correctly', () {
        const guest = WeddingGuest(
          id: 'guest-1',
          weddingId: 'wedding-1',
          role: GuestRole.guest,
        );

        expect(guest.toJson()['role'], 'guest');
      });

      test('should serialize bestMan role correctly', () {
        const guest = WeddingGuest(
          id: 'guest-1',
          weddingId: 'wedding-1',
          role: GuestRole.bestMan,
        );

        expect(guest.toJson()['role'], 'bestMan');
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final createdAt = DateTime(2025, 1, 24, 10, 0, 0);
        final original = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
          name: 'Marie Dupont',
          email: 'marie@example.com',
          phone: '+33612345678',
          role: GuestRole.bridesmaid,
          notes: 'Original notes',
          createdAt: createdAt,
        );

        final copied = original.copyWith(name: 'Jean Pierre');

        expect(copied.id, 'guest-123');
        expect(copied.weddingId, 'wedding-456');
        expect(copied.name, 'Jean Pierre');
        expect(copied.email, 'marie@example.com');
        expect(copied.phone, '+33612345678');
        expect(copied.role, GuestRole.bridesmaid);
        expect(copied.notes, 'Original notes');
        expect(copied.createdAt, createdAt);
      });

      test('should update multiple fields at once', () {
        const original = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
          name: 'Marie',
          role: GuestRole.guest,
        );

        final copied = original.copyWith(
          name: 'Jean',
          email: 'jean@example.com',
          role: GuestRole.bestMan,
        );

        expect(copied.name, 'Jean');
        expect(copied.email, 'jean@example.com');
        expect(copied.role, GuestRole.bestMan);
      });

      test('should not modify original', () {
        const original = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
          name: 'Original',
        );

        original.copyWith(name: 'Modified');

        expect(original.name, 'Original');
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when id is same', () {
        const guest1 = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
          name: 'Marie',
        );
        const guest2 = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
          name: 'Jean',
        );

        expect(guest1, equals(guest2));
        expect(guest1.hashCode, equals(guest2.hashCode));
      });

      test('should not be equal when id differs', () {
        const guest1 = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
          name: 'Marie',
        );
        const guest2 = WeddingGuest(
          id: 'guest-789',
          weddingId: 'wedding-456',
          name: 'Marie',
        );

        expect(guest1, isNot(equals(guest2)));
      });

      test('should return identical for same instance', () {
        const guest = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
        );

        expect(guest == guest, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        const guest = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
          name: 'Marie Dupont',
        );

        final result = guest.toString();

        expect(result, contains('guest-123'));
        expect(result, contains('Marie Dupont'));
      });

      test('should handle null name', () {
        const guest = WeddingGuest(
          id: 'guest-123',
          weddingId: 'wedding-456',
        );

        final result = guest.toString();

        expect(result, contains('guest-123'));
        expect(result, contains('null'));
      });
    });
  });

  // ==============================================================
  // GUESTROLE ENUM TESTS
  // ==============================================================

  group('GuestRole', () {
    test('should have all expected values', () {
      expect(GuestRole.values, contains(GuestRole.guest));
      expect(GuestRole.values, contains(GuestRole.bridesmaid));
      expect(GuestRole.values, contains(GuestRole.bestMan));
      expect(GuestRole.values, contains(GuestRole.family));
      expect(GuestRole.values, contains(GuestRole.witness));
      expect(GuestRole.values, contains(GuestRole.other));
      expect(GuestRole.values.length, 6);
    });
  });
}
