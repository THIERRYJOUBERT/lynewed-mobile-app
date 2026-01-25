import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/auth/supabase_auth/supabase_user_provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Note: Cannot import auth_util.dart directly because it initializes
// SupabaseAuthManager which accesses SupaFlow. Instead, we test the
// behavior of the global helpers through supabase_user_provider.

/// Mock for Supabase User
class MockUser extends Mock implements User {}

/// Concrete implementation of BaseAuthUser for testing utilities
class TestAuthUser extends BaseAuthUser {
  final AuthUserInfo _authUserInfo;
  final bool _loggedIn;
  final bool _emailVerified;

  TestAuthUser({
    required AuthUserInfo authUserInfo,
    required bool loggedIn,
    bool emailVerified = false,
  })  : _authUserInfo = authUserInfo,
        _loggedIn = loggedIn,
        _emailVerified = emailVerified;

  @override
  AuthUserInfo get authUserInfo => _authUserInfo;

  @override
  bool get loggedIn => _loggedIn;

  @override
  bool get emailVerified => _emailVerified;

  @override
  Future? delete() async {}

  @override
  Future? updateEmail(String email) async {}

  @override
  Future? updatePassword(String newPassword) async {}

  @override
  Future? sendEmailVerification() async {}
}

void main() {
  setUp(() {
    // Reset global currentUser before each test
    currentUser = null;
  });

  tearDown(() {
    // Ensure global state is cleaned up even if tests fail
    currentUser = null;
  });

  // Note: auth_util.dart defines these getters that we test indirectly:
  // - currentUserEmail => currentUser?.email ?? ''
  // - currentUserUid => currentUser?.uid ?? ''
  // - currentUserDisplayName => currentUser?.displayName ?? ''
  // - currentUserPhoto => currentUser?.photoUrl ?? ''
  // - currentPhoneNumber => currentUser?.phoneNumber ?? ''
  // - currentUserEmailVerified => currentUser?.emailVerified ?? false
  //
  // These are simple getters that delegate to currentUser properties,
  // returning empty string or false as defaults when currentUser is null.

  group('Auth utilities via currentUser', () {
    group('when currentUser is null', () {
      test('email should be accessible as empty string via currentUser', () {
        expect(currentUser?.email ?? '', equals(''));
      });

      test('uid should be accessible as empty string via currentUser', () {
        expect(currentUser?.uid ?? '', equals(''));
      });

      test('displayName should be accessible as empty string via currentUser',
          () {
        expect(currentUser?.displayName ?? '', equals(''));
      });

      test('photoUrl should be accessible as empty string via currentUser', () {
        expect(currentUser?.photoUrl ?? '', equals(''));
      });

      test('phoneNumber should be accessible as empty string via currentUser',
          () {
        expect(currentUser?.phoneNumber ?? '', equals(''));
      });

      test('emailVerified should be accessible as false via currentUser', () {
        expect(currentUser?.emailVerified ?? false, isFalse);
      });

      test('loggedIn global getter should return false', () {
        expect(loggedIn, isFalse);
      });
    });

    group('when currentUser is set with TestAuthUser', () {
      late TestAuthUser testUser;

      setUp(() {
        testUser = TestAuthUser(
          authUserInfo: const AuthUserInfo(
            uid: 'util-test-uid-123',
            email: 'util-test@example.com',
            displayName: 'Util Test User',
            photoUrl: 'https://example.com/util-avatar.jpg',
            phoneNumber: '+33612345678',
          ),
          loggedIn: true,
          emailVerified: true,
        );
        currentUser = testUser;
      });

      test('email should return user email', () {
        expect(currentUser?.email ?? '', equals('util-test@example.com'));
      });

      test('uid should return user uid', () {
        expect(currentUser?.uid ?? '', equals('util-test-uid-123'));
      });

      test('displayName should return user displayName', () {
        expect(currentUser?.displayName ?? '', equals('Util Test User'));
      });

      test('photoUrl should return user photoUrl', () {
        expect(currentUser?.photoUrl ?? '',
            equals('https://example.com/util-avatar.jpg'));
      });

      test('phoneNumber should return user phoneNumber', () {
        expect(currentUser?.phoneNumber ?? '', equals('+33612345678'));
      });

      test('emailVerified should return user emailVerified', () {
        expect(currentUser?.emailVerified ?? false, isTrue);
      });

      test('loggedIn global getter should return true', () {
        expect(loggedIn, isTrue);
      });
    });

    group('when currentUser is LynewedAlphaSupabaseUser', () {
      late MockUser mockUser;
      late LynewedAlphaSupabaseUser supabaseUser;

      setUp(() {
        mockUser = MockUser();
        when(() => mockUser.id).thenReturn('supabase-uid-456');
        when(() => mockUser.email).thenReturn('supabase@example.com');
        when(() => mockUser.phone).thenReturn('+33699887766');
        when(() => mockUser.emailConfirmedAt)
            .thenReturn(DateTime.now().toIso8601String());

        supabaseUser = LynewedAlphaSupabaseUser(mockUser);
        currentUser = supabaseUser;
      });

      test('email should return Supabase user email', () {
        expect(currentUser?.email ?? '', equals('supabase@example.com'));
      });

      test('uid should return Supabase user id', () {
        expect(currentUser?.uid ?? '', equals('supabase-uid-456'));
      });

      test('phoneNumber should return Supabase user phone', () {
        expect(currentUser?.phoneNumber ?? '', equals('+33699887766'));
      });

      test('displayName should be empty (not mapped in LynewedAlphaSupabaseUser)',
          () {
        // LynewedAlphaSupabaseUser does not map displayName from userMetadata
        expect(currentUser?.displayName ?? '', equals(''));
      });

      test('photoUrl should be empty (not mapped in LynewedAlphaSupabaseUser)',
          () {
        // LynewedAlphaSupabaseUser does not map photoUrl from userMetadata
        expect(currentUser?.photoUrl ?? '', equals(''));
      });

      test('emailVerified should return true when emailConfirmedAt is set', () {
        expect(currentUser?.emailVerified ?? false, isTrue);
      });

      test('loggedIn should return true', () {
        expect(loggedIn, isTrue);
      });
    });

    group('edge cases', () {
      test('should handle null values in AuthUserInfo gracefully', () {
        final user = TestAuthUser(
          authUserInfo: const AuthUserInfo(),
          loggedIn: true,
        );
        currentUser = user;

        // All nullable fields should work with null-coalescing
        expect(currentUser?.email ?? '', equals(''));
        expect(currentUser?.uid ?? '', equals(''));
        expect(currentUser?.displayName ?? '', equals(''));
        expect(currentUser?.photoUrl ?? '', equals(''));
        expect(currentUser?.phoneNumber ?? '', equals(''));
      });

      test('should handle loggedIn false with valid AuthUserInfo', () {
        final user = TestAuthUser(
          authUserInfo: const AuthUserInfo(
            uid: 'not-logged-uid',
            email: 'not-logged@example.com',
          ),
          loggedIn: false,
        );
        currentUser = user;

        // Properties should still be accessible
        expect(currentUser?.email ?? '', equals('not-logged@example.com'));
        expect(currentUser?.uid ?? '', equals('not-logged-uid'));

        // But loggedIn should be false
        expect(loggedIn, isFalse);
      });
    });
  });

  // Note: The following cannot be unit tested without Supabase initialization:
  // - authManager getter (creates SupabaseAuthManager singleton)
  // - currentJwtToken (requires SupaFlow.client.auth)
  // - jwtTokenStream (requires SupaFlow.client.auth.onAuthStateChange)
  //
  // These would require integration tests with a real Supabase instance.
}
