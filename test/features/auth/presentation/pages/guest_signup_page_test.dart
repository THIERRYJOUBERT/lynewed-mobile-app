/// Tests for GuestSignupPage.
///
/// Verifies the guest signup page including:
/// - Welcome message display
/// - Form integration
/// - OAuth buttons
/// - Navigation
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/guest_repository.dart';
import 'package:lynewed_beta/features/auth/domain/usecases/create_guest_account.dart';
import 'package:lynewed_beta/features/auth/presentation/pages/guest_signup_page.dart';
import 'package:mocktail/mocktail.dart';

class MockGuestRepository extends Mock implements GuestRepository {}

class MockCreateGuestAccount extends Mock implements CreateGuestAccount {}

void main() {
  group('GuestSignupPage', () {
    late MockGuestRepository mockRepository;
    late MockCreateGuestAccount mockUseCase;

    setUp(() {
      mockRepository = MockGuestRepository();
      mockUseCase = MockCreateGuestAccount();
    });

    setUpAll(() {
      registerFallbackValue(const CreateGuestAccountParams(
        firstName: 'Test',
        email: 'test@test.com',
        password: 'password',
        inviteCode: 'ABCD1234',
      ));
    });

    Widget buildTestWidget({
      String inviteCode = 'ABCD1234',
      String brideName = 'Marie',
      String? prefilledEmail,
    }) {
      return MaterialApp(
        home: GuestSignupPage(
          inviteCode: inviteCode,
          brideName: brideName,
          prefilledEmail: prefilledEmail,
          guestRepository: mockRepository,
          createGuestAccountUseCase: mockUseCase,
        ),
      );
    }

    group('Route constants', () {
      test('should have correct route name', () {
        expect(GuestSignupPage.routeName, equals('GuestSignupPage'));
      });

      test('should have correct route path', () {
        expect(GuestSignupPage.routePath, equals('/guestSignup'));
      });
    });

    group('Basic rendering', () {
      testWidgets('should display welcome message with bride name',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(brideName: 'Sophie'));

        // Assert
        expect(
            find.text('Bienvenue au mariage de Sophie !'), findsOneWidget);
      });

      testWidgets('should display instruction text', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(
          find.text(
              'Créez votre compte pour accéder aux photos, au chat et plus encore.'),
          findsOneWidget,
        );
      });

      testWidgets('should display signup form', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Prénom'), findsOneWidget);
        expect(find.text('Email'), findsOneWidget);
        expect(find.text('Mot de passe'), findsOneWidget);
      });

      testWidgets('should display OR divider', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('OU'), findsOneWidget);
      });

      testWidgets('should display Google OAuth button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Continuer avec Google'), findsOneWidget);
      });

      testWidgets('should display Apple OAuth button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Continuer avec Apple'), findsOneWidget);
        expect(find.byIcon(Icons.apple), findsOneWidget);
      });

      testWidgets('should display login link', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Déjà un compte ? '), findsOneWidget);
        expect(find.text('Se connecter'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should display back button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
      });

      testWidgets('should have transparent app bar', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, Colors.transparent);
        expect(appBar.elevation, 0);
      });
    });

    group('Pre-filled email', () {
      testWidgets('should pre-fill email when provided', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(
            buildTestWidget(prefilledEmail: 'pierre@example.com'));

        // Assert
        expect(find.text('pierre@example.com'), findsOneWidget);
      });
    });

    group('Form submission', () {
      testWidgets('should show error message on EmailAlreadyExists',
          (tester) async {
        // Arrange
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => const EmailAlreadyExists());

        await tester.pumpWidget(buildTestWidget());

        // Fill form
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Prénom'), 'Pierre');
        await tester.enterText(find.widgetWithText(TextFormField, 'Email'),
            'pierre@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Mot de passe'), 'SecurePass123!');
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Act - submit
        await tester.tap(find.text('Créer mon compte invité'));
        await tester.pump();

        // Assert
        expect(
          find.textContaining('Cet email est déjà utilisé'),
          findsOneWidget,
        );
      });

      testWidgets('should show error message on InvalidEmailFormat',
          (tester) async {
        // Arrange
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => const InvalidEmailFormat());

        await tester.pumpWidget(buildTestWidget());

        // Fill form
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Prénom'), 'Pierre');
        await tester.enterText(find.widgetWithText(TextFormField, 'Email'),
            'invalid-email');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Mot de passe'), 'SecurePass123!');
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Act - submit
        await tester.tap(find.text('Créer mon compte invité'));
        await tester.pump();

        // Assert - error message contains "email"
        expect(
          find.textContaining("email"),
          findsWidgets, // Email label + error message
        );
      });

      testWidgets('should show error message on InvalidInviteCodeError',
          (tester) async {
        // Arrange
        when(() => mockUseCase(any()))
            .thenAnswer((_) async => const InvalidInviteCodeError());

        await tester.pumpWidget(buildTestWidget());

        // Fill form
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Prénom'), 'Pierre');
        await tester.enterText(find.widgetWithText(TextFormField, 'Email'),
            'pierre@example.com');
        await tester.enterText(
            find.widgetWithText(TextFormField, 'Mot de passe'), 'SecurePass123!');
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Act - submit
        await tester.tap(find.text('Créer mon compte invité'));
        await tester.pump();

        // Assert
        expect(
          find.textContaining("Code d'invitation invalide"),
          findsOneWidget,
        );
      });
    });

    group('OAuth buttons', () {
      testWidgets('should display Google and Apple buttons', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Assert - buttons exist in widget tree even if not visible
        expect(find.text('Continuer avec Google'), findsOneWidget);
        expect(find.text('Continuer avec Apple'), findsOneWidget);
      });
    });
  });
}
