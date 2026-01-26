/// Tests for PublicProProfilePage.
///
/// Verifies the public professional profile page:
/// - Route configuration
/// - Displays professional profile info from AuthCubit
/// - Shows edit button for the professional
/// - Handles loading and unauthenticated states
/// - Portfolio section and hint card
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
import 'package:lynewed_beta/features/profile/presentation/pages/public_pro_profile_page.dart';

// Mock repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late StreamController<AuthUser?> authStateController;

  final testUser = AuthUser(
    id: 'test-user-id',
    email: 'pro@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  final proProfile = UserProfile(
    id: 'profile-1',
    authUserId: 'test-user-id',
    role: UserRole.professional,
    displayName: 'Jean Photography',
    avatarUrl: 'https://example.com/avatar.jpg',
    profession: 'Photographer',
    companyName: 'Jean Photo Studio',
    bio: 'Capturing beautiful moments for your special day.',
    isOnboardingComplete: true,
    createdAt: DateTime(2024, 1, 1),
  );

  final proProfileMinimal = UserProfile(
    id: 'profile-2',
    authUserId: 'test-user-id',
    role: UserRole.professional,
    displayName: null,
    avatarUrl: null,
    profession: null,
    companyName: null,
    bio: null,
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

  Widget buildTestWidget({
    required AuthCubit cubit,
  }) {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const PublicProProfilePage(),
      ),
    );
  }

  group('PublicProProfilePage', () {
    group('Route configuration', () {
      test('should have correct route name', () {
        expect(PublicProProfilePage.routeName, 'PublicProProfile');
      });

      test('should have correct route path', () {
        expect(PublicProProfilePage.routePath, '/publicProProfile');
      });
    });

    group('Widget structure', () {
      testWidgets('should have a scaffold', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should have an app bar with title', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('My Public Profile'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should have an edit button in app bar', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.edit), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Loading state', () {
      testWidgets('should display loading indicator when loading', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Unauthenticated state', () {
      testWidgets('should display message when not authenticated', (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(null);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Not authenticated'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Authenticated state - Profile display', () {
      testWidgets('should display professional display name', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Jean Photography'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display profession', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Photographer'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display company name', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Jean Photo Studio'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display bio', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Capturing beautiful moments for your special day.'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display avatar when available', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert - should have a CircleAvatar or ClipRRect with avatar
        expect(find.byType(CircleAvatar), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display fallback when display name is null', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfileMinimal));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Professional'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Hint card', () {
      testWidgets('should display hint card about how brides see profile', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.textContaining('This is how brides see your profile'),
          findsOneWidget,
        );

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display info icon in hint card', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.info_outline), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Layout', () {
      testWidgets('should have scrollable content', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Portfolio section', () {
      testWidgets('should display Portfolio section title', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(proProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Portfolio'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });
  });
}
