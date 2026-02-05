/// Tests for CgvuSellerDialog.
///
/// Tests the marketplace seller CGVU dialog scroll detection, checkbox state,
/// and acceptance flow. Mirrors the MagazineCgvuDialog test structure.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/constants/cgvu_texts.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/cgvu_seller_dialog.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/accept_cgvu_use_case.dart';

/// Mock use case that returns success without database calls.
class MockAcceptCgvuUseCase extends AcceptCgvuUseCase {
  bool callCalled = false;
  bool hasAcceptedCalled = false;
  String? lastCgvuType;
  String? lastCgvuVersion;

  @override
  Future<AcceptCgvuResult> call({
    required String cgvuType,
    required String cgvuVersion,
    Map<String, dynamic>? deviceInfo,
  }) async {
    callCalled = true;
    lastCgvuType = cgvuType;
    lastCgvuVersion = cgvuVersion;
    return const AcceptCgvuResult.success();
  }

  @override
  Future<bool> hasAccepted({
    required String cgvuType,
    required String cgvuVersion,
  }) async {
    hasAcceptedCalled = true;
    return false;
  }
}

/// Mock use case that returns failure.
class FailingMockAcceptCgvuUseCase extends AcceptCgvuUseCase {
  @override
  Future<AcceptCgvuResult> call({
    required String cgvuType,
    required String cgvuVersion,
    Map<String, dynamic>? deviceInfo,
  }) async {
    return const AcceptCgvuResult.failure('Database error');
  }
}

