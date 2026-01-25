import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/core.dart' hide AuthException;
import 'package:lynewed_beta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:lynewed_beta/features/auth/data/models/auth_user_model.dart';
import 'package:lynewed_beta/features/auth/data/models/user_profile_model.dart';
import 'package:lynewed_beta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lynewed_beta/features/auth/domain/entities/auth_user.dart';
import 'package:lynewed_beta/features/auth/domain/entities/user_profile.dart';
import 'package:lynewed_beta/features/auth/domain/entities/user_role.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

// Mock
class MockAuthRemoteDatasource extends Mock implements AuthRemoteDatasource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDatasource mockDatasource;

  final testCreatedAt = DateTime(2024, 1, 15, 10, 30);
  final testLastSignInAt = DateTime(2024, 1, 20, 14, 45);

  final testAuthUserModel = AuthUserModel(
    id: 'user-123',
    email: 'test@example.com',
    phone: null,
    emailConfirmed: true,
    lastSignInAt: testLastSignInAt,
    createdAt: testCreatedAt,
    userMetadata: {'role': 'bride'},
  );

  final testUserProfileModel = UserProfileModel(
    id: 'user-123',
    authUserId: 'user-123',
    displayName: 'Test User',
    avatarUrl: 'https://example.com/avatar.jpg',
    role: UserRole.bride,
    profession: null,
    companyName: null,
    bio: 'A bio',
    isOnboardingComplete: true,
    onboardingStep: null,
    createdAt: testCreatedAt,
    updatedAt: testLastSignInAt,
  );

  setUpAll(() {
    registerFallbackValue(UpdateProfileParams());
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    mockDatasource = MockAuthRemoteDatasource();
    repository = AuthRepositoryImpl(mockDatasource);
  });

  group('AuthRepositoryImpl', () {
    group('signInWithEmail', () {
      test('should return Success with AuthUser on successful sign in',
          () async {
        // Arrange
        when(() => mockDatasource.signInWithEmail(any(), any()))
            .thenAnswer((_) async => testAuthUserModel);

        // Act
        final result = await repository.signInWithEmail(
          'test@example.com',
          'password123',
        );

        // Assert
        expect(result, isA<Success<AuthUser>>());
        final user = (result as Success<AuthUser>).data;
        expect(user.id, 'user-123');
        expect(user.email, 'test@example.com');
        verify(() =>
                mockDatasource.signInWithEmail('test@example.com', 'password123'))
            .called(1);
      });

      test('should return Failure with AuthFailure on AuthException', () async {
        // Arrange
        when(() => mockDatasource.signInWithEmail(any(), any()))
            .thenThrow(const AuthException('Invalid credentials'));

        // Act
        final result = await repository.signInWithEmail(
          'test@example.com',
          'wrong',
        );

        // Assert
        expect(result, isA<Failure<AuthUser>>());
        final failure = (result as Failure<AuthUser>).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, contains('Invalid credentials'));
      });

      test('should return Failure with UnknownFailure on generic exception',
          () async {
        // Arrange
        when(() => mockDatasource.signInWithEmail(any(), any()))
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.signInWithEmail(
          'test@example.com',
          'pass',
        );

        // Assert
        expect(result, isA<Failure<AuthUser>>());
        final failure = (result as Failure<AuthUser>).failure;
        expect(failure, isA<UnknownFailure>());
      });
    });

    group('signUpBride', () {
      test('should return Success with AuthUser on successful sign up',
          () async {
        // Arrange
        when(() => mockDatasource.signUpWithEmail(
              any(),
              any(),
              metadata: any(named: 'metadata'),
            )).thenAnswer((_) async => testAuthUserModel);
        when(() => mockDatasource.acceptTerms(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.signUpBride(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        );

        // Assert
        expect(result, isA<Success<AuthUser>>());
        final user = (result as Success<AuthUser>).data;
        expect(user.id, 'user-123');
        verify(() => mockDatasource.signUpWithEmail(
              'test@example.com',
              'password123',
              metadata: any(named: 'metadata'),
            )).called(1);
        verify(() => mockDatasource.acceptTerms('user-123')).called(1);
      });

      test('should return Failure when sign up fails', () async {
        // Arrange
        when(() => mockDatasource.signUpWithEmail(
              any(),
              any(),
              metadata: any(named: 'metadata'),
            )).thenThrow(const AuthException('Email already registered'));

        // Act
        final result = await repository.signUpBride(
          email: 'existing@example.com',
          password: 'password123',
        );

        // Assert
        expect(result, isA<Failure<AuthUser>>());
        final failure = (result as Failure<AuthUser>).failure;
        expect(failure, isA<AuthFailure>());
      });
    });

    group('signOut', () {
      test('should return Success on successful sign out', () async {
        // Arrange
        when(() => mockDatasource.signOut()).thenAnswer((_) async {});

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Success<void>>());
        verify(() => mockDatasource.signOut()).called(1);
      });

      test('should return Failure on error', () async {
        // Arrange
        when(() => mockDatasource.signOut())
            .thenThrow(const AuthException('Sign out failed'));

        // Act
        final result = await repository.signOut();

        // Assert
        expect(result, isA<Failure<void>>());
      });
    });

    group('sendPasswordResetEmail', () {
      test('should return Success when email is sent', () async {
        // Arrange
        when(() => mockDatasource.sendPasswordResetEmail(any()))
            .thenAnswer((_) async {});

        // Act
        final result =
            await repository.sendPasswordResetEmail('test@example.com');

        // Assert
        expect(result, isA<Success<void>>());
        verify(() => mockDatasource.sendPasswordResetEmail('test@example.com'))
            .called(1);
      });
    });

    group('updatePassword', () {
      test('should return Success when password is updated', () async {
        // Arrange
        when(() => mockDatasource.updatePassword(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.updatePassword('newPassword123');

        // Assert
        expect(result, isA<Success<void>>());
        verify(() => mockDatasource.updatePassword('newPassword123')).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return Success with AuthUser when user is logged in',
          () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser())
            .thenReturn(testAuthUserModel);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Success<AuthUser?>>());
        final user = (result as Success<AuthUser?>).data;
        expect(user, isNotNull);
        expect(user!.id, 'user-123');
      });

      test('should return Success with null when no user is logged in',
          () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser()).thenReturn(null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isA<Success<AuthUser?>>());
        final user = (result as Success<AuthUser?>).data;
        expect(user, isNull);
      });
    });

    group('isAuthenticated', () {
      test('should return true when user is logged in', () {
        // Arrange
        when(() => mockDatasource.getCurrentUser())
            .thenReturn(testAuthUserModel);

        // Act
        final result = repository.isAuthenticated;

        // Assert
        expect(result, true);
      });

      test('should return false when no user is logged in', () {
        // Arrange
        when(() => mockDatasource.getCurrentUser()).thenReturn(null);

        // Act
        final result = repository.isAuthenticated;

        // Assert
        expect(result, false);
      });
    });

    group('watchAuthState', () {
      test('should return stream of AuthUser from datasource', () async {
        // Arrange
        when(() => mockDatasource.watchAuthState())
            .thenAnswer((_) => Stream.value(testAuthUserModel));

        // Act
        final stream = repository.watchAuthState();

        // Assert
        expect(
          stream,
          emits(predicate<AuthUser?>((user) => user?.id == 'user-123')),
        );
      });

      test('should emit null when no user', () async {
        // Arrange
        when(() => mockDatasource.watchAuthState())
            .thenAnswer((_) => Stream.value(null));

        // Act
        final stream = repository.watchAuthState();

        // Assert
        expect(stream, emits(isNull));
      });
    });

    group('getCurrentProfile', () {
      test('should return Success with UserProfile when profile exists',
          () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser())
            .thenReturn(testAuthUserModel);
        when(() => mockDatasource.getProfile(any()))
            .thenAnswer((_) async => testUserProfileModel);

        // Act
        final result = await repository.getCurrentProfile();

        // Assert
        expect(result, isA<Success<UserProfile?>>());
        final profile = (result as Success<UserProfile?>).data;
        expect(profile, isNotNull);
        expect(profile!.id, 'user-123');
        expect(profile.displayName, 'Test User');
      });

      test('should return Success with null when no user is logged in',
          () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser()).thenReturn(null);

        // Act
        final result = await repository.getCurrentProfile();

        // Assert
        expect(result, isA<Success<UserProfile?>>());
        final profile = (result as Success<UserProfile?>).data;
        expect(profile, isNull);
      });
    });

    group('updateProfile', () {
      test('should return Success with updated UserProfile', () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser())
            .thenReturn(testAuthUserModel);
        when(() => mockDatasource.updateProfile(any(), any()))
            .thenAnswer((_) async => testUserProfileModel);

        final params = UpdateProfileParams(
          displayName: 'New Name',
          bio: 'New bio',
        );

        // Act
        final result = await repository.updateProfile(params);

        // Assert
        expect(result, isA<Success<UserProfile>>());
        verify(() => mockDatasource.updateProfile(
              'user-123',
              any(that: containsPair('full_name', 'New Name')),
            )).called(1);
      });

      test('should return Failure when not authenticated', () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser()).thenReturn(null);

        final params = UpdateProfileParams(displayName: 'New Name');

        // Act
        final result = await repository.updateProfile(params);

        // Assert
        expect(result, isA<Failure<UserProfile>>());
        final failure = (result as Failure<UserProfile>).failure;
        expect(failure, isA<AuthFailure>());
      });
    });

    group('uploadAvatar', () {
      test('should return Success with URL on successful upload', () async {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const expectedUrl = 'https://example.com/avatar.jpg';

        when(() => mockDatasource.getCurrentUser())
            .thenReturn(testAuthUserModel);
        when(() => mockDatasource.uploadAvatar(any(), any(), any()))
            .thenAnswer((_) async => expectedUrl);

        // Act
        final result = await repository.uploadAvatar(bytes, 'avatar.jpg');

        // Assert
        expect(result, isA<Success<String>>());
        final url = (result as Success<String>).data;
        expect(url, expectedUrl);
      });

      test('should return Failure when not authenticated', () async {
        // Arrange
        final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        when(() => mockDatasource.getCurrentUser()).thenReturn(null);

        // Act
        final result = await repository.uploadAvatar(bytes, 'avatar.jpg');

        // Assert
        expect(result, isA<Failure<String>>());
        final failure = (result as Failure<String>).failure;
        expect(failure, isA<AuthFailure>());
      });
    });

    group('deleteAccount', () {
      test('should return Success on successful deletion', () async {
        // Arrange
        when(() => mockDatasource.deleteAccount()).thenAnswer((_) async {});

        // Act
        final result = await repository.deleteAccount();

        // Assert
        expect(result, isA<Success<void>>());
        verify(() => mockDatasource.deleteAccount()).called(1);
      });

      test('should return Failure on error', () async {
        // Arrange
        when(() => mockDatasource.deleteAccount())
            .thenThrow(Exception('Deletion failed'));

        // Act
        final result = await repository.deleteAccount();

        // Assert
        expect(result, isA<Failure<void>>());
      });
    });

    group('hasAcceptedTerms', () {
      test('should return Success with true when terms accepted', () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser())
            .thenReturn(testAuthUserModel);
        when(() => mockDatasource.hasAcceptedTerms(any()))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.hasAcceptedTerms();

        // Assert
        expect(result, isA<Success<bool>>());
        final accepted = (result as Success<bool>).data;
        expect(accepted, true);
      });

      test('should return Success with false when terms not accepted',
          () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser())
            .thenReturn(testAuthUserModel);
        when(() => mockDatasource.hasAcceptedTerms(any()))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.hasAcceptedTerms();

        // Assert
        expect(result, isA<Success<bool>>());
        final accepted = (result as Success<bool>).data;
        expect(accepted, false);
      });

      test('should return Failure when not authenticated', () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser()).thenReturn(null);

        // Act
        final result = await repository.hasAcceptedTerms();

        // Assert
        expect(result, isA<Failure<bool>>());
      });
    });

    group('acceptTerms', () {
      test('should return Success when terms are accepted', () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser())
            .thenReturn(testAuthUserModel);
        when(() => mockDatasource.acceptTerms(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.acceptTerms();

        // Assert
        expect(result, isA<Success<void>>());
        verify(() => mockDatasource.acceptTerms('user-123')).called(1);
      });

      test('should return Failure when not authenticated', () async {
        // Arrange
        when(() => mockDatasource.getCurrentUser()).thenReturn(null);

        // Act
        final result = await repository.acceptTerms();

        // Assert
        expect(result, isA<Failure<void>>());
      });
    });
  });
}
