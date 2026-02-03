/// Regression test for guest album page upload flow.
///
/// Tests that the upload preview sheet properly manages its TextEditingController
/// lifecycle to avoid '_dependents.isEmpty' assertion failures.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lynewed_beta/features/my_wedding/presentation/widgets/caption_input_widget.dart';

void main() {
  group('Upload Preview Sheet Controller Lifecycle', () {
    testWidgets(
      'should not crash when closing upload preview sheet with caption input',
      (tester) async {
        // This test reproduces the bug where disposing a TextEditingController
        // passed to CaptionInputWidget before the widget is unmounted causes
        // '_dependents.isEmpty' assertion failure.

        final captionController = TextEditingController();
        bool sheetClosed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    final result = await showModalBottomSheet<String>(
                      context: context,
                      builder: (ctx) => _TestUploadPreviewSheet(
                        captionController: captionController,
                        onConfirm: () {
                          Navigator.pop(ctx, captionController.text);
                        },
                      ),
                    );
                    sheetClosed = true;
                    // BUG: This dispose() was called before CaptionInputWidget
                    // had a chance to remove its listener
                    // captionController.dispose(); // <-- This caused the crash

                    // The fix: either don't dispose here, or let the sheet
                    // manage its own controller
                    expect(result, isNotNull);
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        );

        // Open the sheet
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Verify caption input is shown
        expect(find.byType(CaptionInputWidget), findsOneWidget);

        // Type some text
        await tester.enterText(find.byType(TextField), 'Test caption');
        await tester.pump();

        // Tap confirm button to close
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Sheet should be closed without crash
        expect(sheetClosed, isTrue);
        expect(find.byType(CaptionInputWidget), findsNothing);

        // Cleanup
        captionController.dispose();
      },
    );

    testWidgets(
      'CaptionInputWidget should handle external controller dispose gracefully',
      (tester) async {
        // Test that CaptionInputWidget properly removes its listener on dispose
        final controller = TextEditingController(text: 'Initial');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CaptionInputWidget(
                controller: controller,
              ),
            ),
          ),
        );

        // Widget should be displayed
        expect(find.byType(CaptionInputWidget), findsOneWidget);
        expect(find.text('7/500'), findsOneWidget); // "Initial" has 7 chars

        // Simulate unmounting by pumping a different widget
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox.shrink(),
            ),
          ),
        );

        // Widget should be gone
        expect(find.byType(CaptionInputWidget), findsNothing);

        // Now disposing the controller should NOT crash
        // because CaptionInputWidget should have removed its listener
        controller.dispose();
      },
    );

    testWidgets(
      'StatefulWidget sheet should manage its own controller lifecycle',
      (tester) async {
        // This tests the correct pattern: sheet manages its own controller
        bool confirmedWithCaption = false;
        String? capturedCaption;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    final result = await showModalBottomSheet<String>(
                      context: context,
                      builder: (ctx) => _SelfManagedUploadSheet(
                        onConfirm: (caption) {
                          Navigator.pop(ctx, caption);
                        },
                      ),
                    );
                    if (result != null) {
                      confirmedWithCaption = true;
                      capturedCaption = result;
                    }
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        );

        // Open the sheet
        await tester.tap(find.text('Open Sheet'));
        await tester.pumpAndSettle();

        // Type a caption
        await tester.enterText(find.byType(TextField), 'My wedding photo');
        await tester.pump();

        // Confirm
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        // Should work without any crash
        expect(confirmedWithCaption, isTrue);
        expect(capturedCaption, 'My wedding photo');
      },
    );
  });
}

/// Test widget that uses external controller (the buggy pattern).
class _TestUploadPreviewSheet extends StatelessWidget {
  const _TestUploadPreviewSheet({
    required this.captionController,
    required this.onConfirm,
  });

  final TextEditingController captionController;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CaptionInputWidget(
            controller: captionController,
            label: 'Caption',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onConfirm,
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

/// Test widget that manages its own controller (the correct pattern).
class _SelfManagedUploadSheet extends StatefulWidget {
  const _SelfManagedUploadSheet({
    required this.onConfirm,
  });

  final ValueChanged<String> onConfirm;

  @override
  State<_SelfManagedUploadSheet> createState() => _SelfManagedUploadSheetState();
}

class _SelfManagedUploadSheetState extends State<_SelfManagedUploadSheet> {
  late final TextEditingController _captionController;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CaptionInputWidget(
            controller: _captionController,
            label: 'Caption',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => widget.onConfirm(_captionController.text),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
