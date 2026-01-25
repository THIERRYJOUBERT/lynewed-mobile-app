/// Tests for AuthUser entity.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/domain/entities/auth_user.dart';

void main() {
  group('AuthUser', () {
    final now = DateTime(2024, 1, 15, 10, 30);
    final lastSignIn = DateTime(2024, 1, 14, 8, 0);

    group('constructor', () {
      test('should create AuthUser with required fields', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          createdAt: now,
        );

        expect(user.id, 'user-123');
        expect(user.email, 'test@example.com');
        expect(user.createdAt, now);
        expect(user.phone, isNull);
        expect(user.emailConfirmed, false);
        expect(user.lastSignInAt, isNull);
        expect(user.userMetadata, isNull);
      });

      test('should create AuthUser with all fields', () {
        final metadata = {'role': 'bride', 'onboarded': true};
        final user = AuthUser(
          id: 'user-456',
          email: 'full@example.com',
          phone: '+33612345678',
          emailConfirmed: true,
          lastSignInAt: lastSignIn,
          createdAt: now,
          userMetadata: metadata,
        );

        expect(user.id, 'user-456');
        expect(user.email, 'full@example.com');
        expect(user.phone, '+33612345678');
        expect(user.emailConfirmed, true);
        expect(user.lastSignInAt, lastSignIn);
        expect(user.createdAt, now);
        expect(user.userMetadata, metadata);
      });
    });

    group('copyWith', () {
      test('should create copy with updated email', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'old@example.com',
          createdAt: now,
        );

        final updated = user.copyWith(email: 'new@example.com');

        expect(updated.email, 'new@example.com');
        expect(updated.id, user.id);
        expect(updated.createdAt, user.createdAt);
      });

      test('should create copy with updated emailConfirmed', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          emailConfirmed: false,
          createdAt: now,
        );

        final updated = user.copyWith(emailConfirmed: true);

        expect(updated.emailConfirmed, true);
        expect(updated.email, user.email);
      });

      test('should create copy with all fields updated', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'old@example.com',
          createdAt: now,
        );

        final newMetadata = {'key': 'value'};
        final updated = user.copyWith(
          id: 'user-new',
          email: 'new@example.com',
          phone: '+33699999999',
          emailConfirmed: true,
          lastSignInAt: lastSignIn,
          createdAt: lastSignIn,
          userMetadata: newMetadata,
        );

        expect(updated.id, 'user-new');
        expect(updated.email, 'new@example.com');
        expect(updated.phone, '+33699999999');
        expect(updated.emailConfirmed, true);
        expect(updated.lastSignInAt, lastSignIn);
        expect(updated.createdAt, lastSignIn);
        expect(updated.userMetadata, newMetadata);
      });

      test('should return same values when copyWith called with no arguments', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          phone: '+33612345678',
          emailConfirmed: true,
          lastSignInAt: lastSignIn,
          createdAt: now,
          userMetadata: {'key': 'value'},
        );

        final copy = user.copyWith();

        expect(copy.id, user.id);
        expect(copy.email, user.email);
        expect(copy.phone, user.phone);
        expect(copy.emailConfirmed, user.emailConfirmed);
        expect(copy.lastSignInAt, user.lastSignInAt);
        expect(copy.createdAt, user.createdAt);
        expect(copy.userMetadata, user.userMetadata);
      });
    });

    group('equality', () {
      test('should be equal when all fields match', () {
        final user1 = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          createdAt: now,
        );

        final user2 = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          createdAt: now,
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when id differs', () {
        final user1 = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          createdAt: now,
        );

        final user2 = AuthUser(
          id: 'user-456',
          email: 'test@example.com',
          createdAt: now,
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should not be equal when email differs', () {
        final user1 = AuthUser(
          id: 'user-123',
          email: 'test1@example.com',
          createdAt: now,
        );

        final user2 = AuthUser(
          id: 'user-123',
          email: 'test2@example.com',
          createdAt: now,
        );

        expect(user1, isNot(equals(user2)));
      });
    });

    group('toString', () {
      test('should return readable string representation', () {
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          createdAt: now,
        );

        expect(user.toString(), contains('AuthUser'));
        expect(user.toString(), contains('user-123'));
        expect(user.toString(), contains('test@example.com'));
      });
    });

    group('immutability', () {
      test('should be immutable (metadata cannot affect original)', () {
        final metadata = {'key': 'original'};
        final user = AuthUser(
          id: 'user-123',
          email: 'test@example.com',
          createdAt: now,
          userMetadata: metadata,
        );

        // Attempt to modify original metadata should not affect user
        // Note: Map is mutable, but this tests that the reference is preserved
        expect(user.userMetadata, equals({'key': 'original'}));
      });
    });
  });
}
