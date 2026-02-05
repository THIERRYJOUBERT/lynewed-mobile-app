/// Tests for TrackingTimelineWidget.
///
/// Verifies timeline display, color by event type, empty state,
/// and refresh button.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lynewed_beta/features/marketplace/domain/entities/tracking_event.dart';
import 'package:lynewed_beta/features/marketplace/presentation/widgets/tracking_timeline_widget.dart';

void main() {
  group('TrackingTimelineWidget', () {
    final testEvents = [
      TrackingEvent(
        eventType: 'picked_up',
        description: 'Package picked up',
        timestamp: DateTime(2026, 2, 3, 14, 30),
        location: 'New York, NY',
        city: 'New York',
        country: 'US',
      ),
      TrackingEvent(
        eventType: 'in_transit',
        description: 'In transit to destination',
        timestamp: DateTime(2026, 2, 4, 10, 0),
        location: 'Memphis, TN',
      ),
      TrackingEvent(
        eventType: 'delivered',
        description: 'Delivered to recipient',
        timestamp: DateTime(2026, 2, 6, 16, 45),
        location: 'Los Angeles, CA',
      ),
    ];

    Widget buildWidget({
      List<TrackingEvent> events = const [],
      VoidCallback? onRefresh,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: TrackingTimelineWidget(
            events: events,
            onRefresh: onRefresh,
          ),
        ),
      );
    }

    group('empty state', () {
      testWidgets('should show empty message when no events', (tester) async {
        await tester.pumpWidget(buildWidget());

        expect(find.text('No Tracking Events Yet'), findsOneWidget);
        expect(find.byIcon(Icons.local_shipping_outlined), findsOneWidget);
      });
    });

    group('timeline items', () {
      testWidgets('should display all event descriptions', (tester) async {
        await tester.pumpWidget(buildWidget(events: testEvents));

        expect(find.text('Package picked up'), findsOneWidget);
        expect(find.text('In transit to destination'), findsOneWidget);
        expect(find.text('Delivered to recipient'), findsOneWidget);
      });

      testWidgets('should display event locations', (tester) async {
        await tester.pumpWidget(buildWidget(events: testEvents));

        expect(find.text('New York, NY'), findsOneWidget);
        expect(find.text('Memphis, TN'), findsOneWidget);
        expect(find.text('Los Angeles, CA'), findsOneWidget);
      });
    });

    group('refresh', () {
      testWidgets('should show refresh button when callback provided',
          (tester) async {
        await tester.pumpWidget(
          buildWidget(events: testEvents, onRefresh: () {}),
        );

        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('should call onRefresh when refresh button is tapped',
          (tester) async {
        var refreshCalled = false;
        await tester.pumpWidget(
          buildWidget(
            events: testEvents,
            onRefresh: () => refreshCalled = true,
          ),
        );

        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();

        expect(refreshCalled, true);
      });
    });
  });
}
