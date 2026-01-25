/// Tests for SettingsPage.
///
/// Verifies the settings page:
/// - Displays correct sections (Account, Notifications, Privacy, Support, Account Actions)
/// - Shows settings tiles for each setting item
/// - Handles logout with confirmation dialog
/// - Handles delete account with confirmation dialog
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
import 'package:lynewed_beta/features/settings/presentation/pages/settings_page.dart';
import 'package:lynewed_beta/features/settings/presentation/widgets/settings_tile.dart';

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

  final testProfile = UserProfile(
    id: 'profile-1',
    authUserId: 'test-user-id',
    role: UserRole.bride,
    displayName: 'Test User',
    avatarUrl: null,
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
        child: const SettingsPage(),
      ),
    );
  }

  group('SettingsPage', () {
    group('Route configuration', () {
      test('should have correct route name', () {
        expect(SettingsPage.routeName, 'settings');
      });

      test('should have correct route path', () {
        expect(SettingsPage.routePath, '/settings');
      });
    });

    group('Page structure', () {
      testWidgets('should display page title', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Settings'), findsWidgets);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should have back button', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert - find back button
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should have scrollable content', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(SingleChildScrollView), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Settings sections', () {
      testWidgets('should display Account section', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Account'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Notifications section', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Notifications'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Privacy section', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Privacy'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Support section', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Support'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Account Actions section', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Account Actions'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Settings items', () {
      testWidgets('should display Permissions setting', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Permissions'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Push Notifications setting', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Push Notifications'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Privacy Policy setting', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Privacy Policy'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Terms of Service setting', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Terms of Service'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Help & FAQ setting', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Help & FAQ'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Contact Support setting', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Contact Support'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Log Out setting', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Log Out'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display Delete Account setting', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Delete Account'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('SettingsTile widgets', () {
      testWidgets('should use SettingsTile for settings items', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert - should have multiple SettingsTile widgets
        expect(find.byType(SettingsTile), findsWidgets);

        // Cleanup
        await cubit.close();
      });
    });

    group('Logout dialog', () {
      testWidgets('should show logout confirmation dialog when Log Out is tapped', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));
        when(() => mockRepository.signOut())
            .thenAnswer((_) async => const Success(null));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Scroll to make Log Out visible
        await tester.scrollUntilVisible(
          find.text('Log Out'),
          100.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('Log Out'));
        await tester.pumpAndSettle();

        // Assert - dialog should appear
        expect(find.text('Log Out?'), findsOneWidget);
        expect(find.text('Are you sure you want to log out?'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should close dialog when Cancel is tapped', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Scroll to make Log Out visible
        await tester.scrollUntilVisible(
          find.text('Log Out'),
          100.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Open dialog
        await tester.tap(find.text('Log Out'));
        await tester.pumpAndSettle();

        // Act - tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert - dialog should be closed
        expect(find.text('Log Out?'), findsNothing);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should call signOut when confirmed', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));
        when(() => mockRepository.signOut())
            .thenAnswer((_) async => const Success(null));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Scroll to make Log Out visible
        await tester.scrollUntilVisible(
          find.text('Log Out'),
          100.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Open dialog
        await tester.tap(find.text('Log Out'));
        await tester.pumpAndSettle();

        // Act - confirm logout
        await tester.tap(find.widgetWithText(TextButton, 'Log Out'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockRepository.signOut()).called(1);

        // Cleanup
        await cubit.close();
      });
    });

    group('Delete Account dialog', () {
      testWidgets('should show delete confirmation dialog when Delete Account is tapped', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Scroll to make Delete Account visible
        await tester.scrollUntilVisible(
          find.text('Delete Account'),
          100.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();

        // Assert - dialog should appear
        expect(find.text('Delete Account?'), findsOneWidget);
        expect(find.textContaining('permanent'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should close dialog when Cancel is tapped', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Scroll to make Delete Account visible
        await tester.scrollUntilVisible(
          find.text('Delete Account'),
          100.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Open dialog
        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();

        // Act - tap Cancel
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        // Assert - dialog should be closed
        expect(find.text('Delete Account?'), findsNothing);

        // Cleanup
        await cubit.close();
      });
    });

    group('Destructive styling', () {
      testWidgets('Log Out should use destructive style', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Scroll to make Log Out visible
        await tester.scrollUntilVisible(
          find.text('Log Out'),
          100.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Assert - find Log Out text and verify it has error color
        final logOutText = find.text('Log Out');
        expect(logOutText, findsOneWidget);

        final textWidget = tester.widget<Text>(logOutText);
        expect(textWidget.style?.color, equals(const Color(0xFFFF5963)));

        // Cleanup
        await cubit.close();
      });

      testWidgets('Delete Account should use destructive style', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(testProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildSimpleTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Scroll to make Delete Account visible
        await tester.scrollUntilVisible(
          find.text('Delete Account'),
          100.0,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Assert - find Delete Account text and verify it has error color
        final deleteText = find.text('Delete Account');
        expect(deleteText, findsOneWidget);

        final textWidget = tester.widget<Text>(deleteText);
        expect(textWidget.style?.color, equals(const Color(0xFFFF5963)));

        // Cleanup
        await cubit.close();
      });
    });
  });
}
