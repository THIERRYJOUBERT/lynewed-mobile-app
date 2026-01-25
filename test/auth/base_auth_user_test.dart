import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/auth/base_auth_user_provider.dart';

/// Concrete implementation of BaseAuthUser for testing
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

  group('AuthUserInfo', () {
    test('should create with all fields', () {
      const userInfo = AuthUserInfo(
        uid: 'test-uid-123',
        email: 'test@example.com',
        displayName: 'Test User',
        photoUrl: 'https://example.com/photo.jpg',
        phoneNumber: '+33612345678',
      );

      expect(userInfo.uid, equals('test-uid-123'));
      expect(userInfo.email, equals('test@example.com'));
      expect(userInfo.displayName, equals('Test User'));
      expect(userInfo.photoUrl, equals('https://example.com/photo.jpg'));
      expect(userInfo.phoneNumber, equals('+33612345678'));
    });

    test('should create with minimal fields (all nullable)', () {
      const userInfo = AuthUserInfo();

      expect(userInfo.uid, isNull);
      expect(userInfo.email, isNull);
      expect(userInfo.displayName, isNull);
      expect(userInfo.photoUrl, isNull);
      expect(userInfo.phoneNumber, isNull);
    });

    test('should create with partial fields', () {
      const userInfo = AuthUserInfo(
        uid: 'partial-uid',
        email: 'partial@example.com',
      );

      expect(userInfo.uid, equals('partial-uid'));
      expect(userInfo.email, equals('partial@example.com'));
      expect(userInfo.displayName, isNull);
      expect(userInfo.photoUrl, isNull);
      expect(userInfo.phoneNumber, isNull);
    });
  });

  group('BaseAuthUser', () {
    group('logged in user', () {
      late TestAuthUser user;

      setUp(() {
        user = TestAuthUser(
          authUserInfo: const AuthUserInfo(
            uid: 'user-123',
            email: 'logged@example.com',
            displayName: 'Logged User',
            photoUrl: 'https://example.com/avatar.jpg',
            phoneNumber: '+33698765432',
          ),
          loggedIn: true,
          emailVerified: true,
        );
      });

      test('should return loggedIn as true', () {
        expect(user.loggedIn, isTrue);
      });

      test('should return emailVerified correctly', () {
        expect(user.emailVerified, isTrue);
      });

      test('uid getter should return authUserInfo.uid', () {
        expect(user.uid, equals('user-123'));
      });

      test('email getter should return authUserInfo.email', () {
        expect(user.email, equals('logged@example.com'));
      });

      test('displayName getter should return authUserInfo.displayName', () {
        expect(user.displayName, equals('Logged User'));
      });

      test('photoUrl getter should return authUserInfo.photoUrl', () {
        expect(user.photoUrl, equals('https://example.com/avatar.jpg'));
      });

      test('phoneNumber getter should return authUserInfo.phoneNumber', () {
        expect(user.phoneNumber, equals('+33698765432'));
      });
    });

    group('not logged in user', () {
      late TestAuthUser user;

      setUp(() {
        user = TestAuthUser(
          authUserInfo: const AuthUserInfo(),
          loggedIn: false,
        );
      });

      test('should return loggedIn as false', () {
        expect(user.loggedIn, isFalse);
      });

      test('should return null uid when not logged in', () {
        expect(user.uid, isNull);
      });

      test('should return null email when not logged in', () {
        expect(user.email, isNull);
      });
    });

    group('email not verified', () {
      test('should return emailVerified as false', () {
        final user = TestAuthUser(
          authUserInfo: const AuthUserInfo(
            uid: 'user-456',
            email: 'unverified@example.com',
          ),
          loggedIn: true,
          emailVerified: false,
        );

        expect(user.emailVerified, isFalse);
      });
    });

    group('async methods', () {
      late TestAuthUser user;

      setUp(() {
        user = TestAuthUser(
          authUserInfo: const AuthUserInfo(uid: 'async-user'),
          loggedIn: true,
        );
      });

      test('delete should complete without error', () async {
        expect(user.delete(), completes);
      });

      test('updateEmail should complete without error', () async {
        expect(user.updateEmail('new@example.com'), completes);
      });

      test('updatePassword should complete without error', () async {
        expect(user.updatePassword('newPassword123'), completes);
      });

      test('sendEmailVerification should complete without error', () async {
        expect(user.sendEmailVerification(), completes);
      });

      test('refreshUser should complete without error', () async {
        expect(user.refreshUser(), completes);
      });
    });
  });

  group('Global currentUser and loggedIn', () {
    test('currentUser should be null by default', () {
      expect(currentUser, isNull);
    });

    test('loggedIn should return false when currentUser is null', () {
      expect(loggedIn, isFalse);
    });

    test('loggedIn should return true when currentUser is logged in', () {
      currentUser = TestAuthUser(
        authUserInfo: const AuthUserInfo(uid: 'global-user'),
        loggedIn: true,
      );

      expect(loggedIn, isTrue);
    });

    test('loggedIn should return false when currentUser is not logged in', () {
      currentUser = TestAuthUser(
        authUserInfo: const AuthUserInfo(),
        loggedIn: false,
      );

      expect(loggedIn, isFalse);
    });

    test('currentUser can be assigned and reassigned', () {
      final user1 = TestAuthUser(
        authUserInfo: const AuthUserInfo(uid: 'user-1'),
        loggedIn: true,
      );
      final user2 = TestAuthUser(
        authUserInfo: const AuthUserInfo(uid: 'user-2'),
        loggedIn: true,
      );

      currentUser = user1;
      expect(currentUser?.uid, equals('user-1'));

      currentUser = user2;
      expect(currentUser?.uid, equals('user-2'));

      currentUser = null;
      expect(currentUser, isNull);
    });
  });
}
