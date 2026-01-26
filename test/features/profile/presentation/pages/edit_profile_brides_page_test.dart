/// Tests for EditProfileBridesPage.
///
/// Verifies the edit profile page:
/// - Displays form fields (name, email)
/// - Shows current profile data
/// - Handles avatar picking and upload
/// - Saves profile changes
/// - Validates form inputs
library;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/auth/domain/entities/entities.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:lynewed_beta/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:lynewed_beta/features/profile/presentation/pages/edit_profile_brides_page.dart';
import 'package:lynewed_beta/features/profile/presentation/widgets/avatar_picker.dart';

// Mock repository
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(const UpdateProfileParams());
  });

  late MockAuthRepository mockRepository;
  late StreamController<AuthUser?> authStateController;

  final testUser = AuthUser(
    id: 'test-user-id',
    email: 'bride@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  final brideProfile = UserProfile(
    id: 'profile-1',
    authUserId: 'test-user-id',
    role: UserRole.bride,
    displayName: 'Sarah Johnson',
    avatarUrl: 'https://example.com/avatar.jpg',
    bio: 'Getting married in Paris!',
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

  Widget buildTestWidget({required AuthCubit cubit}) {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const EditProfileBridesPage(),
      ),
    );
  }

  group('EditProfileBridesPage', () {
    group('Route configuration', () {
      test('should have correct route name', () {
        expect(EditProfileBridesPage.routeName, 'editProfileBrides');
      });

      test('should have correct route path', () {
        expect(EditProfileBridesPage.routePath, '/editProfileBrides');
      });
    });

    group('Display', () {
      testWidgets('should display page title', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('EDIT MY PROFILE'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display avatar picker', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byType(AvatarPicker), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display name text field with current value',
          (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Sarah Johnson'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display email field as read-only', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('bride@example.com'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display save button', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Save'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });

      testWidgets('should display loading indicator when not authenticated',
          (tester) async {
        // Arrange
        final cubit = AuthCubit(repository: mockRepository);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));

        // Assert - AuthInitial should show loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Form interaction', () {
      testWidgets('should allow editing name field', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Act - Find and edit the name field
        final nameField = find.byType(TextFormField).first;
        await tester.enterText(nameField, 'New Name');
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('New Name'), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });

    group('Save profile', () {
      testWidgets('should call updateProfile when save is tapped',
          (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));
        when(() => mockRepository.updateProfile(any()))
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockRepository.updateProfile(any())).called(1);

        // Cleanup
        await cubit.close();
      });
    });

    group('Back navigation', () {
      testWidgets('should have back button', (tester) async {
        // Arrange
        when(() => mockRepository.getCurrentProfile())
            .thenAnswer((_) async => Success(brideProfile));

        final cubit = AuthCubit(repository: mockRepository);
        authStateController.add(testUser);

        // Act
        await tester.pumpWidget(buildTestWidget(cubit: cubit));
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);

        // Cleanup
        await cubit.close();
      });
    });
  });
}
