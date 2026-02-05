/// Tests for ShippingLabelWidget.
///
/// Verifies tracking number display, copy button, view/download buttons,
/// and instructions text.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/shipping_label_widget.dart';

void main() {
  group('ShippingLabelWidget', () {
    Widget buildWidget({
      String trackingNumber = '123456789012',
      String labelUrl = 'https://example.com/label.pdf',
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ShippingLabelWidget(
            trackingNumber: trackingNumber,
            labelUrl: labelUrl,
          ),
        ),
      );
    }

    group('display', () {
      testWidgets('should display tracking number', (tester) async {
        await tester.pumpWidget(
          buildWidget(trackingNumber: '123456789012'),
        );

        expect(find.text('123456789012'), findsOneWidget);
      });

      testWidgets('should display shipping label ready title', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Shipping Label Ready'), findsOneWidget);
      });

      testWidgets('should display tracking number label', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Tracking Number'), findsOneWidget);
      });

      testWidgets('should display view label button', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('View Label'), findsOneWidget);
      });

      testWidgets('should display download label button', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('Download Label'), findsOneWidget);
      });

      testWidgets('should display instructions text', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(
          find.text(
            'Print this label and attach it to your package.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('should display success check icon', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
      });
    });

    group('interaction', () {
      testWidgets('should copy tracking number to clipboard on copy tap',
          (tester) async {
        // Set up clipboard mock.
        String? clipboardData;
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (MethodCall methodCall) async {
            if (methodCall.method == 'Clipboard.setData') {
              final args = methodCall.arguments as Map<dynamic, dynamic>;
              clipboardData = args['text'] as String?;
            }
            return null;
          },
        );

        await tester.pumpWidget(
          buildWidget(trackingNumber: '794644790138'),
        );

        // Tap the copy icon button.
        await tester.tap(find.byIcon(Icons.copy));
        await tester.pump();

        expect(clipboardData, equals('794644790138'));

        // Clean up.
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        );
      });
    });
  });
}
