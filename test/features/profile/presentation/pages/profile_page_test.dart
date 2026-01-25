/// Tests for ProfilePage.
///
/// Verifies the profile page:
/// - Displays profile header with user info
/// - Shows different menus for bride vs professional
/// - Handles loading and authenticated states
/// - Route configuration
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed_beta/features/profile/presentation/pages/profile_page.dart';
import 'package:lynewed_beta/features/profile/presentation/widgets/profile_header.dart';
import 'package:lynewed_beta/features/profile/presentation/widgets/profile_menu_item_widget.dart';

// Mock repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late StreamController<AuthUser?> authStateController;

  final testUser = AuthUser(
    id: 'test-user-id',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  final brideProfile = UserProfile(
    id: 'profile-1',
    authUserId: 'test-user-id',
    role: UserRole.bride,
    displayName: 'Sarah Johnson',
    avatarUrl: null,
    bio: 'Getting married in Paris!',
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final proProfile = UserProfile(
    id: 'profile-2',
    authUserId: 'test-user-id',
    role: UserRole.professional,
    displayName: 'Jean Photography',
    avatarUrl: null,
    profession: 'Photographer',
    companyName: 'Jean Photo Studio',
    bio: 'Capturing moments',
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    authStateController = StreamController<AuthUser?>.broadcast();

    when(() => mockRepository.watchAuthState())
        .thenAnswer((_) => authStateController.stream);
  });

  tearDown(() {
    authStateController.close();
  });

  // Simple widget without router for basic tests
  Widget buildSimpleTestWidget({
    required AuthCubit cubit,
  }) {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const ProfilePage(),
      ),
    );
  }

  group('ProfilePage', () {
    group('Route configuration', () {
      test('should have correct route name', () {
        expect(ProfilePage.routeName, 'profile');
      });

      test('should have correct route path', () {
        expect(ProfilePage.routePath, '/profile');
      });
    });

    group('Loading state', () {
      testWidgets('should display loading indicator when loading', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));

        // Assert - AuthInitial should show loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Authenticated state - Bride', () {
      testWidgets('should display profile header when authenticated', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);

        // Emit authenticated state
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ProfileHeader), findsOneWidget);
        expect(find.text('Sarah Johnson'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display bride menu items when authenticated as bride', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);

        // Emit authenticated state
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert - should have menu items
        expect(find.byType(ProfileMenuItemWidget), findsWidgets);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Settings menu item', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Settings'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Sign Out menu item', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Sign Out'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Authenticated state - Professional', () {
      testWidgets('should display professional menu items when authenticated as professional', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(ProfileMenuItemWidget), findsWidgets);
        expect(find.text('Jean Photography'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Edit Profile menu item for professionals', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Edit Profile'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Sign out', () {
      testWidgets('should call signOut when sign out is tapped', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));
        when(() => mockRepository.signOut())
            .thenAnswer((_) async => const Success(null));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('Sign Out'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockRepository.signOut()).called(1);

        // Cleanup
        await cubit.close();
      });
    });

    group('Layout', () {
      testWidgets('should have scrollable content', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert - should have a scrollable widget
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });
  });
}
