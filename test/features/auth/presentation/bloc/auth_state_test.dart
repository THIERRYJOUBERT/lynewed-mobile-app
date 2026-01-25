import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_state.dart';

void main() {
  group('AuthState', () {
    group('AuthInitial', () {
      test('should be created as a const', () {
        const state = AuthInitial();
        expect(state, isA<AuthState>());
        expect(state, isA<AuthInitial>());
      });

      test('should be equal to another AuthInitial instance', () {
        const state1 = AuthInitial();
        const state2 = AuthInitial();
        expect(state1, equals(state2));
      });
    });

    group('AuthLoading', () {
      test('should be created as a const', () {
        const state = AuthLoading();
        expect(state, isA<AuthState>());
        expect(state, isA<AuthLoading>());
      });

      test('should be equal to another AuthLoading instance', () {
        const state1 = AuthLoading();
        const state2 = AuthLoading();
        expect(state1, equals(state2));
      });
    });

    group('Authenticated', () {
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

      final testProfileIncomplete = UserProfile(
        id: 'test-profile-id',
        authUserId: 'test-user-id',
        role: UserRole.professional,
        isOnboardingComplete: false,
        createdAt: DateTime(2024, 1, 1),
      );

      test('should be created with user only', () {
        final state = Authenticated(user: testUser);
        expect(state, isA<AuthState>());
        expect(state.user, equals(testUser));
        expect(state.profile, isNull);
      });

      test('should be created with user and profile', () {
        final state = Authenticated(user: testUser, profile: testProfile);
        expect(state.user, equals(testUser));
        expect(state.profile, equals(testProfile));
      });

      test('hasProfile should return true when profile is present', () {
        final state = Authenticated(user: testUser, profile: testProfile);
        expect(state.hasProfile, isTrue);
      });

      test('hasProfile should return false when profile is null', () {
        final state = Authenticated(user: testUser);
        expect(state.hasProfile, isFalse);
      });

      test('needsOnboarding should return true when onboarding is incomplete',
          () {
        final state =
            Authenticated(user: testUser, profile: testProfileIncomplete);
        expect(state.needsOnboarding, isTrue);
      });

      test('needsOnboarding should return false when onboarding is complete',
          () {
        final state = Authenticated(user: testUser, profile: testProfile);
        expect(state.needsOnboarding, isFalse);
      });

      test('needsOnboarding should return false when profile is null', () {
        final state = Authenticated(user: testUser);
        expect(state.needsOnboarding, isFalse);
      });

      test('role should return profile role when profile is present', () {
        final state = Authenticated(user: testUser, profile: testProfile);
        expect(state.role, equals(UserRole.bride));
      });

      test('role should return bride when profile is null', () {
        final state = Authenticated(user: testUser);
        expect(state.role, equals(UserRole.bride));
      });

      test('should be equal when user and profile are the same', () {
        final state1 = Authenticated(user: testUser, profile: testProfile);
        final state2 = Authenticated(user: testUser, profile: testProfile);
        expect(state1, equals(state2));
      });

      test('should not be equal when users differ', () {
        final otherUser = AuthUser(
          id: 'other-user-id',
          email: 'other@example.com',
          createdAt: DateTime(2024, 1, 1),
        );
        final state1 = Authenticated(user: testUser, profile: testProfile);
        final state2 = Authenticated(user: otherUser, profile: testProfile);
        expect(state1, isNot(equals(state2)));
      });
    });

    group('Unauthenticated', () {
      test('should be created as a const', () {
        const state = Unauthenticated();
        expect(state, isA<AuthState>());
        expect(state, isA<Unauthenticated>());
      });

      test('should be equal to another Unauthenticated instance', () {
        const state1 = Unauthenticated();
        const state2 = Unauthenticated();
        expect(state1, equals(state2));
      });
    });

    group('AuthError', () {
      test('should be created with a message', () {
        const state = AuthError('Test error message');
        expect(state, isA<AuthState>());
        expect(state.message, equals('Test error message'));
      });

      test('should be equal when messages are the same', () {
        const state1 = AuthError('Test error');
        const state2 = AuthError('Test error');
        expect(state1, equals(state2));
      });

      test('should not be equal when messages differ', () {
        const state1 = AuthError('Error 1');
        const state2 = AuthError('Error 2');
        expect(state1, isNot(equals(state2)));
      });
    });

    group('All states covered', () {
      test('should have exactly 5 state types', () {
        // This test ensures that all 5 state types exist
        // AuthInitial, AuthLoading, Authenticated, Unauthenticated, AuthError
        const initial = AuthInitial();
        const loading = AuthLoading();
        final authenticated = Authenticated(
          user: AuthUser(
            id: 'id',
            email: 'email@test.com',
            createdAt: DateTime(2024),
          ),
        );
        const unauthenticated = Unauthenticated();
        const error = AuthError('error');

        expect(initial, isA<AuthState>());
        expect(loading, isA<AuthState>());
        expect(authenticated, isA<AuthState>());
        expect(unauthenticated, isA<AuthState>());
        expect(error, isA<AuthState>());
      });
    });
  });
}
