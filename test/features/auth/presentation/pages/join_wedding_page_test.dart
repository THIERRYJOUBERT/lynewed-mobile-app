/// Tests for JoinWeddingPage.
///
/// Verifies the page for guests to join a wedding by code or QR:
/// - Displays proper title and instructions
/// - Has back navigation
/// - Code input with validation
/// - QR scanner button
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/invite_code_repository.dart';
import 'package:lynewed_beta/features/auth/domain/usecases/validate_invite_code.dart';
import 'package:lynewed_beta/features/auth/presentation/pages/join_wedding_page.dart';
import 'package:mocktail/mocktail.dart';

class MockInviteCodeRepository extends Mock implements InviteCodeRepository {}

void main() {
  group('JoinWeddingPage', () {
    late MockInviteCodeRepository mockRepository;
    late ValidateInviteCode validateInviteCode;

    setUp(() {
      mockRepository = MockInviteCodeRepository();
      validateInviteCode = ValidateInviteCode(mockRepository);
    });

    Widget buildTestWidget({String? initialCode}) {
      return MaterialApp(
        home: JoinWeddingPage(
          initialCode: initialCode,
          validateInviteCode: validateInviteCode,
        ),
      );
    }

    group('Route constants', () {
      test('should have correct route name', () {
        expect(JoinWeddingPage.routeName, equals('JoinWeddingPage'));
      });

      test('should have correct route path', () {
        expect(JoinWeddingPage.routePath, equals('/joinWedding'));
      });
    });

    group('Basic rendering', () {
      testWidgets('should display page title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Rejoindre un mariage'), findsOneWidget);
      });

      testWidgets('should display instructions subtitle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(
          find.text(
            'Entrez le code reçu par email ou scannez le QR code de votre invitation',
          ),
          findsOneWidget,
        );
      });

      testWidgets('should display help text at bottom', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(
          find.text(
            "Vous n'avez pas de code ? Demandez à la mariée de vous inviter.",
          ),
          findsOneWidget,
        );
      });

      testWidgets('should display continue button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Continuer'), findsOneWidget);
      });

      testWidgets('should display QR scanner button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Scanner QR Code'), findsOneWidget);
        expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      });

      testWidgets('should display OR divider', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('OU'), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('should display back button in app bar', (tester) async {
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

      testWidgets('back button should pop navigation when tapped',
          (tester) async {
        // Arrange
        var didPop = false;
        await tester.pumpWidget(MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PopScope(
                        canPop: true,
                        onPopInvokedWithResult: (didPopRoute, _) {
                          didPop = didPopRoute;
                        },
                        child: JoinWeddingPage(
                          validateInviteCode: validateInviteCode,
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Navigate'),
              ),
            ),
          ),
        ));

        // Navigate to JoinWeddingPage
        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        // Act - tap back button
        await tester.tap(find.byIcon(Icons.arrow_back_ios));
        await tester.pumpAndSettle();

        // Assert
        expect(didPop, isTrue);
      });
    });

    group('Code input', () {
      testWidgets('should show helper text when code is incomplete',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert - initial state shows helper
        expect(find.textContaining('8 caractères requis'), findsOneWidget);
      });

      testWidgets('should display text field for code entry', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(TextField), findsOneWidget);
      });

      testWidgets('should convert input to uppercase', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.enterText(find.byType(TextField), 'abcd1234');
        await tester.pump();

        // Assert - field should contain uppercase
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, 'ABCD1234');
      });

      testWidgets('continue button should be disabled when code incomplete',
          (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - enter incomplete code
        await tester.enterText(find.byType(TextField), 'ABC');
        await tester.pump();

        // Assert - button should be disabled
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Continuer'),
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('continue button should be enabled when code is complete',
          (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - enter complete code
        await tester.enterText(find.byType(TextField), 'ABCD1234');
        await tester.pump();

        // Assert - button should be enabled
        final button = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Continuer'),
        );
        expect(button.onPressed, isNotNull);
      });
    });

    group('Initial code', () {
      testWidgets('should pre-fill code when initialCode is provided',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget(initialCode: 'WXYZ5678'));
        await tester.pump();

        // Assert
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, 'WXYZ5678');
      });
    });

    group('Layout', () {
      testWidgets('should use SafeArea', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(SafeArea), findsWidgets);
      });

      testWidgets('should have Scaffold as root', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('title should be above subtitle', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final titlePos = tester.getTopLeft(find.text('Rejoindre un mariage'));
        final subtitlePos = tester.getTopLeft(find.text(
          'Entrez le code reçu par email ou scannez le QR code de votre invitation',
        ));
        expect(titlePos.dy, lessThan(subtitlePos.dy));
      });
    });
  });
}
