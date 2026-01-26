/// Tests for ContactStatus enum
///
/// Verifies the contact status enum used in wishlist feature.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/wishlist/domain/entities/contact_status.dart';

void main() {
  group('ContactStatus', () {
    // ==============================================================
    // ENUM VALUES TESTS
    // ==============================================================

    group('enum values', () {
      test('should have all expected values', () {
        expect(ContactStatus.values, contains(ContactStatus.none));
        expect(ContactStatus.values, contains(ContactStatus.pending));
        expect(ContactStatus.values, contains(ContactStatus.accepted));
        expect(ContactStatus.values, contains(ContactStatus.declined));
        expect(ContactStatus.values.length, 4);
      });
    });

    // ==============================================================
    // FROMSTRING TESTS
    // ==============================================================

    group('fromString', () {
      test('should parse "none" correctly', () {
        expect(ContactStatus.fromString('none'), ContactStatus.none);
      });

      test('should parse "pending" correctly', () {
        expect(ContactStatus.fromString('pending'), ContactStatus.pending);
      });

      test('should parse "accepted" correctly', () {
        expect(ContactStatus.fromString('accepted'), ContactStatus.accepted);
      });

      test('should parse "declined" correctly', () {
        expect(ContactStatus.fromString('declined'), ContactStatus.declined);
      });

      test('should return none for null', () {
        expect(ContactStatus.fromString(null), ContactStatus.none);
      });

      test('should return none for empty string', () {
        expect(ContactStatus.fromString(''), ContactStatus.none);
      });

      test('should return none for unknown value', () {
        expect(ContactStatus.fromString('unknown'), ContactStatus.none);
      });

      test('should be case insensitive', () {
        expect(ContactStatus.fromString('PENDING'), ContactStatus.pending);
        expect(ContactStatus.fromString('Accepted'), ContactStatus.accepted);
      });
    });

    // ==============================================================
    // DERIVED GETTERS TESTS
    // ==============================================================

    group('derived getters', () {
      test('isNone should return true for none status', () {
        expect(ContactStatus.none.isNone, true);
        expect(ContactStatus.pending.isNone, false);
        expect(ContactStatus.accepted.isNone, false);
        expect(ContactStatus.declined.isNone, false);
      });

      test('isPending should return true for pending status', () {
        expect(ContactStatus.pending.isPending, true);
        expect(ContactStatus.none.isPending, false);
        expect(ContactStatus.accepted.isPending, false);
        expect(ContactStatus.declined.isPending, false);
      });

      test('isAccepted should return true for accepted status', () {
        expect(ContactStatus.accepted.isAccepted, true);
        expect(ContactStatus.none.isAccepted, false);
        expect(ContactStatus.pending.isAccepted, false);
        expect(ContactStatus.declined.isAccepted, false);
      });

      test('isDeclined should return true for declined status', () {
        expect(ContactStatus.declined.isDeclined, true);
        expect(ContactStatus.none.isDeclined, false);
        expect(ContactStatus.pending.isDeclined, false);
        expect(ContactStatus.accepted.isDeclined, false);
      });

      test('canContact should return true for none or accepted', () {
        expect(ContactStatus.none.canContact, true);
        expect(ContactStatus.accepted.canContact, true);
        expect(ContactStatus.pending.canContact, false);
        expect(ContactStatus.declined.canContact, false);
      });
    });

    // ==============================================================
    // TOSTRING TEST
    // ==============================================================

    group('toValue', () {
      test('should return lowercase string value', () {
        expect(ContactStatus.none.toValue, 'none');
        expect(ContactStatus.pending.toValue, 'pending');
        expect(ContactStatus.accepted.toValue, 'accepted');
        expect(ContactStatus.declined.toValue, 'declined');
      });
    });
  });
}
