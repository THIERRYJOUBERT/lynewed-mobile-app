/// Tests for MediaUploadCgvuDialog.
///
/// Tests the CGVU dialog scroll detection, checkbox state, acceptance flow,
/// and blocking behavior on DB errors (legal compliance).
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/core/constants/cgvu_texts.dart';
import 'package:lynewed_beta/features/my_wedding/domain/usecases/accept_cgvu_use_case.dart';
import 'package:lynewed_beta/features/guest/presentation/dialogs/media_upload_cgvu_dialog.dart';

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
  bool callCalled = false;

  @override
  Future<AcceptCgvuResult> call({
    required String cgvuType,
    required String cgvuVersion,
    Map<String, dynamic>? deviceInfo,
  }) async {
    callCalled = true;
    return const AcceptCgvuResult.failure('Database error');
  }
}

void main() {
  group('MediaUploadCgvuDialog', () {
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
                builder: (_) => MediaUploadCgvuDialog(
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
      testWidgets('should show title "Terms of Media Upload"', (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Terms of Media Upload'), findsOneWidget);
      });

      testWidgets('should show CGVU text content', (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('By uploading photos or videos'),
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

      testWidgets('should show scroll hint with arrow icon', (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
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

      testWidgets('should have checkbox label text', (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('I have read and accept the terms'), findsOneWidget);
      });
    });

    group('scroll behavior', () {
      testWidgets('checkbox should be disabled before scrolling to bottom',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(Checkbox));
        await tester.pumpAndSettle();

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.value, false);
      });

      testWidgets('scroll hint should be visible before scrolling',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Scroll to read all terms'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_downward), findsOneWidget);
      });

      testWidgets('checkbox should enable after scrolling to bottom',
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

        // Checkbox should now be enabled
        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
        expect(checkbox.onChanged, isNotNull);
      });

      testWidgets('scroll hint should disappear after scrolling to bottom',
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

        expect(find.text('Scroll to read all terms'), findsNothing);
        expect(find.byIcon(Icons.arrow_downward), findsNothing);
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

        expect(find.text('Terms of Media Upload'), findsNothing);
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

        final acceptButton = find.widgetWithText(ElevatedButton, 'Accept');
        final button = tester.widget<ElevatedButton>(acceptButton);
        expect(button.onPressed, isNull);
      });

      testWidgets('Accept button should enable when checkbox is checked',
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
        expect(mockUseCase.lastCgvuType, guestMediaUploadCgvuType);
        expect(mockUseCase.lastCgvuVersion, guestMediaUploadCgvuVersion);
        expect(acceptedCalled, true);
      });

      testWidgets('should BLOCK upload when use case fails (legal compliance)',
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

        // Should NOT call onAccepted (blocking pattern)
        expect(acceptedCalled, false);
        // Dialog should be closed
        expect(find.text('Terms of Media Upload'), findsNothing);
      });
    });

    group('dispose', () {
      testWidgets('disposes scroll controller without error', (tester) async {
        await tester.pumpWidget(buildTestWidget(onAccepted: () {}));
        await tester.tap(find.text('Show Dialog'));
        await tester.pumpAndSettle();

        // Close dialog to trigger dispose
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();

        // No crash means dispose worked correctly
        expect(find.text('Terms of Media Upload'), findsNothing);
      });
    });
  });

  group('showMediaUploadCgvuDialog', () {
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
                  result = await showMediaUploadCgvuDialog(
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
                  result = await showMediaUploadCgvuDialog(
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

    testWidgets('should return false when use case fails (blocking)',
        (tester) async {
      bool? result;
      final failingUseCase = FailingMockAcceptCgvuUseCase();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () async {
                  result = await showMediaUploadCgvuDialog(
                    context: context,
                    onAccepted: () {},
                    acceptCgvuUseCase: failingUseCase,
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

      expect(result, false);
    });
  });

  group('cgvu_texts constants', () {
    test('guestMediaUploadCgvuVersion should be 1.0', () {
      expect(guestMediaUploadCgvuVersion, '1.0');
    });

    test('guestMediaUploadCgvuType should be guest_media_upload', () {
      expect(guestMediaUploadCgvuType, 'guest_media_upload');
    });

    test('guestMediaUploadCgvuText should not be empty', () {
      expect(guestMediaUploadCgvuText.isNotEmpty, true);
    });

    test('guestMediaUploadCgvuText should contain key content', () {
      expect(
        guestMediaUploadCgvuText.contains('uploading photos or videos'),
        true,
      );
      expect(
        guestMediaUploadCgvuText.contains('private wedding gallery'),
        true,
      );
      expect(
        guestMediaUploadCgvuText.contains('solely responsible'),
        true,
      );
    });
  });
}
