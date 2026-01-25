import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/auth/auth_manager.dart';
import 'package:lynewed_beta/auth/base_auth_user_provider.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes for testing
class MockBuildContext extends Mock implements BuildContext {}

class MockBaseAuthUser extends Mock implements BaseAuthUser {}

/// Concrete implementation of AuthManager for testing abstract class behavior
class TestAuthManager extends AuthManager {
  bool signOutCalled = false;
  bool deleteUserCalled = false;
  bool updateEmailCalled = false;
  bool resetPasswordCalled = false;

  @override
  Future signOut() async {
    signOutCalled = true;
  }

  @override
  Future deleteUser(BuildContext context) async {
    deleteUserCalled = true;
  }

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    updateEmailCalled = true;
  }

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    resetPasswordCalled = true;
  }
}

/// Test implementation with EmailSignInManager mixin
class TestEmailAuthManager extends AuthManager with EmailSignInManager {
  bool signInWithEmailCalled = false;
  bool createAccountWithEmailCalled = false;

  @override
  Future signOut() async {}

  @override
  Future deleteUser(BuildContext context) async {}

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {}

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {}

  @override
  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    signInWithEmailCalled = true;
    return null;
  }

  @override
  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    createAccountWithEmailCalled = true;
    return null;
  }
}

/// Test implementation with AppleSignInManager mixin
class TestAppleAuthManager extends AuthManager with AppleSignInManager {
  bool signInWithAppleCalled = false;

  @override
  Future signOut() async {}

  @override
  Future deleteUser(BuildContext context) async {}

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {}

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {}

  @override
  Future<BaseAuthUser?> signInWithApple(BuildContext context) async {
    signInWithAppleCalled = true;
    return null;
  }
}

/// Test implementation with GoogleSignInManager mixin
class TestGoogleAuthManager extends AuthManager with GoogleSignInManager {
  bool signInWithGoogleCalled = false;

  @override
  Future signOut() async {}

  @override
  Future deleteUser(BuildContext context) async {}

  @override
  Future updateEmail({
    required String email,
    required BuildContext context,
  }) async {}

  @override
  Future resetPassword({
    required String email,
    required BuildContext context,
  }) async {}

  @override
  Future<BaseAuthUser?> signInWithGoogle(BuildContext context) async {
    signInWithGoogleCalled = true;
    return null;
  }
}

void main() {
  late MockBuildContext mockContext;

  setUpAll(() {
    registerFallbackValue(MockBuildContext());
  });

  setUp(() {
    mockContext = MockBuildContext();
    // Reset global currentUser before each test
    currentUser = null;
  });

  tearDown(() {
    // Ensure global state is cleaned up even if tests fail
    currentUser = null;
  });

  group('AuthManager abstract class', () {
    late TestAuthManager authManager;

    setUp(() {
      authManager = TestAuthManager();
    });

    test('should define signOut method', () async {
      await authManager.signOut();
      expect(authManager.signOutCalled, isTrue);
    });

    test('should define deleteUser method with BuildContext', () async {
      await authManager.deleteUser(mockContext);
      expect(authManager.deleteUserCalled, isTrue);
    });

    test('should define updateEmail method with email and BuildContext',
        () async {
      await authManager.updateEmail(
        email: 'test@example.com',
        context: mockContext,
      );
      expect(authManager.updateEmailCalled, isTrue);
    });

    test('should define resetPassword method with email and BuildContext',
        () async {
      await authManager.resetPassword(
        email: 'test@example.com',
        context: mockContext,
      );
      expect(authManager.resetPasswordCalled, isTrue);
    });

    test('sendEmailVerification delegates to currentUser', () async {
      // When currentUser is null, sendEmailVerification returns null
      final result = await authManager.sendEmailVerification();
      expect(result, isNull);
    });

    test('sendEmailVerification calls currentUser.sendEmailVerification',
        () async {
      final mockUser = MockBaseAuthUser();
      when(() => mockUser.sendEmailVerification()).thenAnswer((_) async {});
      currentUser = mockUser;

      await authManager.sendEmailVerification();

      verify(() => mockUser.sendEmailVerification()).called(1);
    });

    test('refreshUser delegates to currentUser', () async {
      // When currentUser is null, refreshUser returns null
      final result = await authManager.refreshUser();
      expect(result, isNull);
    });

    test('refreshUser calls currentUser.refreshUser', () async {
      final mockUser = MockBaseAuthUser();
      when(() => mockUser.refreshUser()).thenAnswer((_) async {});
      currentUser = mockUser;

      await authManager.refreshUser();

      verify(() => mockUser.refreshUser()).called(1);
    });
  });

  group('EmailSignInManager mixin', () {
    late TestEmailAuthManager authManager;

    setUp(() {
      authManager = TestEmailAuthManager();
    });

    test('should define signInWithEmail method', () async {
      await authManager.signInWithEmail(
        mockContext,
        'test@example.com',
        'password123',
      );
      expect(authManager.signInWithEmailCalled, isTrue);
    });

    test('should define createAccountWithEmail method', () async {
      await authManager.createAccountWithEmail(
        mockContext,
        'test@example.com',
        'password123',
      );
      expect(authManager.createAccountWithEmailCalled, isTrue);
    });
  });

  group('AppleSignInManager mixin', () {
    late TestAppleAuthManager authManager;

    setUp(() {
      authManager = TestAppleAuthManager();
    });

    test('should define signInWithApple method', () async {
      await authManager.signInWithApple(mockContext);
      expect(authManager.signInWithAppleCalled, isTrue);
    });
  });

  group('GoogleSignInManager mixin', () {
    late TestGoogleAuthManager authManager;

    setUp(() {
      authManager = TestGoogleAuthManager();
    });

    test('should define signInWithGoogle method', () async {
      await authManager.signInWithGoogle(mockContext);
      expect(authManager.signInWithGoogleCalled, isTrue);
    });
  });
}
