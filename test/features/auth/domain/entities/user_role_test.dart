/// Tests for UserRole enum.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/domain/entities/user_role.dart';

void main() {
  group('UserRole', () {
    group('values', () {
      test('should have bride role', () {
        expect(UserRole.bride, isNotNull);
      });

      test('should have professional role', () {
        expect(UserRole.professional, isNotNull);
      });

      test('should have admin role', () {
        expect(UserRole.admin, isNotNull);
      });

      test('should have guest role', () {
        expect(UserRole.guest, isNotNull);
      });

      test('should have exactly 4 roles', () {
        expect(UserRole.values.length, 4);
      });
    });

    group('value extension', () {
      test('should return "bride" for UserRole.bride', () {
        expect(UserRole.bride.value, 'bride');
      });

      test('should return "professional" for UserRole.professional', () {
        expect(UserRole.professional.value, 'professional');
      });

      test('should return "admin" for UserRole.admin', () {
        expect(UserRole.admin.value, 'admin');
      });

      test('should return "guest" for UserRole.guest', () {
        expect(UserRole.guest.value, 'guest');
      });
    });

    group('fromString', () {
      test('should parse "bride" to UserRole.bride', () {
        expect(UserRoleX.fromString('bride'), UserRole.bride);
      });

      test('should parse "professional" to UserRole.professional', () {
        expect(UserRoleX.fromString('professional'), UserRole.professional);
      });

      test('should parse "admin" to UserRole.admin', () {
        expect(UserRoleX.fromString('admin'), UserRole.admin);
      });

      test('should parse "guest" to UserRole.guest', () {
        expect(UserRoleX.fromString('guest'), UserRole.guest);
      });

      test('should parse case-insensitively', () {
        expect(UserRoleX.fromString('BRIDE'), UserRole.bride);
        expect(UserRoleX.fromString('Professional'), UserRole.professional);
        expect(UserRoleX.fromString('ADMIN'), UserRole.admin);
        expect(UserRoleX.fromString('GUEST'), UserRole.guest);
      });

      test('should default to bride for unknown values', () {
        expect(UserRoleX.fromString('unknown'), UserRole.bride);
        expect(UserRoleX.fromString(''), UserRole.bride);
        expect(UserRoleX.fromString('invalid'), UserRole.bride);
      });

      test('should not return guest as default for unknown values', () {
        expect(UserRoleX.fromString('unknown'), isNot(UserRole.guest));
      });
    });
  });
}
