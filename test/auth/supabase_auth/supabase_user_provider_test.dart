import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/auth/supabase_auth/supabase_user_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Mock for Supabase User
class MockUser extends Mock implements User {}

void main() {
  setUp(() {
    // Reset global currentUser before each test
    currentUser = null;
  });

  tearDown(() {
    // Ensure global state is cleaned up even if tests fail
    currentUser = null;
  });

  group('LynewedAlphaSupabaseUser', () {
    group('creation and properties', () {
      test('should create with valid Supabase User', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('supabase-user-123');
        when(() => mockUser.email).thenReturn('test@example.com');
        when(() => mockUser.phone).thenReturn('+33612345678');
        when(() => mockUser.emailConfirmedAt).thenReturn(DateTime.now().toIso8601String());

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(supabaseUser.user, equals(mockUser));
      });

      test('should create with null User', () {
        final supabaseUser = LynewedAlphaSupabaseUser(null);

        expect(supabaseUser.user, isNull);
      });
    });

    group('loggedIn', () {
      test('should return true when user is not null', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('user-123');

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(supabaseUser.loggedIn, isTrue);
      });

      test('should return false when user is null', () {
        final supabaseUser = LynewedAlphaSupabaseUser(null);

        expect(supabaseUser.loggedIn, isFalse);
      });
    });

    group('authUserInfo', () {
      test('should return AuthUserInfo with user data', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('info-user-123');
        when(() => mockUser.email).thenReturn('info@example.com');
        when(() => mockUser.phone).thenReturn('+33698765432');

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);
        final authInfo = supabaseUser.authUserInfo;

        expect(authInfo.uid, equals('info-user-123'));
        expect(authInfo.email, equals('info@example.com'));
        expect(authInfo.phoneNumber, equals('+33698765432'));
      });

      test('should return AuthUserInfo with null values when user is null', () {
        final supabaseUser = LynewedAlphaSupabaseUser(null);
        final authInfo = supabaseUser.authUserInfo;

        expect(authInfo.uid, isNull);
        expect(authInfo.email, isNull);
        expect(authInfo.phoneNumber, isNull);
      });
    });

    group('getters from BaseAuthUser', () {
      test('uid should return user id', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('getter-uid-123');
        when(() => mockUser.email).thenReturn(null);
        when(() => mockUser.phone).thenReturn(null);

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(supabaseUser.uid, equals('getter-uid-123'));
      });

      test('email should return user email', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('user-id');
        when(() => mockUser.email).thenReturn('getter@example.com');
        when(() => mockUser.phone).thenReturn(null);

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(supabaseUser.email, equals('getter@example.com'));
      });

      test('phoneNumber should return user phone', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('user-id');
        when(() => mockUser.email).thenReturn(null);
        when(() => mockUser.phone).thenReturn('+33600000000');

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(supabaseUser.phoneNumber, equals('+33600000000'));
      });

      test('displayName should return null (not mapped from user metadata)', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('user-id');
        when(() => mockUser.email).thenReturn(null);
        when(() => mockUser.phone).thenReturn(null);

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        // displayName is not set in authUserInfo, so it will be null
        expect(supabaseUser.displayName, isNull);
      });

      test('photoUrl should return null (not mapped from user metadata)', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('user-id');
        when(() => mockUser.email).thenReturn(null);
        when(() => mockUser.phone).thenReturn(null);

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        // photoUrl is not set in authUserInfo, so it will be null
        expect(supabaseUser.photoUrl, isNull);
      });
    });

    group('emailVerified', () {
      test('should return true when emailConfirmedAt is not null', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('verified-user');
        when(() => mockUser.emailConfirmedAt)
            .thenReturn(DateTime.now().toIso8601String());

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(supabaseUser.emailVerified, isTrue);
      });

      // Note: Testing emailVerified when emailConfirmedAt is null and user is
      // logged in triggers refreshUser() which requires Supabase initialization.
      // This is a limitation of the current implementation that couples the
      // getter with a side effect (refresh). We only test the null user case.

      test('should return false when user is null', () {
        final supabaseUser = LynewedAlphaSupabaseUser(null);

        expect(supabaseUser.emailVerified, isFalse);
      });
    });

    group('delete', () {
      test('should throw UnsupportedError', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('delete-user');

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(
          () => supabaseUser.delete(),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('error message should indicate operation not supported', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('delete-user');

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(
          () => supabaseUser.delete(),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              contains('not yet supported'),
            ),
          ),
        );
      });
    });

    group('sendEmailVerification', () {
      test('should throw UnsupportedError', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('verification-user');

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(
          () => supabaseUser.sendEmailVerification(),
          throwsA(isA<UnsupportedError>()),
        );
      });

      test('error message should indicate operation not supported', () {
        final mockUser = MockUser();
        when(() => mockUser.id).thenReturn('verification-user');

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser);

        expect(
          () => supabaseUser.sendEmailVerification(),
          throwsA(
            isA<UnsupportedError>().having(
              (e) => e.message,
              'message',
              contains('not yet supported'),
            ),
          ),
        );
      });
    });

    group('user property mutation', () {
      test('user property can be updated', () {
        final mockUser1 = MockUser();
        when(() => mockUser1.id).thenReturn('user-1');

        final mockUser2 = MockUser();
        when(() => mockUser2.id).thenReturn('user-2');

        final supabaseUser = LynewedAlphaSupabaseUser(mockUser1);
        expect(supabaseUser.uid, equals('user-1'));

        // User can be reassigned
        supabaseUser.user = mockUser2;
        expect(supabaseUser.uid, equals('user-2'));

        // User can be set to null
        supabaseUser.user = null;
        expect(supabaseUser.loggedIn, isFalse);
      });
    });
  });

  group('Integration with global currentUser', () {
    test('LynewedAlphaSupabaseUser can be assigned to currentUser', () {
      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('global-test-user');
      when(() => mockUser.email).thenReturn('global@example.com');
      when(() => mockUser.phone).thenReturn(null);

      final supabaseUser = LynewedAlphaSupabaseUser(mockUser);
      currentUser = supabaseUser;

      expect(currentUser, isNotNull);
      expect(currentUser?.uid, equals('global-test-user'));
      expect(currentUser?.email, equals('global@example.com'));
      expect(loggedIn, isTrue);
    });

    test('loggedIn should reflect currentUser state', () {
      expect(loggedIn, isFalse);

      final mockUser = MockUser();
      when(() => mockUser.id).thenReturn('state-user');

      currentUser = LynewedAlphaSupabaseUser(mockUser);
      expect(loggedIn, isTrue);

      currentUser = LynewedAlphaSupabaseUser(null);
      expect(loggedIn, isFalse);
    });
  });
}
