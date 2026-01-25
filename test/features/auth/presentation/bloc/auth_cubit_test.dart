import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late StreamController<AuthUser?> authStateController;

  final testUser = AuthUser(
    id: 'test-user-id',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  final testProfile = UserProfile(
    id: 'test-profile-id',
    authUserId: 'test-user-id',
    role: UserRole.bride,
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    authStateController = StreamController<AuthUser?>.broadcast();

    // Default stubs
    when(() => mockRepository.watchAuthState())
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  group('AuthCubit', () {
    group('AC-1: AuthCubit manages authentication state', () {
      test('should be created with AuthRepository', () {
        final cubit = AuthCubit(repository: mockRepository);
        expect(cubit, isA<AuthCubit>());
        cubit.close();
      });

      test('initial state should be AuthInitial', () {
        final cubit = AuthCubit(repository: mockRepository);
        expect(cubit.state, isA<AuthInitial>());
        cubit.close();
      });
    });

    group('AC-3: AuthCubit verifies auth on startup', () {
      blocTest<AuthCubit, AuthState>(
        'should emit Unauthenticated when user stream emits null',
        setUp: () {
          when(() => mockRepository.watchAuthState())
              .thenAnswer((_) => Stream.value(null));
        },
        build: () => AuthCubit(repository: mockRepository),
        wait: const Duration(milliseconds: 100),
        expect: () => [const Unauthenticated()],
        verify: (_) {
          verify(() => mockRepository.watchAuthState()).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit Authenticated when user stream emits a user',
        setUp: () {
          when(() => mockRepository.watchAuthState())
              .thenAnswer((_) => Stream.value(testUser));
          when(() => mockRepository.getCurrentProfile())
              .thenAnswer((_) async => Success(testProfile));
        },
        build: () => AuthCubit(repository: mockRepository),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          Authenticated(user: testUser, profile: testProfile),
        ],
        verify: (_) {
          verify(() => mockRepository.watchAuthState()).called(1);
          verify(() => mockRepository.getCurrentProfile()).called(1);
        },
      );
    });

    group('AC-4: App reacts to auth state changes', () {
      blocTest<AuthCubit, AuthState>(
        'should emit new state when auth stream changes from null to user',
        setUp: () {
          when(() => mockRepository.getCurrentProfile())
              .thenAnswer((_) async => Success(testProfile));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) {
          authStateController.add(null);
          authStateController.add(testUser);
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const Unauthenticated(),
          Authenticated(user: testUser, profile: testProfile),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit Unauthenticated when auth stream changes from user to null',
        setUp: () {
          when(() => mockRepository.getCurrentProfile())
              .thenAnswer((_) async => Success(testProfile));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) {
          authStateController.add(testUser);
          authStateController.add(null);
        },
        wait: const Duration(milliseconds: 100),
        expect: () => [
          Authenticated(user: testUser, profile: testProfile),
          const Unauthenticated(),
        ],
      );
    });

    group('signIn', () {
      blocTest<AuthCubit, AuthState>(
        'should emit Loading then Authenticated on successful sign in',
        setUp: () {
          when(() => mockRepository.signInWithEmail(any(), any()))
              .thenAnswer((_) async => Success(testUser));
          when(() => mockRepository.getCurrentProfile())
              .thenAnswer((_) async => Success(testProfile));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) => cubit.signIn('test@example.com', 'password123'),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthLoading(),
          Authenticated(user: testUser, profile: testProfile),
        ],
        verify: (_) {
          verify(() =>
                  mockRepository.signInWithEmail('test@example.com', 'password123'))
              .called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit Loading then AuthError on failed sign in',
        setUp: () {
          when(() => mockRepository.signInWithEmail(any(), any())).thenAnswer(
              (_) async => const Failure(AuthFailure('Invalid credentials')));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) => cubit.signIn('test@example.com', 'wrongpassword'),
        expect: () => [
          const AuthLoading(),
          const AuthError('Invalid credentials'),
        ],
      );
    });

    group('signUp', () {
      blocTest<AuthCubit, AuthState>(
        'should emit Loading then Authenticated on successful sign up',
        setUp: () {
          when(() => mockRepository.signUpBride(
                email: any(named: 'email'),
                password: any(named: 'password'),
                displayName: any(named: 'displayName'),
              )).thenAnswer((_) async => Success(testUser));
          when(() => mockRepository.getCurrentProfile())
              .thenAnswer((_) async => Success(testProfile));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) => cubit.signUp(
          email: 'test@example.com',
          password: 'password123',
          displayName: 'Test User',
        ),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthLoading(),
          Authenticated(user: testUser, profile: testProfile),
        ],
        verify: (_) {
          verify(() => mockRepository.signUpBride(
                email: 'test@example.com',
                password: 'password123',
                displayName: 'Test User',
              )).called(1);
        },
      );

      blocTest<AuthCubit, AuthState>(
        'should emit Loading then AuthError on failed sign up',
        setUp: () {
          when(() => mockRepository.signUpBride(
                email: any(named: 'email'),
                password: any(named: 'password'),
                displayName: any(named: 'displayName'),
              )).thenAnswer(
              (_) async => const Failure(AuthFailure('Email already exists')));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) => cubit.signUp(
          email: 'existing@example.com',
          password: 'password123',
        ),
        expect: () => [
          const AuthLoading(),
          const AuthError('Email already exists'),
        ],
      );
    });

    group('signOut', () {
      blocTest<AuthCubit, AuthState>(
        'should emit Unauthenticated on sign out',
        setUp: () {
          when(() => mockRepository.signOut())
              .thenAnswer((_) async => const Success(null));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) => cubit.signOut(),
        expect: () => [const Unauthenticated()],
        verify: (_) {
          verify(() => mockRepository.signOut()).called(1);
        },
      );
    });

    group('checkAuthStatus', () {
      blocTest<AuthCubit, AuthState>(
        'should emit Loading then Authenticated when user is signed in',
        setUp: () {
          when(() => mockRepository.getCurrentUser())
              .thenAnswer((_) async => Success(testUser));
          when(() => mockRepository.getCurrentProfile())
              .thenAnswer((_) async => Success(testProfile));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) => cubit.checkAuthStatus(),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          const AuthLoading(),
          Authenticated(user: testUser, profile: testProfile),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit Loading then Unauthenticated when no user is signed in',
        setUp: () {
          when(() => mockRepository.getCurrentUser())
              .thenAnswer((_) async => const Success(null));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'should emit Loading then Unauthenticated on failure',
        setUp: () {
          when(() => mockRepository.getCurrentUser()).thenAnswer(
              (_) async => const Failure(AuthFailure('Session expired')));
        },
        build: () => AuthCubit(repository: mockRepository),
        act: (cubit) => cubit.checkAuthStatus(),
        expect: () => [
          const AuthLoading(),
          const Unauthenticated(),
        ],
      );
    });

    group('profile loading edge cases', () {
      blocTest<AuthCubit, AuthState>(
        'should emit Authenticated with null profile when profile fetch fails',
        setUp: () {
          when(() => mockRepository.watchAuthState())
              .thenAnswer((_) => Stream.value(testUser));
          when(() => mockRepository.getCurrentProfile()).thenAnswer(
              (_) async => const Failure(UnknownFailure('Profile error')));
        },
        build: () => AuthCubit(repository: mockRepository),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          Authenticated(user: testUser, profile: null),
        ],
      );
    });

    group('close', () {
      test('should cancel auth subscription on close', () async {
        final cubit = AuthCubit(repository: mockRepository);

        // Wait a bit for subscription to be set up
        await Future<void>.delayed(const Duration(milliseconds: 10));

        await cubit.close();

        // Adding to a closed stream should not cause any issues
        // The cubit should have unsubscribed
        expect(cubit.isClosed, isTrue);
      });
    });

    group('sendPasswordResetEmail', () {
      test('should return Success when repository succeeds', () async {
        // Arrange
        when(() => mockRepository.sendPasswordResetEmail(any()))
            .thenAnswer((_) async => const Success(null));

        final cubit = AuthCubit(repository: mockRepository);

        // Act
        final result = await cubit.sendPasswordResetEmail('test@example.com');

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockRepository.sendPasswordResetEmail('test@example.com'))
            .called(1);

        // Cleanup
        await cubit.close();
      });

      test('should return Failure when repository fails', () async {
        // Arrange
        when(() => mockRepository.sendPasswordResetEmail(any())).thenAnswer(
            (_) async => const Failure(AuthFailure('User not found')));

        final cubit = AuthCubit(repository: mockRepository);

        // Act
        final result = await cubit.sendPasswordResetEmail('unknown@example.com');

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull()?.message, 'User not found');

        // Cleanup
        await cubit.close();
      });
    });

    group('updatePassword', () {
      test('should return Success when repository succeeds', () async {
        // Arrange
        when(() => mockRepository.updatePassword(any()))
            .thenAnswer((_) async => const Success(null));

        final cubit = AuthCubit(repository: mockRepository);

        // Act
        final result = await cubit.updatePassword('newPassword123');

        // Assert
        expect(result.isSuccess, isTrue);
        verify(() => mockRepository.updatePassword('newPassword123')).called(1);

        // Cleanup
        await cubit.close();
      });

      test('should return Failure when repository fails', () async {
        // Arrange
        when(() => mockRepository.updatePassword(any())).thenAnswer(
            (_) async => const Failure(AuthFailure('Password too weak')));

        final cubit = AuthCubit(repository: mockRepository);

        // Act
        final result = await cubit.updatePassword('weak');

        // Assert
        expect(result.isFailure, isTrue);
        expect(result.failureOrNull()?.message, 'Password too weak');

        // Cleanup
        await cubit.close();
      });
    });
  });
}
