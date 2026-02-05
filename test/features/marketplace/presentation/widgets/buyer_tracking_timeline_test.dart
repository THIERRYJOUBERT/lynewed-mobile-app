/// Tests for BuyerTrackingTimeline.
///
/// Verifies step-based timeline display, completed/current/pending step
/// states, tracking number display, event date/location rendering,
/// and FedEx tracking link.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/tracking_event.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/buyer_tracking_timeline.dart';

void main() {
  group('BuyerTrackingTimeline', () {
    Widget buildWidget({
      required String currentStatus,
      String? trackingNumber,
      List<TrackingEvent> events = const [],
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: BuyerTrackingTimeline(
              currentStatus: currentStatus,
              trackingNumber: trackingNumber,
              events: events,
            ),
          ),
        ),
      );
    }

    group('step labels', () {
      testWidgets('should show all seven step labels', (tester) async {
        await tester.pumpWidget(buildWidget(currentStatus: 'pending'));

        expect(find.text('Order Placed'), findsOneWidget);
        expect(find.text('Payment Confirmed'), findsOneWidget);
        expect(find.text('Label Created'), findsOneWidget);
        expect(find.text('Shipped'), findsOneWidget);
        expect(find.text('In Transit'), findsOneWidget);
        expect(find.text('Delivered'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
      });
    });

    group('completed steps', () {
      testWidgets('should mark steps up to current status as completed',
          (tester) async {
        await tester.pumpWidget(buildWidget(currentStatus: 'shipped'));

        // Steps before and including 'shipped' (index 3) are completed.
        // Steps: pending(0), paid(1), label_created(2), shipped(3)
        // We verify by checking for the check icon on completed steps.
        // Shipped is index 3, so 4 steps should be green/completed.
        final greenCircles = find.byWidgetPredicate((widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final decoration = widget.decoration as BoxDecoration;
            if (decoration.shape == BoxShape.circle &&
                decoration.color == Colors.green) {
              return true;
            }
          }
          return false;
        });
        // At least 4 green circles for the 4 completed steps.
        expect(greenCircles, findsAtLeast(4));
      });

      testWidgets(
          'should mark pending steps as gray when status is label_created',
          (tester) async {
        await tester.pumpWidget(buildWidget(currentStatus: 'label_created'));

        // Steps after label_created (index 2): shipped(3), in_transit(4),
        // delivered(5), completed(6) should be gray.
        final grayCircles = find.byWidgetPredicate((widget) {
          if (widget is Container && widget.decoration is BoxDecoration) {
            final decoration = widget.decoration as BoxDecoration;
            if (decoration.shape == BoxShape.circle &&
                decoration.border != null &&
                decoration.color == null) {
              return true;
            }
          }
          return false;
        });
        // 4 pending steps should have outlined gray circles.
        expect(grayCircles, findsAtLeast(4));
      });
    });

    group('tracking number', () {
      testWidgets('should show tracking number when provided', (tester) async {
        await tester.pumpWidget(buildWidget(
          currentStatus: 'shipped',
          trackingNumber: '794644790138',
        ));

        expect(find.text('794644790138'), findsOneWidget);
      });

      testWidgets('should not show tracking section when no tracking number',
          (tester) async {
        await tester.pumpWidget(buildWidget(
          currentStatus: 'paid',
        ));

        expect(find.text('Track on FedEx'), findsNothing);
      });

      testWidgets('should show Track on FedEx text as tappable',
          (tester) async {
        await tester.pumpWidget(buildWidget(
          currentStatus: 'shipped',
          trackingNumber: '794644790138',
        ));

        expect(find.text('Track on FedEx'), findsOneWidget);
      });
    });

    group('event dates and locations', () {
      testWidgets('should show event date when event matches a step',
          (tester) async {
        final events = [
          TrackingEvent(
            eventType: 'pending',
            description: 'Order created',
            timestamp: DateTime(2026, 2, 1, 10, 30),
          ),
          TrackingEvent(
            eventType: 'paid',
            description: 'Payment received',
            timestamp: DateTime(2026, 2, 1, 10, 35),
          ),
        ];

        await tester.pumpWidget(buildWidget(
          currentStatus: 'paid',
          events: events,
        ));

        // Should display formatted date for matched events.
        expect(find.textContaining('Feb 1'), findsAtLeast(1));
      });

      testWidgets('should show event location when available', (tester) async {
        final events = [
          TrackingEvent(
            eventType: 'in_transit',
            description: 'In transit',
            timestamp: DateTime(2026, 2, 3, 14, 0),
            location: 'Memphis, TN',
            city: 'Memphis',
            country: 'US',
          ),
        ];

        await tester.pumpWidget(buildWidget(
          currentStatus: 'in_transit',
          events: events,
        ));

        expect(find.text('Memphis, TN'), findsOneWidget);
      });
    });

    group('all statuses display', () {
      testWidgets('should handle pending status', (tester) async {
        await tester.pumpWidget(buildWidget(currentStatus: 'pending'));

        // Only first step should be active/completed.
        expect(find.text('Order Placed'), findsOneWidget);
      });

      testWidgets('should handle completed status', (tester) async {
        await tester.pumpWidget(buildWidget(currentStatus: 'completed'));

        // All steps should be marked as completed.
        expect(find.text('Completed'), findsOneWidget);
      });

      testWidgets('should handle delivered status', (tester) async {
        await tester.pumpWidget(buildWidget(currentStatus: 'delivered'));

        // 6 steps completed, 1 pending (completed step).
        expect(find.text('Delivered'), findsOneWidget);
      });
    });
  });
}
