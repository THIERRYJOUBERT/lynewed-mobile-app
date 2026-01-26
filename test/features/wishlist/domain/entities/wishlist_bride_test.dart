/// Tests for WishlistBride entity
///
/// Verifies the bride entity used in the professional wishlist feature.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/wishlist/domain/entities/wishlist_bride.dart';
import 'package:lynewed_beta/features/wishlist/domain/entities/contact_status.dart';

void main() {
  group('WishlistBride', () {
    // ==============================================================
    // CREATION TESTS
    // ==============================================================

    group('creation', () {
      test('should create WishlistBride with required fields', () {
        final now = DateTime.now();
        final bride = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          addedAt: now,
          contactStatus: ContactStatus.none,
        );

        expect(bride.profileId, 'bride-123');
        expect(bride.fullName, 'Jane Doe');
        expect(bride.addedAt, now);
        expect(bride.contactStatus, ContactStatus.none);
        expect(bride.avatarUrl, isNull);
      });

      test('should create WishlistBride with all optional fields', () {
        final now = DateTime.now();
        final bride = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          addedAt: now,
          contactStatus: ContactStatus.accepted,
        );

        expect(bride.avatarUrl, 'https://example.com/avatar.jpg');
        expect(bride.contactStatus, ContactStatus.accepted);
      });
    });

    // ==============================================================
    // FROMMAP TESTS
    // ==============================================================

    group('fromMap', () {
      test('should parse bride correctly from camelCase (RPC format)', () {
        final map = {
          'brideProfileId': 'bride-123',
          'fullName': 'Jane Doe',
          'avatarUrl': 'https://example.com/avatar.jpg',
          'addedAt': '2025-01-24T10:00:00Z',
          'contactStatus': 'pending',
        };

        final bride = WishlistBride.fromMap(map);

        expect(bride.profileId, 'bride-123');
        expect(bride.fullName, 'Jane Doe');
        expect(bride.avatarUrl, 'https://example.com/avatar.jpg');
        expect(bride.addedAt.year, 2025);
        expect(bride.addedAt.month, 1);
        expect(bride.addedAt.day, 24);
        expect(bride.contactStatus, ContactStatus.pending);
      });

      test('should parse bride correctly from snake_case', () {
        final map = {
          'bride_profile_id': 'bride-456',
          'full_name': 'Sarah Smith',
          'avatar_url': 'https://example.com/sarah.jpg',
          'added_at': '2025-01-25T15:30:00Z',
          'contact_status': 'accepted',
        };

        final bride = WishlistBride.fromMap(map);

        expect(bride.profileId, 'bride-456');
        expect(bride.fullName, 'Sarah Smith');
        expect(bride.avatarUrl, 'https://example.com/sarah.jpg');
        expect(bride.contactStatus, ContactStatus.accepted);
      });

      test('should handle null optional fields', () {
        final map = {
          'brideProfileId': 'bride-123',
          'fullName': 'Jane Doe',
          'avatarUrl': null,
          'addedAt': '2025-01-24T10:00:00Z',
          'contactStatus': null,
        };

        final bride = WishlistBride.fromMap(map);

        expect(bride.avatarUrl, isNull);
        expect(bride.contactStatus, ContactStatus.none);
      });

      test('should default fullName to Bride when null', () {
        final map = {
          'brideProfileId': 'bride-123',
          'fullName': null,
          'addedAt': '2025-01-24T10:00:00Z',
          'contactStatus': 'none',
        };

        final bride = WishlistBride.fromMap(map);

        expect(bride.fullName, 'Bride');
      });

      test('should handle DateTime object directly', () {
        final now = DateTime.now();
        final map = {
          'brideProfileId': 'bride-123',
          'fullName': 'Jane Doe',
          'addedAt': now,
          'contactStatus': 'none',
        };

        final bride = WishlistBride.fromMap(map);

        expect(bride.addedAt, now);
      });
    });

    // ==============================================================
    // DERIVED GETTERS TESTS
    // ==============================================================

    group('derived getters', () {
      test('displayName should return fullName', () {
        final bride = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.none,
        );

        expect(bride.displayName, 'Jane Doe');
      });

      test('hasAvatar should return true when avatarUrl is not null or empty', () {
        final brideWithAvatar = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.none,
        );

        final brideWithoutAvatar = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.none,
        );

        final brideWithEmptyAvatar = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          avatarUrl: '',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.none,
        );

        expect(brideWithAvatar.hasAvatar, true);
        expect(brideWithoutAvatar.hasAvatar, false);
        expect(brideWithEmptyAvatar.hasAvatar, false);
      });

      test('canContact should delegate to contactStatus', () {
        final brideNone = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.none,
        );

        final bridePending = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.pending,
        );

        final brideAccepted = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.accepted,
        );

        expect(brideNone.canContact, true);
        expect(bridePending.canContact, false);
        expect(brideAccepted.canContact, true);
      });

      test('isPending should delegate to contactStatus', () {
        final bridePending = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.pending,
        );

        final brideNone = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.none,
        );

        expect(bridePending.isPending, true);
        expect(brideNone.isPending, false);
      });

      test('isAccepted should delegate to contactStatus', () {
        final brideAccepted = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.accepted,
        );

        final brideNone = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.none,
        );

        expect(brideAccepted.isAccepted, true);
        expect(brideNone.isAccepted, false);
      });
    });

    // ==============================================================
    // COPYWITH TESTS
    // ==============================================================

    group('copyWith', () {
      test('should preserve unchanged fields', () {
        final now = DateTime.now();
        final original = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          addedAt: now,
          contactStatus: ContactStatus.none,
        );

        final copied = original.copyWith(fullName: 'New Name');

        expect(copied.profileId, 'bride-123');
        expect(copied.avatarUrl, 'https://example.com/avatar.jpg');
        expect(copied.addedAt, now);
        expect(copied.contactStatus, ContactStatus.none);
        expect(copied.fullName, 'New Name');
      });

      test('should update contactStatus correctly', () {
        final original = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.none,
        );

        final copied = original.copyWith(contactStatus: ContactStatus.accepted);

        expect(copied.contactStatus, ContactStatus.accepted);
        expect(original.contactStatus, ContactStatus.none);
      });
    });

    // ==============================================================
    // EQUALITY TESTS
    // ==============================================================

    group('equality', () {
      test('should be equal when all fields are same', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final bride1 = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          addedAt: now,
          contactStatus: ContactStatus.none,
        );
        final bride2 = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          avatarUrl: 'https://example.com/avatar.jpg',
          addedAt: now,
          contactStatus: ContactStatus.none,
        );

        expect(bride1, equals(bride2));
        expect(bride1.hashCode, equals(bride2.hashCode));
      });

      test('should not be equal when profileId differs', () {
        final now = DateTime(2025, 1, 24, 10, 0, 0);
        final bride1 = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          addedAt: now,
          contactStatus: ContactStatus.none,
        );
        final bride2 = WishlistBride(
          profileId: 'bride-456',
          fullName: 'Jane Doe',
          addedAt: now,
          contactStatus: ContactStatus.none,
        );

        expect(bride1, isNot(equals(bride2)));
      });

      test('should return identical for same instance', () {
        final bride = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.none,
        );

        expect(bride == bride, true);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toString', () {
      test('should return formatted string', () {
        final bride = WishlistBride(
          profileId: 'bride-123',
          fullName: 'Jane Doe',
          addedAt: DateTime.now(),
          contactStatus: ContactStatus.pending,
        );

        final result = bride.toString();

        expect(result, contains('bride-123'));
        expect(result, contains('Jane Doe'));
        expect(result, contains('pending'));
      });
    });
  });
}