void main() {
  group('CgvuSellerDialog', () {
    late MockAcceptCgvuUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockAcceptCgvuUseCase();
    });

    Widget buildTestWidget({
      required VoidCallback onAccepted,
      AcceptCgvuUseCase? useCase,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => CgvuSellerDialog(
                  onAccepted: onAccepted,
                  acceptCgvuUseCase: useCase ?? mockUseCase,
                ),
              ),
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      );
    }

    group('initial state', () {
      testWidgets('should show title "Marketplace Seller Terms"',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Marketplace Seller Terms'), findsOneWidget);
      });

      testWidgets('should show CGVU text content', (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('LYNEWED MARKETPLACE'),
          findsOneWidget,
        );
      });

      testWidgets('should show close button', (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.close), findsOneWidget);
      });

      testWidgets('should show scroll hint initially', (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Scroll to read all terms'), findsOneWidget);
      });

      testWidgets('should show unchecked checkbox', (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, false);
      });

      testWidgets('should show disabled Accept button initially',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        final acceptButton = find.widgetWithText(ElevatedButton, 'Accept');
        expect(acceptButton, findsOneWidget);

        final button = tester.widget<ElevatedButton>(acceptButton);
        expect(button.onPressed, isNull);
      });

      testWidgets('should have marketplace seller checkbox label text',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(
          find.text('I have read and accept the Marketplace Seller Terms'),
          findsOneWidget,
        );
      });
    });

    group('scroll behavior', () {
      testWidgets('checkbox should be disabled before scrolling to bottom',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Try to tap checkbox - it should not change
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, false);
      });

      testWidgets('checkbox should become enabled after scrolling to bottom',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Scroll to bottom
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -5000),
        );
        await tester.pumpAndSettle();

        // Now checkbox should be tappable
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, true);
      });

      testWidgets('scroll hint should be visible before scrolling',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Scroll to read all terms'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      });
    });

    group('close behavior', () {
      testWidgets('should close dialog when close button is tapped',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(find.text('Marketplace Seller Terms'), findsNothing);
      });

      testWidgets('should not call onAccepted when dialog is closed',
          (tester) async {
        var acceptedCalled = false;

        await tester.pumpWidget(
          buildTestWidget(onAccepted: () => acceptedCalled = true),
        );
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        expect(acceptedCalled, false);
      });
    });

    group('accept flow', () {
      testWidgets(
          'Accept button should remain disabled when checkbox unchecked',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Scroll to bottom to enable checkbox
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -5000),
        );
        await tester.pumpAndSettle();

        // Accept button should still be disabled since checkbox is not checked
        final acceptButton = find.widgetWithText(ElevatedButton, 'Accept');
        final button = tester.widget<ElevatedButton>(acceptButton);
        expect(button.onPressed, isNull);
      });

      testWidgets(
          'Accept button should be enabled when checkbox is checked',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Scroll to bottom
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -5000),
        );
        await tester.pumpAndSettle();

        // Check the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        // Accept button should now be enabled
        final acceptButton = find.widgetWithText(ElevatedButton, 'Accept');
        final button = tester.widget<ElevatedButton>(acceptButton);
        expect(button.onPressed, isNotNull);
      });
    });

    group('use case integration', () {
      testWidgets('should pass correct cgvu type and version to use case',
          (tester) async {
        var acceptedCalled = false;

        await tester.pumpWidget(
          buildTestWidget(
            onAccepted: () => acceptedCalled = true,
            useCase: mockUseCase,
          ),
        );
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Scroll to bottom
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -5000),
        );
        await tester.pumpAndSettle();

        // Check the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        // Tap Accept
        await tester.tap(find.text('Accept'));
        await tester.pumpAndSettle();

        expect(mockUseCase.callCalled, true);
        expect(mockUseCase.lastCgvuType, marketplaceSellerCgvuType);
        expect(mockUseCase.lastCgvuVersion, marketplaceSellerCgvuVersion);
        expect(acceptedCalled, true);
      });

      testWidgets('should close dialog after acceptance', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            onAccepted: () {},
            useCase: mockUseCase,
          ),
        );
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Scroll to bottom
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -5000),
        );
        await tester.pumpAndSettle();

        // Check the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        // Tap Accept
        await tester.tap(find.text('Accept'));
        await tester.pumpAndSettle();

        // Dialog should be closed
        expect(find.text('Marketplace Seller Terms'), findsNothing);
      });

      testWidgets('should still close dialog even if use case fails',
          (tester) async {
        var acceptedCalled = false;
        final failingUseCase = FailingMockAcceptCgvuUseCase();

        await tester.pumpWidget(
          buildTestWidget(
            onAccepted: () => acceptedCalled = true,
            useCase: failingUseCase,
          ),
        );
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Scroll to bottom
        await tester.drag(
          find.byType(SingleChildScrollView).last,
          const Offset(0, -5000),
        );
        await tester.pumpAndSettle();

        // Check the checkbox
        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        // Tap Accept
        await tester.tap(find.text('Accept'));
        await tester.pumpAndSettle();

        // Should still call onAccepted and close dialog
        expect(acceptedCalled, true);
        expect(find.text('Marketplace Seller Terms'), findsNothing);
      });
    });
  });

  group('showCgvuSellerDialog', () {
    testWidgets('should return false when user closes without accepting',
        (tester) async {
      bool? result;
      final mockUseCase = MockAcceptCgvuUseCase();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showCgvuSellerDialog(
                    context: context,
                    onAccepted: () {},
                    acceptCgvuUseCase: mockUseCase,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(result, false);
    });

    testWidgets('should return true when user accepts', (tester) async {
      bool? result;
      final mockUseCase = MockAcceptCgvuUseCase();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showCgvuSellerDialog(
                    context: context,
                    onAccepted: () {},
                    acceptCgvuUseCase: mockUseCase,
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Scroll to bottom
      await tester.drag(
        find.byType(SingleChildScrollView).last,
        const Offset(0, -5000),
      );
      await tester.pumpAndSettle();

      // Check the checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      // Tap Accept
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      expect(result, true);
    });
  });

  group('marketplace seller cgvu_texts constants', () {
    test('marketplaceSellerCgvuVersion should be 1.0', () {
      expect(marketplaceSellerCgvuVersion, '1.0');
    });

    test('marketplaceSellerCgvuType should be marketplace_seller', () {
      expect(marketplaceSellerCgvuType, 'marketplace_seller');
    });

    test('marketplaceSellerCgvuText should not be empty', () {
      expect(marketplaceSellerCgvuText.isNotEmpty, true);
    });

    test('marketplaceSellerCgvuText should contain key sections', () {
      expect(
        marketplaceSellerCgvuText.contains('MARKETPLACE OVERVIEW'),
        true,
      );
      expect(
        marketplaceSellerCgvuText.contains('SELLER OBLIGATIONS'),
        true,
      );
      expect(
        marketplaceSellerCgvuText.contains('PROHIBITED ITEMS'),
        true,
      );
      expect(
        marketplaceSellerCgvuText.contains('PRICING AND FEES'),
        true,
      );
      expect(marketplaceSellerCgvuText.contains('SHIPPING'), true);
      expect(
        marketplaceSellerCgvuText.contains('RETURNS AND DISPUTES'),
        true,
      );
      expect(marketplaceSellerCgvuText.contains('PAYMENTS'), true);
      expect(
        marketplaceSellerCgvuText.contains('ACCOUNT SUSPENSION'),
        true,
      );
      expect(marketplaceSellerCgvuText.contains('LIABILITY'), true);
      expect(
        marketplaceSellerCgvuText.contains('DATA AND PRIVACY'),
        true,
      );
      expect(
        marketplaceSellerCgvuText.contains('CHANGES TO TERMS'),
        true,
      );
    });

    test('marketplaceSellerCgvuText should end with acceptance instruction',
        () {
      expect(
        marketplaceSellerCgvuText.contains(
          'By scrolling to the bottom and checking the box below',
        ),
        true,
      );
    });
  });
}
