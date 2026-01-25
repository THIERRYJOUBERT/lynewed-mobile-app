/// Tests for TermsOfServiceSheet widget.
///
/// Verifies the Terms of Service modal:
/// - Displays terms content with checkbox
/// - Continue button is disabled until acceptance
/// - Calls AuthRepository.acceptTerms() on acceptance
/// - Returns true/false via Navigator.pop()
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:lynewed_beta/core/core.dart';
import 'package:lynewed_beta/features/auth/domain/repositories/auth_repository.dart';
import 'package:lynewed_beta/features/auth/presentation/widgets/terms_of_service_sheet.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    // Reset and register mock in GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthRepository>()) {
      getIt.unregister<AuthRepository>();
    }
    getIt.registerSingleton<AuthRepository>(mockAuthRepository);
  });

  tearDown(() {
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthRepository>()) {
      getIt.unregister<AuthRepository>();
    }
  });

  Widget buildTestWidget({Widget? child}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => child ?? const TermsOfServiceSheet(),
        ),
      ),
    );
  }

  group('TermsOfServiceSheet', () {
    group('Basic rendering', () {
      testWidgets('should display Terms of Service title', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Terms of Service'), findsOneWidget);
      });

      testWidgets('should display terms content', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.textContaining('Terms of Service'), findsWidgets);
        expect(find.textContaining('Privacy Policy'), findsWidgets);
      });

      testWidgets('should display checkbox for acceptance', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(Checkbox), findsOneWidget);
      });

      testWidgets('should display Continue button', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Continue'), findsOneWidget);
      });
    });

    group('Checkbox interaction', () {
      testWidgets('checkbox should be unchecked by default', (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isFalse);
      });

      testWidgets('should toggle checkbox when tapped', (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - tap the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Assert
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      });

      testWidgets('should toggle checkbox when tapping the label text',
          (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - tap on the checkbox list tile text
        await tester.tap(find.textContaining('I accept'));
        await tester.pump();

        // Assert
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, isTrue);
      });
    });

    group('Continue button state', () {
      testWidgets('Continue button should be disabled when checkbox unchecked',
          (tester) async {
        // Arrange & Act
        await tester.pumpWidget(buildTestWidget());

        // Assert - find the button and check if it's disabled
        // The LynewedButton wraps an ElevatedButton when primary type
        final elevatedButton = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Continue'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(elevatedButton.onPressed, isNull);
      });

      testWidgets('Continue button should be enabled when checkbox checked',
          (tester) async {
        // Arrange
        await tester.pumpWidget(buildTestWidget());

        // Act - check the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        // Assert
        final elevatedButton = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Continue'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(elevatedButton.onPressed, isNotNull);
      });
    });

    group('Accept terms interaction', () {
      testWidgets('should call acceptTerms when Continue is tapped',
          (tester) async {
        // Arrange
        when(() => mockAuthRepository.acceptTerms())
            .thenAnswer((_) async => const Success(null));

        await tester.pumpWidget(buildTestWidget());

        // Act - accept terms and tap continue
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pump();

        // Assert
        verify(() => mockAuthRepository.acceptTerms()).called(1);
      });

      testWidgets('should show loading state while accepting', (tester) async {
        // Arrange - use a completer to control the async flow
        final completer = Completer<Result<void>>();
        when(() => mockAuthRepository.acceptTerms())
            .thenAnswer((_) => completer.future);

        await tester.pumpWidget(buildTestWidget());

        // Act - accept and tap continue
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pump();

        // Assert - should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the future to allow test cleanup
        completer.complete(const Success(null));
        await tester.pumpAndSettle();
      });

      testWidgets('should pop with true on successful acceptance',
          (tester) async {
        // Arrange
        when(() => mockAuthRepository.acceptTerms())
            .thenAnswer((_) async => const Success(null));

        bool? popResult;

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  popResult = await showModalBottomSheet<bool>(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => const TermsOfServiceSheet(),
                  );
                },
                child: const Text('Show Sheet'),
              ),
            ),
          ),
        ));

        // Act - open sheet, accept, and continue
        await tester.tap(find.text('Show Sheet'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Assert
        expect(popResult, isTrue);
      });

      testWidgets('should show error snackbar on failure', (tester) async {
        // Arrange
        when(() => mockAuthRepository.acceptTerms()).thenAnswer(
            (_) async => const Failure(AuthFailure('Network error')));

        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Network error'), findsOneWidget);
      });

      testWidgets('should reset loading state on failure', (tester) async {
        // Arrange
        when(() => mockAuthRepository.acceptTerms()).thenAnswer(
            (_) async => const Failure(AuthFailure('Network error')));

        await tester.pumpWidget(buildTestWidget());

        // Act
        await tester.tap(find.byType(Checkbox));
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        // Assert - button should be enabled again
        final elevatedButton = tester.widget<ElevatedButton>(
          find.ancestor(
            of: find.text('Continue'),
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(elevatedButton.onPressed, isNotNull);
      });
    });

    group('Static show method', () {
      test('should have a static show method', () {
        // Assert - verify the static method exists
        expect(TermsOfServiceSheet.show, isA<Function>());
      });
    });
  });
}
